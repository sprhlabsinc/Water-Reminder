//
//  WeekGraph.swift
//  WaterReminder
//
//  Created by Andrey Aksenov on 3/25/15.
//  Copyright (c) 2015 Suwao Ltd (suwao.com). All rights reserved.
//

import UIKit

//@IBDesignable
class SUWeekGraph: UIView {
    var width: CGFloat = UIScreen.main.bounds.width / 9
    var padding: CGFloat = 8.0
    var bars: [SUVerticalBar]?
    var overlay = CAShapeLayer()
    var mainColor = UIColor.red
    var borderColor = UIColor.blue
    var borderWidth: CGFloat = 8.0
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.adjust()
    }
    
    func adjust() {
        if self.bars == nil {
            self.overlay.zPosition = self.layer.zPosition + 1
            self.bars = [SUVerticalBar]()
            for i in 0 ..< 7 {
                if let bar = Bundle.main.loadNibNamed("VerticalBarView", owner: self, options: nil)?.first as? SUVerticalBar {
                    bar.data0Label.text = "0.0L"
                    let spacing = ((self.frame.size.width - self.padding * 2.0) - (self.width * 7)) / 6
                    bar.frame = CGRect(x: self.padding + spacing * CGFloat(i) + CGFloat(i) * self.width, y: self.padding, width: self.width, height: self.frame.size.height - self.padding * 2)
                    bar.parent = self
                    bar.capView = UIImageView(image: filledCircle(self.mainColor, borderColor: self.borderColor, size: CGSize(width: self.width, height: self.width), width: self.borderWidth))
                    self.addSubview(bar)
                    self.addSubview(bar.capView!)
                    bar.capView!.layer.zPosition = self.overlay.zPosition + 1
                    self.bars?.append(bar)
                }
            }
            self.layer.addSublayer(overlay)
        }
        for i in 0 ..< 7 {
            let bar = self.bars![i]
            let spacing = ((self.frame.size.width - self.padding * 2.0) - (self.width * 7)) / 6
            bar.frame = CGRect(x: self.padding + spacing * CGFloat(i) + CGFloat(i) * self.width, y: self.padding, width: self.width, height: self.frame.size.height - self.padding * 2)
            bar.capView!.center = CGPoint(x: bar.frame.midX, y: bar.indicatorView.frame.minY + self.padding)
            bar.needsUpdateConstraints()
            bar.layoutIfNeeded()
        }
    }
    
    func caps(_ mainColor: UIColor, borderColor: UIColor, borderWidth: CGFloat) {
        self.mainColor = mainColor
        self.borderColor = borderColor
        self.borderWidth = borderWidth
        if self.bars != nil  {
            for bar in self.bars! {
                if bar.capView != nil {
                    bar.capView!.image = filledCircle(self.mainColor, borderColor: self.borderColor, size: CGSize(width: self.width, height: self.width), width: self.borderWidth * 1)
                }
            }
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        var point: CGPoint?
        
        if self.bars != nil {
            self.overlay.lineWidth = self.borderWidth
            self.overlay.fillColor = self.mainColor.cgColor
            self.overlay.strokeColor = self.borderColor.cgColor
            
//            let side = (self.width - self.overlay.lineWidth) / 2
            let path = UIBezierPath()
            for bar in self.bars! {
                if point != nil {
                    path.move(to: point!)
                    path.addLine(to: CGPoint(x: bar.frame.midX, y: bar.indicatorView.frame.minY + self.padding))
                }
                point = CGPoint(x: bar.frame.midX, y: bar.indicatorView.frame.minY + self.padding)
                bar.capView?.center = point!
            }
            self.overlay.path = path.cgPath
            self.overlay.rasterizationScale = UIScreen.main.scale
            self.overlay.shouldRasterize = true
        }
    }
}


class SUVerticalBar: UIView {
    @IBOutlet weak var indicatorView: UIView!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var data0Label: UILabel!
    @IBOutlet weak var data1Label: UILabel!
    @IBOutlet weak var markerView: UIView!
    var capView: UIImageView?

    @IBOutlet weak var data0LabelHeight: NSLayoutConstraint!
    @IBOutlet weak var data1LabelHeight: NSLayoutConstraint!
    @IBOutlet weak var indicatorViewHeight: NSLayoutConstraint!

    var parent: SUWeekGraph?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func position(_ value: CGFloat) {
        self.layoutIfNeeded()
//        self.position = value
        let max = self.frame.height - self.data0LabelHeight.constant - self.data1LabelHeight.constant - self.frame.width - self.markerView.frame.height
        let height = self.frame.width / 2 + (value >= 1 ? max : max * value)
        let count: Int = 50
        let step = (height - self.indicatorViewHeight.constant) / CGFloat(count)
        for i in 0 ..< count {
            delay(0.01 * Double(i), closure: { _ in
                self.indicatorViewHeight.constant += step
                self.layoutIfNeeded()
                if self.parent != nil {
                    self.parent!.setNeedsDisplay()
                }
            })
        }
    }
}
