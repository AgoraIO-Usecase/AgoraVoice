//
//  ChatRoomViewController.swift
//  AgoraVoice
//
//  Created by CavanSu on 2020/9/3.
//  Copyright © 2020 Agora. All rights reserved.
//

import UIKit

class ChatRoomViewController: MaskViewController, LiveViewController {
    @IBOutlet weak var seatViewHeight: NSLayoutConstraint!
    
    
    // LiveViewController
    var liveSession: LiveSession!
    var tintColor = UIColor(hexString: "#000000-0.3")
    
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
    var userListVM: LiveUserListVM!
    var giftVM: GiftVM!
    var musicVM = MusicVM()
    var chatVM = ChatVM()
    var deviceVM = MediaDeviceVM()
    var monitor = NetworkMonitor(host: "www.apple.com")
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()
        calculateSeatViewHeight()
        
        users()
        gift()
        chatList()
        musicList()
        netMonitor()
        bottomTools()
        chatInput()
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
        case "BottomToolsViewController":
            let vc = segue.destination as! BottomToolsViewController
            vc.liveType = .chatRoom
            vc.perspective = .owner
            vc.tintColor = tintColor
            bottomToolsVC = vc
        default:
            break
        }
    }
}

private extension ChatRoomViewController {
    func updateViews() {
        backgroundImageView.image = Center.shared().centerProvideImagesHelper().roomBackgrounds.first
        personCountView.backgroundColor = tintColor
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
        vc.commands.accept(seatCommands.commands)
        vc.selectedCommand.subscribe(onNext: { [unowned self] (command) in
            self.hiddenMaskView()
        }).disposed(by: vc.bag)
        vc.view.cornerRadius(10)
        vc.view.layer.masksToBounds = true
        
        let height: CGFloat = CGFloat(seatCommands.commands.count * 48 + 50) + UIScreen.main.heightOfSafeAreaBottom
        let y: CGFloat = UIScreen.main.bounds.height - height
        let frame = CGRect(x: 0, y: y, width: UIScreen.main.bounds.width, height: height)
        
        presentChild(vc, animated: true, presentedFrame: frame)
    }
}
