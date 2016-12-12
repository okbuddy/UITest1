//
//  ZHKTopCollectionView.swift
//  UITest1
//
//  Created by zhk on 16/9/20.
//  Copyright © 2016年 zhk. All rights reserved.
//

import UIKit
import SnapKit

class ZHKTopCollectionView: UIView,UICollectionViewDataSource,UICollectionViewDelegate {
    let sectionMax=10
    @IBOutlet weak var imagesCollection: UICollectionView!
    
    @IBOutlet var view1: UIView!
    var timer:NSTimer?
    @IBOutlet weak var pageControl: UIPageControl!
    
    var top_stories=[AnyObject]()
    lazy var queue=NSOperationQueue()
    let ID="cell"
    lazy var dic=NSMutableDictionary()
    var nav:UINavigationController!
    
    convenience init(top_stories:[AnyObject], nav:UINavigationController,frame:CGRect){
        
        self.init(frame: frame)
        self.top_stories=top_stories
        self.nav=nav
        imagesCollection.scrollToItemAtIndexPath(NSIndexPath.init(forItem: 0, inSection: sectionMax/2), atScrollPosition: .CenteredHorizontally, animated: false)
        
        // Do any additional setup after loading the view.
        addNSTimer()
        pageControl.numberOfPages=top_stories.count
        
    }
    override init(frame: CGRect) {
        super.init(frame: frame)

        //add the colletionview
        view1=NSBundle.mainBundle().loadNibNamed("ZHKTopCollectionView", owner: self, options: nil)[0] as! UIView
        self.addSubview(view1)
        
        //change the UICollectionViewFlowLayout  setting the cell size
        let size1=frame.size
        let flow=UICollectionViewFlowLayout()
        flow.scrollDirection = .Horizontal
        flow.minimumLineSpacing=0
        flow.minimumInteritemSpacing=0
        flow.itemSize=size1
        imagesCollection.collectionViewLayout=flow
        
        view1.frame=self.bounds

        //register nib
        let nib=UINib.init(nibName: "SCROLLCollectionViewCell", bundle: nil)
        imagesCollection.registerNib(nib, forCellWithReuseIdentifier: ID)
        imagesCollection.dataSource=self
        imagesCollection.delegate=self
        

    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
//        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK:- ACTION seletPage
    
    func automaticallyScrollPage(){
        let index=self.imagesCollection.indexPathsForVisibleItems().last
        
        let index0=NSIndexPath.init(forItem: (index?.item)!, inSection: sectionMax/2)
        imagesCollection.scrollToItemAtIndexPath(index0, atScrollPosition: .CenteredHorizontally, animated: false)
        
        var index1=NSIndexPath.init(forItem: (index?.item)!+1, inSection: sectionMax/2)
        if (index?.item==top_stories.count-1) {
            index1=NSIndexPath.init(forItem: 0, inSection: sectionMax/2+1)
        }
        imagesCollection.scrollToItemAtIndexPath(index1, atScrollPosition: .CenteredHorizontally, animated: true)
        
    }
    
    func addNSTimer(){
        timer=NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: "automaticallyScrollPage", userInfo: nil, repeats: true)
        
    }
    func removeNSTimer(){
        timer?.invalidate()
        timer=nil
    }
    
    
    //MARK:-  UICollectionView DATASOURSE
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        print("number of section")
        return sectionMax
    }
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return top_stories.count
        
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell:SCROLLCollectionViewCell=imagesCollection.dequeueReusableCellWithReuseIdentifier(ID, forIndexPath: indexPath) as! SCROLLCollectionViewCell
        
        cell.imageView1.image=UIImage.init(named: "blueSquare.jpg")
        let story=top_stories[indexPath.row]
        let title=story["title"] as! String
        let imageStr=story["image"] as! String
        
        cell.titleLabel.text=title
        
        let mm=dic.valueForKey(imageStr)
        if (mm != nil)
        {
            cell.imageView1.image=mm as? UIImage
            return cell
        }
        
        let url=NSURL.init(string: imageStr)
        let operation=NSBlockOperation.init { () -> Void in
            let data=NSData.init(contentsOfURL: url!)
            if let data1=data {
                let mm1=UIImage.init(data: data1)
                print("\(NSThread.currentThread())")
                self.dic.setValue(mm1, forKey: imageStr)
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    cell.imageView1.image=mm1
                    
                })
            }
            
        }
        queue.addOperation(operation)
        
        return cell
    }
    
    
    
    //MARK:- UICollectionView Delegate
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let story=top_stories[indexPath.row]
        let id=String(story["id"])
        let webview=ZHKWebViewController.init(nibName: "ZHKWebViewController", bundle: nil)
        webview.id=id
        nav.pushViewController(webview, animated: true)
        nav.navigationBar.translucent=false

    }
    
    //MARK:- UIScrollView Delegate
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        removeNSTimer()
    }
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        addNSTimer()
    }
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let item=Int(round(imagesCollection.contentOffset.x/imagesCollection.frame.width))%top_stories.count
        pageControl.currentPage=item
    }
    

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
