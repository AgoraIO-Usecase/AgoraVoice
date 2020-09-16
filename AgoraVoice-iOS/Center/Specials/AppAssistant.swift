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
import AlamoClient

class AppAssistant: NSObject {
    func checkMinVersion(success: Completion = nil) {
        let client = Center.shared().centerProvideRequestHelper()
        let url = URLGroup.appVersion
        let event = RequestEvent(name: "app-version")
        let parameters: StringAnyDic = ["appCode": "ent-voice",
                                        "osType": 1,
                                        "terminalType": 1,
                                        "version": AppAssistant.version]
        
        let task = RequestTask(event: event,
                               type: .http(.get, url: url),
                               timeout: .low,
                               parameters: parameters)
        
        let successCallback: ACDicEXCompletion = { (json: ([String: Any])) throws in
            let data = try json.getDataObject()
//            let config = try data.getDictionaryValue(of: "config")
//            let appId = try config.getStringValue(of: "appId")
//            Keys.AgoraAppId = appId
            
            if let success = success {
                success()
            }
        }
        let response = ACResponse.json(successCallback)
        
        let retry: ACErrorRetryCompletion = { (error: Error) -> RetryOptions in
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
}
