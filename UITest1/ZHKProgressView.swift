//
//  ZHKProgressView.swift
//  UITest1
//
//  Created by zhk on 16/9/25.
//  Copyright © 2016年 zhk. All rights reserved.
//

import UIKit

class ZHKProgressView: UIView {
    
    var progressLayer:CAShapeLayer!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        progressLayer=buildShapeLayerColor(UIColor.whiteColor(), lineWidth: 4)
        self.buildView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func buildView()->Void {
    self.transform = CGAffineTransformMakeRotation(CGFloat(-M_PI_2))
    progressLayer.frame=bounds
    self.layer.addSublayer(progressLayer)
    self.progressLayer.strokeEnd = 0

    }
  
    func buildShapeLayerColor(color:UIColor, lineWidth:CGFloat)->CAShapeLayer {
    let layer=CAShapeLayer()
    // 设置path
    let path=UIBezierPath.init(ovalInRect: self.bounds)
    layer.path = path.CGPath
    // 设置layer
    layer.strokeColor = color.CGColor
    layer.fillColor = UIColor.clearColor().CGColor
    layer.lineWidth = lineWidth
    layer.lineCap = kCALineCapRound
    return layer
    }

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
