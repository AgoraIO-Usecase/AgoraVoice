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
        return URLGroup.host + "ent/v1/" + "musics"
    }
    
    static var roomPage: String {
        return URLGroup.host + URLGroup.mainPath + "rooms/page"
    }
    
    static var liveCreate: String {
        return URLGroup.host + URLGroup.mainPath + "rooms"
    }
    
    static func userUpdateInfo(userId: String) -> String {
        return URLGroup.host + URLGroup.mainPath + "users/\(userId)"
    }
    
    static func liveLeave(userId: String, roomId: String) -> String {
        return URLGroup.host + URLGroup.mainPath + "rooms/\(roomId)/users/\(userId)/leave"
    }
    
    static func liveClose(roomId: String) -> String {
        return URLGroup.host + URLGroup.mainPath + "rooms/\(roomId)/close"
    }
    
    static func liveSeatStatus(roomId: String) -> String {
        return URLGroup.host + URLGroup.mainPath + "rooms/\(roomId)/seats"
    }
    
    static func presentGift(roomId: String) -> String {
        return URLGroup.host + URLGroup.mainPath + "rooms/\(roomId)/gifts"
    }
    
    static func multiHosts(userId: String, roomId: String) -> String {
        return URLGroup.host + URLGroup.mainPath + "rooms/\(roomId)/users/\(userId)/seats"
    }
    
    static func roomBackground(roomId: String) -> String {
        return URLGroup.host + URLGroup.mainPath + "rooms/\(roomId)"
    }
}
