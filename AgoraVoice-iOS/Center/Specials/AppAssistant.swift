//
//  AppAssistant.swift
//  MetCenter
//
//  Created by CavanSu on 2019/7/7.
//  Copyright © 2019 Agora. All rights reserved.
//
#if os(iOS)
import UIKit
#endif
import Foundation
import RxSwift
import RxRelay
import Armin

enum AppUpdate: Int {
    case noNeed, advise, need
}

class AppAssistant: NSObject {
    let update = PublishRelay<AppUpdate>()
    
    func checkMinVersion() {
        let client = Center.shared().centerProvideRequestHelper()
        let url = URLGroup.appVersion
        let event = ArRequestEvent(name: "app-version")
        let parameters: StringAnyDic = ["appCode": "ent-voice",
                                        "osType": 1,
                                        "terminalType": 1,
                                        "appVersion": AppAssistant.version]
        
        let task = ArRequestTask(event: event,
                               type: .http(.get, url: url),
                               timeout: .low,
                               parameters: parameters)
        
        let successCallback: ArDicEXCompletion = { [unowned self] (json: ([String: Any])) throws in
            let data = try json.getDataObject()
            let update = try data.getEnum(of: "forcedUpgrade", type: AppUpdate.self)
            self.update.accept(update)
        }
        
        let response = ArResponse.json(successCallback)
        
        let retry: ArErrorRetryCompletion = { (error: Error) -> ArRetryOptions in
            return .retry(after: 0.5)
        }
        
        client.request(task: task, success: response, failRetry: retry)
    }
}

extension AppAssistant {
    static var name: String {
        return "AgoraVoice"
    }

    static var version: String {
        guard let dic = Bundle.main.infoDictionary,
            let tVersion = dic["CFBundleShortVersionString"],
            let version = try? Convert.force(instance: tVersion, to: String.self) else {
                return "0"
        }
        return version
    }

    static var buildNumber: String {
        guard let dic = Bundle.main.infoDictionary,
            let tNumber = dic["CFBundleVersion"],
            let number = try? Convert.force(instance: tNumber, to: String.self) else {
            return "0"
        }
        return number
    }
    
    static var bundleId: String {
        guard let id = Bundle.main.bundleIdentifier else {
            return ""
        }
        return id
    }
    
    static var idOfAppStore: Int {
        return 1537528920
    }
}
