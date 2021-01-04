//
//  ChatRoomViewController.swift
//  AgoraVoice
//
//  Created by CavanSu on 2020/9/3.
//  Copyright © 2020 Agora. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class OwnerHeadView: RxView {
    let headImageView = UIImageView()
    let hasAudio = BehaviorRelay(value: false)
    let audioSilenceTag = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initViews()
        observe()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initViews()
        observe()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        headImageView.frame = bounds
        headImageView.isCycle = true
        
        audioSilenceTag.frame = CGRect(x: bounds.width - 20,
                                       y: bounds.height - 20,
                                       width: 20,
                                       height: 20)
    }
    
    private func initViews() {
        backgroundColor = .clear
        
        addSubview(headImageView)
        
        audioSilenceTag.image = UIImage(named: "icon-Mic-off-tag")
        audioSilenceTag.isHidden = true
        addSubview(audioSilenceTag)
    }
    
    private func observe() {
        hasAudio.bind(to: audioSilenceTag.rx.isHidden).disposed(by: bag)
    }
}

class ChatRoomViewController: MaskViewController, LiveViewController {
    @IBOutlet weak var ownerView: OwnerHeadView!
    @IBOutlet weak var ownerLabel: UILabel!
    @IBOutlet weak var ownerLabelWidth: NSLayoutConstraint!
    
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
    
    fileprivate lazy var errorToast: TagImageTextToast = {
        let view = TagImageTextToast(frame: CGRect(x: 0,
                                                   y: 200,
                                                   width: 0,
                                                   height: 44),
                                     filletRadius: 8)
        view.tagImage = UIImage(named: "icon-red warning")
        return view
    }()
    
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
        
        // check live state
        let state = liveSession.state.value
        
        switch state {
        case .end(let reason):
            liveEndAlert(reason: reason)
        case .active:
            break
        }
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
        
        users()
        gift()
        chatList()
        background()
        music()
        audioEffect()
        netMonitor()
        bottomTools()
        chatInput()
        mediaDevice()
        syncLiveSessionInfo()
        
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
            
            vc.seatCommands.subscribe(onNext: { [unowned self] (seatCommands) in
                self.presentCommandCollection(seatCommands: seatCommands)
            }).disposed(by: vc.bag)
            
            liveSession.localRole.map { (user) -> LiveRoleType in
                return user.type
            }.bind(to: vc.perspective).disposed(by: vc.bag)
            
            seatsVM.seatList.filter { (list) -> Bool in
                return (list.count != 0)
            }.bind(to: vc.seats).disposed(by: bag)
        case "GiftAudienceViewController":
            let vc = segue.destination as! GiftAudienceViewController
            self.giftAudienceVC = vc
        case "BottomToolsViewController":
            let vc = segue.destination as! BottomToolsViewController
            vc.liveType = .chatRoom
            vc.tintColor = tintColor
            bottomToolsVC = vc
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
            self.showAlert(NSLocalizedString("Live_End"),
                           message: NSLocalizedString("Confirm_End_Live"),
                           action1: NSLocalizedString("Cancel"),
                           action2: NSLocalizedString("Confirm"),
                           handler2: { [unowned self] (_) in
                            self.liveSession.leave()
                            self.dimissSelf()
                           })
        }).disposed(by: bag)
        
        liveSession.room.subscribe(onNext: { [unowned self] (room) in
            self.ownerView.headImageView.image = room.owner.info.image
            self.ownerLabel.text = room.owner.info.name
            
            let drawRange = CGSize(width: CGFloat(MAXFLOAT),
                                   height: 25)
            let size = room.owner.info.name.size(font: self.ownerLabel.font,
                                                 drawRange: drawRange)
            var width = size.width + 24
            if width < 42 {
                width = 42
            }
            self.ownerLabelWidth.constant = width
        }).disposed(by: bag)
        
        liveSession.streamList.subscribe(onNext: { [unowned self] (streams) in
            let owner = self.liveSession.room.value.owner.info
            for stream in streams where stream.owner.info == owner {
                self.ownerView.hasAudio.accept(stream.hasAudio)
            }
        }).disposed(by: bag)
        
        personCountView.rx.controlEvent(.touchUpInside).subscribe(onNext: { [unowned self] in
            if self.liveSession.localRole.value.type == .owner {
                self.presentUserList(type: .multiHosts)
            } else {
                self.presentUserList(type: .onlyUser)
            }
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
    func presentUserList(type: UserListViewController.ShowType) {
        guard (type == .multiHosts) || (type == .onlyUser) else {
            return
        }
        
        self.showMaskView(color: UIColor.clear)
        
        let vc = UIStoryboard.initViewController(of: "UserListViewController",
                                                 class: UserListViewController.self,
                                                 on: "Popover")
        
        vc.userListVM = userListVM
        vc.multiHostsVM = multiHostsVM
        vc.showType = type
        vc.view.cornerRadius(10)
        
        if type == .multiHosts, personCountView.needRemind {
            vc.tabView.selectedIndex.accept(1)
            personCountView.needRemind = false
        }
        
        vc.rejectApplicationOfUser.subscribe(onNext: { [unowned self] (application) in
            self.hiddenMaskView()
            
            let name = application.initiator.info.name
            let message = ChatRoomLocalizable.doYouRejectApplication(from: name)
            
            self.showAlert(message: message,
                           action1: NSLocalizedString("Cancel"),
                           action2: NSLocalizedString("Confirm"),
                           handler2: { [unowned self] (_) in
                            self.multiHostsVM.reject(application: application)
                           })
        }).disposed(by: vc.bag)
        
        vc.acceptApplicationOfUser.subscribe(onNext: { [unowned self] (application) in
            self.hiddenMaskView()
            
            let name = application.initiator.info.name
            let message = ChatRoomLocalizable.doYouAcceptApplication(from: name)
            
            self.showAlert(message: message,
                           action1: NSLocalizedString("Cancel"),
                           action2: NSLocalizedString("Confirm"),
                           handler2: { [unowned self] (_) in
                            self.multiHostsVM.accept(application: application)
                           })
        }).disposed(by: vc.bag)
        
        let presenetedHeight: CGFloat = 526.0
        let y = UIScreen.main.bounds.height - presenetedHeight
        let presentedFrame = CGRect(x: 0,
                                    y: y,
                                    width: UIScreen.main.bounds.width,
                                    height: presenetedHeight)
        
        self.presentChild(vc,
                          animated: true,
                          presentedFrame: presentedFrame)
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
        }).disposed(by: vc.bag)
        
        self.presentChild(vc,
                          animated: true,
                          presentedFrame: presentedFrame)
    }
    
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
        let y: CGFloat = UIScreen.main.bounds.height - height + 25
        let frame = CGRect(x: 0,
                           y: y,
                           width: UIScreen.main.bounds.width,
                           height: height)
        
        presentChild(vc, animated: true, presentedFrame: frame)
        
        vc.commands.accept(seatCommands.commands)
        
        vc.selectedCommand.subscribe(onNext: { [unowned self] (command) in
            self.hiddenMaskView()
            
            switch command {
            // Owenr
            case .block, .unblock:
                self.blockOperation(command: command,
                                    seatCommands: seatCommands)
            case .invite:
                self.inviteOperation(command: command,
                                     seatCommands: seatCommands)
            case .forceToStopBroadcasting, .mute, .unmute:
                self.forceToStopBroadcastingMuteOperation(command: command,
                                                          seatCommands: seatCommands)
            // Broadcaster
            case .stopBroadcasting:
                self.stopBroadcastingOperation(command: command,
                                               seatCommands: seatCommands)
            // Audience
            case .apply:
                self.applyOperation(command: command,
                                    seatCommands: seatCommands)
            }
        }).disposed(by: vc.bag)
    }
}

// MARK: Multi broadcasters
private extension ChatRoomViewController {
    func multiHosts() {
        liveSession.customMessage.bind(to: multiHostsVM.message).disposed(by: bag)
        liveSession.localRole.bind(to: multiHostsVM.localRole).disposed(by: bag)
        
        multiHostsVM.fail.subscribe(onNext: { [unowned self] (text) in
            self.showErrorToast(text)
        }).disposed(by: bag)
        
        // owner
        multiHostsVM.receivedApplication.subscribe(onNext: { [unowned self] (application) in
            self.personCountView.needRemind = true
        }).disposed(by: bag)
        
        multiHostsVM.invitationByRejected.subscribe(onNext: { [unowned self] (invitation) in
            let message = ChatRoomLocalizable.rejectThisInvitation()
            let name = invitation.receiver.info.name
            self.showTextToast(text: name + message)
        }).disposed(by: bag)
        
        // broadcaster
        multiHostsVM.receivedEndBroadcasting.subscribe(onNext: { [unowned self] in
            let message = ChatRoomLocalizable.ownerForcedYouToBecomeAudience()
            self.showTextToast(text: message)
        }).disposed(by: bag)
        
        // audience
        multiHostsVM.receivedInvitation.subscribe(onNext: { [unowned self] (invitation) in
            let user = invitation.initiator.info.name
            let message = ChatRoomLocalizable.doYouAgreeToBecomeHost(owner: user)
            
            self.showAlert(message: message,
                           action1: NSLocalizedString("Reject"),
                           action2: NSLocalizedString("Confirm"),
                           handler1: { [unowned self] (_) in
                            self.multiHostsVM.reject(invitation: invitation)
            }) { [unowned self] (_) in
                self.multiHostsVM.accept(invitation: invitation)
            }
        }).disposed(by: bag)
        
        multiHostsVM.applicationByAccepted.subscribe(onNext: { [unowned self] (_) in
            self.hiddenMaskView()
        }).disposed(by: bag)
        
        // role update
        multiHostsVM.audienceBecameBroadcaster.subscribe(onNext: { [unowned self] (user) in
            let message = NSLocalizedString("Became_A_Host")
            let chat = Chat(name: user.info.name,
                            text: " \(message)",
                            widthLimit: self.chatWidthLimit)
            
            self.chatVM.newMessages([chat])
            self.showTextToast(text: chat.content.string)
        }).disposed(by: bag)
        
        multiHostsVM.broadcasterBecameAudience.subscribe(onNext: { [unowned self] (user) in
            let message = NSLocalizedString("Became_A_Audience")
            let chat = Chat(name: user.info.name,
                            text: " \(message)",
                            widthLimit: self.chatWidthLimit)
            
            self.chatVM.newMessages([chat])
            self.showTextToast(text: chat.content.string)
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
}

// MARK: - Seat command operation
private extension ChatRoomViewController {
    func blockOperation(command: LiveSeatView.Command,
                        seatCommands: LiveSeatCommands) {
        var message: String
        
        switch command {
        case .block:
            message = ChatRoomLocalizable.unblockThisSeat()
        case .unblock:
            message = ChatRoomLocalizable.blockThisSeat()
        default:
            assert(false)
            return
        }
        
        let seatState: SeatState = (command == .block ? .close : .empty)
        
        self.showAlert(message: message,
                       action1: NSLocalizedString("Cancel"),
                       action2: NSLocalizedString("Confirm"),
                       handler2:  { [unowned self] (_) in
                        self.seatsVM.update(state: seatState,
                                            index: seatCommands.seat.index)
                       })
    }
    
    func inviteOperation(command: LiveSeatView.Command,
                         seatCommands: LiveSeatCommands) {
        self.presentInvitationList { [unowned self] (user) in
            self.hiddenMaskView()
            
            let message = ChatRoomLocalizable.sendInvitation(to: user.info.name)
            
            self.showAlert(message: message,
                           action1: NSLocalizedString("NO"),
                           action2: NSLocalizedString("YES"),
                           handler2: { [unowned self] (_) in
                            self.multiHostsVM.sendInvitation(to: user,
                                                             on: seatCommands.seat.index)
                           })
        }
    }
    
    func forceToStopBroadcastingMuteOperation(command: LiveSeatView.Command,
                                              seatCommands: LiveSeatCommands) {
        guard let stream = seatCommands.seat.state.stream else {
            assert(false)
            return
        }
        
        let userName = stream.owner.info.name
        
        var message: String
        
        switch command {
        case .forceToStopBroadcasting:
            message = ChatRoomLocalizable.forceBroacasterToBecomeAudience(userName: userName)
        case .mute:
            message = ChatRoomLocalizable.muteSomeOne(userName: userName)
        case .unmute:
            message = ChatRoomLocalizable.ummuteSomeOne(userName: userName)
        default:
            assert(false)
            return
        }
        
        self.showAlert(message: message,
                       action1: NSLocalizedString("Cancel"),
                       action2: NSLocalizedString("Confirm"),
                       handler2: { [unowned self] (_) in
                        switch command {
                        case .forceToStopBroadcasting:
                            self.multiHostsVM.forceEndWith(user: stream.owner,
                                                           on: seatCommands.seat.index)
                        case .unmute:
                            self.liveSession.unmuteOther(stream: stream)
                        case .mute:
                            self.liveSession.muteOther(stream: stream)
                        default:
                            break
                        }
                       })
    }
    
    func stopBroadcastingOperation(command: LiveSeatView.Command,
                                   seatCommands: LiveSeatCommands) {
        guard let user = seatCommands.seat.state.stream?.owner else {
            assert(false)
            return
        }
        
        let message = ChatRoomLocalizable.stopBroadcasting()
        
        self.showAlert(message: message,
                       action1: NSLocalizedString("Cancel"),
                       action2: NSLocalizedString("Confirm"),
                       handler2:  { [unowned self] (_) in
                        self.multiHostsVM.endBroadcasting(seatIndex: seatCommands.seat.index,
                                                          user: user)
                       })
    }
    
    func applyOperation(command: LiveSeatView.Command,
                        seatCommands: LiveSeatCommands) {
        let message = ChatRoomLocalizable.doYouSendApplication()
        self.showAlert(message: message,
                       action1: NSLocalizedString("Cancel"),
                       action2: NSLocalizedString("Confirm"),
                       handler2:  { [unowned self] (_) in
                        self.multiHostsVM.sendApplication(by: self.liveSession.localRole.value,
                                                          for: seatCommands.seat.index,
                                                          success: { [unowned self] in
                                                            let message = ChatRoomLocalizable.yourApplicationHasBeenSent()
                                                            self.showTextToast(text: message)
                                                          })
                       })
    }
}

private extension ChatRoomViewController {
    func showErrorToast(_ text: String) {
        errorToast.text = text
        showToastView(errorToast, duration: 3)
    }
}
