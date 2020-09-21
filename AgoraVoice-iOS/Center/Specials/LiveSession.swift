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

class LiveSession: RxObject {
    var type: LiveType
    var roomManager: EduClassroomManager
    var room: BehaviorRelay<Room>
    var userService: EduUserService?
    
    let fail = PublishRelay<String>()
    
    //
    let end = PublishRelay<()>()
    
    // Local role
    let localRole: BehaviorRelay<LiveRole>
    // Local stream
    let localStream = BehaviorRelay<LiveStream?>(value: nil)
    
    // Statistic
    let sessionReport = BehaviorRelay(value: RTCStatistics(type: .local(RTCStatistics.Local(stats: AgoraChannelStats()))))
    
    // User
    let userList = BehaviorRelay(value: [LiveRole]())
    let userJoined = PublishRelay<[LiveRole]>()
    let userLeft = PublishRelay<[LiveRole]>()
    
    // Stream
    let streamList = BehaviorRelay(value: [LiveStream]())
    let streamJoined = PublishRelay<LiveStream>()
    let streamLeft = PublishRelay<LiveStream>()
    
    // Message
    var chatMessage = PublishRelay<(user: LiveRole, message: String)>()
    var customMessage = BehaviorRelay(value: [String: Any]())
    
    init(room: Room, role: LiveRoleType) {
        let configuration = EduClassroomConfig(roomName: room.name,
                                               roomUuid: room.roomId,
                                               scene: .typeBig)
        let manager = EduClassroomManager(roomConfig: configuration)
        self.type = .chatRoom
        self.roomManager = manager
        self.room = BehaviorRelay(value: room)
        let userInfo = Center.shared().centerProvideLocalUser().info.value
        let localRole = LiveRoleItem(type: role, info: userInfo, agUId: "0")
        self.localRole = BehaviorRelay(value: localRole)
        super.init()
        
        manager.delegate = self
        let channelDelegateConfiguration = RTCChannelDelegateConfig()
        channelDelegateConfiguration.statisticsReportDelegate = self
        RTCManager.share().setChannelDelegateWith(channelDelegateConfiguration,
                                                  channelId: room.roomId)
        
        observer()
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
            let session = LiveSession(room: room, role: .owner)
            
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
    
    func join(success: ((LiveSession) -> Void)? = nil, fail: ErrorCompletion = nil) {
        let userName = Center.shared().centerProvideLocalUser().info.value.name
        var eduRole: EduRoleType
        switch localRole.value.type {
        case .owner:
            eduRole = .teacher
        case .broadcaster, .audience:
            eduRole = .student
        }
        
        let options = EduClassroomJoinOptions(userName: userName, role: eduRole)
        roomManager.joinClassroom(options, success: { [unowned self] (userService) in
            if let service = userService as? EduTeacherService {
                service.delegate = self
            } else if let service = userService as? EduStudentService {
                service.delegate = self
            }
            
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
                    
                    if let json = eduRoom.roomProperties as? [String: Any] {
                        self.customMessage.accept(json)
                    }
                }, failure: nil)
            }, failure: nil)
            
            // all users
            self.roomManager.getFullUserList(success: { [unowned self] (list) in
                self.userList.accept([LiveRole](list: list))
            }, failure: nil)
            
            self.userService = userService
            
            let role = self.localRole.value
            self.localRole.accept(role)
            
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
        guard let _ = userService else {
            return
        }
        
        roomManager.getLocalUser(success: { [unowned self] (local) in
            let configuration = EduStreamConfig(streamUuid: local.streamUuid)
            configuration.enableMicrophone = isOn
            configuration.enableCamera = false
            self.userService?.startOrUpdateLocalStream(configuration,
                                                       success: { [unowned self] (stream) in
                                                        
                                                        if isOn {
                                                            self.userService?.publishStream(stream, success: {
                                                                
                                                            }, failure: { (error) in
                                                                
                                                            })
                                                        } else {
                                                            self.userService?.unpublishStream(stream, success: {
                                                                
                                                            }, failure: { (error) in
                                                                
                                                            })
                                                        }
                }, failure: { (error) in
                    
            })
        }) { (error) in
            
        }
    }
}

fileprivate extension LiveSession {
    func addNewStream(eduStream: EduStream) {
        let stream = LiveStream(eduStream: eduStream)
        var new = streamList.value
        new.append(stream)
        streamList.accept(new)
        
        if stream.owner.info == localRole.value.info {
            var local = localRole.value
            local.agUId = stream.streamId
            localRole.accept(local)
        }
        
        streamJoined.accept(stream)
    }
    
    func removeStream(eduStream: EduStream) {
        let index = streamList.value.firstIndex { (stream) -> Bool in
            return eduStream.streamUuid == stream.streamId
        }
        
        guard let tIndex = index else {
            return
        }
        
        var new = streamList.value
        let left = new[tIndex]
        new.remove(at: tIndex)
        streamList.accept(new)
        
        streamLeft.accept(left)
    }
    
    func updateStream(eduStream: EduStream) {
        let index = streamList.value.firstIndex { (stream) -> Bool in
            return eduStream.streamUuid == stream.streamId
        }
        
        guard let tIndex = index else {
            return
        }
        
        var new = streamList.value
        let stream = LiveStream(eduStream: eduStream)
        new[tIndex] = stream
        streamList.accept(new)
    }
    
    func observer() {
        // Determine whether local user is a broadcaster or an audience
        // If local user is owner, no need this judgment
        streamList.subscribe(onNext: { [unowned self] (list) in
            guard self.localRole.value.type != .owner else {
                return
            }
            
            var local = self.localRole.value
            var hasLocalStream = false
            
            for item in list where item.streamId == local.agUId {
                hasLocalStream = true
                break
            }
            
            let newType: LiveRoleType = (hasLocalStream ? .broadcaster : .audience)
            
            if newType != local.type {
                local.type = newType
                self.localRole.accept(local)
            }
        }).disposed(by: bag)
        
        localRole.subscribe(onNext: { [unowned self] (local) in
            switch local.type {
            case .owner, .broadcaster:
                self.updateLocalAudioStream(isOn: true)
            case .audience:
                self.updateLocalAudioStream(isOn: false)
            }
        }).disposed(by: bag)
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
        for item in streams {
            addNewStream(eduStream: item)
        }
    }
    
    func classroom(_ classroom: EduClassroom, remoteStreamsAdded events: [EduStreamEvent]) {
        for item in events {
            addNewStream(eduStream: item.modifiedStream)
        }
    }
    
    func classroom(_ classroom: EduClassroom, remoteStreamsUpdated events: [EduStreamEvent]) {
        for item in events {
            updateStream(eduStream: item.modifiedStream)
        }
    }
    
    func classroom(_ classroom: EduClassroom, remoteStreamsRemoved events: [EduStreamEvent]) {
        for item in events {
            removeStream(eduStream: item.modifiedStream)
        }
    }
    
    // Room
    func classroom(_ classroom: EduClassroom, stateUpdated reason: EduClassroomChangeReason, operatorUser user: EduBaseUser) {
        if classroom.roomState.courseState == .stop {
            leave()
            end.accept(())
        }
    }
    
    func classroomPropertyUpdated(_ classroom: EduClassroom) {
        // Mutit hosts && Live Seats
        if let json = classroom.roomProperties as? [String: Any] {
            customMessage.accept(json)
        }
    }
    
    func classroom(_ classroom: EduClassroom, remoteUserPropertiesUpdated users: [EduUser]) {
        
    }
}

extension LiveSession: EduTeacherDelegate, EduStudentDelegate {
    func localStreamAdded(_ event: EduStreamEvent) {
        var new = localRole.value
        new.agUId = event.modifiedStream.streamUuid
        localRole.accept(new)
        
        let stream = LiveStream(streamId: event.modifiedStream.streamUuid,
                                hasAudio: event.modifiedStream.hasAudio,
                                owner: new)
        localStream.accept(stream)
        addNewStream(eduStream: event.modifiedStream)
    }
    
    func localStreamRemoved(_ event: EduStreamEvent) {
        localStream.accept(nil)
        removeStream(eduStream: event.modifiedStream)
    }
    
    func localStreamUpdated(_ event: EduStreamEvent) {
        let role = localRole.value
        let stream = LiveStream(streamId: event.modifiedStream.streamUuid,
                                hasAudio: event.modifiedStream.hasAudio,
                                owner: role)
        localStream.accept(stream)
        updateStream(eduStream: event.modifiedStream)
    }
}

extension LiveSession: RTCStatisticsReportDelegate {
    func rtcReportRtcStats(_ stats: AgoraChannelStats) {
        var new = self.sessionReport.value
        new.updateChannelStats(stats)
        sessionReport.accept(new)
    }
}

extension EduUserService {
    func muteOther(stream: LiveStream, fail: Completion = nil) {
        let eduUser = EduBaseUser()
        eduUser.setValue("\(stream.owner.info.userId)", forKey: "userUuid")
        eduUser.setValue("\(stream.owner.info.name)", forKey: "userUuid")
        eduUser.setValue("\(1)", forKey: "role")
        
        let eduStream = EduStream(streamUuid: stream.streamId,
                                  streamName: "",
                                  sourceType: .none,
                                  hasVideo: false,
                                  hasAudio: false,
                                  user: eduUser)
        publishStream(eduStream, success: {
            
        }) { (_) in
            if let fail = fail {
                fail()
            }
        }
    }
    
    func ummuteOther(stream: LiveStream, fail: Completion = nil) {
        let eduUser = EduBaseUser()
        eduUser.setValue("\(stream.owner.info.userId)", forKey: "userUuid")
        eduUser.setValue("\(stream.owner.info.name)", forKey: "userUuid")
        eduUser.setValue("\(1)", forKey: "role")
        
        let eduStream = EduStream(streamUuid: stream.streamId,
                                  streamName: "",
                                  sourceType: .none,
                                  hasVideo: false,
                                  hasAudio: true,
                                  user: eduUser)
        publishStream(eduStream, success: {
            
        }) { (_) in
            if let fail = fail {
                fail()
            }
        }
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

fileprivate extension LiveStream {
    init(eduStream: EduStream) {
        var type: LiveRoleType
        switch eduStream.userInfo.role {
        case .teacher:
            type = .owner
        case .student:
            type = .broadcaster
        default:
            fatalError()
        }
        
        let info = BasicUserInfo(userId: eduStream.userInfo.userUuid,
                                 name: eduStream.userInfo.userName)
        
        let user = LiveRoleItem(type: type,
                                info: info,
                                agUId: eduStream.streamUuid)
        
        self.init(streamId: eduStream.streamUuid,
                  hasAudio: eduStream.hasAudio,
                  owner: user)
    }
}
