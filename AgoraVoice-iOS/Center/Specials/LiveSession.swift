//
//  LiveSession.swift
//  AgoraVoice
//
//  Created by CavanSu on 2020/9/10.
//  Copyright © 2020 Agora. All rights reserved.
//

import UIKit
import Armin
import RxSwift
import RxRelay
import AgoraRte

class LiveSession: RxObject {
    private var sceneService: AgoraRteScene
    private var userService: AgoraRteLocalUser?
    
    // Session
    var type: LiveType
    var room: BehaviorRelay<Room>
    
    let fail = PublishRelay<String>()
    let end = PublishRelay<()>()
    
    // Local role
    let localRole: BehaviorRelay<LiveRole>
    
    // Local stream
    let localStream = BehaviorRelay<LiveStream?>(value: nil)
    let localStreamByRemoved = PublishRelay<()>()
    
    // Statistic
    let sessionReport = BehaviorRelay(value: RTCStatistics())
    
    // User
    let userList = BehaviorRelay(value: [LiveRole]())
    let audienceList = BehaviorRelay(value: [LiveRole]())
    let userJoined = PublishRelay<[LiveRole]>()
    let userLeft = PublishRelay<[LiveRole]>()
    
    // Stream
    let streamList = BehaviorRelay(value: [LiveStream]())
    let streamJoined = PublishRelay<LiveStream>()
    let streamLeft = PublishRelay<LiveStream>()
    
    // Message
    let chatMessage = PublishRelay<(user: LiveRole, message: String)>()
    let customMessage = BehaviorRelay(value: [String: Any]())
//    let actionMessage = PublishRelay<ActionMessage>()
    
    init(room: Room, role: LiveRoleType) {
        let userInfo = Center.shared().centerProvideLocalUser().info.value
        let localRole = LiveRoleItem(type: role, info: userInfo, agUId: "0")
        self.localRole = BehaviorRelay(value: localRole)
        
        self.room = BehaviorRelay(value: room)
        self.type = .chatRoom
        
        let config = AgoraRteSceneConfig(sceneId: room.roomId)
        let rteKit = Center.shared().centerProviderteEngine()
        let scene = rteKit.createAgoraRteScene(config)
        self.sceneService = scene
        
        super.init()
        
        scene.sceneDelegate = self
        scene.statsDelegate = self
        
        observer()
    }
    
    static func create(roomName: String, backgroundIndex:Int, success: ((LiveSession) -> Void)? = nil, fail: ErrorCompletion = nil) {
        let client = Center.shared().centerProvideRequestHelper()
        let event = ArRequestEvent(name: "live-create")
        let url = URLGroup.liveCreate
        let task = ArRequestTask(event: event,
                               type: .http(.post, url: url),
                               timeout: .medium,
                               header: ["token": Keys.UserToken],
                               parameters: ["roomName": roomName,
                                            "backgroundImage": "\(backgroundIndex)"])
        
        client.request(task: task, success: ArResponse.json({ (json) in
            let roomId = try json.getStringValue(of: "data")
            let local = Center.shared().centerProvideLocalUser().info.value
            let owner = LiveRoleItem(type: .owner, info: local, agUId: "0")
            let room = Room(name: roomName, roomId: roomId, personCount: 0, owner: owner)
            let session = LiveSession(room: room, role: .owner)
            
            if let success = success {
                success(session)
            }
        })) { (error) -> ArRetryOptions in
            if let fail = fail {
                fail(error)
            }
            return .resign
        }
    }
    
    func join(success: ((LiveSession) -> Void)? = nil, fail: ErrorCompletion = nil) {
        let role = localRole.value
        let options = AgoraRteSceneJoinOptions(userName: role.info.name,
                                               userRole: role.type.description)
        
        
        //        // sepcail parameters for audio loop
        //        RTCManager.share().setParameters("{\"che.audio.morph.earsback\":true}")
        
        sceneService.join(with: options) { [unowned self] (localUser) in
            localUser.localUserDelegate = self
            self.userService = localUser
            
            
            do {
                // room info
                try self.initRoomInfoDurationJoin()
                
                // all users
                let users = self.sceneService.users
                let list = try [LiveRole](list: users)
                self.userList.accept(list)
                
                // local user
                
            } catch  {
                if let fail = fail {
                    fail(error)
                }
            }
        } fail: { (error) in
            if let fail = fail {
                fail(AGEError(rteError: error))
            }
        }
    }
    
    func leave() {
        if localRole.value.type == .owner {
            let client = Center.shared().centerProvideRequestHelper()
            let event = ArRequestEvent(name: "live-session-close")
            let url = URLGroup.liveClose(roomId: room.value.roomId)
            let task = ArRequestTask(event: event,
                                   type: .http(.post, url: url),
                                   header: ["token": Keys.UserToken])
            client.request(task: task)
        } else {
            if localRole.value.type == .broadcaster {
//                self.unpublishLocalStream()
            }
            
            let client = Center.shared().centerProvideRequestHelper()
            let event = ArRequestEvent(name: "live-session-leave")
            let url = URLGroup.liveLeave(userId: localRole.value.info.userId,
                                         roomId: room.value.roomId)
            let task = ArRequestTask(event: event,
                                   type: .http(.post, url: url),
                                   header: ["token": Keys.UserToken])
            client.request(task: task)
        }
        
        self.sceneService.leave()
    }
    
    deinit {
        print("Livesession deinit")
    }
}

// MARK: - Stream
extension LiveSession {
    func updateLocalAudioStream(isOn: Bool, success: Completion = nil, fail: ErrorCompletion = nil) {
        guard let service = userService else {
            if let fail = fail {
                fail(AGEError.valueNil("userService"))
            }
            return
        }
        
        guard let stream = localStream.value else {
            if let fail = fail {
                fail(AGEError.valueNil("localStream"))
            }
            return
        }
        
        if isOn {
            service.unmuteLocalMediaStream(stream.streamId, type: .audio)
        } else {
            service.muteLocalMediaStream(stream.streamId, type: .audio)
        }
    }
    
    func muteOther(stream: LiveStream, fail: ErrorCompletion = nil) {
        let info = AgoraRteRemoteStreamInfo(streamId: stream.streamId,
                                            userId: stream.owner.info.userId,
                                            mediaStreamType: .none,
                                            videoSourceType: .none,
                                            audioSourceType: .none)
        
        userService?.createOrUpdateRemoteStream(info,
                                                success: nil,
                                                fail: { (error) in
                                                    if let fail = fail {
                                                        fail(AGEError(rteError: error))
                                                    }
                                                })
    }
    
    func unmuteOther(stream: LiveStream, fail: ErrorCompletion = nil) {
        let info = AgoraRteRemoteStreamInfo(streamId: stream.streamId,
                                            userId: stream.owner.info.userId,
                                            mediaStreamType: .audio,
                                            videoSourceType: .none,
                                            audioSourceType: .mic)
        
        userService?.createOrUpdateRemoteStream(info,
                                                success: nil,
                                                fail: { (error) in
                                                    if let fail = fail {
                                                        fail(AGEError(rteError: error))
                                                    }
                                                })
    }
    
    func publishNewStream(_ stream: LiveStream, success: Completion = nil, fail: ErrorCompletion = nil) {
        let rteKit = Center.shared().centerProviderteEngine()
        let mediaControl = rteKit.getAgoraMediaControl()
        let mic = mediaControl.createMicphoneAudioTrack()
        
        userService?.publishLocalMediaTrack(mic,
                                            success: nil,
                                            fail: { (error) in
                                                if let fail = fail {
                                                    fail(AGEError(rteError: error))
                                                }
                                            })
    }
    
    func publishNewStream(for user: LiveRole, success: Completion = nil, fail: ErrorCompletion = nil) {
        let info = AgoraRteRemoteStreamInfo(streamId: user.agUId,
                                            userId: user.info.userId,
                                            mediaStreamType: .audio,
                                            videoSourceType: .none,
                                            audioSourceType: .mic)
        
        userService?.createOrUpdateRemoteStream(info,
                                                success: nil,
                                                fail: { (error) in
                                                    if let fail = fail {
                                                        fail(AGEError(rteError: error))
                                                    }
                                                })
    }
    
    func unpublishStream(_ stream: LiveStream, success: Completion = nil, fail: ErrorCompletion = nil) {
//        let eduStream = EduStream(liveStream: stream)
//        userService?.unpublishStream(eduStream, success: success, fail: fail)
    }
}

// MARK: - Chat Message
extension LiveSession {
    func sendChat(_ text: String, success: Completion = nil, fail: ErrorCompletion = nil) {
        let message = AgoraRteMessage(message: text)
        userService?.sendSceneMessage(toAllRemoteUsers: message,
                                      success: success,
                                      fail: { (error) in
                                        if let fail = fail {
                                            fail(AGEError(rteError: error))
                                        }
                                      })
    }
}

// MARK: - Join process
fileprivate extension LiveSession {
    func initRoomInfoDurationJoin() throws {
        var owner: LiveRoleItem?
        
        for user in sceneService.users where user.userRole == LiveRoleType.owner.description {
            owner = try LiveRoleItem(rteUser: user)
        }
        
        guard let tOwner = owner else {
            throw AGEError.fail("owner nil")
        }
        
        var room = self.room.value
        room.owner = tOwner
        room.personCount = sceneService.users.count
        self.room.accept(room)
        
        if let properties = self.sceneService.properties {
            customMessage.accept(properties)
        }
    }
}

fileprivate extension LiveSession {
    func addNewStream(rteStream: AgoraRteMediaStreamInfo) {
        guard let stream = try? LiveStream(rteStream: rteStream) else {
            return
        }
        var new = streamList.value
        new.append(stream)
        streamList.accept(new)
        streamJoined.accept(stream)
    }
    
    func removeStream(rteStream: AgoraRteMediaStreamInfo) {
        let index = streamList.value.firstIndex { (stream) -> Bool in
            return rteStream.streamId == stream.streamId
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
    
    func updateStream(rteStream: AgoraRteMediaStreamInfo) {
        let index = streamList.value.firstIndex { (stream) -> Bool in
            return rteStream.streamId == stream.streamId
        }

        guard let tIndex = index else {
            return
        }
        
        guard let stream = try? LiveStream(rteStream: rteStream) else {
            return
        }
        
        var new = streamList.value
        new[tIndex] = stream
        streamList.accept(new)
    }
    
    func unpublishLocalStream(noStream: Completion = nil, success: Completion = nil, fail: ErrorCompletion = nil) {
        userService?.unpublishLocalMediaTrack(success: success,
                                              fail: { (error) in
                                                if let fail = fail {
                                                    fail(AGEError(rteError: error))
                                                }
                                              })
    }

    func endLocalStreamCapture() {
        let rteKit = Center.shared().centerProviderteEngine()
        let mediaControl = rteKit.getAgoraMediaControl()
        let mic = mediaControl.createMicphoneAudioTrack()
        mic.stop()
    }

    func observer() {
        // Determine whether local user is a broadcaster or an audience
        // If local user is owner, no need this judgment
        localStream.subscribe(onNext: { [unowned self] (stream) in
            var role = self.localRole.value

            guard role.type != .owner else {
                return
            }

            // update role
            if let stream = stream, role.type == .audience {
                role.type = .broadcaster
                self.localRole.accept(role)
                self.updateLocalAudioStream(isOn: stream.hasAudio)
            } else if stream == nil, role.type == .broadcaster {
                role.type = .audience
                self.localRole.accept(role)
                self.endLocalStreamCapture()
            }
        }).disposed(by: bag)

        // Check the audience list after the stream list is updated
        streamList.subscribe(onNext: { [unowned self] (_) in
            self.userList.accept(self.userList.value)
        }).disposed(by: bag)

        userList.subscribe(onNext: { [unowned self] (all) in
            var temp = [LiveRole]()

            for item in all {
                var isAudience = true
                for stream in self.streamList.value where stream.owner.info == item.info {
                    isAudience = false
                    break
                }

                if isAudience {
                    temp.append(item)
                }
            }

            self.audienceList.accept(temp)
        }).disposed(by: bag)

        Center.shared().customMessage.bind(to: customMessage).disposed(by: bag)
//        Center.shared().actionMessage.bind(to: actionMessage).disposed(by: bag)
    }
}

// MARK: - AgoraRteSceneDelegate
extension LiveSession: AgoraRteSceneDelegate {
    // scene
    func scene(_ scene: AgoraRteScene, didChange state: AgoraRteSceneConnectionState, withError error: AgoraRteError?) {
        
    }
    
    func scene(_ scene: AgoraRteScene, didUpdateSceneProperties changedProperties: [String], remove: Bool, cause: String?) {
        guard let roomProperties = sceneService.properties else {
            return
        }
        
        var properties = roomProperties as [String: Any]
        
        if let changedCause = try? cause?.json() {
            properties["cause"] = changedCause
        }
        
        customMessage.accept(properties)
    }
    
    func scene(_ scene: AgoraRteScene, didReceiveSceneMessage message: AgoraRteMessage, fromUser user: AgoraRteUserInfo) {
        // need parse message
    }
    
    // user
    func scene(_ scene: AgoraRteScene, didRemoteUsersJoin userEvents: [AgoraRteUserEvent]) {
        let users = userEvents.map { (event) -> AgoraRteUserInfo in
            return event.modifiedUser
        }
        
        guard let join = try? [LiveRole](list: users) else {
            return
        }
        
        userJoined.accept(join)
        
        let rteList = sceneService.users
        
        guard let list = try? [LiveRole](list: rteList) else {
            return
        }
        
        userList.accept(list)
    }
    
    func scene(_ scene: AgoraRteScene, didRemoteUsersLeave userEvents: [AgoraRteUserEvent]) {
        let users = userEvents.map { (event) -> AgoraRteUserInfo in
            return event.modifiedUser
        }
        
        guard let leave = try? [LiveRole](list: users) else {
            return
        }
        
        userJoined.accept(leave)
        
        let rteList = sceneService.users
        
        guard let list = try? [LiveRole](list: rteList) else {
            return
        }
        
        userList.accept(list)
    }
    
    func scene(_ scene: AgoraRteScene, didUpdateRemoteUserProperties changedProperties: [String], remove: Bool, cause: String?, fromUser user: AgoraRteUserInfo) {
        
    }
    
    // stream
    func scene(_ scene: AgoraRteScene, didAddRemoteStreams streamEvents: [AgoraRteMediaStreamEvent]) {
        for item in streamEvents {
            addNewStream(rteStream: item.modifiedStream)
        }
    }
    
    func scene(_ scene: AgoraRteScene, didRemoveRemoteStreams streamEvents: [AgoraRteMediaStreamEvent]) {
        for item in streamEvents {
            removeStream(rteStream: item.modifiedStream)
        }
    }
    
    func scene(_ scene: AgoraRteScene, didUpdateRemoteStreams streamEvents: [AgoraRteMediaStreamEvent]) {
        for item in streamEvents {
            updateStream(rteStream: item.modifiedStream)
        }
    }
}

// MARK: - AgoraRteLocalUserDelegate
extension LiveSession: AgoraRteLocalUserDelegate {
    func localUser(_ user: AgoraRteLocalUser, didUpdateLocalProperties changedProperties: [String], remove: Bool, cause: String?) {
        
    }
    
    func localUser(_ user: AgoraRteLocalUser, didChangeOfLocalStream event: AgoraRteMediaStreamEvent, with action: AgoraRteMediaStreamAction) {
        guard let stream = try? LiveStream(rteStream: event.modifiedStream) else {
            return
        }
        
        switch action {
        case .added:
            localStream.accept(stream)
            addNewStream(rteStream: event.modifiedStream)
        case .updated:
            localStream.accept(stream)
            updateStream(rteStream: event.modifiedStream)
        case .removed:
            localStream.accept(nil)
        @unknown default:
            assert(false)
            break
        }
    }
}

// MARK: - AgoraRteStatsDelegate
extension LiveSession: AgoraRteStatsDelegate {
    func scene(_ scene: AgoraRteScene, didUpdateLocalAudioStream streamId: String, with stats: AgoraRteLocalAudioStats) {
        var rtcStats = sessionReport.value
        rtcStats.localAudioStats = stats
        sessionReport.accept(rtcStats)
    }
}

fileprivate extension Array where Element == LiveRole {
    init(list: [AgoraRteUserInfo]) throws {
        var array = [LiveRole]()
        
        for user in list {
            let role = try LiveRoleItem(rteUser: user)
            array.append(role)
        }
        
        self = array
    }
}

fileprivate extension LiveStream {
    init(rteStream: AgoraRteMediaStreamInfo) throws {
        let user = try LiveRoleItem(rteUser: rteStream.owner)
        let hasAudio = !(rteStream.audioSourceType == .none)
        
        self.init(streamId: rteStream.streamId,
                  hasAudio: hasAudio,
                  owner: user)
    }
}
