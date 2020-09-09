//
//  UserListViewController.swift
//  AgoraLive
//
//  Created by CavanSu on 2020/7/31.
//  Copyright © 2020 Agora. All rights reserved.
//

import UIKit
import MJRefresh
import RxSwift
import RxRelay

protocol UserInvitationListCellDelegate: NSObjectProtocol {
    func cell(_ cell: UserInvitationListCell, didTapInvitationButton: UIButton, on index: Int)
}

protocol UserApplicationListCellDelegate: NSObjectProtocol {
    func cell(_ cell: UserApplicationListCell, didTapAcceptButton: UIButton, on index: Int)
    func cell(_ cell: UserApplicationListCell, didTapRejectButton: UIButton, on index: Int)
}

class UserInvitationListCell: UITableViewCell {
    enum InviteButtonState {
        case none, inviting, availableInvite
    }
    
    @IBOutlet var headImageView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet weak var inviteButton: UIButton!
    
    fileprivate weak var delegate: UserInvitationListCellDelegate?
    private let bag = DisposeBag()
    
    var index: Int = 0
    var buttonState: InviteButtonState = .none {
        didSet {
            switch buttonState {
            case .none:
                inviteButton.isHidden = true
            case .inviting:
                inviteButton.isHidden = false
                inviteButton.isEnabled = false
                inviteButton.setTitle(NSLocalizedString("Inviting"), for: .disabled)
                inviteButton.setTitleColor(.white, for: .normal)
                inviteButton.backgroundColor = UIColor(hexString: "#CCCCCC")
                inviteButton.cornerRadius(16)
            case .availableInvite:
                inviteButton.isHidden = false
                inviteButton.isEnabled = true
                inviteButton.setTitle(NSLocalizedString("Invite"), for: .normal)
                inviteButton.setTitleColor(UIColor(hexString: "#0088EB"), for: .normal)
                inviteButton.backgroundColor = .white
                inviteButton.layer.borderWidth = 2
                inviteButton.layer.borderColor = UIColor(hexString: "#CCCCCC").cgColor
                inviteButton.cornerRadius(16)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let color = UIColor(hexString: "#D8D8D8")
        let x: CGFloat = 15.0
        let width = UIScreen.main.bounds.width - (x * 2)
        self.contentView.containUnderline(color,
                                          x: x,
                                          width: width)
        
        self.inviteButton.rx.tap.subscribe(onNext: { [unowned self] in
            self.delegate?.cell(self, didTapInvitationButton: self.inviteButton, on: self.index)
        }).disposed(by: bag)
    }
}

class UserApplicationListCell: UITableViewCell {
    @IBOutlet weak var headImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var rejectButton: UIButton!
    
    fileprivate weak var delegate: UserApplicationListCellDelegate?
    private let bag = DisposeBag()
    
    var index: Int = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let color = UIColor(hexString: "#D8D8D8")
        let x: CGFloat = 15.0
        let width = UIScreen.main.bounds.width - (x * 2)
        self.contentView.containUnderline(color,
                                          x: x,
                                          width: width)
        
        self.rejectButton.setTitle(NSLocalizedString("Reject"), for: .normal)
        self.rejectButton.setTitleColor(UIColor(hexString: "#333333"), for: .normal)
        self.rejectButton.layer.borderWidth = 1
        self.rejectButton.layer.borderColor = UIColor(hexString: "#CCCCCC").cgColor
        self.rejectButton.cornerRadius(16)
        self.rejectButton.rx.tap.subscribe(onNext: { [unowned self] in
            self.delegate?.cell(self, didTapRejectButton: self.rejectButton, on: self.index)
        }).disposed(by: bag)
        
        self.acceptButton.setTitle(NSLocalizedString("Accept"), for: .normal)
        self.acceptButton.setTitleColor(UIColor.white, for: .normal)
        self.acceptButton.backgroundColor = UIColor(hexString: "#0088EB")
        self.acceptButton.cornerRadius(16)
        self.acceptButton.rx.tap.subscribe(onNext: { [unowned self] in
            self.delegate?.cell(self, didTapAcceptButton: self.acceptButton, on: self.index)
        }).disposed(by: bag)
    }
}

class UserListViewController: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tabView: TabSelectView!
    @IBOutlet weak var tableViewTop: NSLayoutConstraint!
    @IBOutlet weak var tableViewBottom: NSLayoutConstraint!
    
    enum ShowType {
        case multiHosts, pk, onlyUser, onlyInvitationOfMultiHosts, onlyInvitationOfPK
    }
    
    // Rx
    private let bag = DisposeBag()
    
    // multi hosts
    private var userListSubscribeOnMultiHosts: Disposable?
    private var applyingUserListSubscribeOnMultiHosts: Disposable?
    private var invitingUserListSubscribeOnMultiHosts: Disposable?
    
    let inviteUser = PublishRelay<LiveRole>()
//    let rejectApplicationOfUser = PublishRelay<MultiHostsVM.Application>()
//    let acceptApplicationOfUser = PublishRelay<MultiHostsVM.Application>()
    
    // pk
    private var availableRoomsSubscribeOnPK: Disposable?
    private var applyingRoomsSubscribeOnOnPK: Disposable?
    private var invitingRoomsSubscribeOnOnPK: Disposable?
   
    let inviteRoom = PublishRelay<Room>()
//    let rejectApplicationOfRoom = PublishRelay<Battle>()
//    let accepteApplicationOfRoom = PublishRelay<Battle>()
    
    var showType: ShowType = .onlyUser
    
    var userListVM: LiveUserListVM!
//    var multiHostsVM: MultiHostsVM!
//
//    var pkVM: PKVM!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 48
        tableViewBottom.constant = UIScreen.main.heightOfSafeAreaBottom
        
        tabView.underlineWidth = 68
        tabView.alignment = .center
        tabView.titleSpace = 80
        tabView.underlineHeight = 3
        
        tableView.delegate = nil
        tableView.dataSource = nil
        
        switch showType {
        case .onlyInvitationOfMultiHosts:
            titleLabel.text = NSLocalizedString("Online_User")
            tabView.isHidden = true
            tableViewTop.constant = 0
        case .multiHosts:
            titleLabel.text = NSLocalizedString("Online_User")
            let titles = [NSLocalizedString("All"), NSLocalizedString("ApplicationOfBroadcasting")]
            tabView.update(titles)
        case .onlyInvitationOfPK:
            titleLabel.text = NSLocalizedString("Invite_PK")
            tabView.isHidden = true
            tableViewTop.constant = 0
        case .pk:
            titleLabel.text = NSLocalizedString("Invite_PK")
            let titles = [NSLocalizedString("PK_Invitation"), NSLocalizedString("PK_Application")]
            tabView.update(titles)
        case .onlyUser:
            titleLabel.text = NSLocalizedString("Online_User")
            tabView.isHidden = true
            tableViewTop.constant = 0
        }
        
        let images = Center.shared().centerProvideImagesHelper()
        
        /*
        switch showType {
        case .onlyUser:
            userListVM.refetch(onlyAudience: false)
            userListVM.list.bind(to: tableView.rx.items(cellIdentifier: "UserInvitationListCell",
                                                        cellType: UserInvitationListCell.self)) { [unowned images] (index, user, cell) in
                                                            cell.nameLabel.text = user.info.name
                                                            cell.buttonState = .none
                                                            cell.headImageView.image = images.getHead(index: user.info.imageIndex)
            }.disposed(by: bag)
        case .onlyInvitationOfMultiHosts:
            userListVM.refetch(onlyAudience: true)
            tableViewBindWithUser(userListVM.audienceList).disposed(by: bag)
        case .multiHosts:
            tabView.selectedIndex.subscribe(onNext: { [unowned self] (index) in
                switch index {
                case 0:
                    if let subscribe = self.applyingUserListSubscribeOnMultiHosts {
                        subscribe.dispose()
                    }
                    
                    self.userListSubscribeOnMultiHosts = self.tableViewBindWithUser(self.userListVM.list)
                    self.invitingUserListSubscribeOnMultiHosts = self.invitingUserList(self.multiHostsVM.invitingUserList)
                    
                    self.userListSubscribeOnMultiHosts?.disposed(by: self.bag)
                    self.invitingUserListSubscribeOnMultiHosts?.disposed(by: self.bag)
                    
                    self.userListVM.refetch(onlyAudience: false)
                case 1:
                    if let subscribe = self.userListSubscribeOnMultiHosts {
                        subscribe.dispose()
                    }
                    
                    if let sub = self.invitingUserListSubscribeOnMultiHosts {
                        sub.dispose()
                    }
                    
                    self.applyingUserListSubscribeOnMultiHosts = self.tableViewBindWithApplicationsFromUser()
                    self.applyingUserListSubscribeOnMultiHosts?.disposed(by: self.bag)
                default:
                    break
                }
            }).disposed(by: bag)
        case .onlyInvitationOfPK:
//            self.pkVM.refetch()
            tableViewBindWithAvailableRooms().disposed(by: bag)
        case .pk:
            tabView.selectedIndex.subscribe(onNext: { [unowned self] (index) in
                switch index {
                case 0:
                    if let subscribe = self.applyingRoomsSubscribeOnOnPK {
                        subscribe.dispose()
                    }
                    
                    self.availableRoomsSubscribeOnPK = self.tableViewBindWithAvailableRooms()
                    self.invitingRoomsSubscribeOnOnPK = self.invitingRoomList(self.pkVM.invitingRoomList)
                    
                    self.availableRoomsSubscribeOnPK?.disposed(by: self.bag)
                    self.invitingRoomsSubscribeOnOnPK?.disposed(by: self.bag)
//                    self.pkVM.refetch()
                case 1:
                    if let subscribe = self.availableRoomsSubscribeOnPK {
                        subscribe.dispose()
                    }
                    
                    if let sub = self.invitingRoomsSubscribeOnOnPK {
                        sub.dispose()
                    }
                    
                    self.applyingRoomsSubscribeOnOnPK = self.tableViewBindWithApplicationsFromRoom()
                    self.applyingRoomsSubscribeOnOnPK?.disposed(by: self.bag)
                default:
                    break
                }
            }).disposed(by: bag)
        }
                
        tableView.mj_header = MJRefreshNormalHeader(refreshingBlock: { [unowned self] in
            let endRefetch: Completion = { [unowned self] in
                self.tableView.mj_header?.endRefreshing()
            }
            
            switch self.showType {
            case .onlyUser:
                self.userListVM.refetch(onlyAudience: false, success: endRefetch, fail: endRefetch)
            case .onlyInvitationOfMultiHosts:
                self.userListVM.refetch(onlyAudience: true, success: endRefetch, fail: endRefetch)
            case .multiHosts:
                if self.tabView.selectedIndex.value == 0 {
                    self.userListVM.refetch(onlyAudience: false, success: endRefetch, fail: endRefetch)
                } else {
                    let list = self.multiHostsVM.applyingUserList.value
                    self.multiHostsVM.applyingUserList.accept(list)
                }
            case .onlyInvitationOfPK:
                self.pkVM.refetch(success: endRefetch, fail: endRefetch)
            case .pk:
                if self.tabView.selectedIndex.value == 0 {
                    self.pkVM.refetch(success: endRefetch, fail: endRefetch)
                } else {
                    let list = self.pkVM.applyingRoomList.value
                    self.pkVM.applyingRoomList.accept(list)
                }
            }
        })
        
        tableView.mj_footer = MJRefreshBackFooter(refreshingBlock: { [unowned self] in
            let endRefetch: Completion = { [unowned self] in
                self.tableView.mj_footer?.endRefreshing()
            }
            
            switch self.showType {
            case .onlyUser:
                self.userListVM.fetch(onlyAudience: false, success: endRefetch, fail: endRefetch)
            case .onlyInvitationOfMultiHosts:
                self.userListVM.fetch(onlyAudience: true, success: endRefetch, fail: endRefetch)
            case .multiHosts:
                if self.tabView.selectedIndex.value == 0 {
                    self.userListVM.fetch(onlyAudience: false, success: endRefetch, fail: endRefetch)
                } else {
                    let list = self.multiHostsVM.applyingUserList.value
                    self.multiHostsVM.applyingUserList.accept(list)
                }
            case .onlyInvitationOfPK:
                self.pkVM.fetch(success: endRefetch, fail: endRefetch)
            case .pk:
                if self.tabView.selectedIndex.value == 0 {
                    self.pkVM.fetch(success: endRefetch, fail: endRefetch)
                } else {
                    let list = self.pkVM.applyingRoomList.value
                    self.pkVM.applyingRoomList.accept(list)
                }
            }
        })
         */
    }
}

private extension UserListViewController {
    /*
    func tableViewBindWithUser(_ list: BehaviorRelay<[LiveRole]>) -> Disposable {
        let images = Center.shared().centerProvideImagesHelper()
        
        let subscribe = list.bind(to: tableView
            .rx.items(cellIdentifier: "UserInvitationListCell",
                      cellType: UserInvitationListCell.self)) { [unowned images, unowned self] (index, user, cell) in
                        var buttonState = UserInvitationListCell.InviteButtonState.availableInvite
                        
                        for item in self.multiHostsVM.invitingUserList.value where user.info.userId == item.info.userId {
                            buttonState = .inviting
                            break
                        }
                        
                        if user.type != .audience {
                            buttonState = .none
                        }
                        
                        cell.nameLabel.text = user.info.name
                        cell.buttonState = buttonState
                        cell.headImageView.image = images.getHead(index: user.info.imageIndex)
                        cell.index = index
                        cell.delegate = self
        }
        
        return subscribe
    }
    
    func invitingUserList(_ list: BehaviorRelay<[LiveRole]>) -> Disposable {
        let subscribe = list.subscribe(onNext: { [unowned self] (_) in
            let value = self.userListVM.list.value
            self.userListVM.list.accept(value)
        })
        return subscribe
    }
    
    func tableViewBindWithApplicationsFromUser() -> Disposable {
        let images = Center.shared().centerProvideImagesHelper()
        
        let subscribe = multiHostsVM.applyingUserList.bind(to: tableView
            .rx.items(cellIdentifier: "UserApplicationListCell",
                      cellType: UserApplicationListCell.self)) { [unowned images, unowned self] (index, user, cell) in
                        cell.nameLabel.text = user.info.name
                        cell.headImageView.image = images.getHead(index: user.info.imageIndex)
                        cell.index = index
                        cell.delegate = self
        }
        
        return subscribe
    }
    
    func tableViewBindWithAvailableRooms() -> Disposable {
        let images = Center.shared().centerProvideImagesHelper()
        
        let subscribe = pkVM.availableRooms.bind(to: tableView
            .rx.items(cellIdentifier: "UserInvitationListCell",
                      cellType: UserInvitationListCell.self)) { [unowned images, unowned self] (index, room, cell) in
                        var buttonState = UserInvitationListCell.InviteButtonState.availableInvite
                        
                        for item in self.pkVM.invitingRoomList.value where room.roomId == item.roomId {
                            buttonState = .inviting
                            break
                        }
                        
                        cell.nameLabel.text = room.name
                        cell.buttonState = buttonState
                        cell.headImageView.image = images.getRoom(index: room.imageIndex)
                        cell.index = index
                        cell.delegate = self
        }
        
        return subscribe
    }
    
    func invitingRoomList(_ list: BehaviorRelay<[Room]>) -> Disposable {
        let subscribe = list.subscribe(onNext: { [unowned self] (_) in
            let value = self.pkVM.availableRooms.value
            self.pkVM.availableRooms.accept(value)
        })
        return subscribe
    }
    
    func tableViewBindWithApplicationsFromRoom() -> Disposable {
        let images = Center.shared().centerProvideImagesHelper()
        
        let subscribe = pkVM.applyingRoomList.bind(to: tableView
            .rx.items(cellIdentifier: "UserApplicationListCell",
                      cellType: UserApplicationListCell.self)) { [unowned images, unowned self] (index, room, cell) in
                        cell.nameLabel.text = room.name
                        cell.headImageView.image = images.getRoom(index: room.imageIndex)
                        cell.index = index
                        cell.delegate = self
        }
        
        return subscribe
    }
 */
}

extension UserListViewController: UserInvitationListCellDelegate {
    
    func cell(_ cell: UserInvitationListCell, didTapInvitationButton: UIButton, on index: Int) {
        /*
        switch showType {
        case .multiHosts:
            let user = userListVM.list.value[index]
            inviteUser.accept(user)
        case .onlyInvitationOfMultiHosts:
            let user = userListVM.audienceList.value[index]
            inviteUser.accept(user)
        case .pk, .onlyInvitationOfPK:
            let room = pkVM.availableRooms.value[index]
            inviteRoom.accept(room)
        default:
            break
        }
 */
    }
}

extension UserListViewController: UserApplicationListCellDelegate {
    
    func cell(_ cell: UserApplicationListCell, didTapAcceptButton: UIButton, on index: Int) {
        /*
        switch showType {
        case .multiHosts:
            let user = multiHostsVM.applyingUserList.value[index]
            guard let applicationList = multiHostsVM.applicationQueue.list as? [MultiHostsVM.Application] else {
                return
            }
            
            let application = applicationList.first { (item) -> Bool in
                return item.initiator.info.userId == user.info.userId
            }
            
            guard let tApplication = application else {
                return
            }
            
            acceptApplicationOfUser.accept(tApplication)
        case .pk:
            let room = pkVM.applyingRoomList.value[index]
            guard let applicationList = pkVM.applicationQueue.list as? [Battle] else {
                return
            }
            
            let application = applicationList.first { (item) -> Bool in
                return item.initatorRoom.roomId == room.roomId
            }
            
            guard let tApplication = application else {
                return
            }
            
            accepteApplicationOfRoom.accept(tApplication)
        default:
            break
        }
         */
    }
    
    func cell(_ cell: UserApplicationListCell, didTapRejectButton: UIButton, on index: Int) {
        /*
        switch showType {
        case .multiHosts:
            let user = multiHostsVM.applyingUserList.value[index]
            guard let applicationList = multiHostsVM.applicationQueue.list as? [MultiHostsVM.Application] else {
                return
            }
            
            let application = applicationList.first { (item) -> Bool in
                return item.initiator.info.userId == user.info.userId
            }
            
            guard let tApplication = application else {
                return
            }
            
            rejectApplicationOfUser.accept(tApplication)
        case .pk:
            let room = pkVM.applyingRoomList.value[index]
            guard let applicationList = pkVM.applicationQueue.list as? [Battle] else {
                return
            }
            
            let application = applicationList.first { (item) -> Bool in
                return item.initatorRoom.roomId == room.roomId
            }
            
            guard let tApplication = application else {
                return
            }
            
            rejectApplicationOfRoom.accept(tApplication)
        default:
            break
        }
 */
    }
}
