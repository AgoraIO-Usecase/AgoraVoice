//
//  FiletView.swift
//  FilletView
//
//  Created by CavanSu on 2020/3/25.
//  Copyright © 2020 CavanSu. All rights reserved.
//

import UIKit

protocol Fillet where Self: UIView {
    var insideBackgroundColor: UIColor? {get set}
    var strokeColor: UIColor? {get set}
    var filletRadius: CGFloat {get set}
    
    func drawFillet()
}

extension Fillet {
    func drawFillet() {
        let bezier = UIBezierPath(arcCenter: CGPoint(x: filletRadius, y: filletRadius),
                                  radius: filletRadius,
                                  startAngle: CGFloat.pi,
                                  endAngle: -(CGFloat.pi * 0.5),
                                  clockwise: true)
        
        let rightTopPoint = CGPoint(x: self.bounds.width - filletRadius, y: 0)
        bezier.addLine(to: rightTopPoint)
        
        bezier.addArc(withCenter: CGPoint(x: self.bounds.width - filletRadius, y: filletRadius),
                      radius: filletRadius,
                      startAngle: -(CGFloat.pi * 0.5),
                      endAngle: 0,
                      clockwise: true)

        let rightBottomPoint = CGPoint(x: self.bounds.width, y: self.bounds.height - filletRadius)
        bezier.addLine(to: rightBottomPoint)

        bezier.addArc(withCenter: CGPoint(x: self.bounds.width - filletRadius, y: self.bounds.height - filletRadius),
                      radius: filletRadius,
                      startAngle: 0,
                      endAngle: CGFloat.pi * 0.5,
                      clockwise: true)
        
        
        let leftBottomPoint = CGPoint(x: filletRadius, y: self.bounds.height)
        bezier.addLine(to: leftBottomPoint)
        
        bezier.addArc(withCenter: CGPoint(x: filletRadius, y: self.bounds.height - filletRadius),
                      radius: filletRadius,
                      startAngle: CGFloat.pi * 0.5,
                      endAngle: CGFloat.pi,
                      clockwise: true)
        let leftTopPoint = CGPoint(x: 0, y: filletRadius)
        bezier.addLine(to: leftTopPoint)
        
        insideBackgroundColor?.setFill()
        bezier.fill()
    }
}

class FilletView: UIView, Fillet {
    var insideBackgroundColor: UIColor? {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    var strokeColor: UIColor? {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    var filletRadius: CGFloat = 0.0 {
        didSet {
            guard filletRadius <= self.bounds.height * 0.5 else {
                filletRadius = self.bounds.height * 0.5
                return
            }
            self.setNeedsDisplay()
        }
    }
    
    init(frame: CGRect, filletRadius: CGFloat = 0.0) {
        self.filletRadius = filletRadius
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func draw(_ rect: CGRect) {
        drawFillet()
    }
}
