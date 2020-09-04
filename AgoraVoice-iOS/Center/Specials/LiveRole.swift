//
//  LiveRole.swift
//  AgoraLive
//
//  Created by CavanSu on 2020/3/19.
//  Copyright © 2020 Agora. All rights reserved.
//

import UIKit
import RxSwift
import RxRelay
import AlamoClient

enum LiveRoleType: Int {
    case owner = 1, broadcaster, audience
}

struct LivePermission: OptionSet {
    let rawValue: Int
    
    static let camera = LivePermission(rawValue: 1)
    static let mic = LivePermission(rawValue: 1 << 1)
    static let chat = LivePermission(rawValue: 1 << 2)
    
    static func permission(dic: StringAnyDic) throws -> LivePermission {
        var permission = LivePermission(rawValue: 0)
        
        let enableMic = try dic.getBoolInfoValue(of: "enableAudio")
        let enableCamera = try dic.getBoolInfoValue(of: "enableVideo")
        let enableChat = try? dic.getBoolInfoValue(of: "enableChat")
        
        if enableMic {
            permission.insert(.mic)
        }
        
        if enableCamera {
            permission.insert(.camera)
        }
        
        if let chat = enableChat, chat {
            permission.insert(.chat)
        } else if enableChat == nil {
            permission.insert(.chat)
        }
        
        return permission
    }
}

protocol LiveRole {
    var info: BasicUserInfo {get set}
    var type: LiveRoleType {get set}
    var permission: LivePermission {get set}
    var agUId: Int {get set}
    var giftRank: Int {get set}
}

struct LiveRoleItem: LiveRole {
    
    static func == (left: LiveRoleItem, right: LiveRoleItem) -> Bool {
        return left.info.userId == right.info.userId
    }
    
    var info: BasicUserInfo
    var type: LiveRoleType
    var permission: LivePermission
    var agUId: Int
    var giftRank: Int
    
    init(type: LiveRoleType, info: BasicUserInfo, permission: LivePermission, agUId: Int, giftRank: Int = 0) {
        self.type = type
        self.permission = permission
        self.info = info
        self.agUId = agUId
        self.giftRank = giftRank
    }
    
    init(dic: StringAnyDic) throws {
        self.info = try BasicUserInfo(dic: dic)
        
        if let type = try? dic.getEnum(of: "role", type: LiveRoleType.self) {
            self.type = type
        } else {
            self.type = .owner
        }
        
        if let agUId = try? dic.getIntValue(of: "uid") {
            self.agUId = agUId
        } else {
            self.agUId = 0
        }
        
        if let permission = try? LivePermission.permission(dic: dic) {
            self.permission = permission
        } else {
            self.permission = []
        }
        
        if let rank = try? dic.getIntValue(of: "rank") {
            self.giftRank = rank
        } else {
            self.giftRank = 0
        }
    }
}

class LiveLocalUser : NSObject, LiveRole {
    var type: LiveRoleType
    var permission: LivePermission
    var info: BasicUserInfo
    var agUId: Int
    
    var giftRank: Int
    
    init(type: LiveRoleType, info: BasicUserInfo, permission: LivePermission, agUId: Int, giftRank: Int = 0) {
        self.type = type
        self.permission = permission
        self.info = info
        
        self.agUId = agUId
        self.giftRank = 0
    }
    
    init(dic: StringAnyDic) throws {
        self.type = try dic.getEnum(of: "role", type: LiveRoleType.self)
        self.info = try BasicUserInfo(dic: dic)
        self.agUId = try dic.getIntValue(of: "uid")
        
        if let permission = try? LivePermission.permission(dic: dic) {
            self.permission = permission
        } else {
            self.permission = []
        }
        
        if let rank = try? dic.getIntValue(of: "rank") {
            self.giftRank = rank
        } else {
            self.giftRank = 0
        }
    }
    
    func updateLocal(permission: LivePermission, of roomId: String, success: Completion = nil, fail: ErrorCompletion = nil) {
        self.permission = permission
        
        let url = URLGroup.userCommand(userId: self.info.userId, roomId: roomId)
        let parameters = ["enableAudio": permission.contains(.mic) ? 1 : 0,
                          "enableVideo": permission.contains(.camera) ? 1 : 0,
                          "enableChat": permission.contains(.chat) ? 1 : 0]
        
        let client = Center.shared().centerProvideRequestHelper()
        let event = RequestEvent(name: "local-update-status")
        
        let token = ["token": Keys.UserToken]
        let task = RequestTask(event: event,
                               type: .http(.post, url: url),
                               header: token,
                               parameters: parameters)
        let successCallback: DicEXCompletion = { (json) in
            try json.getCodeCheck()
            let isSuccess = try json.getBoolInfoValue(of: "data")
            if isSuccess, let callback = success {
                callback()
            } else if !isSuccess, let callback = fail {
                callback(ACError.fail("live-seat-command fail") )
            }
        }
        let response = ACResponse.json(successCallback)
        
        let fail: ACErrorRetryCompletion = { (error) in
            if let callback = fail {
                callback(error)
            }
            return .resign
        }
        
        client.request(task: task, success: response, failRetry: fail)
    }
}
