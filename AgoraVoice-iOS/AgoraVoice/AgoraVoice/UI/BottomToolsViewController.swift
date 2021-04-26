//
//  BottomToolsViewController.swift
//  AgoraLive
//
//  Created by CavanSu on 2020/3/27.
//  Copyright © 2020 Agora. All rights reserved.
//

import UIKit
import RxSwift
import RxRelay

class BottomToolsViewController: RxViewController {
    lazy var textInput = TextInputView()
    lazy var belcantoButton = UIButton()
    lazy var soundEffectButton = UIButton()
    lazy var extensionButton = UIButton()
    lazy var micButton = UIButton()
    lazy var giftButton = UIButton()
    
    var tintColor: UIColor = .black {
        didSet {
            textInput.backgroundColor = tintColor
            belcantoButton.backgroundColor = tintColor
            extensionButton.backgroundColor = tintColor
            soundEffectButton.backgroundColor = tintColor
            micButton.backgroundColor = tintColor
            giftButton.backgroundColor = tintColor
        }
    }
    
    var liveType: LiveType = .chatRoom
    
    let perspective = BehaviorRelay<LiveRoleType>(value: .owner)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        
        textInput.textColor = .white
        textInput.returnKeyType = .done
        textInput.attributedPlaceholder = NSAttributedString(string: LiveVCLocalizable.chatInputPlaceholder(),
                                                             attributes: [NSAttributedString.Key.foregroundColor: UIColor(hexString: "#CCCCCC"),
                                                                          NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)])
        view.addSubview(textInput)
        
        extensionButton.setImage(UIImage(named: "icon-more"),
                                 for: .normal)
        view.addSubview(extensionButton)
        
        perspective.subscribe(onNext: { [unowned self] (role) in
            self.updateViews()
            self.viewDidLayoutSubviews()
        }).disposed(by: bag)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let buttonWH: CGFloat = 38.0
        let space: CGFloat = 15.0
        let viewWidth = view.bounds.width
        let viewHeight = view.bounds.height
                
        extensionButton.frame = CGRect(x: viewWidth - buttonWH - space,
                                       y: 0,
                                       width: buttonWH,
                                       height: buttonWH)
        extensionButton.isCycle = true
        
        var lastButton: UIButton
        
        func buttonsLayout(_ buttons: [UIButton],
                           extensionButton: UIButton,
                           buttonWH: CGFloat,
                           space: CGFloat) {
            var lastButton: UIButton = extensionButton
            
            for button in buttons {
                button.frame = CGRect(x: lastButton.frame.minX - space - buttonWH,
                                      y: 0,
                                      width: buttonWH,
                                      height: buttonWH)
                button.isCycle = true
                lastButton = button
            }
        }
        
        switch (liveType, perspective.value) {
        case (.chatRoom, .owner):
            buttonsLayout([soundEffectButton, belcantoButton, micButton],
                          extensionButton: extensionButton,
                          buttonWH: buttonWH,
                          space: space)
            lastButton = micButton
        case (.chatRoom, .broadcaster):
            buttonsLayout([soundEffectButton, belcantoButton, micButton],
                          extensionButton: extensionButton,
                          buttonWH: buttonWH,
                          space: space)
            lastButton = micButton
        case (.chatRoom, .audience):
            buttonsLayout([giftButton],
                          extensionButton: extensionButton,
                          buttonWH: buttonWH,
                          space: space)
            lastButton = giftButton
        }
        
        textInput.frame = CGRect(x: space,
                                 y: 0,
                                 width: lastButton.frame.minX - (space * 2),
                                 height: viewHeight)
        textInput.cornerRadius(viewHeight * 0.5)
    }
}

private extension BottomToolsViewController {
    func updateViews() {
        belcantoButton.isHidden = true
        soundEffectButton.isHidden = true
        micButton.isHidden = true
        giftButton.isHidden = true
        
        switch (liveType, perspective.value) {
        case (.chatRoom, .owner):
            belcantoButton.isHidden = false
            belcantoButton.setImage(UIImage(named: "icon-美声"),
                                    for: .normal)
            view.addSubview(belcantoButton)
            
            soundEffectButton.isHidden = false
            soundEffectButton.setImage(UIImage(named: "icon-音效"),
                                       for: .normal)
            view.addSubview(soundEffectButton)
            
            micButton.isHidden = false
            micButton.setImage(UIImage(named: "icon-microphone-on"),
                               for: .normal)
            micButton.setImage(UIImage(named: "icon-microphone-off"),
                               for: .selected)
            view.addSubview(micButton)
        case (.chatRoom, .broadcaster):
            micButton.isHidden = false
            micButton.setImage(UIImage(named: "icon-microphone-on"),
                               for: .normal)
            micButton.setImage(UIImage(named: "icon-microphone-off"),
                               for: .selected)
            view.addSubview(micButton)
            
            belcantoButton.isHidden = false
            belcantoButton.setImage(UIImage(named: "icon-美声"),
                                    for: .normal)
            view.addSubview(belcantoButton)
            
            soundEffectButton.isHidden = false
            soundEffectButton.setImage(UIImage(named: "icon-音效"),
                                       for: .normal)
            view.addSubview(soundEffectButton)
        case (.chatRoom, .audience):
            giftButton.isHidden = false
            giftButton.setImage(UIImage(named: "icon-gift"),
                                for: .normal)
            view.addSubview(giftButton)
        }
    }
}
