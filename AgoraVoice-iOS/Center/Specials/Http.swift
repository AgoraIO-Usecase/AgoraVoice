//
//  Http.swift
//  AgoraVoice
//
//  Created by Cavan on 2020/12/21.
//  Copyright © 2020 Agora. All rights reserved.
//

import Armin

extension Armin {
    func request(method: ArHttpMethod,
                 url: String,
                 event: String,
                 parameters: [String: Any]? = nil,
                 responseOnMainQueue: Bool = true,
                 failRetry: ArRetryOptions = .resign,
                 success: DicEXCompletion = nil,
                 fail: ErrorCompletion = nil) {
        let eventObj = ArRequestEvent(name: event)
        let task = ArRequestTask(event: eventObj,
                                 type: .http(method, url: url),
                                 timeout: .low,
                                 header: ["token": Keys.UserToken],
                                 parameters: parameters)
        
        request(task: task,
                responseOnMainQueue: responseOnMainQueue,
                success: ArResponse.json({ (json) in
                    try json.getCodeCheck()
                    let object = try json.getDataObject()
                    if let success = success {
                        try success(object)
                    }
                })) { (error) -> ArRetryOptions in
            if let fail = fail {
                fail(error)
            }
            return failRetry
        }
    }
    
    func request(method: ArHttpMethod,
                 url: String,
                 event: String,
                 parameters: [String: Any]? = nil,
                 responseOnMainQueue: Bool = true,
                 failRetry: ArRetryOptions = .resign,
                 success: ExCompletion = nil,
                 fail: ErrorCompletion = nil) {
        let eventObj = ArRequestEvent(name: event)
        let task = ArRequestTask(event: eventObj,
                                 type: .http(method, url: url),
                                 timeout: .low,
                                 header: ["token": Keys.UserToken],
                                 parameters: parameters)
        
        request(task: task,
                responseOnMainQueue: responseOnMainQueue,
                success: ArResponse.json({ (json) in
                    try json.getCodeCheck()
                    if let success = success {
                        try success()
                    }
                })) { (error) -> ArRetryOptions in
            if let fail = fail {
                fail(error)
            }
            return failRetry
        }
    }
}
