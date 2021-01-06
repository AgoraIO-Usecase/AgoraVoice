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
                inviteButton.setTitleColor(UIColor(hexString: "#161D27"), for: .normal)
                inviteButton.backgroundColor = UIColor(hexString: "#556272")
                inviteButton.cornerRadius(16)
                inviteButton.layer.borderWidth = 0
            case .availableInvite:
                inviteButton.isHidden = false
                inviteButton.isEnabled = true
                inviteButton.setTitle(NSLocalizedString("Invite"), for: .normal)
                inviteButton.setTitleColor(UIColor(hexString: "#0088EB"), for: .normal)
                inviteButton.backgroundColor = UIColor(hexString: "#161D27")
                inviteButton.cornerRadius(16)
                inviteButton.layer.borderWidth = 2
                inviteButton.layer.borderColor = UIColor(hexString: "#556272").cgColor
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
        self.rejectButton.setTitleColor(UIColor(hexString: "#0088EB"), for: .normal)
        self.rejectButton.layer.borderWidth = 1
        self.rejectButton.layer.borderColor = UIColor(hexString: "#556272").cgColor
        self.rejectButton.backgroundColor = UIColor(hexString: "#161D27")
        self.rejectButton.cornerRadius(16)
        self.rejectButton.rx.tap.subscribe(onNext: { [unowned self] in
            self.delegate?.cell(self, didTapRejectButton: self.rejectButton, on: self.index)
        }).disposed(by: bag)
        
        self.acceptButton.setTitle(NSLocalizedString("Accept"), for: .normal)
        self.acceptButton.setTitleColor(.white, for: .normal)
        self.acceptButton.backgroundColor = UIColor(hexString: "#0088EB")
        self.acceptButton.cornerRadius(16)
        self.acceptButton.rx.tap.subscribe(onNext: { [unowned self] in
            self.delegate?.cell(self, didTapAcceptButton: self.acceptButton, on: self.index)
        }).disposed(by: bag)
    }
}

class UserListViewController: RxViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tabView: TabSelectView!
    @IBOutlet weak var tableViewTop: NSLayoutConstraint!
    @IBOutlet weak var tableViewBottom: NSLayoutConstraint!
    
    enum ShowType {
        case multiHosts, onlyUser, onlyInvitationOfMultiHosts
    }
    
    // multi hosts
    private var userListSubscribeOnMultiHosts: Disposable?
    private var applyingUserListSubscribeOnMultiHosts: Disposable?
    private var invitingUserListSubscribeOnMultiHosts: Disposable?
    
    let inviteUser = PublishRelay<LiveRole>()
    let rejectApplicationOfUser = PublishRelay<MultiHostsVM.Application>()
    let acceptApplicationOfUser = PublishRelay<MultiHostsVM.Application>()
    
    var showType: ShowType = .onlyUser
    
    var userListVM: LiveUserListVM!
    var multiHostsVM: MultiHostsVM!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 54
        tableViewBottom.constant = UIScreen.main.heightOfSafeAreaBottom
        
        tabView.titleTopSpace = 14
        tabView.underlineWidth = 68
        tabView.alignment = .center
        tabView.titleSpace = 80
        tabView.underlineHeight = 3
        
        tabView.selectedTitle = TabSelectView.TitleProperty(color: UIColor(hexString: "#EEEEEE"),
                                                            font: UIFont.systemFont(ofSize: 14, weight: .medium))
        
        tabView.unselectedTitle = TabSelectView.TitleProperty(color: UIColor(hexString: "#9BA2AB"),
                                                              font: UIFont.systemFont(ofSize: 14))
        tabView.backgroundColor = UIColor(hexString: "#0A0F17")
        
        tableView.delegate = nil
        tableView.dataSource = nil
        
        titleLabel.text = LiveVCLocalizable.onlineUser()
        
        switch showType {
        case .onlyInvitationOfMultiHosts:
            tabView.isHidden = true
            tableViewTop.constant = 0
        case .multiHosts:
            let titles = [NSLocalizedString("All"), ChatRoomLocalizable.applicationList()]
            tabView.update(titles)
        case .onlyUser:
            tabView.isHidden = true
            tableViewTop.constant = 0
        }
        
        switch showType {
        case .onlyUser:
            userListVM.list.bind(to: tableView.rx.items(cellIdentifier: "UserInvitationListCell",
                                                        cellType: UserInvitationListCell.self)) { (index, user, cell) in
                                                            cell.nameLabel.text = user.info.name
                                                            cell.buttonState = .none
                                                            cell.headImageView.image = user.info.image
            }.disposed(by: bag)
        case .onlyInvitationOfMultiHosts:
            tableViewBindWithUser(userListVM.audienceList).disposed(by: bag)
            multiHostsVM.invitationByRejected.map { [unowned self] (_) -> [LiveRole] in
                return self.userListVM.audienceList.value
            }.bind(to: userListVM.audienceList).disposed(by: bag)
            multiHostsVM.invitationTimeout.map { [unowned self] (_) -> [LiveRole] in
                return self.userListVM.audienceList.value
            }.bind(to: userListVM.audienceList).disposed(by: bag)
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
        }
    }
}

private extension UserListViewController {
    func tableViewBindWithUser(_ list: BehaviorRelay<[LiveRole]>) -> Disposable {
        let subscribe = list.bind(to: tableView
            .rx.items(cellIdentifier: "UserInvitationListCell",
                      cellType: UserInvitationListCell.self)) { [unowned self] (index, user, cell) in
                        var buttonState = UserInvitationListCell.InviteButtonState.availableInvite
                        
                        if self.showType == .multiHosts {
                            buttonState = .none
                        } else {
                            for item in self.multiHostsVM.invitingUserList.value where user.info.userId == item.info.userId {
                                buttonState = .inviting
                                break
                            }
                        }
                        
                        if user.type != .audience {
                            buttonState = .none
                        }
                        
                        cell.nameLabel.text = user.info.name
                        cell.buttonState = buttonState
                        cell.headImageView.image = user.info.image
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
        let subscribe = multiHostsVM.applyingUserList.bind(to: tableView
            .rx.items(cellIdentifier: "UserApplicationListCell",
                      cellType: UserApplicationListCell.self)) { [unowned self] (index, user, cell) in
                        cell.nameLabel.text = user.info.name
                        cell.headImageView.image = user.info.image
                        cell.index = index
                        cell.delegate = self
        }
        
        return subscribe
    }
}

extension UserListViewController: UserInvitationListCellDelegate {
    func cell(_ cell: UserInvitationListCell, didTapInvitationButton: UIButton, on index: Int) {
        switch showType {
        case .multiHosts:
            let user = userListVM.list.value[index]
            inviteUser.accept(user)
        case .onlyInvitationOfMultiHosts:
            let user = userListVM.audienceList.value[index]
            inviteUser.accept(user)
        default:
            break
        }
    }
}

extension UserListViewController: UserApplicationListCellDelegate {
    func cell(_ cell: UserApplicationListCell, didTapAcceptButton: UIButton, on index: Int) {
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
        default:
            break
        }
    }
    
    func cell(_ cell: UserApplicationListCell, didTapRejectButton: UIButton, on index: Int) {
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
        default:
            break
        }
    }
}
