//
//  CreateLiveViewController.swift
//  AgoraLive
//
//  Created by CavanSu on 2020/2/26.
//  Copyright © 2020 Agora. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxRelay

struct RandomName {
    static var list: [String] {
        var array: [String]
        
        if DeviceAssistant.Language.isChinese {
            array = ["陌上花开等你来", "天天爱你", "我爱你们",
                     "有人可以", "风情万种", "强势归来",
                     "哈哈哈", "聊聊", "美人舞江山",
                     "最美的回忆", "遇见你", "最长情的告白",
                     "全力以赴", "简单点", "早上好",
                     "春风十里不如你"]
        } else {
            array = ["Cheer", "Vibe", "Devine",
                     "Duo", "Ablaze", "Amaze",
                     "Harmony", "Verse", "Vigilant",
                     "Contender", "Vista", "Wander",
                     "Collections", "Moon", "Boho",
                     "Everest"]
        }
        return array
    }
}

class CreateLiveViewController: MaskViewController {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var nameBgView: UIView!
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var backgroundButton: UIButton!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var randomButton: UIButton!
    
    private let nameLimit: UInt = 25
    
    var liveType: LiveType = .chatRoom
    var selectedImageIndex = 0
    var tempSession: LiveSession?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()
        randomName()
        
        switch liveType {
        case .chatRoom:
           break
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showLimitToast()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let segueId = segue.identifier,
            let liveSession = sender as? LiveSession else {
            return
        }
        
        switch segueId {
        case "ChatRoomViewController":
            let vc = segue.destination as! ChatRoomViewController
            vc.liveSession = liveSession
            vc.backgroundVM = RoomBackgroundVM(room: liveSession.room.value)
            vc.giftVM = GiftVM(room: liveSession.room.value)
            
            vc.coHostingVM = CoHostingVM(room: liveSession.room.value)
            vc.seatsVM = LiveSeatsVM(room: liveSession.room.value)
        default:
            break
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.nameTextField.endEditing(true)
    }
}

private extension CreateLiveViewController {
    func updateViews() {
        backgroundImageView.image = Center.shared().centerProvideImagesHelper().roomBackgrounds.first
        
        nameTextField.delegate = self
        nameLabel.text = CreateLiveLocalizable.channelName()
        startButton.setTitle(CreateLiveLocalizable.startButton(),
                             for: .normal)
        
        nameTextField.rx.controlEvent([.editingDidEndOnExit])
            .subscribe(onNext: { [unowned self] in
                self.view.endEditing(true)
        }).disposed(by: bag)
        
        backButton.rx.tap.subscribe(onNext: { [unowned self] in
            self.close()
        }).disposed(by: bag)
        
        randomButton.rx.tap.subscribe(onNext: { [unowned self] in
            self.randomName()
        }).disposed(by: bag)
        
        backgroundButton.rx.tap.subscribe(onNext: { [unowned self] in
            self.presentBackground()
        }).disposed(by: bag)
        
        startButton.rx.tap.subscribe(onNext: { [unowned self] in
            guard let title = self.nameTextField.text, title.count > 0 else {
                self.showTextToast(text: CreateLiveLocalizable.channelNameCannotBebBlank())
                return
            }
            
            self.startLivingWithName(title)
        }).disposed(by: bag)
    }
    
    func close() {
        self.navigationController?.dismiss(animated: true,
                                           completion: nil)
    }
    
    func randomName() {
        guard let name = RandomName.list.randomElement() else {
            return
        }
        nameTextField.text = name
    }
    
    func showLimitToast() {
        let mainScreen = UIScreen.main
        let y = mainScreen.bounds.height - mainScreen.heightOfSafeAreaBottom - 38 - 15 - 150
        let view = TagImageTextCloseToast(frame: CGRect(x: 15,
                                                        y: y,
                                                        width: 181,
                                                        height: 44.0),
                                          filletRadius: 8)
        
        view.labelSize = CGSize(width: UIScreen.main.bounds.width - 30, height: 0)
        view.text = NSLocalizedString("Limit_Toast")
        view.tagImage = UIImage(named: "icon-yellow-caution")
        self.showToastView(view, duration: 5.0)
        
        view.closeButton.rx.tap.subscribe(onNext: { [unowned self] in
            self.toastView?.removeFromSuperview()
        }).disposed(by: bag)
    }
    
    func presentBackground() {
        showMaskView()
        
        let vc = UIStoryboard.initViewController(of: "ImageSelectViewController",
                                                 class: ImageSelectViewController.self,
                                                 on: "Popover")
        
        let presenetedHeight: CGFloat = 455 + UIScreen.main.heightOfSafeAreaBottom
        let y = UIScreen.main.bounds.height - presenetedHeight
        let presentedFrame = CGRect(x: 0,
                                    y: y,
                                    width: UIScreen.main.bounds.width,
                                    height: presenetedHeight)
        
        self.presentChild(vc,
                          animated: true,
                          presentedFrame: presentedFrame)
        
        vc.selectIndex.accept(selectedImageIndex)
        vc.selectImage.bind(to: backgroundImageView.rx.image).disposed(by: vc.bag)
        vc.selectIndex.subscribe(onNext: { [unowned self] (index) in
            self.selectedImageIndex = index
        }).disposed(by: vc.bag)
    }
}

private extension CreateLiveViewController {
    func startLivingWithName(_ name: String) {
        self.showHUD()
        
        LiveSession.create(roomName: name,
                           backgroundIndex: selectedImageIndex,
                           success: { [unowned self] (session) in
                            self.joinLiving(session: session)
                           }) { [unowned self] (error) in
            self.hiddenHUD()
            
            if error.code == nil {
                self.showAlert(message: NetworkLocalizable.lostConnectionRetry())
            } else {
                self.showAlert(message: CreateLiveLocalizable.createChannelFail())
            }
        }
    }
    
    func joinLiving(session: LiveSession) {
        self.showHUD()
        
        tempSession = session
        
        session.join(success: { [unowned self] (session) in
            self.hiddenHUD()
            
            switch session.type {
            case .chatRoom:
                self.performSegue(withIdentifier: "ChatRoomViewController",
                                  sender: session)
            }
        }) { [unowned self] (error) in
            self.hiddenHUD()
            
            if error.code == nil {
                self.showAlert(message: NetworkLocalizable.lostConnectionRetry())
            } else {
                self.showAlert(message: CreateLiveLocalizable.joinChannelFail())
            }
        }
    }
}

extension CreateLiveViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if range.length == 1 && string.count == 0 {
            return true
        } else if let text = textField.text, text.count >= nameLimit {
            self.showTextToast(text: CreateLiveLocalizable.channelNameLengthLimit(nameLimit))
            return false
        } else {
            return true
        }
    }
}

fileprivate class TagImageTextCloseToast: TagImageTextToast {
    private(set) var closeButton = UIButton(frame: CGRect.zero)
    
    override func initViews() {
        super.initViews()
        closeButton.setImage(UIImage(named: "icon-close-gray"), for: .normal)
        addSubview(closeButton)
        
        contentEdgeInsets = UIEdgeInsets(top: 15.0,
                                         left: 15.0,
                                         bottom: 15.0,
                                         right: 24.0)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let width: CGFloat = 23.0
        let height: CGFloat = width
        closeButton.frame = CGRect(x: bounds.width - width,
                                   y: 0,
                                   width: width,
                                   height: height)
        
    }
}
