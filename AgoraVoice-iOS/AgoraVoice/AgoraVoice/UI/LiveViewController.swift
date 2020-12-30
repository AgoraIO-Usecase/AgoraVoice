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

protocol LiveViewController where Self: MaskViewController {
    var liveSession: LiveSession! {get set}
    
    var tintColor: UIColor {get set}
    var chatWidthLimit: CGFloat {get set}
    
    // ViewController
    var giftAudienceVC: GiftAudienceViewController? {get set}
    var bottomToolsVC: BottomToolsViewController? {get set}
    var chatVC: ChatViewController? {get set}
    
    // View
    var backgroundImageView: UIImageView! {get set}
    var personCountView: RemindIconTextView! {get set}
    var chatInputView: ChatInputView {get set}
    
    // View Model
    var userListVM: LiveUserListVM {get set}
    var musicVM: MusicVM {get set}
    var chatVM: ChatVM {get set}
    var deviceVM: MediaDeviceVM {get set}
    var audioEffectVM: AudioEffectVM {get set}
    var monitor: NetworkMonitor {get set}
    
    var backgroundVM: RoomBackgroundVM! {get set}
    var giftVM: GiftVM! {get set}
}

// MARK: VM
extension LiveViewController {
    func syncLiveSessionInfo() {
        // local role & stream
        liveSession.localRole.filter { (local) -> Bool in
            return local.type == .owner
        }.map { (local) -> [LiveRole] in
            return [local]
        }.bind(to: userListVM.joined).dispose()
        
        liveSession.localStream.subscribe(onNext: { [unowned self] (stream) in
            if let stream = stream {
                self.deviceVM.micStatus.accept(stream.hasAudio ? .on : .off)
            } else {
                self.deviceVM.micStatus.accept(.off)
            }
        }).disposed(by: bag)
        
        // end
        liveSession.state.subscribe(onNext: { [unowned self] (state) in
            switch state {
            case .end(let reason):
                self.liveEndAlert(reason: reason)
            case .active:
                break
            }
        }).disposed(by: bag)
    }
    
    // MARK: - Users
    func users() {
        // user list
        liveSession.userList.bind(to: userListVM.list).disposed(by: bag)
        liveSession.userLeft.bind(to: userListVM.left).disposed(by: bag)
        liveSession.userJoined.bind(to: userListVM.joined).disposed(by: bag)
        liveSession.audienceList.bind(to: userListVM.audienceList).disposed(by: bag)
        
        liveSession.customMessage.bind(to: userListVM.message).disposed(by: bag)
        
        personCountView.backgroundColor = tintColor
        personCountView.offsetLeftX = -4.0
        personCountView.offsetRightX = 4.0
        personCountView.imageView.image = UIImage(named: "icon-audience")
        personCountView.label.textColor = UIColor.white
        personCountView.label.font = UIFont.systemFont(ofSize: 10)
        
        if let giftAudienceVC = self.giftAudienceVC {
            userListVM.giftList.bind(to: giftAudienceVC.list).disposed(by: bag)
        }
        
        userListVM.total.map { (total) -> String in
            return "\(total)"
        }.bind(to: personCountView.label.rx.text).disposed(by: bag)
        
        userListVM.joined.subscribe(onNext: { [unowned self] (list) in
            let chats = list.map { (user) -> Chat in
                let chat = Chat(name: user.info.name,
                                text: " \(NSLocalizedString("Join_Live_Room"))",
                          widthLimit: self.chatWidthLimit)
                return chat
            }

            self.chatVM.newMessages(chats)
        }).disposed(by: bag)
        
        userListVM.left.subscribe(onNext: { [unowned self] (list) in
            let chats = list.map { (user) -> Chat in
                let chat = Chat(name: user.info.name,
                                text: " \(NSLocalizedString("Leave_Live_Room"))",
                          widthLimit: self.chatWidthLimit)
                return chat
            }

            self.chatVM.newMessages(chats)
        }).disposed(by: bag)
    }
    
    // MARK: - Chat List
    func chatList() {
        liveSession.chatMessage.subscribe(onNext: { [unowned self] (userMessage) in
            let chat = Chat(name: userMessage.user.info.name + ": ",
                            text: userMessage.message,
                            widthLimit: self.chatWidthLimit)
            self.chatVM.newMessages([chat])
        }).disposed(by: bag)
        
        if let chatVC = self.chatVC {
            chatVM.list.bind(to: chatVC.list).disposed(by: bag)
        }
    }
    
    // MARK: - Background
    func background() {
        liveSession.customMessage.bind(to: backgroundVM.message).disposed(by: bag)
        
        backgroundVM.selectedImage.bind(to: backgroundImageView.rx.image).disposed(by: bag)
        backgroundVM.fail.subscribe(onNext: { [unowned self] (text) in
            self.showTextToast(text: text)
        }).disposed(by: bag)
    }
    
    // MARK: - Gift
    func gift() {
        // gift
        liveSession.customMessage.bind(to: giftVM.message).disposed(by: bag)
        
        giftVM?.received.subscribe(onNext: { [unowned self] (userGift) in
            let chat = Chat(name: userGift.userName,
                            text: " " + NSLocalizedString("Give_Owner_A_Gift"),
                            image: userGift.gift.image, widthLimit: self.chatWidthLimit)
            self.chatVM.newMessages([chat])
            
            guard userGift.gift.hasGIF else {
                return
            }
            
            self.presentGIF(gift: userGift.gift)
        }).disposed(by: bag)
    }
    
    // MARK: - Music
    func music() {
        musicVM.refetch()
        
        musicVM.playAction.bind(to: liveSession.playMusic).disposed(by: bag)
        musicVM.pauseAction.bind(to: liveSession.pauseMusic).disposed(by: bag)
        musicVM.resumeAction.bind(to: liveSession.resumeMusic).disposed(by: bag)
        musicVM.stopAction.bind(to: liveSession.stopMusic).disposed(by: bag)
        musicVM.volume.bind(to: liveSession.musicVolume).disposed(by: bag)
        
        liveSession.musicState.bind(to: musicVM.playerStatus).disposed(by: bag)
    }
    
    // MARK: - AudioEffect
    func audioEffect() {
        audioEffectVM.outputChatOfBelcanto.bind(to: liveSession.chatOfBelcanto).disposed(by: bag)
        audioEffectVM.outputSingOfBelcanto.bind(to: liveSession.singOfBelcanto).disposed(by: bag)
        audioEffectVM.outputTimbre.bind(to: liveSession.timbre).disposed(by: bag)
        
        audioEffectVM.outputAudioSpace.bind(to: liveSession.audioSpace).disposed(by: bag)
        audioEffectVM.outputTimbreRole.bind(to: liveSession.timbreRole).disposed(by: bag)
        audioEffectVM.outputMusicGenre.bind(to: liveSession.musicGenre).disposed(by: bag)
        
        audioEffectVM.outputElectronicMusic.bind(to: liveSession.electronicMusic).disposed(by: bag)
        audioEffectVM.outputThreeDimensionalVoice.bind(to: liveSession.threeDimensionalVoice).disposed(by: bag)
    }
    
    // MARK: - Net Monitor
    func netMonitor() {
        monitor.action(.on)
        monitor.connect.subscribe(onNext: { [unowned self] (status) in
            switch status {
            case .notReachable:
                let view = TextToast(frame: CGRect(x: 0, y: 200, width: 0, height: 44), filletRadius: 8)
                view.text = NSLocalizedString("Lost_Connection_Retry")
                self.showToastView(view, duration: 3.0)
            case .reachable(let type):
                guard type == .wwan else {
                    return
                }
                let view = TextToast(frame: CGRect(x: 0, y: 200, width: 0, height: 44), filletRadius: 8)
                view.text = NSLocalizedString("Use_Cellular_Data")
                self.showToastView(view, duration: 3.0)
            default:
                break
            }
        }).disposed(by: bag)
    }
    
    func mediaDevice() {
        deviceVM.micAction.subscribe(onNext: { [unowned self] (isOn) in
            self.liveSession.updateLocalAudioStream(isOn: isOn.boolValue)
        }).disposed(by: bag)
        
        liveSession.audioOuputRouting.bind(to: deviceVM.audioOutput).disposed(by: bag)
    }
}

// MARK: - View
extension LiveViewController {
    // MARK: - Bottom Tools
    func bottomTools() {
        guard let bottomToolsVC = self.bottomToolsVC else {
            assert(false)
            return
        }
        
        liveSession.localRole.map({ (role) -> LiveRoleType in
            return role.type
        }).bind(to: bottomToolsVC.perspective).disposed(by: bag)
        
        bottomToolsVC.liveType = liveSession.type
        bottomToolsVC.liveType = .chatRoom
        bottomToolsVC.tintColor = tintColor
        
        bottomToolsVC.giftButton.rx.tap.subscribe(onNext: { [unowned self] in
            self.presentGiftList()
        }).disposed(by: bag)
        
        bottomToolsVC.extensionButton.rx.tap.subscribe(onNext: { [unowned self] in
            self.presentExtensionFunctions()
        }).disposed(by: bag)
        
        bottomToolsVC.micButton.rx.tap.subscribe(onNext: { [unowned self] in
            guard let isSelected = self.bottomToolsVC?.micButton.isSelected else {
                return
            }
            
            self.deviceVM.micAction.accept(!isSelected ? .off : .on)
        }).disposed(by: bag)
        
        deviceVM.micStatus.map { (isOn) -> Bool in
            return !isOn.boolValue
        }.bind(to: bottomToolsVC.micButton.rx.isSelected).disposed(by: bottomToolsVC.bag)
        
        bottomToolsVC.belcantoButton.rx.tap.subscribe(onNext: { [unowned self] in
            self.presentAudioEffect(type: .belCanto)
        }).disposed(by: bag)
        
        bottomToolsVC.soundEffectButton.rx.tap.subscribe(onNext: { [unowned self] in
            self.presentAudioEffect(type: .soundEffect)
        }).disposed(by: bag)
    }
    
    // MARK: - Chat Input
    func chatInput() {
        chatInputView.textView.textColor = .white
        chatInputView.textView.returnKeyType = .send
        
        chatInputView.textView.rx.controlEvent([.editingDidEndOnExit])
            .subscribe(onNext: { [unowned self] in
                self.hiddenMaskView()
                self.view.endEditing(true)
                
                guard let text = self.chatInputView.textView.text,
                    text.count > 0 else {
                    return
                }
                
                self.chatInputView.textView.text = nil
                self.liveSession.sendChat(text, success: { [unowned self] in
                    let local = Center.shared().centerProvideLocalUser().info.value
                    let chat = Chat(name: local.name + ": ",
                                    text: text,
                                    widthLimit: self.chatWidthLimit)
                    self.chatVM.newMessages([chat])
                }) { [unowned self] (_) in
                    self.showAlert(message: NSLocalizedString("Send_Chat_Message_Fail"))
                }
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
    func presentUserList(type: UserListViewController.ShowType) {
        self.showMaskView(color: UIColor.clear)
        
        let vc = UIStoryboard.initViewController(of: "UserListViewController",
                                                 class: UserListViewController.self,
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
        musicVC.musicVM = musicVM
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
    }
    
    // MARK: - ExtensionFunctions
    func presentExtensionFunctions() {
        showMaskView(color: UIColor.clear)
        
        let extensionVC = UIStoryboard.initViewController(of: "ExtensionViewController",
                                                          class: ExtensionViewController.self,
                                                          on: "Popover")
        extensionVC.liveType = liveSession.type
        extensionVC.perspective = liveSession.localRole.value.type
        extensionVC.view.cornerRadius(10)
        
        let height: CGFloat = 171.0
        
        let presenetedHeight: CGFloat = height + UIScreen.main.heightOfSafeAreaBottom
        let y = UIScreen.main.bounds.height - presenetedHeight
        let presentedFrame = CGRect(x: 0,
                                    y: y,
                                    width: UIScreen.main.bounds.width,
                                    height: presenetedHeight)
        self.presentChild(extensionVC,
                          animated: true,
                          presentedFrame: presentedFrame)
        
        liveSession.localRole.subscribe(onNext: { [unowned extensionVC, unowned self] (local) in
            if extensionVC.perspective != local.type {
                self.hiddenMaskView()
            }
        }).disposed(by: extensionVC.bag)
        
        extensionVC.dataButton.rx.tap.subscribe(onNext: { [unowned self] in
            self.hiddenMaskView()
            self.presentRealData()
        }).disposed(by: extensionVC.bag)
        
        extensionVC.audioLoopButton.rx.tap.subscribe(onNext: { [unowned extensionVC, unowned self] in
            guard self.deviceVM.audioOutput.value.isSupportLoop else {
                self.showTextToast(text: NSLocalizedString("Please_Input_Headset"))
                return
            }
            extensionVC.audioLoopButton.isSelected.toggle()
            self.deviceVM.localAudioLoop.accept(extensionVC.audioLoopButton.isSelected ? .on : .off)
        }).disposed(by: extensionVC.bag)
        
        deviceVM.audioOutput.subscribe(onNext: { [unowned extensionVC, unowned self] (routing) in
            if routing.isSupportLoop {
                extensionVC.audioLoopButton.isSelected = self.deviceVM.localAudioLoop.value.boolValue
            } else {
                extensionVC.audioLoopButton.isSelected = false
            }
        }).disposed(by: extensionVC.bag)
        
        extensionVC.backgroudButton.rx.tap.subscribe(onNext: { [unowned self] in
            self.hiddenMaskView()
            self.presentBackground()
        }).disposed(by: extensionVC.bag)
        
        extensionVC.musicButton.rx.tap.subscribe(onNext: { [unowned self] in
            self.hiddenMaskView()
            self.presentMusicList()
        }).disposed(by: extensionVC.bag)
    }
    
    // MARK: - Real Data
    func presentRealData() {
        showMaskView(color: UIColor.clear)
        
        let dataVC = UIStoryboard.initViewController(of: "RealDataViewController",
                                                     class: RealDataViewController.self,
                                                     on: "Popover")
        
        dataVC.view.cornerRadius(10)
        
        liveSession.sessionReport.subscribe(onNext: { [unowned dataVC] (statistics) in
            dataVC.infoLabel.text = statistics.description
        }).disposed(by: dataVC.bag)
        
        let leftSpace: CGFloat = 15.0
        let y: CGFloat = UIScreen.main.heightOfSafeAreaTop + 157.0
        let width: CGFloat = UIScreen.main.bounds.width - (leftSpace * 2)
        let presentedFrame = CGRect(x: leftSpace, y: y, width: width, height: 125.0)
        
        presentChild(dataVC,
                     animated: true,
                     presentedFrame: presentedFrame)
        
        dataVC.closeButton.rx.tap.subscribe(onNext: { [unowned self] in
            self.hiddenMaskView()
        }).disposed(by: dataVC.bag)
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
            self.giftVM?.present(gift: gift) { [unowned self] in
                self.showAlert(message: NSLocalizedString("Present_Gift_Fail"))
            }
        }).disposed(by: giftVC.bag)
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
        
        gifVC.startAnimating(of: data, repeatCount: 1) { [unowned self, unowned gifVC] in
            gifVC.view.removeFromSuperview()
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
        
        vc.selectIndex.accept(backgroundVM.selectedIndex.value)
        vc.selectImage.bind(to: backgroundImageView.rx.image).disposed(by: vc.bag)
        vc.selectIndex.subscribe(onNext: { [unowned self] (index) in
            self.backgroundVM.commit(index: index)
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
        vc.audioEffectVM = audioEffectVM
        
        var height: CGFloat
        switch type {
        case .belCanto:    height = 378
        case .soundEffect: height = 566
        }
        
        let presenetedHeight: CGFloat = height + UIScreen.main.heightOfSafeAreaBottom
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
    func liveEndAlert(reason: LiveSession.State.Reason) {
        if let vc = self.presentedViewController {
            vc.dismiss(animated: false, completion: nil)
        }
        
        var text: String
        
        switch reason {
        case .ownerClose:
            text = NSLocalizedString("Live_End")
        case .timeout:
            text = NSLocalizedString("Live_Timeout")
        }
        
        self.showAlert(text) { [unowned self] (_) in
            self.dimissSelf()
        }
    }
    
    func dimissSelf() {
        if let _ = self.navigationController?.viewControllers.first as? LiveTypeViewController {
            self.navigationController?.popViewController(animated: true)
        } else {
            self.navigationController?.dismiss(animated: true, completion: nil)
        }
    }
}
