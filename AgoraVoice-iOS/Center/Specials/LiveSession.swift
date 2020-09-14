//
//  LiveSession.swift
//  AgoraVoice
//
//  Created by CavanSu on 2020/9/10.
//  Copyright © 2020 Agora. All rights reserved.
//

import UIKit
import AlamoClient
import RxSwift
import RxRelay

class LiveSession: NSObject {
    var type: LiveType = .chatRoom
    
    var roomManager: EduClassroomManager
    var userService: EduUserService?
    
    // User
    var userList = BehaviorRelay(value: [LiveRole]())
    var userJoined = PublishRelay<[LiveRole]>()
    var userLeft = PublishRelay<[LiveRole]>()
    
    // Message
    var chatMessage = PublishRelay<(user: LiveRole, message: String)>()
    
    init(roomName: String, roomId: String) {
        let configuration = EduClassroomConfig(roomName: roomName, roomUuid: roomId, scene: .typeBig)
        let manager = EduClassroomManager(roomConfig: configuration)
        self.roomManager = manager
        super.init()
        manager.delegate = self
    }
    
    static func create(roomName: String, success: ((LiveSession) -> Void)? = nil, fail: ErrorCompletion = nil) {
        let client = Center.shared().centerProvideRequestHelper()
        let event = RequestEvent(name: "present-gift")
        let url = URLGroup.liveCreate
        let task = RequestTask(event: event,
                               type: .http(.post, url: url),
                               timeout: .medium,
                               header: ["token": Keys.UserToken],
                               parameters: ["roomName": roomName])
        
        client.request(task: task, success: ACResponse.json({ (json) in
            let roomId = try json.getStringValue(of: "data")
            let session = LiveSession(roomName: roomName, roomId: roomId)
            
            if let success = success {
                success(session)
            }
        })) { (error) -> RetryOptions in
            if let fail = fail {
                fail(error)
            }
            return .resign
        }
    }
    
    func join(role: LiveRoleType, success: ((LiveSession) -> Void)? = nil, fail: ErrorCompletion = nil) {
        let userName = Center.shared().centerProvideLocalUser().info.value.name
        var eduRole: EduRoleType
        switch role {
        case .owner:
            eduRole = .teacher
        case .broadcaster, .audience:
            eduRole = .student
        }
        
        let options = EduClassroomJoinOptions(userName: userName, role: eduRole)
        roomManager.joinClassroom(options, success: { [unowned self] (userService) in
            self.userService = userService
            
            if let success = success {
                success(self)
            }
        }) { (error) in
            if let fail = fail, let error = error {
                fail(error)
            }
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
