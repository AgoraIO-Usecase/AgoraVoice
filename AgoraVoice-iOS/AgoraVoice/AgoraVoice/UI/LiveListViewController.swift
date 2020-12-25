//
//  LiveListViewController.swift
//  AgoraVoice
//
//  Created by CavanSu on 2020/9/2.
//  Copyright © 2020 Agora. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import MJRefresh

class LiveListPlaceholderView: RxView {
    enum PlaceholderType {
        case noInternet, noData, noRoom
        
        var image: UIImage {
            switch self {
            case .noInternet: return UIImage(named: "pic-empty")!
            case .noData:     return UIImage(named: "pic-No signal")!
            case .noRoom:     return UIImage(named: "pic-No data")!
            }
        }
        
        var description: String {
            switch self {
            case .noInternet: return NSLocalizedString("Lost_Connection")
            case .noData:     return NSLocalizedString("No_Data_Please_Try_Again_Later")
            case .noRoom:     return NSLocalizedString("Create_A_Room")
            }
        }
    }
    
    @IBOutlet weak var tagImageView: UIImageView!
    @IBOutlet weak var label: UILabel!
    
    var type: PlaceholderType = .noData {
        didSet {
            tagImageView.image = type.image
            label.text = type.description
        }
    }
    
    let tap = PublishRelay<()>()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        type = .noData
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        tap.accept(())
    }
}

class RoomCell: UICollectionViewCell {
    @IBOutlet weak var roomImageView: UIImageView!
    @IBOutlet weak var roomNameLabel: UILabel!
    @IBOutlet weak var roomPersonCountView: IconTextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        roomPersonCountView.offsetLeftX = -4.0
        roomPersonCountView.offsetRightX = 4.0
        roomPersonCountView.imageView.image = UIImage(named: "icon-audience")
        roomPersonCountView.label.textColor = UIColor.white
        roomPersonCountView.label.font = UIFont.systemFont(ofSize: 10)
        roomPersonCountView.backgroundColor = .clear
        contentView.cornerRadius(7)
    }
}

class LiveListViewController: MaskViewController {
    @IBOutlet weak var placeHolderView: LiveListPlaceholderView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var createButton: UIButton!
    
    private let listVM = LiveListVM()
    private let monitor = NetworkMonitor(host: "www.apple.com")
    private var timer: Timer?
    private var tempLiveSession: LiveSession?
    
    var type: LiveType!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let navigation = self.navigationController as? CSNavigationController else {
            assert(false)
            return
        }
        
        navigation.navigationBar.isHidden = false
        
        perMinuterRefresh()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString("Chat_Room")
        updateViews()
        subscribeList()
        netMonitor()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        cancelScheduelRefresh()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let segueId = segue.identifier else {
            return
        }
        
        switch segueId {
        case "CreateLiveNavigation":
            guard let type = sender as? LiveType,
                let navi = segue.destination as? CSNavigationController,
                let vc = navi.viewControllers.first as? CreateLiveViewController else {
                    assert(false)
                    return
            }
            navi.statusBarStyle = .lightContent
            vc.liveType = type
        case "ChatRoomViewController":
            guard let vc = segue.destination as? ChatRoomViewController,
                let session = sender as? LiveSession else {
                    assert(false)
                    return
            }
            vc.liveSession = session
            vc.backgroundVM = RoomBackgroundVM(room: session.room.value)
            vc.giftVM = GiftVM(room: session.room.value)
            
            vc.multiHostsVM = MultiHostsVM(room: session.room.value)
            vc.seatsVM = LiveSeatsVM(room: session.room.value)
        default:
            break
        }
    }
}

private extension LiveListViewController {
    func updateViews() {
        let screenWidth = UIScreen.main.bounds.width
        let itemWidth = (screenWidth - (15 * 3)) * 0.5
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: itemWidth,
                                 height: itemWidth)
        
        collectionView.contentInset = UIEdgeInsets(top: 0,
                                                   left: 15,
                                                   bottom: 0,
                                                   right: 15)
        
        collectionView.setCollectionViewLayout(layout, animated: true)
        
        createButton.layer.shadowOpacity = 0.3
        createButton.layer.shadowOffset = CGSize(width: 0, height: 3)
        createButton.layer.shadowColor = UIColor(hexString: "#BD3070").cgColor
        
        createButton.rx.tap.subscribe(onNext: { [unowned self] in
            self.performSegue(withIdentifier: "CreateLiveNavigation",
                              sender: self.listVM.presentingType)
        }).disposed(by: bag)
    }
    
    func subscribeList() {
        placeHolderView.tap.subscribe(onNext: { [unowned self] in
            self.roomListRefresh(true)
        }).disposed(by: bag)
        
        listVM.presentingList.map { (list) -> Bool in
            return list.count > 0 ? true : false
        }.bind(to: placeHolderView.rx.isHidden).disposed(by: bag)
        
        listVM.presentingList
            .bind(to: collectionView.rx.items(cellIdentifier: "RoomCell",
                                              cellType: RoomCell.self)) { index, item, cell in
                                                cell.roomNameLabel.text = item.name
                                                cell.roomPersonCountView.label.text = "\(item.personCount)"
                                                cell.roomImageView.image = item.owner.info.originImage
        }.disposed(by: bag)
        
        collectionView.mj_header = MJRefreshNormalHeader(refreshingBlock: { [unowned self] in
            self.listVM.refetch(success: { [unowned self] in
                self.collectionView.mj_header?.endRefreshing()
            }) { [unowned self] in // fail
                self.collectionView.mj_header?.endRefreshing()
            }
        })
        
        collectionView.mj_footer = MJRefreshBackFooter(refreshingBlock: { [unowned self] in
            self.listVM.fetch(success: { [unowned self] in
                self.collectionView.mj_footer?.endRefreshing()
            }) { [unowned self] in // fail
                self.collectionView.mj_footer?.endRefreshing()
            }
        })
        
        collectionView.rx.willBeginDragging.subscribe(onNext: { [unowned self] in
            self.cancelScheduelRefresh()
        }).disposed(by: bag)
        
        collectionView.rx.didEndDragging.subscribe(onNext: { [unowned self] (done) in
            if done {
                self.perMinuterRefresh()
            }
        }).disposed(by: bag)
        
        collectionView.rx.modelSelected(Room.self).subscribe(onNext: { [unowned self] (room) in
            self.showHUD()
            
            let local = Center.shared().centerProvideLocalUser().info.value
            var localType: LiveRoleType
            
            if room.owner.info == local {
                localType = .owner
            } else {
                localType = .audience
            }
            
            let session = LiveSession(room: room, role: localType)
            self.tempLiveSession = session
            
            session.join(success: { [unowned self] (session) in
                self.hiddenHUD()
                self.performSegue(withIdentifier: "ChatRoomViewController", sender: session)
            }) { [unowned self] (error) in
                self.hiddenHUD()
                
                if let tError = error as? AGEError,
                   let code = tError.code,
                   code == 20403001 {
                    self.showTextToast(text: NSLocalizedString("Join_Fail"))
                } else {
                    self.showTextToast(text: "join live fail")
                }
                
                self.roomListRefresh()
            }
        }).disposed(by: bag)
    }
    
    func netMonitor() {
        monitor.action(.on)
        monitor.connect.subscribe(onNext: { [unowned self] (status) in
            switch status {
            case .notReachable: self.placeHolderView.type = .noInternet
            case .reachable:    self.placeHolderView.type = .noRoom
            default: break
            }
        }).disposed(by: bag)
    }
    
    func perMinuterRefresh() {
        guard timer == nil else {
            return
        }
        
        timer = Timer(fireAt: Date(timeIntervalSinceNow: 60.0),
                      interval: 60.0,
                      target: self,
                      selector: #selector(roomListRefresh),
                      userInfo: nil,
                      repeats: true)
        RunLoop.main.add(timer!, forMode: .common)
        timer?.fire()
    }
    
    @objc func roomListRefresh(_ hasHUD: Bool = false) {
        guard !self.isShowingHUD() else {
            return
        }
        
        if let isRefreshing = self.collectionView.mj_header?.isRefreshing,
            isRefreshing {
            return
        }
        
        let end: Completion = { [unowned self] in
            if hasHUD {
                self.hiddenHUD()
            }
        }

        if hasHUD {
            self.showHUD()
        }
        
        listVM.refetch(success: end, fail: end)
    }
    
    func cancelScheduelRefresh() {
        timer?.invalidate()
        timer = nil
    }
}
