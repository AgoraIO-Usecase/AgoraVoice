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
import Armin
import AgoraRte

class Center: RxObject {
    static let instance = Center()
    static func shared() -> Center {
        return instance
    }
    
    let isWorkNormally = PublishRelay<Bool>()
    let customMessage = PublishRelay<[String: Any]>()
    
    // Specials
    private var files = FilesGroup()
    
    private var current: CurrentUser!
    
    private lazy var appAssistant = AppAssistant()
    
    // Commons
    private lazy var http = Armin(delegate: nil,
                                  logTube: self)
    
    private lazy var userDataHelper = UserDataHelper()
    private lazy var rteLoginRetry = AfterWorker()
    
    private var rteKit: AgoraRteEngine!
    
    private let log = LogTube()
    
    override init() {
        super.init()
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
                    self.login(user: current.info.value) { [unowned self] in
                        self.isWorkNormally.accept(true)
                    }
                    return
                }
                
                self.register { [unowned self] (info: BasicUserInfo) in
                    self.current = CurrentUser(info: info)
                    self.login(user: info)
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
        let event = ArRequestEvent(name: "user-register")
        let random = (Int(arc4random()) % Array.names.count)
        let name = Array.names[random]
        let parameters = ["userName": name]
        let task = ArRequestTask(event: event,
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
        let response = ArResponse.json(successCallback)
        
        let retry: ArErrorRetryCompletion = { (error: Error) -> ArRetryOptions in
            return .retry(after: 1)
        }
        
        http.request(task: task, success: response, failRetry: retry)
    }
    
    func login(user: BasicUserInfo, success: Completion = nil) {
        let url = URLGroup.userLogin
        let event = ArRequestEvent(name: "user-login")
        let task = ArRequestTask(event: event,
                               type: .http(.post, url: url),
                               timeout: .low,
                               parameters: ["userId": user.userId])
        
        let successCallback: DicEXCompletion = { [unowned self] (json: ([String: Any])) throws in
            let object = try json.getDataObject()
            let userToken = try object.getStringValue(of: "userToken")
            Keys.UserToken = userToken
            
            // RTE Login
            self.rteLogin(userId: user.userId, success: success)
        }
        
        let response = ArResponse.json(successCallback)
        
        let retry: ArErrorRetryCompletion = { [unowned self] (error: ArError) -> ArRetryOptions in
            guard let code = error.code else {
                return .retry(after: 1)
            }
            
            if code == 404 || code == 403 {
                self.loginFailHandle()
                return .resign
            } else {
                return .retry(after: 1)
            }
        }
        
        http.request(task: task, success: response, failRetry: retry)
    }
    
    func loginFailHandle() {
        // userId invalid, register again
        self.register { [unowned self] (info: BasicUserInfo) in
            self.login(user: info) { [unowned self] in
                self.current = CurrentUser(info: info)
            }
        }
    }
    
    func rteLogin(userId: String, success: Completion) {
        let configuration = AgoraRteEngineConfig(appId: Keys.AgoraAppId,
                                                customerId: Keys.customerId,
                                                customerCertificate: Keys.customerCertificate,
                                                userId: userId)
        configuration.logConsolePrintType = .all
        configuration.logFilePath = FilesGroup.cacheDirectory + log.folderName
        
        AgoraRteEngine.create(with: configuration, success: { [unowned self] (engine) in
            self.rteKit = engine
            self.rteKit.delegate = self
            
            self.isWorkNormally.accept(true)
            
            if let success = success {
                success()
            }
        }) { (error) in
            self.rteLoginRetry.perform(after: 0.5, on: .main) { [unowned self] in
                self.rteLogin(userId: userId, success: success)
            }
        }
    }
}

extension Center: AgoraRteEngineDelegate {
    func rteEngine(_ engine: AgoraRteEngine, didReceivedMessage message: AgoraRteMessage, fromUserId userId: String) {
        guard let json = try? message.message.json() else {
            return
        }
        
        customMessage.accept(json)
    }
}

extension Center: CenterHelper {
    func centerProviderteEngine() -> AgoraRteEngine {
        return rteKit
    }
    
    func centerProvideLocalUser() -> CurrentUser {
        return current
    }
    
    func centerProvideRequestHelper() -> Armin {
        return http
    }
    
    func centerProvideImagesHelper() -> ImageFiles {
        return files.images
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
}

extension Center: ArLogTube {
    func log(info: String, extra: String?) {
        let fromatter = AGELogFormatter(type: .info(info),
                                        className: NSStringFromClass(Armin.self),
                                        funcName: "",
                                        extra: extra)
        log.logFromClass(formatter: fromatter)
    }
    
    func log(warning: String, extra: String?) {
        let fromatter = AGELogFormatter(type: .warning(warning),
                                        className: NSStringFromClass(Armin.self),
                                        funcName: "",
                                        extra: extra)
        log.logFromClass(formatter: fromatter)
    }
    
    func log(error: ArError, extra: String?) {
        let localizedDescription = error.localizedDescription
        let fromatter = AGELogFormatter(type: .error(localizedDescription),
                                        className: NSStringFromClass(Armin.self),
                                        funcName: "",
                                        extra: extra)
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
