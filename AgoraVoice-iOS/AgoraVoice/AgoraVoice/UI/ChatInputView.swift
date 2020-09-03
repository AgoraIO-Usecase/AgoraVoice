//
//  ChatInputView.swift
//  AgoraLive
//
//  Created by CavanSu on 2020/3/31.
//  Copyright © 2020 Agora. All rights reserved.
//

import UIKit

class TextInputView: UITextField {
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: 15, y: 0, width: self.bounds.width - 30, height: self.bounds.height)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: 15, y: 0, width: self.bounds.width - 30, height: self.bounds.height)
    }
}

class ChatInputView: UIView {
    var textView = TextInputView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
        textView.backgroundColor = UIColor(hexString: "#E3E3E3")
        textView.returnKeyType = .done
        self.addSubview(textView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let topSpace: CGFloat = 7.0
        let leftSpace: CGFloat = 10.0
        textView.frame = CGRect(x: leftSpace,
                                y: topSpace,
                                width: frame.width - (leftSpace * 2),
                                height: frame.height - (topSpace * 2))
        textView.cornerRadius(textView.frame.height * 0.5)
    }
    
    func showAbove(frame: CGRect, duration: TimeInterval, completion: ((Bool) -> Void)? = nil) {
        self.isHidden = false
        var newChatFrame = self.frame
        let y = UIScreen.main.bounds.height - frame.height - newChatFrame.height
        newChatFrame.origin.y = y
            
        UIView.animate(withDuration: duration, animations: {
            self.frame = newChatFrame
        }, completion: completion)
    }
    
    func hidden(duration: TimeInterval, completion: ((Bool) -> Void)? = nil) {
        var newChatFrame = self.frame
        newChatFrame.origin.y = UIScreen.main.bounds.height
        
        UIView.animate(withDuration: duration, animations: {
            self.frame = newChatFrame
        }) { (done) in
            if done {
                self.isHidden = true
                
                if let completion = completion {
                    completion(done)
                }
            }
        }
    }
}
