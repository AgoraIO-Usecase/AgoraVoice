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
        var id: String
        var seatIndex: Int
        var initiator: LiveRole
        var receiver: LiveRole
        var timestamp: TimeInterval
        
        init(id: String, seatIndex: Int, initiator: LiveRole, receiver: LiveRole) {
            self.id = id
            self.seatIndex = seatIndex
            self.initiator = initiator
            self.receiver = receiver
            self.timestamp = NSDate().timeIntervalSince1970
        }
    }
    
    struct Application: TimestampModel {
        var id: String
        var seatIndex: Int
        var initiator: LiveRole
        var receiver: LiveRole
        var timestamp: TimeInterval
        
        init(id: String, seatIndex: Int, initiator: LiveRole, receiver: LiveRole) {
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
    
    let actionMessage = PublishRelay<ActionMessage>()
    let localRole = BehaviorRelay<LiveRole?>(value: nil)
    
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

                    let id = try json.getStringValue(of: "data")
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
        actionMessage.subscribe(onNext: { [unowned self] (message) in
            guard let payload = message.payload as? [String: Any] else {
                return
            }
            
            do {
                let fromUserName = message.fromUser.userName
                let fromUserId = message.fromUser.userUuid
                let info = BasicUserInfo(userId: fromUserId, name: fromUserName)
                let fromUser = LiveRoleItem(type:(message.fromUser.role == .teacher ? .owner : .audience),
                                            info: info, agUId: "0")
                
                let processId = message.processUuid
                let event = try payload.getIntValue(of: "type")
                let seatIndex = try payload.getIntValue(of: "no")
                
                guard let local = self.localRole.value else {
                    throw AGEError.valueNil("local role")
                }
                
                switch event {
                // Owner
                case 2: // received application:
                    let initiator = fromUser
                    let receiver = local
                    let application = Application(id: processId, seatIndex: seatIndex, initiator: initiator, receiver: receiver)
                    self.applicationQueue.append(application)
                    self.receivedApplication.accept(application)
                case  4: // audience rejected invitation
                    let initiator = local
                    let receiver = fromUser
                    let invitation = Invitation(id: processId, seatIndex: seatIndex, initiator: initiator, receiver: receiver)
                    self.invitationByRejected.accept(invitation)
                case  6: // audience accepted invitation:
                    let initiator = local
                    let receiver = fromUser
                    let invitation = Invitation(id: processId, seatIndex: seatIndex, initiator: initiator, receiver: receiver)
                    self.invitationByAccepted.accept(invitation)
                    
                // Audience
                case  1: // receivedInvitation
                    let initiator = fromUser
                    let receiver = local
                    let invitation = Invitation(id: processId, seatIndex: seatIndex, initiator: initiator, receiver: receiver)
                    self.invitationQueue.append(invitation)
                    self.receivedInvitation.accept(invitation)
                case  3: // application by rejected
                    let initiator = local
                    let receiver = fromUser
                    let application = Application(id: processId, seatIndex: seatIndex, initiator: initiator, receiver: receiver)
                    self.applicationByRejected.accept(application)
                case  5: // application by accepted:
                    let initiator = local
                    let receiver = fromUser
                    let application = Application(id: processId, seatIndex: 0, initiator: initiator, receiver: receiver)
                    self.applicationByAccepted.accept(application)
                default:
                    break
                }
            } catch {
                self.log(error: error)
            }
        }).disposed(by: bag)
        
        // Owner
        invitationByRejected.subscribe(onNext: { [unowned self] (invitaion) in
            self.invitationQueue.remove(invitaion)
        }).disposed(by: bag)
        
        invitationByAccepted.subscribe(onNext: { [unowned self] (invitaion) in
            self.invitationQueue.remove(invitaion)
        }).disposed(by: bag)
        
        applicationByRejected.subscribe(onNext: { [unowned self] (application) in
            self.applicationQueue.remove(application)
        }).disposed(by: bag)
        
        applicationByAccepted.subscribe(onNext: { [unowned self] (application) in
            self.applicationQueue.remove(application)
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
