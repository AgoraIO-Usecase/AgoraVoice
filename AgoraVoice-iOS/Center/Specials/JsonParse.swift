//
//  JsonParse.swift
//
//  Created by CavanSu on 2020/3/10.
//  Copyright © 2020 Agora. All rights reserved.
//

import Foundation

extension DictionaryGetable {
    func getDataObject(funcName: String = #function) throws -> [String: Any] {
        let object = try self.getDictionaryValue(of: "data", funcName: funcName)
        return object
    }
    
    func getCodeCheck(funcName: String = #function) throws {
        let code = try self.getIntValue(of: "code")
        if code != 0 {
            let message = try? self.getStringValue(of: "msg")
            throw AGEError.fail("request fail",
                                code: code,
                                extra: "message: \(OptionsDescription.any(message)), call fucname: \(funcName)")
        }
    }
}

//struct ALPeerMessage {
//    enum AType: Int {
//        case multiHosts = 1
//    }
//    
//    enum Command {
//        // MultiBroadcasting Owner
//        case inviteBroadcasting(seatIndex: Int), rejectBroadcasting, acceptBroadcastingRequest
//        
//        // MultiBroadcasting Audience
//        case applyForBroadcasting(seatIndex: Int), rejectInviteBroadcasting, acceptInvitingRequest
//        
//        var seatIndex: Int? {
//            switch self {
//            case .inviteBroadcasting(let index):   return index
//            case .applyForBroadcasting(let index): return index
//            default: return nil
//            }
//        }
//        
//        var rawValue:Int {
//            switch self {
//            case .applyForBroadcasting:      return 101
//            case .inviteBroadcasting:        return 102
//            case .rejectBroadcasting:        return 103
//            case .rejectInviteBroadcasting:  return 104
//            case .acceptBroadcastingRequest: return 105
//            case .acceptInvitingRequest:     return 106
//            }
//        }
//    }
//    
//    var type: AType = .multiHosts
//    var command: Command
//    var userName: String
//    var userId: String
//    var agoraUid: Int
//    
//    init(type: AType, command: Command, userName: String, userId: String, agoraUid: Int) {
//        self.type = type
//        self.command = command
//        self.userName = userName
//        self.userId = userId
//        self.agoraUid = agoraUid
//    }
//    
//    init(dic: [String: Any]) throws {
//        let type = try dic.getEnum(of: "cmd", type: AType.self)
//        let data = try dic.getDictionaryValue(of: "data")
//        let commandType = try data.getIntValue(of: "operate")
//        let account = try data.getStringValue(of: "account")
//        let userId = try data.getStringValue(of: "userId")
//        let agoraUid = try data.getIntValue(of: "agoraUid")
//        
//        switch commandType {
//        case 101:
//            let index = try data.getIntValue(of: "coindex")
//            self.command = Command.applyForBroadcasting(seatIndex: index)
//        default:
//            fatalError()
//        }
//        
//        self.type = type
//        self.userName = account
//        self.userId = userId
//        self.agoraUid = agoraUid
//    }
//    
//    func json() -> [String: Any] {
//        var subJson: [String: Any] = ["account": self.userName,
//                                      "operate": self.command.rawValue,
//                                      "agoraUid": self.agoraUid,
//                                      "userId": self.userId]
//        
//        var json: [String: Any] = ["cmd": self.type.rawValue]
//        
//        if let seatIndex = self.command.seatIndex {
//            subJson["coindex"] = seatIndex
//        }
//        
//        json["data"] = subJson
//        return json
//    }
//}

//struct ALChannelMessage {
//    enum AType: Int {
//        // ranks: audience's total gift value
//        case chat = 1, userJoinOrLeave = 2, ranks = 3, owner = 4, seatList = 5, pkEvent = 6, gift = 7, liveEnd = 8
//    }
//}
