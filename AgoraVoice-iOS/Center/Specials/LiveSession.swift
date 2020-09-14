//
//  LiveSession.swift
//  AgoraVoice
//
//  Created by CavanSu on 2020/9/10.
//  Copyright © 2020 Agora. All rights reserved.
//

import UIKit
import RxSwift
import RxRelay

class LiveSession: NSObject {
    var type: LiveType = .chatRoom
    
    var roomManager: EduClassroomManager
    
    // User
    var userList = BehaviorRelay(value: [LiveRole]())
    var userJoined = PublishRelay<[LiveRole]>()
    var userLeft = PublishRelay<[LiveRole]>()
    
    // Message
    var chatMessage = PublishRelay<(user: LiveRole, message: String)>()
    
    init(roomManager: EduClassroomManager) {
        self.roomManager = roomManager
        super.init()
        self.roomManager.delegate = self
    }
    
    static func create(success: ((LiveSession) -> Void), fail: ErrorCompletion = nil) {
        let configuration = EduClassroomConfig(roomName: "", roomUuid: "", scene: .typeBig)
        let room = EduClassroomManager(roomConfig: configuration)
        let session = LiveSession(roomManager: room)
        
        success(session)
    }
    
    func join(success: ((LiveSession) -> Void)? = nil, fail: ErrorCompletion = nil) {
        let options = EduClassroomJoinOptions(userName: "", role: .student)
        roomManager.joinClassroom(options, success: { [unowned self] (userService) in
            
            
        }) { [unowned self] (_) in
            
        }
    }
    
    func leave() {
        
    }
}

extension LiveSession: EduClassroomDelegate {
    // User
    func classroom(_ classroom: EduClassroom, remoteUsersInit users: [EduUser]) {
        userList.accept([LiveRole](list: users))
    }
    
    func classroom(_ classroom: EduClassroom, remoteUsersJoined users: [EduUser]) {
        userJoined.accept([LiveRole](list: users))
    }
    
    func classroom(_ classroom: EduClassroom, remoteUserStatesUpdated events: [EduUserEvent]) {
        
    }
    
    func classroom(_ classroom: EduClassroom, remoteUsersLeft events: [EduUserEvent]) {
        var list = [LiveRole]()
        
        for event in events {
            let role = LiveRoleItem(eduUser: event.modifiedUser)
            list.append(role)
        }
        
        userLeft.accept(list)
    }
    
    // Message
    func classroom(_ classroom: EduClassroom, roomChatMessageReceived textMessage: EduTextMessage) {
        let user = LiveRoleItem(eduUser: textMessage.fromUser)
        let message = textMessage.message
        chatMessage.accept((user, message))
    }
    
    func classroom(_ classroom: EduClassroom, roomMessageReceived textMessage: EduTextMessage) {
        
    }
    
    // Stream
    func classroom(_ classroom: EduClassroom, remoteStreamsInitAdded streams: [EduStream]) {
        
    }
    
    func classroom(_ classroom: EduClassroom, remoteStreamsAdded events: [EduStreamEvent]) {
        
    }
    
    func classroom(_ classroom: EduClassroom, remoteStreamsUpdated events: [EduStreamEvent]) {
        
    }
    
    func classroom(_ classroom: EduClassroom, remoteStreamsRemoved events: [EduStreamEvent]) {
        
    }
    
    // Room
    func classroom(_ classroom: EduClassroom, stateUpdated reason: EduClassroomChangeReason, operatorUser user: EduBaseUser) {
        
    }
    
    func classroomPropertyUpdated(_ classroom: EduClassroom) {
        
    }
    
    func classroom(_ classroom: EduClassroom, remoteUserPropertiesUpdated users: [EduUser]) {
        
    }
}

fileprivate extension LiveRoleItem {
    init(eduUser: EduUser) {
        let info = BasicUserInfo(userId: eduUser.userUuid,
                                 name: eduUser.userName)
        
        self.info = info
        self.agUId = eduUser.streamUuid
        
        switch eduUser.role {
        case .teacher:
            self.type = .owner
        case .student:
            self.type = .audience
        default:
            self.type = .audience
            assert(false)
            break
        }
        
        self.giftRank = 0
    }
}

fileprivate extension Array where Element == LiveRole {
    init(list: [EduUser]) {
        var array = [LiveRole]()
        
        for item in list {
            let role = LiveRoleItem(eduUser: item)
            array.append(role)
        }
        
        self = array
    }
}
