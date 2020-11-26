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
import Armin
import AgoraRte

enum LiveRoleType: Int {
    case owner = 1, broadcaster, audience
    
    static func initWithDescription(_ description: String) throws -> LiveRoleType {
        switch description {
        case LiveRoleType.owner.description:
            return .owner
        case LiveRoleType.broadcaster.description:
            return .broadcaster
        case LiveRoleType.audience.description:
            return .audience
        default:
            throw AGEError(type: .fail("unsupport this rte role"), extra: "\(description)")
        }
    }
    
    var description: String {
        switch self {
        case .owner:       return "Owner"
        case .broadcaster: return "Broadcaster"
        case .audience:    return "Audience"
        }
    }
}

protocol LiveRole {
    var info: BasicUserInfo {get set}
    var type: LiveRoleType {get set}
    var agUId: String {get set}
    var giftRank: Int {get set}
}

struct LiveRoleItem: LiveRole {

    static func == (left: LiveRoleItem, right: LiveRoleItem) -> Bool {
        return left.info.userId == right.info.userId
    }

    var info: BasicUserInfo
    var type: LiveRoleType
    var agUId: String
    var giftRank: Int

    init(type: LiveRoleType, info: BasicUserInfo, agUId: String, giftRank: Int = 0) {
        self.type = type
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

        if let agUId = try? dic.getStringValue(of: "uid") {
            self.agUId = agUId
        } else {
            self.agUId = "0"
        }
        
        if let rank = try? dic.getIntValue(of: "rank") {
            self.giftRank = rank
        } else {
            self.giftRank = 0
        }
    }
    
    init(rteUser: AgoraRteUserInfo) throws {
        self.info = BasicUserInfo(userId: rteUser.userId,
                                  name: rteUser.userName)
        self.agUId = rteUser.streamId
        self.type = try LiveRoleType.initWithDescription(rteUser.userRole)
        self.giftRank = 0
    }
}
