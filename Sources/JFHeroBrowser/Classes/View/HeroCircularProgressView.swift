//
//  HeroCircularProgressView.swift
//  Example
//
//  Created by 逸风 on 2021/8/8.
//

import UIKit

class HeroCircularProgressView: UIView {
    
    var progress: Double = 0.0 {
        willSet {
            if newValue > 1 {
                self.progress = 1
            } else if newValue < 0 {
                self.progress = 0
            } else {
                self.progress = newValue
            }
        }
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    class func commonImageProgressView() -> HeroCircularProgressView {
        let progressView = HeroCircularProgressView(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        return progressView
    }
    
    override func draw(_ rect: CGRect) {
        let size = rect.size
        let originP = CGPoint(x: size.width / 2, y: size.height / 2)
        let radius  = size.width / 2
        let startAngle: Double = .pi / -2
        let endAngle: Double = startAngle + self.progress * .pi * 2
        let circularPath = UIBezierPath(arcCenter: originP, radius: radius, startAngle: CGFloat(startAngle), endAngle: CGFloat(endAngle), clockwise: true)
        circularPath.addLine(to: originP)
        UIColor.jf.rgb(0xD8D8D8).set()
        circularPath.fill()
    }
    
}

extension HeroCircularProgressView: HeroCompatible {}
extension Hero where Base: HeroCircularProgressView {
    static func progressView() -> HeroCircularProgressView {
        return HeroCircularProgressView.commonImageProgressView()
    }
}
