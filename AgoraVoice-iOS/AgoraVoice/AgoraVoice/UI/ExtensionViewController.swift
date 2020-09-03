//
//  ExtensionViewController.swift
//  AgoraLive
//
//  Created by CavanSu on 2020/4/1.
//  Copyright © 2020 Agora. All rights reserved.
//

import UIKit

class ExtensionButton: UIButton {
    override func titleRect(forContentRect contentRect: CGRect) -> CGRect {
        let w: CGFloat = self.bounds.width
        let h: CGFloat = 17.0
        let x: CGFloat = 0
        let y: CGFloat = self.bounds.height - h
        return CGRect(x: x, y: y, width: w, height: h)
    }
    
    override func imageRect(forContentRect contentRect: CGRect) -> CGRect {
        let wh: CGFloat = 42.0
        let x: CGFloat = (self.bounds.width - wh) * 0.5
        let y: CGFloat = 0
        return CGRect(x: x, y: y, width: wh, height: wh)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        titleLabel?.textAlignment = .center
        titleLabel?.font = UIFont.systemFont(ofSize: 12)
        self.setTitleColor(UIColor(hexString: "#333333"), for: .normal)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ExtensionViewController: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    
    lazy var dataButton = ExtensionButton(frame: CGRect.zero)
    lazy var settingsButton = ExtensionButton(frame: CGRect.zero)
    lazy var switchCameraButton = ExtensionButton(frame: CGRect.zero)
    lazy var cameraButton = ExtensionButton(frame: CGRect.zero)
    lazy var micButton = ExtensionButton(frame: CGRect.zero)
    lazy var audioLoopButton = ExtensionButton(frame: CGRect.zero)
    lazy var beautyButton = ExtensionButton(frame: CGRect.zero)
    lazy var musicButton = ExtensionButton(frame: CGRect.zero)
    lazy var broadcastingButton = ExtensionButton(frame: CGRect.zero)
    
    var liveType: LiveType = .chatRoom
//    var perspective: LiveRoleType = .audience
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let color = UIColor(hexString: "#D8D8D8")
        let x: CGFloat = 15.0
        let width = UIScreen.main.bounds.width - (x * 2)
        titleLabel.text = NSLocalizedString("Tool")
        titleLabel.containUnderline(color,
                                    x: x,
                                    width: width)
        
        dataButton.setImage(UIImage(named: "icon-data"), for: .normal)
        dataButton.setTitle(NSLocalizedString("Real_Data"), for: .normal)
        view.addSubview(dataButton)
        
//        switch perspective {
//        case .owner, .broadcaster:
//            if liveType != .virtual {
//                settingsButton.setImage(UIImage(named: "icon-setting"), for: .normal)
//                settingsButton.setTitle(NSLocalizedString("Live_Room_Settings"), for: .normal)
//                view.addSubview(settingsButton)
//                
//                switchCameraButton.setImage(UIImage(named: "icon-rotate"), for: .normal)
//                switchCameraButton.setTitle(NSLocalizedString("Switch_Camera"), for: .normal)
//                view.addSubview(switchCameraButton)
//                
//                cameraButton.setImage(UIImage(named: "icon-video on"), for: .normal)
//                cameraButton.setImage(UIImage(named: "icon-video off"), for: .selected)
//                cameraButton.setTitle(NSLocalizedString("Camera"), for: .normal)
//                cameraButton.setTitle(NSLocalizedString("Camera"), for: .selected)
//                view.addSubview(cameraButton)
//            }
//            
//            if liveType == .shopping {
//                musicButton.setImage(UIImage(named: "icon-music-shopping"), for: .normal)
//                musicButton.setTitle(NSLocalizedString("Music"), for: .normal)
//                view.addSubview(musicButton)
//                
//                beautyButton.setImage(UIImage(named: "icon-美颜"), for: .normal)
//                beautyButton.setTitle(NSLocalizedString("Beauty"), for: .normal)
//                view.addSubview(beautyButton)
//            }
//            
//            micButton.setImage(UIImage(named: "icon-speaker on"), for: .normal)
//            micButton.setImage(UIImage(named: "icon-speaker off"), for: .selected)
//            micButton.setTitle(NSLocalizedString("Mic"), for: .normal)
//            micButton.setTitle(NSLocalizedString("Mic"), for: .selected)
//            view.addSubview(micButton)
//            
//            audioLoopButton.setImage(UIImage(named: "icon-loop"), for: .normal)
//            audioLoopButton.setImage(UIImage(named: "icon-loop-active"), for: .selected)
//            audioLoopButton.setTitle(NSLocalizedString("Audio_Loop"), for: .normal)
//            audioLoopButton.setTitle(NSLocalizedString("Audio_Loop"), for: .selected)
//            view.addSubview(audioLoopButton)
//        case .audience:
//            if liveType == .shopping {
//                broadcastingButton.setImage(UIImage(named: "icon-连麦"), for: .normal)
//                broadcastingButton.setTitle(NSLocalizedString("ApplicationOfBroadcasting"), for: .normal)
//                view.addSubview(broadcastingButton)
//            }
//            break
//        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        func buttonsLayout(_ buttons: [UIButton], y: CGFloat) {
            let width: CGFloat = 63.0
            let height: CGFloat = 17.0 + 8.0 + 42.0
            let leftRightSpace: CGFloat = 25.0
            let betweenSpace: CGFloat = (UIScreen.main.bounds.width - (leftRightSpace * 2) - (width * 4)) / 3
            
            var lastButton: UIButton? = nil
            
            for button in buttons {
                if lastButton == nil {
                    button.frame = CGRect(x: leftRightSpace,
                                          y: y,
                                          width: width,
                                          height: height)
                } else {
                    button.frame = CGRect(x: lastButton!.frame.maxX + betweenSpace,
                                          y: y,
                                          width: width,
                                          height: height)
                }
                lastButton = button
            }
        }
        
//        switch perspective {
//        case .owner, .broadcaster:
//            // row 0
//            var y: CGFloat = self.titleLabel.frame.maxY + 20.0
//            var buttons: [UIButton]
//            
//            switch liveType {
//            case .shopping:
//                buttons = [dataButton, settingsButton, beautyButton, musicButton]
//            case .virtual:
//                buttons = [dataButton]
//            default:
//                buttons = [dataButton, settingsButton]
//            }
//            
//            buttonsLayout(buttons, y: y)
//            
//            // row 1
//            y = dataButton.frame.maxY + 22.0
//            
//            switch liveType {
//            case .virtual:
//                buttons = [micButton, audioLoopButton]
//            default:
//                buttons = [switchCameraButton, cameraButton, micButton, audioLoopButton]
//            }
//            
//            buttonsLayout(buttons, y: y)
//        case .audience:
//            switch liveType {
//            case .shopping:
//                let y: CGFloat = self.titleLabel.frame.maxY + 20.0
//                buttonsLayout([broadcastingButton, dataButton], y: y)
//            default:
//                let width: CGFloat = 63.0
//                let height: CGFloat = 17.0 + 8.0 + 42.0
//                let y: CGFloat = self.titleLabel.frame.maxY + 20.0
//                let x: CGFloat = (self.view.bounds.width - width) * 0.5
//                self.dataButton.frame = CGRect(x: x,
//                                               y: y,
//                                               width: width,
//                                               height: height)
//            }
//        }
    }
}
