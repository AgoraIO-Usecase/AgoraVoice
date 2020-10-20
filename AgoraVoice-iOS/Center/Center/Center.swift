//
//  Center.swift
//  Center
//
//  Created by CavanSu on 2020/2/11.
//  Copyright © 2020 Agora. All rights reserved.
//

import UIKit
import RxSwift
import RxRelay
import AlamoClient

typealias ActionMessage = EduActionMessage

class Center: RxObject {
    static let instance = Center()
    static func shared() -> Center {
        return instance
    }
    
    let isWorkNormally = PublishRelay<Bool>()
    let customMessage = PublishRelay<[String: Any]>()
    let actionMessage = PublishRelay<ActionMessage>()
    
    // Specials
    private var files = FilesGroup()
    
    private var current: CurrentUser!
    
    private lazy var appAssistant = AppAssistant()
    
    // Commons
    private lazy var alamo = AlamoClient(delegate: nil,
                                         logTube: self)
    
    private lazy var oss = AGOSSClient()
        
    private lazy var userDataHelper = UserDataHelper()
    
    private var liveManager: EduManager!
    
    private lazy var liveManagerLoginRetry = AfterWorker()
    private lazy var rtc = RTCManager.share()
    private lazy var mediaDevice = MediaDevice(rtcEngine: rtc)
    
    private let log = LogTube()
    
    override init() {
        super.init()
        _ = liveManager
        appInfo()
    }
}

extension Center {
    func registerAndLogin() {
        appAssistant.checkMinVersion()
        appAssistant.update.subscribe(onNext: { [unowned self] (update) in
            func privateRegisterAndLogin() {
                if let current = CurrentUser.local() {
                    self.current = current
                    self.login(userId: current.info.value.userId) { [unowned self] in
                        self.isWorkNormally.accept(true)
                    }
                    return
                }
                
                self.register { [unowned self] (info: BasicUserInfo) in
                    self.login(userId: info.userId) { [unowned self] in
                        self.current = CurrentUser(info: info)
                        self.isWorkNormally.accept(true)
                    }
                }
            }
            
            switch update {
            case .noNeed:
                privateRegisterAndLogin()
            case .advise:
                privateRegisterAndLogin()
            case .need:
                self.isWorkNormally.accept(false)
            }
        }).disposed(by: bag)
    }
}

private extension Center {
    func appInfo() {
        let dic: [String: Any] = ["name": AppAssistant.name,
                                  "buildNumber": AppAssistant.buildNumber,
                                  "version": AppAssistant.version,
                                  "bundleId": AppAssistant.bundleId]
        
        let formatter = AGELogFormatter(type: .info(dic.description),
                                        className: NSStringFromClass(Center.self),
                                        funcName: #function,
                                        extra: "app-build-info")
        log.logFromClass(formatter: formatter)
    }
    
    func register(success: ((BasicUserInfo) -> Void)?) {
        let url = URLGroup.userRegister
        let event = RequestEvent(name: "user-register")
        let random = (Int(arc4random()) % Array.names.count) - 1
        let name = Array.names[random]
        let parameters = ["userName": name]
        let task = RequestTask(event: event,
                               type: .http(.post, url: url),
                               timeout: .low,
                               parameters: parameters)
        
        let successCallback: DicEXCompletion = { (json: ([String: Any])) throws in
            let object = try json.getDataObject()
            let userId = try object.getStringValue(of: "userId")
            let info = BasicUserInfo(userId: userId,
                                     name: name,
                                     headURL: "local")
            
            if let success = success {
                success(info)
            }
        }
        let response = ACResponse.json(successCallback)
        
        let retry: ACErrorRetryCompletion = { (error: Error) -> RetryOptions in
            return .retry(after: 1)
        }
        
        alamo.request(task: task, success: response, failRetry: retry)
    }
    
    func login(userId: String, success: Completion) {
        let url = URLGroup.userLogin
        let event = RequestEvent(name: "user-login")
        let task = RequestTask(event: event,
                               type: .http(.post, url: url),
                               timeout: .low,
                               parameters: ["userId": userId])
        
        let successCallback: DicEXCompletion = { [unowned self] (json: ([String: Any])) throws in
            let object = try json.getDataObject()
            let userToken = try object.getStringValue(of: "userToken")
            let rtmToken = try object.getStringValue(of: "rtmToken")
            Keys.UserToken = userToken
            Keys.AgoraRtmToken = rtmToken
            
            // RTM Login
            self.liveManagerLogin(userId: userId, success: success)
        }
        let response = ACResponse.json(successCallback)
        
        let retry: ACErrorRetryCompletion = { (error: Error) -> RetryOptions in
            return .retry(after: 1)
        }
        
        alamo.request(task: task, success: response, failRetry: retry)
    }
    
    func liveManagerLogin(userId: String, success: Completion) {
        let configuration = EduConfiguration(appId: Keys.AgoraAppId,
                                             customerId: Keys.customerId,
                                             customerCertificate: Keys.customerCertificate,
                                             userUuid: userId,
                                             userName: "")
        let manager = EduManager(config: configuration, success: {
            if let success = success {
                success()
            }
        }) { [unowned self]  (error) in
            self.liveManagerLoginRetry.perform(after: 0.5, on: .main) { [unowned self] in
                self.liveManagerLogin(userId: userId, success: success)
            }
        }
        manager.delegate = self
        self.liveManager = manager
    }
}

extension Center: EduManagerDelegate {
    func userMessageReceived(_ textMessage: EduTextMessage) {
        guard let json = try? textMessage.message.json() else {
            return
        }
        customMessage.accept(json)
    }
    
    func userActionMessageReceived(_ actionMessage: EduActionMessage) {
        self.actionMessage.accept(actionMessage)
    }
}

extension Center: CenterHelper {
    func centerProvideLiveManager() -> EduManager {
        return liveManager
    }
    
    func centerProvideLocalUser() -> CurrentUser {
        return current
    }
    
    func centerProvideRequestHelper() -> AlamoClient {
        return alamo
    }
    
    func centerProvideImagesHelper() -> ImageFiles {
        return files.images
    }
    
    func centerProvideMediaDevice() -> MediaDevice {
        return mediaDevice
    }
    
    func centerProvideFilesGroup() -> FilesGroup {
        return files
    }
        
    func centerProvideLogTubeHelper() -> LogTube {
        return log
    }
    
    func centerProvideAppAssistant() -> AppAssistant {
        return appAssistant
    }
    
    func centerProvideUserDataHelper() -> UserDataHelper {
        return userDataHelper
    }
    
    func centerProvideOSSClient() -> AGOSSClient {
        return oss
    }
}

extension Center: ACLogTube {
    func log(from: AnyClass, info: String, extral: String?, funcName: String) {
        let fromatter = AGELogFormatter(type: .info(info),
                                        className: NSStringFromClass(from),
                                        funcName: funcName,
                                        extra: extral)
        log.logFromClass(formatter: fromatter)
    }
    
    func log(from: AnyClass, warning: String, extral: String?, funcName: String) {
        let fromatter = AGELogFormatter(type: .warning(warning),
                                        className: NSStringFromClass(from),
                                        funcName: funcName,
                                        extra: extral)
        log.logFromClass(formatter: fromatter)
    }
    
    func log(from: AnyClass, error: Error, extral: String?, funcName: String) {
        var description: String
        if let cError = error as? ACError {
            description = cError.localizedDescription
        } else if let aError = error as? AGEError {
            description = aError.localizedDescription
        } else {
            description = error.localizedDescription
        }
        
        let fromatter = AGELogFormatter(type: .error(description),
                                        className: NSStringFromClass(from),
                                        funcName: funcName,
                                        extra: extral)
        log.logFromClass(formatter: fromatter)
    }
}

extension Array where Element == String {
    static let names = ["Alexander",
                        "Halley",
                        "Rickey",
                        "Xavior",
                        "Yolanda",
                        "Corynn",
                        "Daniel",
                        "Kelly",
                        "Lauren"]
}
