//
//  TabSelectView.swift
//  AgoraLive
//
//  Created by CavanSu on 2020/2/19.
//  Copyright © 2020 Agora. All rights reserved.
//

import UIKit
import RxSwift
import RxRelay

class TabSelectView: UIScrollView {
    enum Aligment {
        case left, center
    }
    
    struct TitleProperty {
        var color: UIColor
        var font: UIFont
    }
    
    private lazy var underline: UIView = {
        let line = UIView()
        line.backgroundColor = underlineColor
        return line
    }()
    
    private var titles: [String]?
    private var titleButtons: [RemindButton]?
    private var needLayoutButtons = false {
        didSet {
            if needLayoutButtons {
                layoutIfNeeded()
            }
        }
    }
    
    private let bag = DisposeBag()
    
    let selectedIndex = BehaviorRelay(value: 0)
    
    var underlineColor: UIColor = UIColor(hexString: "#0088EB") {
        didSet {
            underline.backgroundColor = underlineColor
        }
    }
    
    var unselectedTitle = TitleProperty(color: UIColor.gray,
                                        font: UIFont.systemFont(ofSize: 14))
    
    var selectedTitle = TitleProperty(color: UIColor.black,
                                      font: UIFont.systemFont(ofSize: 16, weight: .medium))
    
    var alignment = Aligment.left
    var insets = UIEdgeInsets(top: 0,
                              left: 0,
                              bottom: 0,
                              right: 0)
    
    var titleSpace: CGFloat = 28.0
    var underlineWidth: CGFloat? = nil
    var underlineHeight: CGFloat = 5
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.masksToBounds = true
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if needLayoutButtons, let titles = titles {
            needLayoutButtons = false
            layoutButtons(titles: titles,
                          space: titleSpace)
        }
    }
}

extension TabSelectView {
    func update(_ titles: [String]) {
        guard titles.count > 0 else {
            return
        }
        
        if let buttons = self.titleButtons {
            for item in buttons {
                item.removeFromSuperview()
            }
            self.titleButtons = nil
        }
        
        self.titles = titles
        needLayoutButtons = true
        
        selectedIndex.accept(0)
        
        selectedIndex.subscribe(onNext: { [unowned self] (index) in
            self.updateSelectedButton(index)
            self.updateUnderlinePosition()
            self.needRemind(false,
                            index: index)
        }).disposed(by: bag)
    }
    
    func needRemind(_ remind: Bool,
                    index: Int) {
        guard let buttons = titleButtons,
            index <= buttons.count - 1
            else {
                return
        }
        let button = buttons[index]
        
        button.needRemind = remind
    }
}

private extension TabSelectView {
    func layoutButtons(titles: [String], space: CGFloat) {
        var lastButtonMaxX: CGFloat? = nil
        var buttons = [RemindButton]()
        
        // alignment left layout
        for (index, title) in titles.enumerated() {
            let textSize = title.size(font: selectedTitle.font,
                                      drawRange: CGSize(width: CGFloat(MAXFLOAT), height: bounds.height))
            
            let height = bounds.height - insets.top - insets.bottom
            let frame = CGRect(x: lastButtonMaxX ?? insets.left,
                               y: insets.top,
                               width: textSize.width,
                               height: height)
            
            let button = RemindButton(frame: frame)
            button.setTitle(title, for: .normal)
            button.titleLabel?.font = unselectedTitle.font
            button.tag = index
            button.setTitleColor(unselectedTitle.color,
                                 for: .normal)
            buttons.append(button)
            addSubview(button)
            lastButtonMaxX = button.frame.maxX + space
            
            button.rx.tap.subscribe(onNext: { [weak button, weak self] (event) in
                guard let tButton = button,
                    let strongSelf = self else {
                        return
                }
                strongSelf.selectedIndex.accept(tButton.tag)
            }).disposed(by: bag)
        }
        
        lastButtonMaxX = nil
        
        // alignment center layout
        if alignment == .center {
            let totalLength = buttons.last!.frame.maxX - insets.left
            let beginX = (bounds.width - totalLength) * 0.5
            
            for item in buttons {
                var frame = item.frame
                var pointer = frame.origin
                
                pointer.x = lastButtonMaxX ?? beginX
                frame.origin = pointer
                item.frame = frame
                
                lastButtonMaxX = item.frame.maxX + space
            }
        }
        
        var contentSize: CGSize
        
        switch alignment {
        case .left:
            contentSize = CGSize(width: buttons.last!.frame.maxX + insets.right,
                                 height: 0)
        case .center:
            contentSize = CGSize(width: bounds.width + insets.left + insets.right,
                                 height: 0)
        }
        
        self.contentSize = contentSize
        titleButtons = buttons
        
        insertSubview(underline,
                      at: subviews.count - 1)
        
        updateUnderlinePosition(false)
    }
    
    func updateSelectedButton(_ index: Int) {
        guard let buttons = self.titleButtons else {
            assert(false, "buttons nil")
            return
        }
        
        for (i, item) in buttons.enumerated() {
            if i == index {
                item.titleLabel?.font = selectedTitle.font
                item.setTitleColor(selectedTitle.color,
                                   for: .normal)
            } else {
                item.titleLabel?.font = unselectedTitle.font
                item.setTitleColor(unselectedTitle.color,
                                   for: .normal)
            }
        }
    }
    
    func updateUnderlinePosition(_ animate: Bool = true) {
        guard let buttons = self.titleButtons else {
            assert(false, "buttons nil")
            return
        }
        
        let index = selectedIndex.value
        let h: CGFloat = underlineHeight
    
        var x: CGFloat
        var w: CGFloat
        
        if let tW = underlineWidth {
            x = (buttons[index].frame.width - tW) * 0.5 + buttons[index].frame.minX
            w = tW
        } else {
            x = buttons[index].frame.minX
            w = buttons[index].frame.width
        }
        
        let boundsWidth = bounds.width
        let y = bounds.height - h
        
        var offsetX: CGFloat = (x + w) - boundsWidth
        offsetX = (offsetX >= 0 ? offsetX : 0)
        
        // over right
        if (contentOffset.x + boundsWidth) < (x + w) {
            setContentOffset(CGPoint(x: offsetX + insets.right, y: 0),
                             animated: true)
        // over left
        } else if (contentOffset.x > x) {
            setContentOffset(CGPoint(x: offsetX, y: 0),
                             animated: true)
        }
        
        if animate {
            UIView.animate(withDuration: 0.3) { [unowned self] in
                self.underline.frame = CGRect(x: x,
                                              y: y,
                                              width: w,
                                              height: h)
            }
        } else {
            underline.frame = CGRect(x: x,
                                     y: y,
                                     width: w,
                                     height: h)
        }
    }
}

class RemindButton: UIButton {
    private var remindView = FilletView(frame: CGRect.zero, filletRadius: 3)
    
    var needRemind: Bool = false {
        didSet {
            remindView.isHidden = !needRemind
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initViews()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initViews()
    }
    
    func initViews() {
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
