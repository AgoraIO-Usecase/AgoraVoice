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
    private static let version = "v1/"
    private static let mainPath = "ent/voice/"
    
    static var userRegister: String {
        return URLGroup.host + URLGroup.mainPath + version + "users"
    }
    
    static var appVersion: String {
        return URLGroup.host + "ent/" + version + "app/version"
    }
    
    static var userLogin: String {
        return URLGroup.host + URLGroup.mainPath + version + "users/login"
    }
    
    static var musicList: String {
        return URLGroup.host + "ent/" + version + "musics"
    }
    
    static var roomPage: String {
        return URLGroup.host + URLGroup.mainPath + version + "rooms/page"
    }
    
    static var liveCreate: String {
        return URLGroup.host + URLGroup.mainPath + version + "rooms"
    }
    
    static func userUpdateInfo(userId: String) -> String {
        return URLGroup.host + URLGroup.mainPath + version + "users/\(userId)"
    }
    
    static func liveLeave(userId: String, roomId: String) -> String {
        return URLGroup.host + URLGroup.mainPath + version + "rooms/\(roomId)/users/\(userId)/leave"
    }
    
    static func liveClose(roomId: String) -> String {
        return URLGroup.host + URLGroup.mainPath + version + "rooms/\(roomId)/close"
    }
    
    static func liveSeatStatus(roomId: String) -> String {
        return URLGroup.host + URLGroup.mainPath + version + "rooms/\(roomId)/seats"
    }
    
    static func presentGift(roomId: String) -> String {
        return URLGroup.host + URLGroup.mainPath + version + "rooms/\(roomId)/gifts"
    }
    
    static func multiHosts(userId: String, roomId: String) -> String {
        return URLGroup.host + URLGroup.mainPath + version + "rooms/\(roomId)/users/\(userId)/seats"
    }
    
    static func roomBackground(roomId: String) -> String {
        return URLGroup.host + URLGroup.mainPath + version + "rooms/\(roomId)"
    }
}
