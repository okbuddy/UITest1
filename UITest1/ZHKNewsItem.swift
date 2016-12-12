//
//  ZHKNewsItem.swift
//  UITest1
//
//  Created by zhk on 16/9/13.
//  Copyright © 2016年 zhk. All rights reserved.
//

import UIKit
import Alamofire

class ZHKNewsItem:NSObject {
    var id:Int=0
    var image:UIImage=UIImage()
    var title:String=""
    override init() {
        super.init()
    }
    init(id:Int, title:String) {
        super.init()
        self.id=id
        self.title=title
    }
}


