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
    
    // Statistic
    let sessionReport = BehaviorRelay(value: RTEStatistics())
    
    // User
    let userList = BehaviorRelay(value: [LiveRole]())
    let audienceList = BehaviorRelay(value: [LiveRole]())
    let userJoined = PublishRelay<[LiveRole]>()
    let userLeft = PublishRelay<[LiveRole]>()
    
    // Stream
    let streamList = BehaviorRelay(value: [LiveStream]())
    let streamJoined = PublishRelay<LiveStream>()
    let streamLeft = PublishRelay<LiveStream>()
    
    // Music
    let playMusic = PublishRelay<Music>()
    let pauseMusic = PublishRelay<Music>()
    let resumeMusic = PublishRelay<Music>()
    let stopMusic = PublishRelay<Music>()
    let musicState = BehaviorRelay(value: AgoraRteMediaPlayerState.stopped)
    let musicError = PublishRelay<AGEError>()
    
    // AudioEffect
    let chatOfBelcanto = PublishRelay<ChatOfBelCanto>()
    let singOfBelcanto = PublishRelay<SingOfBelCanto>()
    let timbre = PublishRelay<Timbre>()
    
    let audioSpace = PublishRelay<AudioSpace>()
    let timbreRole = PublishRelay<TimbreRole>()
    let musicGenre = PublishRelay<MusicGenre>()
    
    let electronicMusic = PublishRelay<ElectronicMusic>()
    let threeDimensionalVoice = PublishRelay<Int>()
    
    // Audio output routing
    let audioOuputRouting = BehaviorRelay(value: AgoraRteAudioOutputRouting.default)
    
    // Message
    let chatMessage = PublishRelay<(user: LiveRole, message: String)>()
    let customMessage = BehaviorRelay(value: [String: Any]())
    
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
        
        let mediaControl = rteKit.getAgoraMediaControl()
        mediaControl.delegate = self
    }
    
    static func create(roomName: String,
                       backgroundIndex:Int,
                       success: ((LiveSession) -> Void)? = nil,
                       fail: ErrorCompletion = nil) {
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
        
        // audio encoder configuration
        let rteKit = Center.shared().centerProviderteEngine()
        let mediaControl = rteKit.getAgoraMediaControl()
        let mic = mediaControl.createMicphoneAudioTrack()
        let config = AgoraRteAudioEncoderConfig(profile: .musicHighQualityStereo,
                                                scenario: .gameStreaming)
        mic.setAudioEncoderConfig(config)
        
        // sepcail parameters for audio loop
        sceneService.setParameters("{\"che.audio.morph.earsback\":true}")
        
        sceneService.join(with: options, success: { [unowned self] (localUser) in
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
                let localUserInfo = try LiveRoleItem(rteUser: localUser.info)
                self.localRole.accept(localUserInfo)
                
                // media stream
                switch self.localRole.value.type {
                case .owner: fallthrough
                case .broadcaster:
                    localUser.publishLocalMediaTrack(mic,
                                                     withStreamId: "0",
                                                     success: nil,
                                                     fail: nil)
                default:
                    break
                }
                
                // subscribe remote streams
                for item in self.sceneService.streams {
                    localUser.subscribeRemoteStream(item.streamId, type: .audio)
                }
                
                // event observe
                self.streamObserve()
                self.musicObserve()
                self.audioEffectObserve()
                self.messageObserver()
                
                if let success = success {
                    success(self)
                }
            } catch  {
                if let fail = fail {
                    fail(error)
                }
            }
        }) { (error) in
            if let fail = fail {
                fail(AGEError(rteError: error))
            }
        }
    }
    
    func leave() {
        if localRole.value.type != .audience {
            unpublishLocalStream()
        }
        
        if localRole.value.type == .owner {
            let client = Center.shared().centerProvideRequestHelper()
            let event = ArRequestEvent(name: "live-session-close")
            let url = URLGroup.liveClose(roomId: room.value.roomId)
            let task = ArRequestTask(event: event,
                                   type: .http(.post, url: url),
                                   header: ["token": Keys.UserToken])
            client.request(task: task)
        } else {
            let client = Center.shared().centerProvideRequestHelper()
            let event = ArRequestEvent(name: "live-session-leave")
            let url = URLGroup.liveLeave(userId: localRole.value.info.userId,
                                         roomId: room.value.roomId)
            let task = ArRequestTask(event: event,
                                   type: .http(.post, url: url),
                                   header: ["token": Keys.UserToken])
            client.request(task: task)
        }
        
        sceneService.leave()
    }
    
    deinit {
        print("Livesession deinit")
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

// MARK: - Stream
// MARK: - Local Stream
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
        
        let failCallback = { (error: AgoraRteError) in
            if let fail = fail {
                fail(AGEError(rteError: error))
            }
        }
        
        if isOn {
            service.unmuteLocalMediaStream(stream.streamId,
                                           type: .audio,
                                           success: success,
                                           fail: failCallback)
        } else {
            service.muteLocalMediaStream(stream.streamId,
                                         type: .audio,
                                         success: success,
                                         fail: failCallback)
        }
    }
    
    func unpublishLocalStream(success: Completion = nil, fail: ErrorCompletion = nil) {
        let rteKit = Center.shared().centerProviderteEngine()
        let mediaControl = rteKit.getAgoraMediaControl()
        let mic = mediaControl.createMicphoneAudioTrack()
        
        userService?.unpublishLocalMediaTrack(mic,
                                              withStreamId: "0",
                                              success: success,
                                              fail: { (error) in
                                                if let fail = fail {
                                                    fail(AGEError(rteError: error))
                                                }
                                              })
    }
}

// MARK: - Remote Stream
extension LiveSession {
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
}

// MARK: - Stream list
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
    
    func streamObserve() {
        // Check the audience list after the stream list is updated
        streamList.subscribe(onNext: { [unowned self] (_) in
            self.userList.accept(self.userList.value)
        }).disposed(by: bag)

        userList.subscribe(onNext: { [unowned self] (all) in
            var temp = [LiveRole]()

            for item in all where item.type == .audience {
                temp.append(item)
            }

            self.audienceList.accept(temp)
        }).disposed(by: bag)
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

// MARK: - Custome Message
fileprivate extension LiveSession {
    func messageObserver() {
        Center.shared().customMessage.bind(to: customMessage).disposed(by: bag)
    }
}

// MARK: - Music
fileprivate extension LiveSession {
    func musicObserve() {
        playMusic.subscribe(onNext: { (music) in
            let mediaControl = Center.shared().centerProviderteEngine().getAgoraMediaControl()
            let player = mediaControl.createMediaPlayerTrack()
            player.open(withURL: music.url)
            player.play()
        }).disposed(by: bag)

        pauseMusic.subscribe { (music) in
            let mediaControl = Center.shared().centerProviderteEngine().getAgoraMediaControl()
            let player = mediaControl.createMediaPlayerTrack()
            player.pause()
        }.disposed(by: bag)
        
        resumeMusic.subscribe { (music) in
            let mediaControl = Center.shared().centerProviderteEngine().getAgoraMediaControl()
            let player = mediaControl.createMediaPlayerTrack()
            player.resume()
        }.disposed(by: bag)
        
        stopMusic.subscribe { (music) in
            let mediaControl = Center.shared().centerProviderteEngine().getAgoraMediaControl()
            let player = mediaControl.createMediaPlayerTrack()
            player.stop()
        }.disposed(by: bag)
    }
}

// MARK: - AudioEffect
fileprivate extension LiveSession {
    func audioEffectObserve() {
        chatOfBelcanto.subscribe(onNext: { [unowned self] (chat) in
            self.sceneService.setParameters(chat.parameters)
        }).disposed(by: bag)
        
        singOfBelcanto.subscribe(onNext: { [unowned self] (sing) in
            self.sceneService.setParameters(sing.parameters)
        }).disposed(by: bag)
        
        timbre.subscribe(onNext: { [unowned self] (timbre) in
            self.sceneService.setParameters(timbre.parameters)
        }).disposed(by: bag)
        
        audioSpace.subscribe(onNext: { [unowned self] (space) in
            self.sceneService.setParameters(space.parameters)
        }).disposed(by: bag)
        
        timbreRole.subscribe(onNext: { [unowned self] (role) in
            self.sceneService.setParameters(role.parameters)
        }).disposed(by: bag)
        
        musicGenre.subscribe(onNext: { [unowned self] (music) in
            self.sceneService.setParameters(music.parameters)
        }).disposed(by: bag)
        
        electronicMusic.subscribe(onNext: { [unowned self] (music) in
            self.sceneService.setParameters(music.parameters)
        }).disposed(by: bag)
        
        threeDimensionalVoice.subscribe(onNext: { [unowned self] (value) in
            let parameters = "{\"che.audio.morph.threedim_voice\":\(value)}"
            self.sceneService.setParameters(parameters)
        }).disposed(by: bag)
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
        
        if let basic = try? properties.getDictionaryValue(of: "basic"),
           let roomState = try? basic.getIntValue(of: "state"),
           roomState == 0 {
            end.accept(())
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
        
        userLeft.accept(leave)
        
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
            userService?.subscribeRemoteStream(item.modifiedStream.streamId,
                                               type: .audio)
            addNewStream(rteStream: item.modifiedStream)
        }
    }
    
    func scene(_ scene: AgoraRteScene, didRemoveRemoteStreams streamEvents: [AgoraRteMediaStreamEvent]) {
        for item in streamEvents {
            userService?.unsubscribeRemoteStream(item.modifiedStream.streamId,
                                                 type: .audio)
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
    func localUser(_ user: AgoraRteLocalUser, didUpdateLocalUserInfo info: AgoraRteUserInfo, cause: String?) {
        var local = localRole.value
        
        if let newRole = try? LiveRoleType.initWithDescription(info.userRole) {
            local.type = newRole
            localRole.accept(local)
        }
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
    
    func localUser(_ user: AgoraRteLocalUser, didUpdateLocalUserInfo userEvent: AgoraRteUserEvent) {
        var old = localRole.value
        let newRoleString = userEvent.modifiedUser.userRole
        guard let newRole = try? LiveRoleType.initWithDescription(newRoleString) else {
            return
        }
        
        old.type = newRole
        localRole.accept(old)
    }
}

// MARK: - AgoraRteStatsDelegate
extension LiveSession: AgoraRteStatsDelegate {
    func scene(_ scene: AgoraRteScene, didUpdateLocalAudioStream streamId: String, with stats: AgoraRteLocalAudioStats) {
        var sessionStats = sessionReport.value
        sessionStats.localAudioStats = stats
        sessionReport.accept(sessionStats)
    }
    
    func scene(_ scene: AgoraRteScene, report stats: AgoraRteSceneStats) {
        var sessionStats = sessionReport.value
        sessionStats.sceneStats = stats
        sessionReport.accept(sessionStats)
    }
}

// MARK: - AgoraRteMediaControlDelegate
extension LiveSession: AgoraRteMediaControlDelegate {
    func mediaControl(_ control: AgoraRteMediaControl, didChnageAudioRouting routing: AgoraRteAudioOutputRouting) {
        audioOuputRouting.accept(routing)
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
        let hasAudio = (rteStream.streamType.rawValue & AgoraRteMediaStreamType.audio.rawValue)
        
        self.init(streamId: rteStream.streamId,
                  hasAudio: hasAudio == 1 ? true : false,
                  owner: user)
    }
}
