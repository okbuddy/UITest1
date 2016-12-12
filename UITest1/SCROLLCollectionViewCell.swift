//
//  SCROLLCollectionViewCell.swift
//  ZHKSwift
//
//  Created by zhk on 16/8/6.
//  Copyright © 2016年 zhk. All rights reserved.
//

import UIKit

class SCROLLCollectionViewCell: UICollectionViewCell {
    
    

    @IBOutlet weak var imageView1: UIImageView!
    
    @IBOutlet weak var surface: UIView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    override func awakeFromNib() {
//        self.translatesAutoresizingMaskIntoConstraints=false
        surface.autoresizingMask = [UIViewAutoresizing.FlexibleBottomMargin,UIViewAutoresizing.FlexibleLeftMargin,UIViewAutoresizing.FlexibleRightMargin,UIViewAutoresizing.FlexibleTopMargin]
        print("awake in scrollCell")
        let gradientLayer=CAGradientLayer()
        
        var bounds1=UIScreen.mainScreen().bounds
        bounds1.size.height=bounds1.width*0.8
        bounds1.origin.y = bounds1.width*0.2
        gradientLayer.frame=bounds1
        gradientLayer.colors = [UIColor.init(white: 0, alpha: 0).CGColor,UIColor.init(white: 0, alpha: 0.8).CGColor]
        //  设置三种颜色变化点，取值范围 0.0~1.0
        gradientLayer.locations = [0.0,1.0]
        //  设置渐变颜色方向，左上点为(0,0), 右下点为(1,1)
        gradientLayer.startPoint = CGPointMake(0, 0)
        gradientLayer.endPoint = CGPointMake(0, 1)
        imageView1.layer.addSublayer(gradientLayer)
        
    }
}
