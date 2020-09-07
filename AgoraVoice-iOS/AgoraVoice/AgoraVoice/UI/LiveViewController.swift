//
//  LiveViewController.swift
//  AgoraLive
//
//  Created by CavanSu on 2020/4/10.
//  Copyright © 2020 Agora. All rights reserved.
//

import UIKit
import RxSwift
import RxRelay
import MJRefresh

//enum HostCount {
//    case single(LiveRole), multi([LiveRole])
//
//    var isSingle: Bool {
//        switch self {
//        case .single: return true
//        case .multi:  return false
//        }
//    }
//}

protocol LiveViewController where Self: MaskViewController {
    var liveType: LiveType {get set}
    var tintColor: UIColor {get set}
    
    // ViewController
    var giftAudienceVC: GiftAudienceViewController? {get set}
    var bottomToolsVC: BottomToolsViewController? {get set}
    var chatVC: ChatViewController? {get set}
    
    // View
    var backgroundImageView: UIImageView! {get set}
    var personCountView: RemindIconTextView! {get set}
    var chatInputView: ChatInputView {get set}
    
    // View Model
    var userListVM: LiveUserListVM! {get set}
    var giftVM: GiftVM! {get set}
    var musicVM: MusicVM {get set}
    var chatVM: ChatVM {get set}
    var deviceVM: MediaDeviceVM {get set}
    var monitor: NetworkMonitor {get set}
}

// MARK: VM
extension LiveViewController {
    // MARK: - Audience
    func users() {
        personCountView.backgroundColor = tintColor
        personCountView.offsetLeftX = -4.0
        personCountView.offsetRightX = 4.0
        personCountView.imageView.image = UIImage(named: "icon-audience")
        personCountView.label.textColor = UIColor.white
        personCountView.label.font = UIFont.systemFont(ofSize: 10)
        
        personCountView.rx.controlEvent(.touchUpInside).subscribe(onNext: { [unowned self] in
//            guard let session = Center.shared().liveSession,
//                session.type != .shopping else {
//                return
//            }
            self.presentUserList(type: .onlyUser)
        }).disposed(by: bag)
        
        if let giftAudienceVC = self.giftAudienceVC {
            userListVM.giftList.bind(to: giftAudienceVC.list).disposed(by: bag)
        }
        
        userListVM?.total.subscribe(onNext: { [unowned self] (total) in
            self.personCountView.label.text = "\(total)"
        }).disposed(by: bag)
        
        userListVM?.join.subscribe(onNext: { [unowned self] (list) in
            let chats = list.map { (user) -> Chat in
                let chat = Chat(name: user.info.name,
                                text: " \(NSLocalizedString("Join_Live_Room"))",
                          widthLimit: self.chatVM.chatWidthLimit)
                return chat
            }

            self.chatVM.newMessages(chats)
        }).disposed(by: bag)

        userListVM?.left.subscribe(onNext: { [unowned self] (list) in
            let chats = list.map { (user) -> Chat in
                let chat = Chat(name: user.info.name,
                                text: " \(NSLocalizedString("Leave_Live_Room"))",
                          widthLimit: self.chatVM.chatWidthLimit)
                return chat
            }

            self.chatVM.newMessages(chats)
        }).disposed(by: bag)
    }
    
    // MARK: - Chat List
    func chatList() {
        if let chatVC = self.chatVC {
            chatVM.list.bind(to: chatVC.list).disposed(by: bag)
        }
    }
    
    // MARK: - Gift
    func gift() {
        giftVM?.received.subscribe(onNext: { [unowned self] (userGift) in
            let chat = Chat(name: userGift.userName,
                            text: " " + NSLocalizedString("Give_Owner_A_Gift"),
                            image: userGift.gift.image, widthLimit: self.chatVM.chatWidthLimit)
            self.chatVM.newMessages([chat])
            
            guard userGift.gift.hasGIF else {
                return
            }
            
            self.presentGIF(gift: userGift.gift)
        }).disposed(by: bag)
    }
    
    // MARK: - Music List
    func musicList() {
        musicVM.refetch()
        musicVM.isPlaying.subscribe(onNext: { [unowned self] (isPlaying) in
//            self.bottomToolsVC?.musicButton.isSelected = isPlaying
        }).disposed(by: bag)
    }
    
    // MARK: - Net Monitor
    func netMonitor() {
        monitor.action(.on)
        monitor.connect.subscribe(onNext: { [unowned self] (status) in
            switch status {
            case .notReachable:
                let view = TextToast(frame: CGRect(x: 0, y: 200, width: 0, height: 44), filletRadius: 8)
                view.text = NSLocalizedString("Lost_Connection_Retry")
                self.showToastView(view, duration: 2.0)
            case .reachable(let type):
                guard type == .wwan else {
                    return
                }
                let view = TextToast(frame: CGRect(x: 0, y: 200, width: 0, height: 44), filletRadius: 8)
                view.text = NSLocalizedString("Use_Cellular_Data")
                self.showToastView(view, duration: 2.0)
            default:
                break
            }
        }).disposed(by: bag)
    }
    
    // MARK: - Live Session
//    func liveSession(_ session: LiveSession) {
//        session.end.subscribe(onNext: { [weak self] (_) in
//            guard let strongSelf = self else {
//                return
//            }
//
//            strongSelf.leave()
//
//            if let vc = strongSelf.presentedViewController {
//                vc.dismiss(animated: false, completion: nil)
//            }
//
//            strongSelf.showAlert(NSLocalizedString("Live_End")) { [weak self] (_) in
//                guard let strongSelf = self else {
//                    return
//                }
//                strongSelf.dimissSelf()
//            }
//        }).disposed(by: bag)
//    }
//
//    func liveRole(_ session: LiveSession) {
//        let role = session.role
//
//        role.subscribe(onNext: { [unowned self] (local) in
//            self.deviceVM.camera = (local.type == .audience) ? .off : .on
//            self.deviceVM.mic = (local.type == .audience) ? .off : .on
//            self.hiddenMaskView()
//            self.bottomToolsVC?.perspective = local.type
//        }).disposed(by: bag)
//    }
}

// MARK: - View
extension LiveViewController {
    // MARK: - Bottom Tools
    func bottomTools() {
        guard let bottomToolsVC = self.bottomToolsVC else {
            assert(false)
            return
        }
        
        bottomToolsVC.liveType = liveType
        bottomToolsVC.tintColor = tintColor
        
        bottomToolsVC.giftButton.rx.tap.subscribe(onNext: { [unowned self] in
            self.presentGiftList()
        }).disposed(by: bag)
        
        bottomToolsVC.extensionButton.rx.tap.subscribe(onNext: { [unowned self] in
            self.presentExtensionFunctions()
        }).disposed(by: bag)
        
        bottomToolsVC.micButton.rx.tap.subscribe(onNext: { [unowned self] in
            self.bottomToolsVC?.micButton.isSelected.toggle()
            //            self.deviceVM.mic = extensionVC.micButton.isSelected ? .off : .on
            //
            //            guard let session = Center.shared().liveSession else {
            //                assert(false)
            //                return
            //            }
            //
            //            let role = session.role.value
            //            var permission = role.permission
            //            switch self.deviceVM.mic {
            //            case .on:
            //                permission.insert(.mic)
            //            case .off:
            //                permission.remove(.mic)
            //            }
            //
            //            role.updateLocal(permission: permission, of: session.room.roomId)
        }).disposed(by: bag)
        
        bottomToolsVC.belcantoButton.rx.tap.subscribe(onNext: { [unowned self] in
            self.presentAudioEffect(type: .belCanto)
        }).disposed(by: bag)
        
        bottomToolsVC.soundEffectButton.rx.tap.subscribe(onNext: { [unowned self] in
            self.presentAudioEffect(type: .soundEffect)
        }).disposed(by: bag)
    }
    
    // MARK: - Chat Input
    func chatInput() {
        chatInputView.textView.rx.controlEvent([.editingDidEndOnExit])
            .subscribe(onNext: { [unowned self] in
                self.hiddenMaskView()
                self.view.endEditing(true)
                
//                guard let session = Center.shared().liveSession else {
//                        assert(false)
//                        return
//                }
//
//                let role = session.role.value
//                if let text = self.chatInputView.textView.text, text.count > 0 {
//                    self.chatInputView.textView.text = nil
//                    self.chatVM.sendMessage(text, local: role.info) { [weak self] (_) in
//                         self?.showAlert(message: NSLocalizedString("Send_Chat_Message_Fail"))
//                    }
//                }
        }).disposed(by: bag)
        
        NotificationCenter.default.observerKeyboard { [weak self] (info: (endFrame: CGRect, duration: Double)) in
            guard let strongSelf = self else {
                return
            }
            
            let isShow = info.endFrame.minY < UIScreen.main.bounds.height ? true : false
            
            if isShow {
                strongSelf.showMaskView(color: UIColor.clear) { [weak self] in
                    guard let strongSelf = self else {
                        return
                    }
                    strongSelf.hiddenMaskView()
                    if !strongSelf.chatInputView.isHidden {
                        strongSelf.view.endEditing(true)
                    }
                    strongSelf.view.endEditing(true)
                }
                
                strongSelf.view.addSubview(strongSelf.chatInputView)
                strongSelf.chatInputView.textView.becomeFirstResponder()
                strongSelf.chatInputView.showAbove(frame: info.endFrame,
                                                   duration: info.duration) { (done) in
                                                    
                }
            } else {
                strongSelf.chatInputView.hidden(duration: info.duration) { [weak self] (done) in
                    guard let strongSelf = self else {
                        return
                    }
                    strongSelf.chatInputView.removeFromSuperview()
                }
            }
        }
    }
}

extension LiveViewController {
    // MARK: - User List
    func presentUserList(type: CVUserListViewController.ShowType) {
        self.showMaskView(color: UIColor.clear)
        
        let vc = UIStoryboard.initViewController(of: "CVUserListViewController",
                                                 class: CVUserListViewController.self,
                                                 on: "Popover")
        
        vc.userListVM = userListVM
        vc.showType = type
        vc.view.cornerRadius(10)
        
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

    // MARK: - Music List
    func presentMusicList() {
        self.showMaskView(color: UIColor.clear)
        
        let musicVC = UIStoryboard.initViewController(of: "MusicViewController",
                                                      class: MusicViewController.self,
                                                      on: "Popover")
        
        musicVC.view.cornerRadius(10)
        
        let presenetedHeight: CGFloat = 526.0 + UIScreen.main.heightOfSafeAreaBottom
        let y = UIScreen.main.bounds.height - presenetedHeight
        let presentedFrame = CGRect(x: 0,
                                    y: y,
                                    width: UIScreen.main.bounds.width,
                                    height: presenetedHeight)
        self.presentChild(musicVC,
                          animated: true,
                          presentedFrame: presentedFrame)
        
        musicVM.list.bind(to: musicVC.tableView.rx.items(cellIdentifier: "MusicCell",
                                                          cellType: MusicCell.self)) { index, music, cell in
                                                            cell.tagImageView.image = music.isPlaying ? musicVC.playingImage : musicVC.pauseImage
                                                            cell.isPlaying = music.isPlaying
                                                            cell.nameLabel.text = music.name
                                                            cell.singerLabel.text = music.singer
        }.disposed(by: bag)
        
        musicVC.tableView.rx.itemSelected.subscribe(onNext: { [unowned self] (index) in
            self.musicVM.listSelectedIndex = index.row
        }).disposed(by: bag)
    }
    
    // MARK: - ExtensionFunctions
    func presentExtensionFunctions() {
        showMaskView(color: UIColor.clear)
        
        let extensionVC = UIStoryboard.initViewController(of: "ExtensionViewController",
                                                          class: ExtensionViewController.self,
                                                          on: "Popover")
        extensionVC.liveType = liveType
        extensionVC.perspective = .owner
        extensionVC.view.cornerRadius(10)
        
        let height: CGFloat = 171.0
        
        let presenetedHeight: CGFloat = height + UIScreen.main.heightOfSafeAreaBottom
        let y = UIScreen.main.bounds.height - presenetedHeight
        let presentedFrame = CGRect(x: 0,
                                    y: y,
                                    width: UIScreen.main.bounds.width,
                                    height: UIScreen.main.bounds.height)
        self.presentChild(extensionVC,
                          animated: true,
                          presentedFrame: presentedFrame)
        
        extensionVC.dataButton.rx.tap.subscribe(onNext: { [unowned self] in
            self.hiddenMaskView()
            self.presentRealData()
        }).disposed(by: bag)
        
        extensionVC.audioLoopButton.rx.tap.subscribe(onNext: { [unowned extensionVC, unowned self] in
//            guard self.deviceVM.audioOutput.value.isSupportLoop else {
//                self.showTextToast(text: NSLocalizedString("Please_Input_Headset"))
//                return
//            }
//            extensionVC.audioLoopButton.isSelected.toggle()
//            self.deviceVM.audioLoop(extensionVC.audioLoopButton.isSelected ? .off : .on)
        }).disposed(by: bag)
        
        extensionVC.backgroudButton.rx.tap.subscribe(onNext: { [unowned self] in
            self.hiddenMaskView()
            self.presentBackground()
        }).disposed(by: bag)
        
        extensionVC.musicButton.rx.tap.subscribe(onNext: { [unowned self] in
            self.hiddenMaskView()
            self.presentMusicList()
        }).disposed(by: bag)
        
    }
    
    
    // MARK: - Real Data
    func presentRealData() {
        showMaskView(color: UIColor.clear)
        
//        guard let session = Center.shared().liveSession else {
//            assert(false)
//            return
//        }
        
        let dataVC = UIStoryboard.initViewController(of: "RealDataViewController",
                                                     class: RealDataViewController.self,
                                                     on: "Popover")
        
        dataVC.view.cornerRadius(10)
        
//        session.rtcChannelReport?.subscribe(onNext: { [weak dataVC] (info) in
//            dataVC?.infoLabel.text = info.description()
//        }).disposed(by: bag)
        
        let leftSpace: CGFloat = 15.0
        let y: CGFloat = UIScreen.main.heightOfSafeAreaTop + 157.0
        let width: CGFloat = UIScreen.main.bounds.width - (leftSpace * 2)
        let presentedFrame = CGRect(x: leftSpace, y: y, width: width, height: 125.0)
        
        presentChild(dataVC,
                     animated: true,
                     presentedFrame: presentedFrame)
        
        dataVC.closeButton.rx.tap.subscribe(onNext: { [unowned self] in
            self.hiddenMaskView()
        }).disposed(by: bag)
    }
    
    // MARK: - Gift List
    func presentGiftList() {
        showMaskView(color: UIColor.clear)
        
        let giftVC = UIStoryboard.initViewController(of: "GiftViewController",
                                                     class: GiftViewController.self,
                                                     on: "Popover")
       
        giftVC.view.cornerRadius(10)
        
        let presenetedHeight: CGFloat = UIScreen.main.heightOfSafeAreaTop + 336.0
        let y = UIScreen.main.bounds.height - presenetedHeight
        let presentedFrame = CGRect(x: 0,
                                    y: y,
                                    width: UIScreen.main.bounds.width,
                                    height: presenetedHeight)
        
        presentChild(giftVC,
                     animated: true,
                     presentedFrame: presentedFrame)
        
        giftVC.selectGift.subscribe(onNext: { [unowned self] (gift) in
            self.hiddenMaskView()
            self.giftVM?.present(gift: gift) {
                self.showAlert(message: NSLocalizedString("Present_Gift_Fail"))
            }
        }).disposed(by: bag)
    }
    
    // MARK: - GIF
    func presentGIF(gift: Gift) {
        hiddenMaskView()
        
        let gifVC = UIStoryboard.initViewController(of: "GIFViewController",
                                                    class: GIFViewController.self,
                                                    on: "Popover")
        
        gifVC.view.cornerRadius(10)
        
        let presentedFrame = CGRect(x: 0,
                                    y: 0,
                                    width: UIScreen.main.bounds.width,
                                    height: UIScreen.main.bounds.height)
        
        presentChild(gifVC,
                     animated: false,
                     presentedFrame: presentedFrame)
        
        let gif = Bundle.main.url(forResource: gift.gifFileName, withExtension: "gif")
        let data = try! Data(contentsOf: gif!)
        
        gifVC.startAnimating(of: data, repeatCount: 1) { [unowned self] in
            self.hiddenMaskView()
        }
    }
    
    func presentBackground() {
        showMaskView(color: UIColor.clear)
        
        let vc = UIStoryboard.initViewController(of: "ImageSelectViewController",
                                                 class: ImageSelectViewController.self,
                                                 on: "Popover")
        
        vc.view.cornerRadius(10)
        
        let presenetedHeight: CGFloat = 455 + UIScreen.main.heightOfSafeAreaBottom
        let y = UIScreen.main.bounds.height - presenetedHeight
        let presentedFrame = CGRect(x: 0,
                                    y: y,
                                    width: UIScreen.main.bounds.width,
                                    height: presenetedHeight)
        
        presentChild(vc,
                     animated: true,
                     presentedFrame: presentedFrame)
        
        vc.selectIndex.accept(0)
        vc.selectImage.bind(to: backgroundImageView.rx.image).disposed(by: vc.bag)
        vc.selectIndex.subscribe(onNext: { [unowned self] (index) in
            
        }).disposed(by: vc.bag)
    }
    
    func presentAudioEffect(type: AudioEffectType) {
        showMaskView(color: UIColor.clear)
        
        let navigation = UIStoryboard.initViewController(of: "AudioEffectNavigation",
                                                         class: UINavigationController.self,
                                                         on: "Popover")
        guard let vc = navigation.viewControllers.first as? AudioEffectViewController else {
            assert(false)
            return
        }
        
        navigation.view.cornerRadius(10)
        vc.audioEffect = type
        
        let presenetedHeight: CGFloat = 378 + UIScreen.main.heightOfSafeAreaBottom
        let y = UIScreen.main.bounds.height - presenetedHeight
        let presentedFrame = CGRect(x: 0,
                                    y: y,
                                    width: UIScreen.main.bounds.width,
                                    height: presenetedHeight)
        
        presentChild(navigation,
                     animated: true,
                     presentedFrame: presentedFrame)
    }
}

extension LiveViewController {
    func leave() {
//        Center.shared().liveSession?.leave()
//        Center.shared().liveSession = nil
    }
    
    func dimissSelf() {
        if let _ = self.navigationController?.viewControllers.first as? LiveListViewController {
            self.navigationController?.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
}
