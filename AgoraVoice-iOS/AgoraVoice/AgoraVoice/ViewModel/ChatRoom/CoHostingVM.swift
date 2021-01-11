//
//  coHostingVM.swift
//  AgoraLive
//
//  Created by CavanSu on 2020/7/22.
//  Copyright © 2020 Agora. All rights reserved.
//

import UIKit
import RxSwift
import RxRelay
import Armin

class CoHostingVM: CustomObserver {
    struct Invitation: TimestampModel {
        var id: String
        var seatIndex: Int
        var initiator: LiveRole
        var receiver: LiveRole
        var timestamp: TimeInterval
        
        init(id: String,
             seatIndex: Int,
             initiator: LiveRole,
             receiver: LiveRole) {
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
        
        init(id: String,
             seatIndex: Int,
             initiator: LiveRole,
             receiver: LiveRole) {
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
    var receivedEndBroadcasting = PublishRelay<(LiveRole)>()
    
    // Audience
    var receivedInvitation = PublishRelay<Invitation>()
    var applicationByRejected = PublishRelay<Application>()
    var applicationByAccepted = PublishRelay<Application>()
    
    // notification of role change
    var audienceBecameBroadcaster = PublishRelay<LiveRole>()
    var broadcasterBecameAudience = PublishRelay<LiveRole>()
    
    let localRole = BehaviorRelay<LiveRole?>(value: nil)
    
    init(room: Room) {
        self.room = room
        super.init()
        observe()
    }
    
    deinit {
        #if !RELEASE
        print("deinit CoHostingVM")
        #endif
    }
}

// MARK: Owner
extension CoHostingVM {
    func sendInvitation(to user: LiveRole, on seatIndex: Int) {
        request(seatIndex: seatIndex,
                type: 1,
                userId: "\(user.info.userId)",
                roomId: room.roomId,
                success: { [unowned self] (json) in
                    let invitationTag = "2"
                    let id = "\(localRole.value!.info.userId)_\(user.info.userId)_\(invitationTag)"
                    let invitation = Invitation(id: id,
                                                seatIndex: seatIndex,
                                                initiator: self.room.owner,
                                                receiver: user)
                    self.invitationQueue.append(invitation)
                }, fail: nil)
    }
    
    func accept(application: Application, success: Completion = nil) {
        request(seatIndex: application.seatIndex,
                type: 5,
                userId: "\(application.initiator.info.userId)",
                roomId: room.roomId,
                success: { [unowned self] (json) in
                    self.applicationQueue.remove(application)
                    
                    for item in self.applicationQueue.list {
                        guard let temp = item as? Application,
                              temp.seatIndex == application.seatIndex else {
                            return
                        }
                        
                        self.applicationQueue.remove(temp)
                    }
                    
                    if let success = success {
                        success()
                    }
                }) { [unowned self] (error) in
                    if let cError = error as? AGEError,
                        cError.code == 1301006 {
                        self.applicationQueue.remove(application)
                    }
                }
    }
    
    func reject(application: Application) {
        request(seatIndex: application.seatIndex,
                type: 3,
                userId: "\(application.initiator.info.userId)",
                roomId: room.roomId,
                success: { [unowned self] (json) in
                    self.applicationQueue.remove(application)
                }, fail: nil)
    }
    
    func forceEndWith(user: LiveRole, on seatIndex: Int) {
        request(seatIndex: seatIndex,
                type: 7,
                userId: "\(user.info.userId)",
                roomId: room.roomId,
                success: nil,
                fail: nil)
    }
}

// MARK: Broadcaster
extension CoHostingVM {
    func endBroadcasting(seatIndex: Int, user: LiveRole) {
        request(seatIndex: seatIndex,
                type: 8,
                userId: "\(user.info.userId)",
                roomId: room.roomId,
                success: nil,
                fail: nil)
    }
}

// MARK: Audience
extension CoHostingVM {
    func sendApplication(by local: LiveRole, for seatIndex: Int, success: Completion = nil) {
        request(seatIndex: seatIndex,
                type: 2,
                userId: "\(room.owner.info.userId)",
                roomId: room.roomId,
                success: { (_) in
                    if let success = success {
                        success()
                    }
                }, fail: nil)
    }
    
    func accept(invitation: Invitation) {
        let tInvi = invitationQueue.list.first { (item) -> Bool in
            return item.id == invitation.id
        }
        
        guard let _ = tInvi else {
            fail.accept(ChatRoomLocalizable.invitationTimeout())
            return
        }
        
        request(seatIndex: invitation.seatIndex,
                type: 6,
                userId: "\(invitation.initiator.info.userId)",
                roomId: room.roomId,
                success: nil,
                fail: nil)
    }
    
    func reject(invitation: Invitation) {
        let tInvi = invitationQueue.list.first { (item) -> Bool in
            return item.id == invitation.id
        }
        
        guard let _ = tInvi else {
            fail.accept(ChatRoomLocalizable.invitationTimeout())
            return
        }
        
        request(seatIndex: invitation.seatIndex,
                type: 4,
                userId: "\(invitation.initiator.info.userId)",
                roomId: room.roomId,
                fail: nil)
    }
}

private extension CoHostingVM {
    // type: 1.房主邀请 2.观众申请 3.房主拒绝 4.观众拒绝 5.房主同意观众申请 6.观众接受房主邀请 7.房主让主播下麦 8.主播下麦
    func request(seatIndex: Int, type: Int, userId: String, roomId: String, success: DicEXCompletion = nil, fail: ErrorCompletion) {
        let client = Center.shared().centerProvideRequestHelper()
        let url = URLGroup.multiHosts(userId: userId, roomId: roomId)
        let task = ArRequestTask(event: ArRequestEvent(name: "co-hosting-action: \(type)"),
                               type: .http(.post, url: url),
                               timeout: .medium,
                               header: ["token": Keys.UserToken],
                               parameters: ["no": seatIndex, "type": type])
        client.request(task: task, success: ArResponse.json({ [weak self] (json) in
            guard let strongSelf = self else {
                return
            }
            
            let code = try json.getIntValue(of: "code")
            
            if code == 1301006 {
                let message = ChatRoomLocalizable.thisSeatHasBeenTakenUp()
                
                strongSelf.fail.accept(message)
                
                if let fail = fail {
                    fail(AGEError.fail(message, code: code))
                }
                
                return
            }
            
            if let success = success {
                try success(json)
            }
        })) { [weak self] (error) -> ArRetryOptions in
            guard let strongSelf = self else {
                return .resign
            }
            
            if error.code == nil {
                strongSelf.fail.accept(NetworkLocalizable.lostConnectionRetry())
            } else {
                strongSelf.fail.accept(ChatRoomLocalizable.coHostingActionFail())
            }
            
            if let fail = fail {
                fail(error)
            }
            return .resign
        }
    }
    
    func observe() {
        message.subscribe(onNext: { [unowned self] (json) in
            do {
                guard let cause = try? json.getDictionaryValue(of: "cause"),
                      let cmd = try? cause.getIntValue(of: "cmd"),
                      cmd == 2,
                      let data =  try? cause.getDictionaryValue(of: "data")  else {
                    return
                }
                
                let type = try data.getIntValue(of: "type")
                let userDic = try data.getDictionaryValue(of: "user")
                let user = try LiveRoleItem(dic: userDic)
                
                let ownerAcceptedAudienceRequest = 5
                let audienceAcceptedOwnerInvitation = 6
                let ownerForcedYouBecomeAudience = 7
                let broadcastorStoppedCoHosting = 8
                
                switch type {
                case ownerForcedYouBecomeAudience:
                    self.receivedEndBroadcasting.accept((user))
                    self.broadcasterBecameAudience.accept((user))
                case ownerAcceptedAudienceRequest, audienceAcceptedOwnerInvitation:
                    self.audienceBecameBroadcaster.accept((user))
                case broadcastorStoppedCoHosting:
                    self.broadcasterBecameAudience.accept((user))
                default:
                    break
                }
                
            } catch {
                self.log(error: error)
            }
        }).disposed(by: bag)
        
        message.subscribe(onNext: { [unowned self] (json) in
            do {
                guard let data = try? json.getDictionaryValue(of: "data"),
                      let payload = try? data.getDictionaryValue(of: "payload"),
                      let fromUserDic = try? data.getDictionaryValue(of: "fromUser") else {
                    return
                }
                
                let fromUserId = try fromUserDic.getStringValue(of: "userUuid")
                let fromUserName = try fromUserDic.getStringValue(of: "userName")
                let roleString = try fromUserDic.getStringValue(of: "role")
                let role = try LiveRoleType.initWithDescription(roleString)
                
                let seatIndex = try payload.getIntValue(of: "no")
                let event = try payload.getIntValue(of: "type")
                
                let info = BasicUserInfo(userId: fromUserId,
                                         name: fromUserName)
                
                let fromUser = LiveRoleItem(type: role,
                                            info: info,
                                            agUId: "0")
                
                guard let local = self.localRole.value else {
                    throw AGEError.valueNil("local role")
                }
                
                let applicationId = "1"
                let invitationTag = "2"
                
                switch event {
                // Owner
                case 2: // received application:
                    let initiator = fromUser
                    let receiver = local
                    let applicationId = "\(initiator.info.userId)_\(receiver.info.userId)_\(applicationId)"
                    let application = Application(id: applicationId,
                                                  seatIndex: seatIndex,
                                                  initiator: initiator,
                                                  receiver: receiver)
                    self.applicationQueue.append(application)
                    self.receivedApplication.accept(application)
                case  4: // audience rejected invitation
                    let initiator = local
                    let receiver = fromUser
                    let invitationId = "\(initiator.info.userId)_\(receiver.info.userId)_\(invitationTag)"
                    let invitation = Invitation(id: invitationId,
                                                seatIndex: seatIndex,
                                                initiator: initiator,
                                                receiver: receiver)
                    self.invitationByRejected.accept(invitation)
                case  6: // audience accepted invitation:
                    let initiator = local
                    let receiver = fromUser
                    let invitationId = "\(initiator.info.userId)_\(receiver.info.userId)_\(invitationTag)"
                    let invitation = Invitation(id: invitationId,
                                                seatIndex: seatIndex,
                                                initiator: initiator,
                                                receiver: receiver)
                    self.invitationByAccepted.accept(invitation)
                
                // Audience
                case  1: // receivedInvitation
                    let initiator = fromUser
                    let receiver = local
                    let invitationId = "\(initiator.info.userId)_\(receiver.info.userId)_\(invitationTag)"
                    let invitation = Invitation(id: invitationId,
                                                seatIndex: seatIndex,
                                                initiator: initiator,
                                                receiver: receiver)
                    self.invitationQueue.append(invitation)
                    self.receivedInvitation.accept(invitation)
                case  3: // application by rejected
                    let initiator = local
                    let receiver = fromUser
                    let applicationId = "\(initiator.info.userId)_\(receiver.info.userId)_\(applicationId)"
                    let application = Application(id: applicationId,
                                                  seatIndex: seatIndex,
                                                  initiator: initiator,
                                                  receiver: receiver)
                    self.applicationByRejected.accept(application)
                case  5: // application by accepted:
                    let initiator = local
                    let receiver = fromUser
                    let applicationId = "\(initiator.info.userId)_\(receiver.info.userId)_\(applicationId)"
                    let application = Application(id: applicationId,
                                                  seatIndex: 0,
                                                  initiator: initiator,
                                                  receiver: receiver)
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
            
            for item in self.applicationQueue.list {
                guard let temp = item as? Application,
                      temp.seatIndex == invitaion.seatIndex else {
                    return
                }
                
                self.applicationQueue.remove(temp)
            }
        }).disposed(by: bag)
        
        // Audience
        applicationByRejected.subscribe(onNext: { [unowned self] (application) in
            self.applicationQueue.remove(application)
        }).disposed(by: bag)
        
        applicationByAccepted.subscribe(onNext: { [unowned self] (application) in
            self.applicationQueue.remove(application)
        }).disposed(by: bag)
        
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
