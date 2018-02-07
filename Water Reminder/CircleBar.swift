//
//  CircleBar.swift
//  WaterReminder
//
//  Created by Andrey Aksenov on 3/23/15.
//  Copyright (c) 2015 Suwao Ltd (suwao.com). All rights reserved.
//

import UIKit

@IBDesignable
class SUCircleBar: UIView {
    @IBInspectable var latency: CGFloat = 300
    @IBInspectable var padding: CGFloat = 2
    @IBInspectable var width: CGFloat = 6.0
    @IBInspectable var spacing: CGFloat = 8.0
    
    var barColor: UIColor = UIColor.red
    var barBackgroundColor: UIColor = UIColor.blue
    var barBorderColor: UIColor = UIColor.red
    
    fileprivate var progress: CGFloat = 0
    fileprivate var step: CGFloat = 0
    fileprivate var stage: CGFloat = 0

    fileprivate var timer: Timer?
    fileprivate var backgroundImage: UIImage?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.update()
    }
    
    func progress(_ value: CGFloat) {
        self.progress = value
        self.step = (self.progress - self.stage) / CGFloat(self.latency)
        if self.timer == nil {
            self.timer = Timer.scheduledTimer(timeInterval: 0.01, target:self, selector: #selector(SUCircleBar.update), userInfo:nil, repeats:true)
        }
    }
    
    func update() {
        if ((self.progress >= 0 && self.stage >= 0) || (self.progress <= 0 && self.stage <= 0)) && max(abs(self.progress), abs(self.stage)) - min(abs(self.progress), abs(self.stage)) < abs(self.step) {
            self.stage = self.progress
            self.timer?.invalidate()
            self.timer = nil;
        } else {
            self.stage = self.stage + self.step
        }
        self.setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let side = min(rect.size.width, rect.size.height) - self.padding * 2
        let canvas = CGRect(x: (rect.size.width - side) * 0.5, y: (rect.size.height - side) * 0.5, width: side, height: side)
        
        if self.spacing > 0 {
            if self.backgroundImage == nil {
                self.backgroundImage = circle(self.barBorderColor, size: canvas.size, width: self.width + self.spacing * 2)
            }
            self.backgroundImage!.draw(in: canvas)
        }
        
        let radius = (canvas.size.width - width) / 2 - self.spacing
        let startAngle = -M_PI_2
        for i in 0...1 {
            let endAngle = i == 0 ? CGFloat(M_PI_2) * 3.0 : CGFloat(-M_PI_2) + min(1.0, self.stage) * CGFloat(M_PI) * 2.0
            let color = i == 0 ? self.barBackgroundColor : self.barColor as UIColor!
            let path = UIBezierPath()
            path.addArc(withCenter: CGPoint(x: rect.size.width / 2, y: rect.size.height / 2), radius: radius, startAngle: CGFloat(startAngle), endAngle: CGFloat(endAngle), clockwise:true)
            path.lineWidth = self.width;
            color?.setStroke()
            path.stroke()
        }
    }
}
