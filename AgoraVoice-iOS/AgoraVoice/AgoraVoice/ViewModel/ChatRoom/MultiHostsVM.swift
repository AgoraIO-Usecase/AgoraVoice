//
//  MultiHostsVM.swift
//  AgoraLive
//
//  Created by CavanSu on 2020/7/22.
//  Copyright © 2020 Agora. All rights reserved.
//

import UIKit
import RxSwift
import RxRelay
import AlamoClient

class MultiHostsVM: CustomObserver {
    struct Invitation: TimestampModel {
        var id: Int
        var seatIndex: Int
        var initiator: LiveRole
        var receiver: LiveRole
        var timestamp: TimeInterval
        
        init(id: Int, seatIndex: Int, initiator: LiveRole, receiver: LiveRole) {
            self.id = id
            self.seatIndex = seatIndex
            self.initiator = initiator
            self.receiver = receiver
            self.timestamp = NSDate().timeIntervalSince1970
        }
    }
    
    struct Application: TimestampModel {
        var id: Int
        var seatIndex: Int
        var initiator: LiveRole
        var receiver: LiveRole
        var timestamp: TimeInterval
        
        init(id: Int, seatIndex: Int, initiator: LiveRole, receiver: LiveRole) {
            self.id = id
            self.seatIndex = seatIndex
            self.initiator = initiator
            self.receiver = receiver
            self.timestamp = NSDate().timeIntervalSince1970
        }
    }
    
    private var room: Room
    
    let invitationQueue = TimestampQueue(name: "multi-hosts-invitation")
    let applicationQueue = TimestampQueue(name: "multi-hosts-application")
    
    let invitingUserList = BehaviorRelay(value: [LiveRole]())
    let applyingUserList = BehaviorRelay(value: [LiveRole]())
    
    // Owner
    var invitationByRejected = PublishRelay<Invitation>()
    var invitationByAccepted = PublishRelay<Invitation>()
    var receivedApplication = PublishRelay<Application>()
    
    let invitationTimeout = PublishRelay<[Invitation]>()
    
    // Broadcaster
    var receivedEndBroadcasting = PublishRelay<()>()
    
    // Audience
    var receivedInvitation = PublishRelay<Invitation>()
    var applicationByRejected = PublishRelay<Application>()
    var applicationByAccepted = PublishRelay<Application>()
    
    // notification of role change
    var audienceBecameBroadcaster = PublishRelay<LiveRole>()
    var broadcasterBecameAudience = PublishRelay<LiveRole>()
    
    // fail
    let fail = PublishRelay<String>()
    
    init(room: Room) {
        self.room = room
        super.init()
        observe()
    }
    
    deinit {
        #if !RELEASE
        print("deinit MultiHostsVM")
        #endif
    }
}

// MARK: Owner
extension MultiHostsVM {
    func sendInvitation(to user: LiveRole, on seatIndex: Int, fail: ErrorCompletion = nil) {
        request(seatIndex: seatIndex,
                type: 1,
                userId: "\(user.info.userId)",
                roomId: room.roomId,
                success: { [weak self] (json) in
                    guard let strongSelf = self else {
                        return
                    }

                    let id = try json.getIntValue(of: "data")
                    let invitation = Invitation(id: id,
                                                seatIndex: seatIndex,
                                                initiator: strongSelf.room.owner,
                                                receiver: user)
                    strongSelf.invitationQueue.append(invitation)
                }, fail: fail)
    }
    
    func accept(application: Application, fail: ErrorCompletion = nil) {
        request(seatIndex: application.seatIndex,
                type: 5,
                userId: "\(application.initiator.info.userId)",
                roomId: room.roomId,
                success: { [weak self] (json) in
                    self?.applicationQueue.remove(application)
                }, fail: fail)
                
    }
    
    func reject(application: Application, fail: ErrorCompletion = nil) {
        request(seatIndex: application.seatIndex,
                type: 3,
                userId: "\(application.initiator.info.userId)",
                roomId: room.roomId,
                success: { [weak self] (json) in
                    self?.applicationQueue.remove(application)
                }, fail: fail)
    }
    
    func forceEndWith(user: LiveRole, on seatIndex: Int, success: Completion = nil, fail: ErrorCompletion = nil) {
        request(seatIndex: seatIndex,
                type: 7,
                userId: "\(user.info.userId)",
                roomId: room.roomId,
                success: { (_) in
                    if let success = success {
                        success()
                    }
                }, fail: fail)
    }
}

// MARK: Broadcaster
extension MultiHostsVM {
    func endBroadcasting(seatIndex: Int, user: LiveRole, success: Completion = nil, fail: ErrorCompletion = nil) {
        request(seatIndex: seatIndex,
                type: 8,
                userId: "\(user.info.userId)",
                roomId: room.roomId,
                success: { (_) in
                    if let success = success {
                        success()
                    }
                }, fail: fail)
    }
}

// MARK: Audience
extension MultiHostsVM {
    func sendApplication(by local: LiveRole, for seatIndex: Int, fail: ErrorCompletion = nil) {
        request(seatIndex: seatIndex,
                type: 2,
                userId: "\(room.owner.info.userId)",
                roomId: room.roomId,
                fail: fail)
    }
    
    func accept(invitation: Invitation, success: Completion = nil, fail: ErrorCompletion = nil) {
        let tInvi = invitationQueue.list.first { (item) -> Bool in
            return item.id == invitation.id
        }
        
        guard let _ = tInvi else {
            if let fail = fail {
                fail(AGEError.fail("invitation timeout"))
            }
            return
        }
        
        request(seatIndex: invitation.seatIndex,
                type: 6,
                userId: "\(invitation.initiator.info.userId)",
                roomId: room.roomId,
                success: { (_) in
                    if let success = success {
                        success()
                    }
                }, fail: fail)
    }
    
    func reject(invitation: Invitation, fail: ErrorCompletion = nil) {
        let tInvi = invitationQueue.list.first { (item) -> Bool in
            return item.id == invitation.id
        }
        
        guard let _ = tInvi else {
            if let fail = fail {
                fail(AGEError.fail("invitation timeout"))
            }
            return
        }
        
        request(seatIndex: invitation.seatIndex,
                type: 4,
                userId: "\(invitation.initiator.info.userId)",
                roomId: room.roomId,
                fail: fail)
    }
}

private extension MultiHostsVM {
    // type: 1.房主邀请 2.观众申请 3.房主拒绝 4.观众拒绝 5.房主同意观众申请 6.观众接受房主邀请 7.房主让主播下麦 8.主播下麦
    func request(seatIndex: Int, type: Int, userId: String, roomId: String, success: DicEXCompletion = nil, fail: ErrorCompletion) {
        let client = Center.shared().centerProvideRequestHelper()
        let task = RequestTask(event: RequestEvent(name: "multi-action: \(type)"),
                               type: .http(.post, url: URLGroup.multiHosts(userId: userId, roomId: roomId)),
                               timeout: .medium,
                               header: ["token": Keys.UserToken],
                               parameters: ["no": seatIndex, "type": type])
        client.request(task: task, success: ACResponse.json({ [weak self] (json) in
            guard let _ = self else {
                return
            }
            
            if let success = success {
                try success(json)
            }
        })) { [weak self] (error) -> RetryOptions in
            guard let strongSelf = self else {
                return .resign
            }
            
            switch type {
            case 1: strongSelf.fail.accept("send invitation fail")
            case 2: strongSelf.fail.accept("send application fail")
            case 3: strongSelf.fail.accept("owner rejects application fail")
            case 4: strongSelf.fail.accept("audience rejects invitation fail")
            case 5: strongSelf.fail.accept("owner accepts application fail")
            case 6: strongSelf.fail.accept("audience accepts invitation fail")
            case 7: strongSelf.fail.accept("owner force broadcaster to end fail")
            case 8: strongSelf.fail.accept("broadcaster end fail")
            default:
                assert(false)
                break
            }
            
            if let fail = fail {
                fail(error)
            }
            return .resign
        }
    }
    
    func observe() {
        /*
        let rtm = Center.shared().centerProvideRTMHelper()
        
        rtm.addReceivedPeerMessage(observer: self.address) { [weak self] (json) in
            guard let cmd = try? json.getEnum(of: "cmd", type: ALPeerMessage.AType.self),
                cmd == .multiHosts,
                let strongSelf = self else {
                return
            }
            
            let data = try json.getDataObject()
            
            let type = try data.getIntValue(of: "type")
            let seatIndex = try data.getIntValue(of: "no")
            
            let userJson = try data.getDictionaryValue(of: "fromUser")
            let role = try LiveRoleItem(dic: userJson)
            
            guard let local = Center.shared().liveSession?.role.value else {
                return
            }
            
            switch type {
            // Owner
            case  2: // receivedApplication:
                let id = try data.getIntValue(of: "processId")
                let application = Application(id: id, seatIndex: seatIndex, initiator: role, receiver: local)
                strongSelf.applicationQueue.append(application)
                strongSelf.receivedApplication.accept(application)
            case  4: // audience rejected invitation
                let id = try data.getIntValue(of: "processId")
                let invitation = Invitation(id: id, seatIndex: seatIndex, initiator: local, receiver: role)
                strongSelf.invitationQueue.remove(invitation)
                strongSelf.invitationByRejected.accept(invitation)
            case  6: // audience accepted invitation:
                let id = try data.getIntValue(of: "processId")
                let invitation = Invitation(id: id, seatIndex: seatIndex, initiator: local, receiver: role)
                strongSelf.invitationQueue.remove(invitation)
                strongSelf.invitationByAccepted.accept(invitation)
            
            // Broadcaster
            case 7: //
                strongSelf.receivedEndBroadcasting.accept(())
                
            // Audience
            case  1: // receivedInvitation
                let id = try data.getIntValue(of: "processId")
                let invitation = Invitation(id: id, seatIndex: seatIndex, initiator: role, receiver: local)
                strongSelf.invitationQueue.append(invitation)
                strongSelf.receivedInvitation.accept(invitation)
            case  3: // applicationByRejected
                let id = try data.getIntValue(of: "processId")
                let application = Application(id: id, seatIndex: seatIndex, initiator: local, receiver: role)
                strongSelf.applicationByRejected.accept(application)
            case  5: // applicationByAccepted:
                let id = try data.getIntValue(of: "processId")
                let application = Application(id: id, seatIndex: seatIndex, initiator: local, receiver: role)
                strongSelf.applicationByAccepted.accept(application)
            // broadcaster end live
            case 8:
                break
            default:
                assert(false)
                break
            }
        }
        
        rtm.addReceivedChannelMessage(observer: self.address) { [weak self] (json) in
            guard let command = try? json.getIntValue(of: "cmd"),
                command == 11,
                let strongSelf = self else {
                    return
            }
            
            let data = try json.getDataObject()
            let userJson = try data.getDictionaryValue(of: "fromUser")
            var user = try LiveRoleItem(dic: userJson)
            let old = try data.getEnum(of: "originRole", type: LiveRoleType.self)
            let new = try data.getEnum(of: "currentRole", type: LiveRoleType.self)
            user.type = new
            
            if old == .audience, new == .broadcaster {
                strongSelf.audienceBecameBroadcaster.accept(user)
            } else if old == .broadcaster, new == .audience {
                strongSelf.broadcasterBecameAudience.accept(user)
            }
        }
        */
        
        message.subscribe(onNext: { (json) in
            
        }).disposed(by: bag)
        
        // Owner
        invitationByRejected.subscribe(onNext: { [unowned self] (invitaion) in
            self.invitationQueue.remove(invitaion)
        }).disposed(by: bag)
        
        invitationByAccepted.subscribe(onNext: { [unowned self] (invitaion) in
            self.invitationQueue.remove(invitaion)
        }).disposed(by: bag)
        
        //
        invitationQueue.queueChanged.subscribe(onNext: { [unowned self] (list) in
            guard let tList = list as? [Invitation] else {
                return
            }
            
            let users = tList.map { (invitation) -> LiveRole in
                return invitation.receiver
            }
            
            self.invitingUserList.accept(users)
        }).disposed(by: bag)
        
        applicationQueue.queueChanged.subscribe(onNext: { [unowned self] (list) in
            guard let tList = list as? [Application] else {
                return
            }
            
            let users = tList.map { (invitation) -> LiveRole in
                return invitation.initiator
            }
            
            self.applyingUserList.accept(users)
        }).disposed(by: bag)
        
        invitationQueue.timeout.subscribe(onNext: { [unowned self] (list) in
            guard let tList = list as? [Invitation] else {
                return
            }
            
            self.invitationTimeout.accept(tList)
        }).disposed(by: bag)
    }
}
