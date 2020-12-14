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
        
        //        // sepcail parameters for audio loop
        //        RTCManager.share().setParameters("{\"che.audio.morph.earsback\":true}")
        
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
                    let rteKit = Center.shared().centerProviderteEngine()
                    let mediaControl = rteKit.getAgoraMediaControl()
                    let mic = mediaControl.createMicphoneAudioTrack()
                    mic.start()
                    localUser.publishLocalMediaTrack(mic,
                                                     withStreamId: "0",
                                                     success: nil,
                                                     fail: nil)
                default:
                    break
                }
                
                // subscribe remote streams
                for item in self.sceneService.streams {
                    self.userService?.subscribeRemoteStream(item.streamId, type: .audio)
                }
                
                // event observe
                self.streamObserve()
                self.musicObserve()
                
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
                                            withStreamId: "0",
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
        let info = AgoraRteRemoteStreamInfo(streamId: stream.streamId,
                                            userId: stream.owner.info.userId,
                                            mediaStreamType: .none,
                                            videoSourceType: .none,
                                            audioSourceType: .none)

        userService?.deleteRemoteStream(info,
                                        success: success,
                                        fail: { (error) in
                                            if let fail = fail {
                                                fail(AGEError(rteError: error))
                                            }
                                        })
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

    func endLocalStreamCapture() {
        let rteKit = Center.shared().centerProviderteEngine()
        let mediaControl = rteKit.getAgoraMediaControl()
        let mic = mediaControl.createMicphoneAudioTrack()
        mic.stop()
    }

    func streamObserve() {
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

// MARK: - Music
fileprivate extension LiveSession {
    func musicObserve() {
        playMusic.subscribe(onNext: { (music) in
            let mediaControl = Center.shared().centerProviderteEngine().getAgoraMediaControl()
            let track = mediaControl.createMediaPlayerTrack()
            track.open(withURL: music.url)
            track.play()
        }).disposed(by: bag)

        pauseMusic.asObservable().subscribe { (music) in
            let mediaControl = Center.shared().centerProviderteEngine().getAgoraMediaControl()
            let track = mediaControl.createMediaPlayerTrack()
            track.pause()
        }.disposed(by: bag)
        
        resumeMusic.asObservable().subscribe { (music) in
            let mediaControl = Center.shared().centerProviderteEngine().getAgoraMediaControl()
            let track = mediaControl.createMediaPlayerTrack()
            track.resume()
        }.disposed(by: bag)
        
        stopMusic.asObservable().subscribe { (music) in
            let mediaControl = Center.shared().centerProviderteEngine().getAgoraMediaControl()
            let track = mediaControl.createMediaPlayerTrack()
            track.stop()
        }.disposed(by: bag)
    }
}

// MARK: - AudioEffect
fileprivate extension LiveSession {
    func audioEffectObserve() {
        chatOfBelcanto.subscribe(onNext: { [unowned self] (chat) in
            var value: Int
            
            switch chat {
            case .maleMagnetic:
                value = 1
            case .femaleFresh:
                value = 2
            case .femaleVitality:
                value = 3
            case .disable:
                self.audioEffectDisable()
                return
            }
            
            let parameters = "{\"che.audio.morph.beauty_voice\":\(value)}"
            self.sceneService.setParameters(parameters)
        }).disposed(by: bag)
        
        singOfBelcanto.subscribe(onNext: { [unowned self] (sing) in
            var value: Int
            
            switch sing {
            case .male:
                value = 1
            case .female:
                value = 2
            case .disable:
                self.audioEffectDisable()
                return
            }
            
            let parameters = "{\"che.audio.morph.beauty_sing\":\(value)}"
            self.sceneService.setParameters(parameters)
        }).disposed(by: bag)
        
        timbre.subscribe(onNext: { [unowned self] (timbre) in
            var value: Int
            
            switch timbre {
            case .vigorous:
                value = 7
            case .deep:
                value = 8
            case .mellow:
                value = 9
            case .falsetto:
                value = 10
            case .full:
                value = 11
            case .clear:
                value = 12
            case .resounding:
                value = 13
            case .ringing:
                value = 14
            case .disable:
                self.audioEffectDisable()
                return
            }
            
            let parameters = "{\"che.audio.morph.voice_changer\":\(value)}"
            self.sceneService.setParameters(parameters)
        }).disposed(by: bag)
        
        audioSpace.subscribe(onNext: { [unowned self] (space) in
            var value: Int
            var parameters: String
            
            switch space {
            case .ktv:
                value = 1
                parameters = "{\"che.audio.morph.voice_changer\":\(value)}"
                self.sceneService.setParameters(parameters)
            case .vocalConcer:
                value = 2
                parameters = "{\"che.audio.morph.voice_changer\":\(value)}"
                self.sceneService.setParameters(parameters)
            case .studio:
                value = 5
                parameters = "{\"che.audio.morph.voice_changer\":\(value)}"
                self.sceneService.setParameters(parameters)
            case .phonograph:
                value = 8
                parameters = "{\"che.audio.morph.voice_changer\":\(value)}"
                self.sceneService.setParameters(parameters)
            case .spacial:
                value = 15
                parameters = "{\"che.audio.morph.voice_changer\":\(value)}"
                self.sceneService.setParameters(parameters)
            case .ethereal:
                value = 5
                parameters = "{\"che.audio.morph.voice_changer\":\(value)}"
                self.sceneService.setParameters(parameters)
            default:
                break
            }
            
            switch space {
            case .virtualStereo:
                parameters = "{\"che.audio.morph.virtual_stereo\":1}"
                self.sceneService.setParameters(parameters)
            case .threeDimensionalVoice:
                parameters = "{\"che.audio.morph.threedim_voice\":\(0)}"
                self.sceneService.setParameters(parameters)
            case .disable:
                self.audioEffectDisable()
            default:
                break
            }
        }).disposed(by: bag)
        
        timbreRole.subscribe(onNext: { [unowned self] (role) in
            var value: Int
            var parameters: String
            
            switch role {
            case .uncle:
                value = 3
                parameters = "{\"che.audio.morph.reverb_preset\":\(value)}"
                self.sceneService.setParameters(parameters)
            case .oldMan:
                value = 1
                parameters = "{\"che.audio.morph.voice_changer\":\(value)}"
                self.sceneService.setParameters(parameters)
            case .babyBoy:
                value = 2
                parameters = "{\"che.audio.morph.voice_changer\":\(value)}"
                self.sceneService.setParameters(parameters)
            case .sister:
                value = 4
                parameters = "{\"che.audio.morph.reverb_preset\":\(value)}"
                self.sceneService.setParameters(parameters)
            case .babyGirl:
                value = 3
                parameters = "{\"che.audio.morph.voice_changer\":\(value)}"
                self.sceneService.setParameters(parameters)
            case .zhuBaJie:
                value = 4
                parameters = "{\"che.audio.morph.voice_changer\":\(value)}"
                self.sceneService.setParameters(parameters)
            case .hulk:
                value = 6
                parameters = "{\"che.audio.morph.voice_changer\":\(value)}"
                self.sceneService.setParameters(parameters)
            case .disable:
                self.audioEffectDisable()
            }
        }).disposed(by: bag)
        
        musicGenre.subscribe(onNext: { [unowned self] (music) in
            var value: Int
            var parameters: String
            
            switch music {
            case .rnb:
                value = 7
                parameters = "{\"che.audio.morph.reverb_preset\":\(value)}"
            case .popular:
                value = 6
                parameters = "{\"che.audio.morph.reverb_preset\":\(value)}"
            case .rock:
                value = 11
                parameters = "{\"che.audio.morph.reverb_preset\":\(value)}"
            case .hiphop:
                value = 12
                parameters = "{\"che.audio.morph.reverb_preset\":\(value)}"
            case .disable:
                self.audioEffectDisable()
                return
            }
            
            self.sceneService.setParameters(parameters)
        }).disposed(by: bag)
        
        electronicMusic.subscribe(onNext: { [unowned self] (music) in
            let parameters = "{\"che.audio.morph.electronic_voice\":{\"key\":\(music.type),\"value\":\(music.value)}}"
            self.sceneService.setParameters(parameters)
        }).disposed(by: bag)
        
        threeDimensionalVoice.subscribe(onNext: { [unowned self] (value) in
            let parameters = "{\"che.audio.morph.threedim_voice\":\(value)}"
            self.sceneService.setParameters(parameters)
        }).disposed(by: bag)
    }
    
    func audioEffectDisable() {
        let parameters = "{\"che.audio.morph.reverb_preset\":0}"
        sceneService.setParameters(parameters)
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
            self.userService?.subscribeRemoteStream(item.modifiedStream.streamId,
                                                    type: .audio)
            addNewStream(rteStream: item.modifiedStream)
        }
    }
    
    func scene(_ scene: AgoraRteScene, didRemoveRemoteStreams streamEvents: [AgoraRteMediaStreamEvent]) {
        for item in streamEvents {
            self.userService?.unsubscribeRemoteStream(item.modifiedStream.streamId,
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
        let hasAudio = (rteStream.streamType.rawValue & AgoraRteMediaStreamType.audio.rawValue)
        
        self.init(streamId: rteStream.streamId,
                  hasAudio: hasAudio == 1 ? true : false,
                  owner: user)
    }
}
