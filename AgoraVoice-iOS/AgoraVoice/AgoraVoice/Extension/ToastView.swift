//
//  ToastView.swift
//
//  Created by CavanSu on 2020/4/29.
//  Copyright © 2020 Agora. All rights reserved.
//

import UIKit

class ToastView: FilletView {

}

class TextToast: ToastView {
    private var label = UILabel(frame: CGRect.zero)
    
    var text: String? {
        didSet {
            label.text = text
        }
    }
    
    var labelSize = CGSize(width: 0, height: 20)
    
    var contentEdgeInsets = UIEdgeInsets(top: 15.0,
                                         left: 15.0,
                                         bottom: 15.0,
                                         right: 15.0)
    
    override init(frame: CGRect,
                  filletRadius: CGFloat = 0.0) {
        super.init(frame: frame,
                   filletRadius: filletRadius)
        self.initViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.initViews()
    }
    
    func initViews() {
        insideBackgroundColor = UIColor(red: 0,
                                        green: 0,
                                        blue: 0,
                                        alpha: 0.6)
        backgroundColor = .clear
        label.numberOfLines = 0
        label.textAlignment = .left
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 14)
        
        addSubview(label)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let text = label.text {
            let font = UIFont.systemFont(ofSize: 14)
            
            let width: CGFloat = UIScreen.main.bounds.width - contentEdgeInsets.left - contentEdgeInsets.right
            let height: CGFloat = CGFloat(MAXFLOAT)
            
            let newSize = text.size(font: font,
                                    drawRange: CGSize(width: width,
                                                      height: height))
            self.labelSize = newSize
        }
        
        label.frame = CGRect(x: contentEdgeInsets.left,
                             y: contentEdgeInsets.top,
                             width: labelSize.width,
                             height: labelSize.height)
        
        let condition1 = (label.frame.maxX + contentEdgeInsets.right) != bounds.width
        let condition2 = (label.frame.maxY + contentEdgeInsets.bottom) != bounds.height
        
        if (condition1 || condition2) {
            var newFrame = frame
            var newSize = frame.size
            
            newSize.width = label.frame.maxX + contentEdgeInsets.right
            newSize.height = label.frame.maxY + contentEdgeInsets.bottom
            
            newFrame.size = newSize
            
            if let superview = superview {
                newFrame.origin.x = (superview.bounds.width - newSize.width) * 0.5
            }
            
            self.frame = newFrame
        }
    }
}

class TagImageTextToast: ToastView {
    private var tagImageView = UIImageView(frame: CGRect.zero)
    private var label = UILabel(frame: CGRect.zero)
    
    var tagImage: UIImage? {
        didSet {
            tagImageView.image = tagImage
        }
    }
    
    var text: String? {
        didSet {
            label.text = text
        }
    }
    
    var labelSize = CGSize(width: 0,
                           height: 20)
    
    var contentEdgeInsets = UIEdgeInsets(top: 15.0,
                                         left: 15.0,
                                         bottom: 15.0,
                                         right: 15.0)
    
    override init(frame: CGRect,
                  filletRadius: CGFloat = 0.0) {
        super.init(frame: frame,
                   filletRadius: filletRadius)
        self.initViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.initViews()
    }
    
    func initViews() {
        insideBackgroundColor = UIColor(red: 0,
                                        green: 0,
                                        blue: 0,
                                        alpha: 0.6)
        backgroundColor = .clear
        label.numberOfLines = 0
        label.textAlignment = .left
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 14)
        
        addSubview(tagImageView)
        addSubview(label)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let space: CGFloat = 6
        
        if let text = label.text {
            let font = UIFont.systemFont(ofSize: 14)
            
            let width: CGFloat = UIScreen.main.bounds.width - contentEdgeInsets.left - contentEdgeInsets.right - (space * 5)
            let height: CGFloat = CGFloat(MAXFLOAT)
            
            let newSize = text.size(font: font,
                                    drawRange: CGSize(width: width,
                                                      height: height))
            self.labelSize = newSize
        }
        
        tagImageView.frame = CGRect(x: contentEdgeInsets.left,
                                         y: contentEdgeInsets.top,
                                         width: 14,
                                         height: 14)
        self.label.frame = CGRect(x: self.tagImageView.frame.maxX + space,
                                  y: contentEdgeInsets.top,
                                  width: labelSize.width,
                                  height: labelSize.height)
        
        let condition1 = (label.frame.maxX + contentEdgeInsets.right) != bounds.width
        let condition2 = (label.frame.maxY + contentEdgeInsets.bottom) != bounds.height
        
        if (condition1 || condition2) {
            var newFrame = frame
            var newSize = frame.size
            
            newSize.width = label.frame.maxX + contentEdgeInsets.right
            newSize.height = label.frame.maxY + contentEdgeInsets.bottom
            
            newFrame.size = newSize
            
            if let superview = superview {
                newFrame.origin.x = (superview.bounds.width - newSize.width) * 0.5
            }
            
            self.frame = newFrame
        }
    }
}
