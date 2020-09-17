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
    var type: LiveType
    
    var roomManager: EduClassroomManager
    
    var room: BehaviorRelay<Room>
    var userService: EduUserService?
    
    //
    var end = PublishRelay<()>()
    
    // User
    var userList = BehaviorRelay(value: [LiveRole]())
    var userJoined = PublishRelay<[LiveRole]>()
    var userLeft = PublishRelay<[LiveRole]>()
    
    // Stream
    
    // Message
    var chatMessage = PublishRelay<(user: LiveRole, message: String)>()
    var customMessage = PublishRelay<[String: Any]>()
    
    init(room: Room) {
        let configuration = EduClassroomConfig(roomName: room.name,
                                               roomUuid: room.roomId,
                                               scene: .typeBig)
        let manager = EduClassroomManager(roomConfig: configuration)
        self.roomManager = manager
        self.room = BehaviorRelay(value: room)
        self.type = .chatRoom
        super.init()
        manager.delegate = self
    }
    
    static func create(roomName: String, backgroundIndex:Int, success: ((LiveSession) -> Void)? = nil, fail: ErrorCompletion = nil) {
        let client = Center.shared().centerProvideRequestHelper()
        let event = RequestEvent(name: "live-create")
        let url = URLGroup.liveCreate
        let task = RequestTask(event: event,
                               type: .http(.post, url: url),
                               timeout: .medium,
                               header: ["token": Keys.UserToken],
                               parameters: ["roomName": roomName,
                                            "backgroundImage": "\(backgroundIndex)"])
        
        client.request(task: task, success: ACResponse.json({ (json) in
            let roomId = try json.getStringValue(of: "data")
            let local = Center.shared().centerProvideLocalUser().info.value
            let owner = LiveRoleItem(type: .owner, info: local, agUId: "0")
            let room = Room(name: roomName, roomId: roomId, personCount: 0, owner: owner)
            let session = LiveSession(room: room)
            
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
            self.roomManager.getUserList(with: .teacher, from: 0, to: 1, success: { [unowned self] (list) in
                guard let owner = [LiveRole](list: list).first else {
                    if let fail = fail {
                        let error = AGEError.fail("owner nil")
                        fail(error)
                    }
                    return
                }
                
                self.roomManager.getClassroomInfo(success: { [unowned self] (eduRoom) in
                    let room = Room(name: eduRoom.roomInfo.roomName,
                                    roomId: eduRoom.roomInfo.roomUuid,
                                    personCount: Int(eduRoom.roomState.onlineUserCount),
                                    owner: owner)
                    self.room.accept(room)
                }, failure: nil)
            }, failure: nil)
            
            // all users
            self.roomManager.getFullUserList(success: { [unowned self] (list) in
                self.userList.accept([LiveRole](list: list))
            }, failure: nil)
            
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
        let client = Center.shared().centerProvideRequestHelper()
        let event = RequestEvent(name: "live-session-leave")
        let url = URLGroup.leaveLive(roomId: room.value.roomId)
        let task = RequestTask(event: event,
                               type: .http(.post, url: url),
                               header: ["token": Keys.UserToken])
        client.request(task: task)
        
        roomManager.leaveClassroom(success: nil, failure: nil)
    }
}

extension LiveSession {
    func updateLocalAudioStream(isOn: Bool) {
        roomManager.getLocalUser(success: { [unowned self] (local) in
            let configuration = EduStreamConfig(streamUuid: local.streamUuid)
            configuration.enableMicrophone = isOn
            configuration.enableCamera = false
            self.userService?.startOrUpdateLocalStream(configuration,
                                                       success: { (stream) in
                                                        
            }, failure: { (error) in
                
            })
        }) { (error) in
            
        }
    }
}

extension LiveSession: EduClassroomDelegate {
    // User
    func classroom(_ classroom: EduClassroom, remoteUsersInit users: [EduUser]) {
        roomManager.getFullUserList(success: { [unowned self] (list) in
            self.userList.accept([LiveRole](list: list))
        }, failure: nil)
    }
    
    func classroom(_ classroom: EduClassroom, remoteUsersJoined users: [EduUser]) {
        roomManager.getFullUserList(success: { [unowned self] (list) in
            self.userList.accept([LiveRole](list: list))
        }, failure: nil)
        
        userJoined.accept([LiveRole](list: users))
    }
    
    func classroom(_ classroom: EduClassroom, remoteUserStatesUpdated events: [EduUserEvent]) {
        
    }
    
    func classroom(_ classroom: EduClassroom, remoteUsersLeft events: [EduUserEvent]) {
        roomManager.getFullUserList(success: { [unowned self] (list) in
            self.userList.accept([LiveRole](list: list))
        }, failure: nil)
        
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
        guard let json = try? textMessage.message.json() else {
            return
        }
        customMessage.accept(json)
    }
    
    // Stream
    func classroom(_ classroom: EduClassroom, remoteStreamsInitAdded streams: [EduStream]) {
        
    }
    
    func classroom(_ classroom: EduClassroom, remoteStreamsAdded events: [EduStreamEvent]) {
//        for item in events {
//            item.modifiedStream.userInfo
//        }
    }
    
    func classroom(_ classroom: EduClassroom, remoteStreamsUpdated events: [EduStreamEvent]) {
        
    }
    
    func classroom(_ classroom: EduClassroom, remoteStreamsRemoved events: [EduStreamEvent]) {
        
    }
    
    // Room
    func classroom(_ classroom: EduClassroom, stateUpdated reason: EduClassroomChangeReason, operatorUser user: EduBaseUser) {
        if classroom.roomState.courseState == .stop {
            leave()
            end.accept(())
        }
    }
    
    func classroomPropertyUpdated(_ classroom: EduClassroom) {
        // Mutit hosts &&
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
        
        for user in list {
            let role = LiveRoleItem(eduUser: user)
            array.append(role)
        }
        
        self = array
    }
}
