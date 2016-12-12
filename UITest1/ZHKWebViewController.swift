//
//  ViewController.swift
//  UITest1
//
//  Created by zhk on 16/8/24.
//  Copyright © 2016年 zhk. All rights reserved.
//

import UIKit
import WebKit
import Alamofire
import SnapKit
class ZHKWebViewController: UIViewController {
    var id:String!
    var web:WKWebView!
    let blue1=UIColor.init(red: 0, green: 210/255.0, blue: 1, alpha: 1)

    @IBOutlet weak var tool: UIToolbar!
    override func viewDidLoad() {
        super.viewDidLoad()
       
        //add baritem
        let image1=UIImage.init(named: "backward.png")
        let b1=UIButton.init(frame: CGRect.init(x: 0, y: 0, width: 50, height: 40))
        b1.addTarget(self, action: "backward", forControlEvents: .TouchDown)
        b1.setBackgroundImage(image1, forState: .Normal)
        let baritem1=UIBarButtonItem.init(customView: b1)
        
        let image2=UIImage.init(named: "forward.png")
        let b2=UIButton.init(frame: CGRect.init(x: 0, y: 0, width: 50, height: 40))
        b2.setBackgroundImage(image2, forState: .Normal)
        b2.addTarget(self, action: "forward", forControlEvents: .TouchDown)
        let baritem2=UIBarButtonItem.init(customView: b2)
        
        tool.items=[baritem1,baritem2]
        self.web=WKWebView.init()
        self.web.allowsBackForwardNavigationGestures=true
        self.view.addSubview(self.web)
        web.snp_makeConstraints { (make) -> Void in
            make.left.right.top.equalTo(self.view)
            make.bottom.equalTo(tool.snp_top)
        }
        
        Alamofire.request(.GET, "http://news-at.zhihu.com/api/4/news/"+id!)
        .response { (_, response, data, err) -> Void in
            
            print(NSThread.currentThread())
            do{
                 let dic = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)
                let body=dic["body"] as! String
                
                let image_source=dic["image_source"] as! String
                let title=dic["title"] as! String
                let image=dic["image"] as! String
                let css=(dic["css"] as! Array<String>)[0]
                let path=NSBundle.mainBundle().pathForResource("css1", ofType: "html")
                var css1:String!
                do{
                    let str=try NSString.init(contentsOfFile: path!, encoding: NSUTF8StringEncoding)
                    css1=str as String
                }catch let err as NSError {
                    print(err.description)
                }
                let html=css1 +
                "<body><div id=\"outOne\" > <div class=\"box\"><img src=\"\(image)\"width=100% /><div class=\"back1\"></div><b class=\"word1\">\(title)</b><p class=\"word2\">图片:\(image_source)</p></div></div>"
                self.web.loadHTMLString(html+body, baseURL: nil)
                
            }catch let error as NSError {
                print(error.description)
            }
        }
       
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        //change navigationBar color
        navigationController?.navigationBar.translucent=false
        navigationController?.navigationBar.barTintColor=blue1
        navigationController?.navigationBar.tintColor=UIColor.whiteColor()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
    }
    // MARK: - add action
    func backward()->Void{
        if web.canGoBack {
            web.goBack()
        } else {
            navigationController?.popViewControllerAnimated(true)
        }
    }
    func forward()->Void{
        if web.canGoForward {
            web.goForward()
        } 
    }


}

