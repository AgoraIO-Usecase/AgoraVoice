//
//  URLGroup.swift
//
//  Created by CavanSu on 2020/3/9.
//  Copyright © 2020 Agora. All rights reserved.
//

import UIKit

struct URLGroup {
    #if PREPRODUCT
    private static let host = "http://api-solutions-pre.sh.agoralab.co/"
    #elseif PRODUCT
    private static let host = "http://api-solutions.sh.agoralab.co/"
    #else
    private static let host = "http://api-solutions-dev.sh.agoralab.co/"
    #endif
    private static let mainPath = "ent/voice/v1/"
    
    static var userRegister: String {
        return URLGroup.host + URLGroup.mainPath + "users"
    }
    
    static var appVersion: String {
        return URLGroup.host + "ent/v1/" + "app/version"
    }
    
    static var userLogin: String {
        return URLGroup.host + URLGroup.mainPath + "users/login"
    }
    
    static var musicList: String {
        return URLGroup.host + URLGroup.mainPath + "musics"
    }
    
//    static var ossSTS: String {
//        return URLGroup.host +  "edu/v1/log/sts"
//    }
//
//    static var ossUpload: String {
//        return URLGroup.host + "edu/v1/log/params"
//    }
//
//    static var ossUploadCallback: String {
//        return URLGroup.host + "edu/v1/log/sts/callback"
//    }
    
    static var roomPage: String {
        return URLGroup.host + URLGroup.mainPath + "rooms/page"
    }
    
    static var liveCreate: String {
        return URLGroup.host + URLGroup.mainPath + "rooms"
    }
    
    static func userUpdateInfo(userId: String) -> String {
        return URLGroup.host + URLGroup.mainPath + "user/\(userId)"
    }
    
//    static func joinLive(roomId: String) -> String {
//        return URLGroup.host + URLGroup.mainPath + "room/\(roomId)/entry"
//    }
    
    static func leaveLive(roomId: String) -> String {
        return URLGroup.host + URLGroup.mainPath + "rooms/\(roomId)/close"
    }
    
    static func userList(roomId: String) -> String {
        return URLGroup.host + URLGroup.mainPath + "room/\(roomId)/user/page"
    }
    
    static func liveSeatCommand(roomId: String) -> String {
        return URLGroup.host + URLGroup.mainPath + "room/\(roomId)/seat"
    }
    
    static func userCommand(userId: String, roomId: String) -> String {
        return URLGroup.host + URLGroup.mainPath + "room/\(roomId)/user/\(userId)"
    }
    
    static func receivedGift(roomId: String) -> String {
        return URLGroup.host + URLGroup.mainPath + "room/\(roomId)/gift"
    }
    
    static func pkLive(roomId: String) -> String {
        return URLGroup.host + URLGroup.mainPath + "room/\(roomId)/pk"
    }
    
    static func pkLiveBattle(roomId: String) -> String {
        return URLGroup.host + URLGroup.mainPath + "room/\(roomId)/pk/notice"
    }
    
    static func multiHosts(userId: String, roomId: String) -> String {
        return URLGroup.host + URLGroup.mainPath + "room/\(roomId)/users/\(userId)/seats"
    }
    
    static func goodsPurchase(roomId: String) -> String {
        return URLGroup.host + URLGroup.mainPath + "room/\(roomId)/commerce/purchase"
    }
    
    static func goodsList(roomId: String) -> String {
        return URLGroup.host + URLGroup.mainPath + "room/\(roomId)/commerce/products"
    }
    
    static func goodsOnShelf(roomId: String, state: Int, goodsId: String) -> String {
        return URLGroup.host + URLGroup.mainPath +  "room/\(roomId)/commerce/products/\(goodsId)/state/\(state)"
    }
}
