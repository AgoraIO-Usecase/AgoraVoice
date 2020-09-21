//
//  ChatRoomViewController.swift
//  AgoraVoice
//
//  Created by CavanSu on 2020/9/3.
//  Copyright © 2020 Agora. All rights reserved.
//

import UIKit

class ChatRoomViewController: MaskViewController, LiveViewController {
    @IBOutlet weak var ownerImageView: UIImageView!
    @IBOutlet weak var ownerLabel: UILabel!
    
    @IBOutlet weak var seatViewHeight: NSLayoutConstraint!
    @IBOutlet weak var closeButton: UIButton!
    
    // LiveViewController
    var liveSession: LiveSession!
    var tintColor = UIColor(hexString: "#000000-0.3")
    var chatWidthLimit: CGFloat = UIScreen.main.bounds.width - 60
    
    // ViewController
    var giftAudienceVC: GiftAudienceViewController?
    var bottomToolsVC: BottomToolsViewController?
    var chatVC: ChatViewController?
    
    // View
    @IBOutlet weak var personCountView: RemindIconTextView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    internal lazy var chatInputView: ChatInputView = {
        let chatHeight: CGFloat = 50.0
        let frame = CGRect(x: 0,
                           y: UIScreen.main.bounds.height,
                           width: UIScreen.main.bounds.width,
                           height: chatHeight)
        let view = ChatInputView(frame: frame)
        view.isHidden = true
        return view
    }()
    
    // ViewModel
    var userListVM = LiveUserListVM()
    var musicVM = MusicVM()
    var chatVM = ChatVM()
    var deviceVM = MediaDeviceVM()
    var audioEffectVM = AudioEffectVM()
    var monitor = NetworkMonitor(host: "www.apple.com")
    
    var backgroundVM: RoomBackgroundVM!
    var giftVM: GiftVM!
    
    // multi hosts & live seats
    var multiHostsVM: MultiHostsVM!
    var seatsVM: LiveSeatsVM!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let navigation = self.navigationController as? CSNavigationController else {
            assert(false)
            return
        }
        
        navigation.navigationBar.isHidden = true
    }
    
    deinit {
        #if !RELEASE
        print("deinit ChatRoomViewController")
        #endif
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()
        calculateSeatViewHeight()
        
        syncLiveSessionInfo()
        users()
        gift()
        chatList()
        background()
        musicList()
        netMonitor()
        bottomTools()
        chatInput()
        
        multiHosts()
        liveSeats()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let segueId = segue.identifier else {
            return
        }
        
        switch segueId {
        case "LiveSeatViewController":
            let vc = segue.destination as! LiveSeatViewController
            vc.perspective = .owner
            vc.seatCommands.subscribe(onNext: { [unowned self] (seatCommands) in
                self.presentCommandCollection(seatCommands: seatCommands)
            }).disposed(by: vc.bag)
        case "GiftAudienceViewController":
            let vc = segue.destination as! GiftAudienceViewController
            self.giftAudienceVC = vc
        case "BottomToolsViewController":
            let vc = segue.destination as! BottomToolsViewController
            vc.liveType = .chatRoom
            vc.tintColor = tintColor
            bottomToolsVC = vc
            
            liveSession.localRole.subscribe(onNext: { [unowned vc] (local) in
                vc.perspective = local.type
            }).disposed(by: vc.bag)
        case "ChatViewController":
            let vc = segue.destination as! ChatViewController
            vc.cellColor = tintColor
            self.chatVC = vc
        default:
            break
        }
    }
}

private extension ChatRoomViewController {
    func updateViews() {
        backgroundImageView.image = Center.shared().centerProvideImagesHelper().roomBackgrounds.first
        personCountView.backgroundColor = tintColor
        
        closeButton.rx.tap.subscribe(onNext: { [unowned self] in
            self.liveSession.leave()
            self.dimissSelf()
        }).disposed(by: bag)
        
        liveSession.room.subscribe(onNext: { [unowned self] (room) in
            self.ownerImageView.image = room.owner.info.image
            self.ownerLabel.text = room.owner.info.name
        }).disposed(by: bag)
    }
    
    func calculateSeatViewHeight() {
        let space: CGFloat = 26
        let itemWidth: CGFloat = (UIScreen.main.bounds.width - (space * 5)) / 4
        let itemHeight = itemWidth
        seatViewHeight.constant = itemHeight * 2 + space
    }
}

private extension ChatRoomViewController {
    func presentCommandCollection(seatCommands: LiveSeatCommands) {
        showMaskView(color: .clear)
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width, height: 48)
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        let vc = CommandViewController(collectionViewLayout: layout)
        vc.view.cornerRadius(10)
        vc.view.layer.masksToBounds = true
        
        let height: CGFloat = CGFloat(seatCommands.commands.count * 48 + 50) + UIScreen.main.heightOfSafeAreaBottom
        let y: CGFloat = UIScreen.main.bounds.height - height
        let frame = CGRect(x: 0, y: y, width: UIScreen.main.bounds.width, height: height)
        
        presentChild(vc, animated: true, presentedFrame: frame)
        
        vc.commands.accept(seatCommands.commands)
        
        vc.selectedCommand.subscribe(onNext: { [unowned self] (command) in
            self.hiddenMaskView()
            
            switch command {
            case .close, .release:
                let handler: ((UIAlertAction) -> Void)? = { [unowned self] (_) in
                    let update = { [unowned self] in
                        self.seatsVM.update(state: .close,
                                            index: seatCommands.seat.index)
                    }
                    
                    if command == .release {
                        update()
                    } else {
                        if let user = seatCommands.seat.state.stream?.owner {
                            self.multiHostsVM.forceEndWith(user: user,
                                                           on: seatCommands.seat.index,
                                                           success: {
                                                            update()
                            })
                        } else {
                            update()
                        }
                    }
                }
                
                let message = self.alertMessageOfSeatCommand(command,
                                                             with: seatCommands.seat.state.stream?.owner.info.name)
                
                self.showAlert(message: message,
                               action1: NSLocalizedString("Cancel"),
                               action2: NSLocalizedString("Confirm"),
                               handler2: handler)
            
            // Owenr
            case .invitation:
                self.presentInvitationList { [unowned self] (user) in
                    self.hiddenMaskView()
                    
                    let handler: ((UIAlertAction) -> Void)? = { [unowned self] (_) in
                        self.multiHostsVM.sendInvitation(to: user,
                                                         on: seatCommands.seat.index)
                    }
                    let message = self.alertMessageOfSeatCommand(command,
                                                                 with: user.info.name)
                    self.showAlert(message: message,
                                   action1: NSLocalizedString("Cancel"),
                                   action2: NSLocalizedString("Confirm"),
                                   handler2: handler)
                }
            case .forceBroadcasteEnd, .unban, .ban:
                guard let stream = seatCommands.seat.state.stream else {
                                   assert(false)
                                   break
                }
                
                let handler: ((UIAlertAction) -> Void)? = { [unowned self] (_) in
                    if command == .forceBroadcasteEnd {
                        self.multiHostsVM.forceEndWith(user: stream.owner,
                                                       on: seatCommands.seat.index)
                    } else if command == .unban {
                        
                    } else if command == .ban {
                        
                    }
                }
                
                let message = self.alertMessageOfSeatCommand(command,
                                                             with: stream.owner.info.name)
                
                self.showAlert(message: message,
                               action1: NSLocalizedString("Cancel"),
                               action2: NSLocalizedString("Confirm"),
                               handler2: handler)
                
            // Broadcaster
            case .endBroadcasting:
                self.showAlert(message: NSLocalizedString("Confirm_End_Broadcasting"),
                               action1: NSLocalizedString("Cancel"),
                               action2: NSLocalizedString("Confirm")) { [unowned self] (_) in
                                guard let user = seatCommands.seat.state.stream?.owner else {
                                    assert(false)
                                    return
                                }
                                
                                self.multiHostsVM.endBroadcasting(seatIndex: seatCommands.seat.index, user: user)
                }
            // Audience
            case .application:
                self.showAlert(message: NSLocalizedString("Confirm_Apply_For_Broadcasting"),
                               action1: NSLocalizedString("Cancel"),
                               action2: NSLocalizedString("Confirm")) { [unowned self] (_) in
                                self.multiHostsVM.sendApplication(by: self.liveSession.localRole.value,
                                                                  for: seatCommands.seat.index)
                }
            }
        }).disposed(by: vc.bag)
    }
}

private extension ChatRoomViewController {
    func multiHosts() {
        // owner
        multiHostsVM.receivedApplication.subscribe(onNext: { [unowned self] (application) in
            self.showAlert(message: "\"\(application.initiator.info.name)\" " + NSLocalizedString("Apply_For_Broadcasting"),
                           action1: NSLocalizedString("Reject"),
                           action2: NSLocalizedString("Confirm"),
                           handler1: { [unowned self] (_) in
                            self.multiHostsVM.reject(application: application)
            }) { [unowned self] (_) in
                self.multiHostsVM.accept(application: application)
            }
        }).disposed(by: bag)
        
        multiHostsVM.invitationByRejected.subscribe(onNext: { [unowned self] (invitation) in
            if DeviceAssistant.Language.isChinese {
                self.showTextToast(text: invitation.receiver.info.name + "拒绝了这次邀请")
            } else {
                self.showTextToast(text: invitation.receiver.info.name + "rejected this invitation")
            }
        }).disposed(by: bag)
        
        // broadcaster
        multiHostsVM.receivedEndBroadcasting.subscribe(onNext: { [unowned self] in
            if DeviceAssistant.Language.isChinese {
                self.showTextToast(text: "房主强迫你下麦")
            } else {
                self.showTextToast(text: "Owner forced you to becmoe a audience")
            }
        }).disposed(by: bag)
        
        // audience
        multiHostsVM.receivedInvitation.subscribe(onNext: { [unowned self] (invitation) in
            self.showAlert(message: NSLocalizedString("Confirm_Accept_Broadcasting_Invitation"),
                           action1: NSLocalizedString("Reject"),
                           action2: NSLocalizedString("Confirm"),
                           handler1: { [unowned self] (_) in
                            self.multiHostsVM.reject(invitation: invitation)
            }) { [unowned self] (_) in
                self.multiHostsVM.accept(invitation: invitation, success: {
                    
                }) { [unowned self] (_) in
                    self.showTextToast(text: "accept invitation fail")
                }
            }
        }).disposed(by: bag)
        
        multiHostsVM.applicationByAccepted.subscribe(onNext: { [unowned self] (_) in
            self.hiddenMaskView()
        }).disposed(by: bag)
        
        multiHostsVM.applicationByRejected.subscribe(onNext: { [unowned self] (application) in
            if DeviceAssistant.Language.isChinese {
                self.showTextToast(text: "房间拒绝你的申请")
            } else {
                self.showTextToast(text: "Owner rejected your application")
            }
        }).disposed(by: bag)
        
        // role update
        multiHostsVM.audienceBecameBroadcaster.subscribe(onNext: { [unowned self] (user) in
            if DeviceAssistant.Language.isChinese {
                let chat = Chat(name: user.info.name, text: " 上麦", widthLimit: self.chatWidthLimit)
                self.chatVM.newMessages([chat])
                self.showTextToast(text: chat.content.string)
            } else {
                let chat = Chat(name: user.info.name, text: " became a broadcaster", widthLimit: self.chatWidthLimit)
                self.chatVM.newMessages([chat])
                self.showTextToast(text: chat.content.string)
            }
        }).disposed(by: bag)
        
        multiHostsVM.broadcasterBecameAudience.subscribe(onNext: { [unowned self] (user) in
            if DeviceAssistant.Language.isChinese {
                let chat = Chat(name: user.info.name,
                                text: " 下麦",
                                widthLimit: self.chatWidthLimit)
                self.chatVM.newMessages([chat])
                self.showTextToast(text: chat.content.string)
            } else {
                let chat = Chat(name: user.info.name,
                                text: " became a audience",
                                widthLimit: self.chatWidthLimit)
                self.chatVM.newMessages([chat])
                self.showTextToast(text: chat.content.string)
            }
        }).disposed(by: bag)
        
        multiHostsVM.invitationTimeout.subscribe(onNext: { [unowned self] (_) in
            guard self.liveSession.room.value.owner.info == self.liveSession.localRole.value.info else {
                return
            }
            self.showTextToast(text: NSLocalizedString("User_Invitation_Timeout"))
        }).disposed(by: bag)
    }
    
    func liveSeats() {
        liveSession.streamList.bind(to: seatsVM.streamList).disposed(by: bag)
        liveSession.customMessage.bind(to: seatsVM.message).disposed(by: bag)
        
        seatsVM.fail.subscribe(onNext: { [unowned self] (text) in
            self.showTextToast(text: text)
        }).disposed(by: bag)
    }
    
    func alertMessageOfSeatCommand(_ command: LiveSeatView.Command, with userName: String?) -> String {
        switch command {
        case .ban:
            if DeviceAssistant.Language.isChinese {
                return "禁止\"\(userName!)\"发言?"
            } else {
                return "Mute \(userName!)?"
            }
        case .unban:
            if DeviceAssistant.Language.isChinese {
                return "解除\"\(userName!)\"禁言?"
            } else {
                return "Unmute \(userName!)?"
            }
        case .forceBroadcasteEnd:
            if DeviceAssistant.Language.isChinese {
                return "确定\"\(userName!)\"下麦?"
            } else {
                return "Stop \(userName!) hosting"
            }
        case .close:
            if DeviceAssistant.Language.isChinese {
                return "将关闭该麦位，如果该位置上有用户，将下麦该用户"
            } else {
                return "Block this position"
            }
        case .release:
            return NSLocalizedString("Seat_Release_Description")
        case .invitation:
            if DeviceAssistant.Language.isChinese {
                return "你是否要邀请\"\(userName!)\"上麦?"
            } else {
                return "Do you send a invitation to \(userName!)?"
            }
        default:
            assert(false)
            return ""
        }
    }
    
    func presentInvitationList(selected: ((LiveRole) -> Void)? = nil) {
        self.showMaskView(color: UIColor.clear)
        
        let vc = UIStoryboard.initViewController(of: "UserListViewController",
                                                 class: UserListViewController.self,
                                                 on: "Popover")
        
        vc.userListVM = userListVM
        vc.multiHostsVM = multiHostsVM
        vc.showType = .onlyInvitationOfMultiHosts
        vc.view.cornerRadius(10)
        
        let presenetedHeight: CGFloat = 526.0 + UIScreen.main.heightOfSafeAreaTop
        let y = UIScreen.main.bounds.height - presenetedHeight
        let presentedFrame = CGRect(x: 0,
                                    y: y,
                                    width: UIScreen.main.bounds.width,
                                    height: presenetedHeight)
        
        vc.inviteUser.subscribe(onNext: { (user) in
            if let selected = selected {
                selected(user)
            }
        }).disposed(by: bag)
        
        self.presentChild(vc,
                          animated: true,
                          presentedFrame: presentedFrame)
    }
}
