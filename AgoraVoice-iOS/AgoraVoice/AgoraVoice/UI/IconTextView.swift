//
//  IconTextView.swift
//  AgoraLive
//
//  Created by CavanSu on 2020/2/21.
//  Copyright © 2020 Agora. All rights reserved.
//

import UIKit

class IconTextView: UIControl {
    private(set) var label = UILabel(frame: CGRect.zero)
    private(set) var imageView = UIImageView(frame: CGRect.zero)
    
    var offsetLeftX: CGFloat = 0
    var offsetRightX: CGFloat = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor(red: 0,
                                       green: 0,
                                       blue: 0,
                                       alpha: 0.4)
        label.textAlignment = .right
        
        self.addSubview(imageView)
        self.addSubview(label)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        let height = self.frame.height
        let width = self.frame.width
        let radius = height * 0.5
        self.layer.cornerRadius = radius
        
        let subsTopSpace: CGFloat = 2.0
        let imageViewHeight = height - (subsTopSpace * 2.0)
        let imageViewWidth = imageViewHeight
        let imageX = radius + offsetLeftX
        let imageY = subsTopSpace
         
        let imageViewFrame = CGRect(x: imageX,
                                    y: imageY,
                                    width: imageViewWidth,
                                    height: imageViewHeight)
        imageView.frame = imageViewFrame
        
        let labelHeight = imageViewHeight
        let labelWidth = width - radius - imageViewFrame.maxX + offsetRightX
        let labelX = imageViewFrame.maxX
        let labelY = subsTopSpace
        
        let labelFrame = CGRect(x: labelX,
                                y: labelY,
                                width: labelWidth,
                                height: labelHeight)
        label.frame = labelFrame
    }
}

class RemindIconTextView: IconTextView {
    private var remindView = FilletView(frame: CGRect.zero, filletRadius: 3)
    
    var needRemind: Bool = false {
        didSet {
            remindView.isHidden = !needRemind
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        needRemind = false
        remindView.backgroundColor = .clear
        remindView.insideBackgroundColor = UIColor(hexString: "#FF097E")
        addSubview(remindView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let w: CGFloat = 6
        let h: CGFloat = 6
        let x: CGFloat = bounds.width - w
        let y: CGFloat = 0
        
        remindView.frame = CGRect(x: x,
                                  y: y,
                                  width: w,
                                  height: h)
    }
}

protocol UIRemind {
    var remindView: FilletView {get set}
    var needRemind: Bool {get set}
}
