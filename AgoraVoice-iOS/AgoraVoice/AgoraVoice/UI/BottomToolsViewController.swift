//
//  BottomToolsViewController.swift
//  AgoraLive
//
//  Created by CavanSu on 2020/3/27.
//  Copyright © 2020 Agora. All rights reserved.
//

import UIKit

class BottomToolsViewController: UIViewController {
    lazy var textInput = TextInputView()
    lazy var beautyButton = UIButton()
    lazy var extensionButton = UIButton()
    lazy var musicButton = UIButton()
    lazy var closeButton = UIButton()
    lazy var giftButton = UIButton()
    lazy var superRenderButton = UIButton()
    lazy var shoppingButton = UIButton()
    
    var tintColor: UIColor = .black {
        didSet {
            textInput.backgroundColor = tintColor
            closeButton.backgroundColor = tintColor
            extensionButton.backgroundColor = tintColor
            beautyButton.backgroundColor = tintColor
            giftButton.backgroundColor = tintColor
            musicButton.backgroundColor = tintColor
            superRenderButton.backgroundColor = tintColor
            giftButton.backgroundColor = tintColor
        }
    }
    
    var liveType: LiveType = .chatRoom
    
//    var perspective: LiveRoleType = .owner {
//        didSet {
//            updateViews()
//            viewDidLayoutSubviews()
//        }
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .clear
        
        textInput.returnKeyType = .done
        textInput.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("Live_Text_Input_Placeholder"),
                                                             attributes: [NSAttributedString.Key.foregroundColor: UIColor(hexString: "#CCCCCC"),
                                                                          NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)])
        self.view.addSubview(textInput)
        
        closeButton.setImage(UIImage(named: "icon-close-white"), for: .normal)
        self.view.addSubview(closeButton)
        
        extensionButton.setImage(UIImage(named: "icon-more-white"), for: .normal)
        self.view.addSubview(extensionButton)
        
        updateViews()
        
        tintColor = .black
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let buttonWH: CGFloat = 38.0
        let space: CGFloat = 15.0
        let viewWidth = self.view.bounds.width
        let viewHeight = self.view.bounds.height
        
        closeButton.frame = CGRect(x:viewWidth - buttonWH - space,
                                   y: 0,
                                   width: buttonWH,
                                   height: buttonWH)
        closeButton.isCycle = true
        
        extensionButton.frame = CGRect(x: closeButton.frame.minX - space - buttonWH,
                                       y: 0,
                                       width: buttonWH,
                                       height: buttonWH)
        extensionButton.isCycle = true
        
        var lastButton: UIButton
        
        func buttonsLayout(_ buttons: [UIButton], extensionButton: UIButton, buttonWH: CGFloat, space: CGFloat) {
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
        
        /*
        switch (liveType, perspective) {
        case (.multi, .owner): fallthrough
        case (.pk, .owner):    fallthrough
        case (.single, .owner):
            buttonsLayout([musicButton, beautyButton],
                          extensionButton: extensionButton,
                          buttonWH: buttonWH,
                          space: space)
            
            lastButton = beautyButton
        case (.virtual, .owner):
            buttonsLayout([musicButton],
                          extensionButton: extensionButton,
                          buttonWH: buttonWH,
                          space: space)
           
            lastButton = musicButton
        case (.multi, .broadcaster):
            buttonsLayout([giftButton, beautyButton],
                          extensionButton: extensionButton,
                          buttonWH: buttonWH,
                          space: space)
            
            lastButton = beautyButton
        case (.virtual, .broadcaster):
            buttonsLayout([musicButton],
                          extensionButton: extensionButton,
                          buttonWH: buttonWH,
                          space: space)
            
            lastButton = musicButton
        case (.pk, .audience):      fallthrough
        case (.virtual, .audience): fallthrough
        case (.multi, .audience):
            buttonsLayout([giftButton],
                          extensionButton: extensionButton,
                          buttonWH: buttonWH,
                          space: space)
            
            lastButton = giftButton
        case (.single, .audience):
            buttonsLayout([superRenderButton, giftButton],
                          extensionButton: extensionButton,
                          buttonWH: buttonWH,
                          space: space)
            
            lastButton = giftButton
        case (.shopping, .owner):
            buttonsLayout([pkButton, shoppingButton],
                          extensionButton: extensionButton,
                          buttonWH: buttonWH,
                          space: space)
            
            lastButton = shoppingButton
        case (.shopping, .broadcaster): fallthrough
        case (.shopping, .audience):
            buttonsLayout([giftButton, shoppingButton],
                          extensionButton: extensionButton,
                          buttonWH: buttonWH,
                          space: space)
            
            lastButton = shoppingButton
        default: fatalError()
        }
        
        textInput.frame = CGRect(x: space,
                                 y: 0,
                                 width: lastButton.frame.minX - (space * 2),
                                 height: viewHeight)
        textInput.cornerRadius(viewHeight * 0.5)
         */
    }
}

private extension BottomToolsViewController {
    func updateViews() {
        beautyButton.isHidden = true
        musicButton.isHidden = true
        giftButton.isHidden = true
        superRenderButton.isHidden = true
        
        /*
        switch (liveType, perspective) {
        case (.pk, .owner): fallthrough
        case (.single, .owner): fallthrough
        case (.multi, .owner):
            beautyButton.isHidden = false
            musicButton.isHidden = false
            
            beautyButton.setImage(UIImage(named: "icon-beauty"), for: .normal)
            beautyButton.setImage(UIImage(named:"icon-beauty-active"), for: .selected)
            musicButton.setImage(UIImage(named:"icon-music"), for: .normal)
            musicButton.setImage(UIImage(named:"icon-music-active"), for: .selected)
            
            self.view.addSubview(beautyButton)
            self.view.addSubview(musicButton)
        case (.multi, .broadcaster):
            beautyButton.isHidden = false
            giftButton.isHidden = false
            
            beautyButton.setImage(UIImage(named:"icon-beauty"), for: .normal)
            beautyButton.setImage(UIImage(named:"icon-beauty-active"), for: .selected)
            
            giftButton.setImage(UIImage(named:"icon-gift"), for: .normal)
            
            self.view.addSubview(beautyButton)
            self.view.addSubview(giftButton)
        case (.virtual, .owner):
            musicButton.isHidden = false
            
            musicButton.setImage(UIImage(named:"icon-music-black"), for: .normal)
            musicButton.setImage(UIImage(named:"icon-music-active"), for: .selected)
            
            extensionButton.setImage(UIImage(named: "icon-more-black"), for: .normal)
            closeButton.setImage(UIImage(named: "icon-close-black"), for: .normal)
            
            textInput.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("Live_Text_Input_Placeholder"),
                                                                 attributes: [NSAttributedString.Key.foregroundColor: UIColor(hexString: "#999999"),
                                                                              NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)])
            
            self.view.addSubview(musicButton)
        case (.virtual, .broadcaster): fallthrough
        case (.virtual, .audience):
            giftButton.isHidden = false
            
            extensionButton.setImage(UIImage(named: "icon-more-black"), for: .normal)
            closeButton.setImage(UIImage(named: "icon-close-black"), for: .normal)
            giftButton.setImage(UIImage(named:"icon-gift"), for: .normal)
            
            textInput.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("Live_Text_Input_Placeholder"),
                                                                 attributes: [NSAttributedString.Key.foregroundColor: UIColor(hexString: "#999999"),
                                                                              NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)])
            
            self.view.addSubview(giftButton)
        case (.pk, .audience):          fallthrough
        case (.multi, .audience):
            giftButton.isHidden = false
            giftButton.setImage(UIImage(named:"icon-gift"), for: .normal)
            self.view.addSubview(giftButton)
        case (.single, .audience):
            superRenderButton.isHidden = false
            giftButton.isHidden = false
            
            superRenderButton.setImage(UIImage(named: "icon-resolution"), for: .normal)
            superRenderButton.setImage(UIImage(named:"icon-resolution-active"), for: .selected)
            
            giftButton.setImage(UIImage(named:"icon-gift"), for: .normal)
            
            self.view.addSubview(superRenderButton)
            self.view.addSubview(giftButton)
        case (.shopping, .owner):
            shoppingButton.isHidden = false
            pkButton.isHidden = false
            
            shoppingButton.setImage(UIImage(named: "icon-货架"), for: .normal)
            pkButton.setImage(UIImage(named: "icon-PK"), for: .normal)
            
            self.view.addSubview(shoppingButton)
            self.view.addSubview(pkButton)
        case (.shopping, .broadcaster): fallthrough
        case (.shopping, .audience):
            shoppingButton.isHidden = false
            giftButton.isHidden = false
            
            shoppingButton.setImage(UIImage(named: "icon-货架"), for: .normal)
            giftButton.setImage(UIImage(named:"icon-gift"), for: .normal)
            
            self.view.addSubview(shoppingButton)
            self.view.addSubview(giftButton)
        default: fatalError()
        }
        */
    }
}
