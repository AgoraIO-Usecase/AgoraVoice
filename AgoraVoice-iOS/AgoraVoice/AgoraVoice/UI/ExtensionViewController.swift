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
        setTitleColor(UIColor(hexString: "#9BA2AB"), for: .normal)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ExtensionViewController: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    
    lazy var dataButton = ExtensionButton(frame: CGRect.zero)
    lazy var audioLoopButton = ExtensionButton(frame: CGRect.zero)
    lazy var musicButton = ExtensionButton(frame: CGRect.zero)
    lazy var backgroudButton = ExtensionButton(frame: CGRect.zero)
    
    var liveType: LiveType = .chatRoom
    var perspective: LiveRoleType = .audience
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hexString: "#161D27")
        
        titleLabel.text = NSLocalizedString("Tool")
        titleLabel.textColor = UIColor(hexString: "#EEEEEE")
        titleLabel.font = UIFont.systemFont(ofSize: 14)
        
        dataButton.setImage(UIImage(named: "icon-data"), for: .normal)
        dataButton.setTitle(NSLocalizedString("Real_Data"), for: .normal)
        view.addSubview(dataButton)
        
        switch perspective {
        case .owner, .broadcaster:
            musicButton.setImage(UIImage(named: "icon-music"), for: .normal)
            musicButton.setTitle(NSLocalizedString("Music"), for: .normal)
            view.addSubview(musicButton)
            
            backgroudButton.setImage(UIImage(named: "icon-背景"), for: .normal)
            backgroudButton.setTitle(NSLocalizedString("Background"), for: .normal)
            view.addSubview(backgroudButton)
            
            audioLoopButton.setImage(UIImage(named: "icon-耳返-off"), for: .normal)
            audioLoopButton.setImage(UIImage(named: "icon-耳返-on"), for: .selected)
            audioLoopButton.setTitle(NSLocalizedString("Audio_Loop"), for: .normal)
            audioLoopButton.setTitle(NSLocalizedString("Audio_Loop"), for: .selected)
            view.addSubview(audioLoopButton)
        case .audience:
            break
        }
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
        
        switch perspective {
        case .owner:
            let y: CGFloat = self.titleLabel.frame.maxY + 20.0
            buttonsLayout([audioLoopButton, musicButton, backgroudButton, dataButton], y: y)
        case .broadcaster:
            let y: CGFloat = self.titleLabel.frame.maxY + 20.0
            buttonsLayout([audioLoopButton, dataButton], y: y)
        case .audience:
            let y: CGFloat = self.titleLabel.frame.maxY + 20.0
            buttonsLayout([dataButton], y: y)
        }
    }
}
