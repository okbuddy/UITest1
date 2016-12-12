//
//  ZHKZhihuTableViewController.swift
//  UITest1
//
//  Created by zhk on 16/9/15.
//  Copyright © 2016年 zhk. All rights reserved.
//

import UIKit
import Alamofire
import SnapKit

class ZHKZhihuTableViewController: UITableViewController {
    
    var datesArr=[String]()
    var stories=[[AnyObject]]()
    var top_stories=[AnyObject]()

    var itemsArr=[[ZHKNewsItem]]()
    var dbQueue:FMDatabaseQueue!
    var isLoading=false
    var frontRows=0
    var originFrame:CGRect!
    //header
    var collectionheader:ZHKTopCollectionView!
    let progress:ZHKProgressView=ZHKProgressView.init(frame: CGRectMake(0, 0, 30, 30))
    //color
    let blue1=UIColor.init(red: 0, green: 210/255.0, blue: 1, alpha: 1)
    // MARK: - override

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.titleView=progress
        //tableview rowheight
        tableView.rowHeight=55
        //nav
        navigationItem.rightBarButtonItem=UIBarButtonItem.init(barButtonSystemItem: .Search, target: self, action: "toSearch")
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
        //sqlite
        let documentsFolder = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        let path = documentsFolder.stringByAppendingString("/items.sqlite")
        print("databasePath:\(path)")
        dbQueue=FMDatabaseQueue.init(path: path)
        
        dbQueue.inDatabase { (db) -> Void in
            if !db.executeUpdate("create table if not exists items(id integer primary key,title text,imageData blob)", withArgumentsInArray: nil){
                print("create table failed")
            }
        }
        //register cell
        self.tableView.registerClass(UITableViewCell.classForCoder(), forCellReuseIdentifier: "cell1")
        self.tableView.registerClass(UITableViewHeaderFooterView.classForCoder(), forHeaderFooterViewReuseIdentifier: "header1")
        //Alamofire network
        let queue=dispatch_queue_create("queue1", DISPATCH_QUEUE_SERIAL)
        let semaphore=dispatch_semaphore_create(0)
        Alamofire.request(.GET, "http://news-at.zhihu.com/api/4/news/latest")
            .response(queue: queue, completionHandler:{ (_, _, data , _ ) -> Void in
                    do{
                        let dic=try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)
                        let arr=dic["stories"] as! [AnyObject]
                        self.stories.append(arr)
                        self.top_stories=dic["top_stories"] as! [AnyObject]
                        
                        let date=dic["date"] as! String
                        self.datesArr.append(date)
                        // add empty itemArr
                        var itemsArr1=[ZHKNewsItem]()
                        for i in 1...arr.count{
                            itemsArr1.append(ZHKNewsItem())
                            }
                        
                        self.itemsArr.append(itemsArr1)
                        dispatch_semaphore_signal(semaphore)
                        
                    }catch let err as NSError {
                        print(err.description)
                    }
                })

        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
        
        //add header
        var bounds1=UIScreen.mainScreen().bounds
        bounds1.size.height=0.4*bounds1.width
        originFrame=bounds1
        collectionheader=ZHKTopCollectionView.init(top_stories: top_stories, nav: navigationController!, frame: bounds1)
        tableView.tableHeaderView=collectionheader


        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
//        let view1=UIView.init(frame: CGRect.init(x: 100, y: 100, width: 100, height: 100))
//        view1.backgroundColor=UIColor.greenColor()
//        self.view.addSubview(view1)
//        let c1=NSLayoutConstraint.constraintsWithVisualFormat("|-0-[view1]-0-|", options: [], metrics: nil, views:["view1":view1] )
//        self.view.addConstraints(c1)
//        let c2=NSLayoutConstraint.init(item: view1, attribute: .Width, relatedBy: .Equal, toItem: self.view, attribute: .Width, multiplier: 0.2, constant: 400)
//        self.view.addConstraint(c2)
//        view1.translatesAutoresizingMaskIntoConstraints=false
//        self.view.translatesAutoresizingMaskIntoConstraints=false
//        self.view.autoresizesSubviews=false
        
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
    }
    // MARK: - button action
    func toSearch()->Void{
        navigationController?.pushViewController(ZHKSearchTableViewController.init(dbqueue: dbQueue), animated: true)
    }
    // MARK: - save and get item from Sqlite
    func saveItems(item:ZHKNewsItem)
    {
        let queue=dispatch_get_global_queue(0, 0)
        dispatch_async(queue) { () -> Void in
            self.dbQueue.inDatabase({ (db ) -> Void in
                let id=item.id
                let title=item.title
                var imageData=UIImagePNGRepresentation(item.image)
                if imageData==nil {
                    imageData=UIImageJPEGRepresentation(item.image, 1)
                    print("picture is JPEG")
                } else {
                    print("picture is PNG")
                }
                let sql="insert into items values(?,?,?)"
                if !db.executeUpdate(sql, withArgumentsInArray: [id, title, imageData ?? NSNull()]) {
                    print("insert failed")
                }
                else{
                    print("insert succeed")
                }
            })
        }
        
    }
    func getItemWith(id:Int)->ZHKNewsItem?
    {
        var item:ZHKNewsItem?
        self.dbQueue.inDatabase({ (db ) -> Void in
            let sql="select * from items where id=?"
            do{
                let rs=try db.executeQuery(sql, id)
                if rs.next() {
                    print("get item")
                    let id=rs.intForColumn("id")
                    let title=rs.stringForColumn("title")
                    let image=UIImage.init(data: rs.dataForColumn("imageData"))
                    
                    item=ZHKNewsItem.init(id: Int(id), title: title)
                    item!.image=image!
                }
                rs.close()
            }catch let err as NSError {
                print("Cannot get:\(err.description)")
            }
        })
        return item
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return stories.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        let a=stories[section].count
        print("section count : \(a)")
        return stories[section].count
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//        print(indexPath.section)
        let cell = tableView.dequeueReusableCellWithIdentifier("cell1", forIndexPath: indexPath)
        cell.imageView?.image=UIImage.init(named: "blueSquare.jpg")
        cell.imageView?.sd_setImageWithURL(<#T##url: NSURL!##NSURL!#>)

        // Configure the cell...
        let stories1=stories[indexPath.section]
        let story=stories1[indexPath.row]
        let id=story["id"] as! Int
        let title=story["title"] as! String
        let imageStr=(story["images"] as! Array<String>)[0]
        
        cell.textLabel?.text=title
        
        var itemsArr1=itemsArr[indexPath.section]
        //get item from sqlite arr or network
        let manager=SDWebImageManager.sharedManager()
        if self.frontRows>0 {
            manager.downloadImageWithURL(NSURL.init(string: imageStr), options: [], progress: { (_ , _ ) -> Void in
                
                }) { (image, _, _, finished, url ) -> Void in
                    
                    if image==nil {
                        return
                    }
                    
                    cell.imageView?.image=self.thumbnail(image)
                    
                    let item=ZHKNewsItem.init(id: id, title: title)
                    item.image=(cell.imageView?.image)!
                    //inset into array
                    self.itemsArr[indexPath.section][indexPath.row]=item
                    self.frontRows--
                    //insert into sqlite
                    self.saveItems(item)
            }
        } else {
            let item=itemsArr1[indexPath.row]
            if item.id != 0 {
                cell.imageView?.image=item.image
                
            } else {
                if  let item=self.getItemWith(id){
                    itemsArr[indexPath.section][indexPath.row]=item
                    cell.imageView?.image=item.image
                    
                } else {
                    manager.downloadImageWithURL(NSURL.init(string: imageStr), options: [], progress: { (_ , _ ) -> Void in
                        
                        }) { (image, _, _, finished, url ) -> Void in
                            
                            if image==nil {
                                return
                            }
                            let little=self.thumbnail(image)
                            cell.imageView?.image=little
                            
                            let item=ZHKNewsItem.init(id: id, title: title)
                            item.image=little
                            //inset into array
                            self.itemsArr[indexPath.section][indexPath.row]=item
                            //insert into sqlite
                            self.saveItems(item)
                    }
                }
                
            }

        }
       
        return cell
    }
    
    // MARK: - UIScrollViewDelegate

    override func scrollViewDidScroll(scrollView: UIScrollView) {
        
       
        //change the height of collectionView
        let top=tableView.tableHeaderView as! ZHKTopCollectionView
        let topview=top.view1
        let offset=scrollView.contentOffset.y
        var frame=originFrame
        if offset<topview.frame.height {
            frame.origin.y += offset
            frame.size.height -= offset
            topview.frame=frame
        }
        let flow=top.imagesCollection.collectionViewLayout as! UICollectionViewFlowLayout
        flow.itemSize=topview.frame.size
        //change nav color
        if offset>originFrame.height {
            self.navigationController?.navigationBar.translucent=false
        } else {
            self.navigationController?.navigationBar.translucent=true

        }
        //change radian according to the progress
        if navigationItem.titleView != nil {
            let radio = -((offset+64.0) / (tableView.frame.size.height*0.1))
            progress.progressLayer.strokeEnd = radio
        }
        
        //update content
        if (!isLoading) { // 判断是否处于刷新状态，刷新中就不执行
            // 取内容的高度：
            
            //    如果内容高度大于UITableView高度，就取TableView高度
            
            //    如果内容高度小于UITableView高度，就取内容的实际高度
            
           let height = scrollView.contentSize.height > tableView.frame.size.height ? tableView.frame.size.height : scrollView.contentSize.height
            if ((height - scrollView.contentSize.height + scrollView.contentOffset.y) / height > 0.1) {
                isLoading=true
                // 调用上拉刷新方法
                let queue=dispatch_queue_create("queue1", DISPATCH_QUEUE_SERIAL)
                let semaphore=dispatch_semaphore_create(0)
                let dateStr=datesArr.last
                Alamofire.request(.GET, "http://news-at.zhihu.com/api/4/news/before/"+dateStr!)
                    .response(queue: queue, completionHandler:{ (_, _, data , _ ) -> Void in
                        do{
                            let dic=try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)
                            let arr=dic["stories"] as! [AnyObject]
                            self.stories.append(arr)
                            
                            let date=dic["date"] as! String
                            self.datesArr.append(date)
                            // add empty itemArr
                            var itemsArr1=[ZHKNewsItem]()
                            for i in 1...arr.count{
                                itemsArr1.append(ZHKNewsItem())
                            }
                            self.itemsArr.append(itemsArr1)
//                            dispatch_sync(dispatch_get_main_queue(), { () -> Void in
//                                self.tableView.insertSections(NSIndexSet.init(index: self.datesArr.count-1),withRowAnimation: .Bottom)
//
//                            })
                            
                            dispatch_semaphore_signal(semaphore)
                            
                        }catch let err as NSError {
                            print(err.description)
                        }
                    })
                
                dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
                //insert the sections
                self.tableView.insertSections(NSIndexSet.init(index: self.datesArr.count-1), withRowAnimation: .Bottom)
                isLoading=false
            }
            
            if (-(scrollView.contentOffset.y+64) / tableView.frame.size.height > 0.1) {
                var MARK=0
                var indexPaths=[NSIndexPath]()
                isLoading=true
                // 调用下拉刷新方法
                let queue=dispatch_queue_create("queue1", DISPATCH_QUEUE_SERIAL)
                let semaphore=dispatch_semaphore_create(0)
                let dateStr=datesArr.first
                // get the date
                let nextstr=stringOfNextDay(dateStr)
                //string of today
                let today=NSDate()
                let formatter=NSDateFormatter()
                formatter.dateFormat="yyyyMMdd"
                let todayStr=formatter.stringFromDate(today)
                
                var news="http://news-at.zhihu.com/api/4/news/before/"+nextstr
                if dateStr == todayStr {
                    news="http://news-at.zhihu.com/api/4/news/latest"
                }
                Alamofire.request(.GET, news)
                    .response(queue: queue, completionHandler:{ (_, _, data , _ ) -> Void in
                        do{
                            let dic=try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)
                            let arr=dic["stories"] as! [AnyObject]
                            let date=dic["date"] as! String

                            if arr.count>self.stories.first?.count {
                                    MARK=1
                                    self.frontRows=arr.count-(self.stories.first?.count)!
                                    self.stories[0]=arr
                                    for i in 0..<self.frontRows
                                    {
                                        indexPaths.append(NSIndexPath.init(forRow: i, inSection: 0))
                                    }
                                for i in 1...self.frontRows{
                                    self.itemsArr[0].insert(ZHKNewsItem(), atIndex: 0)
                                }
                                //update topnews
                                if dateStr == todayStr {
                                    let top_stories=dic["top_stories"] as! [AnyObject]
                                    self.collectionheader.top_stories=top_stories
                                    self.collectionheader.imagesCollection.reloadData()
                                }
                                
                                dispatch_semaphore_signal(semaphore)

//                                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
//                                        self.tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: .Right)
//                                        
//                                    })
                                }
                            else{
                                    if date != todayStr  {
                                        MARK=2
                                        let str1=self.stringOfNextDay(nextstr)
                                        Alamofire.request(.GET, "http://news-at.zhihu.com/api/4/news/before/"+str1)
                                            .response(queue: queue, completionHandler:{ (_, _, data , _ ) -> Void in
                                                do{
                                                    let dic=try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)
                                                    let arr=dic["stories"] as! [AnyObject]
                                                    self.stories.insert(arr, atIndex: 0)
                                                    
                                                    let date=dic["date"] as! String
                                                    self.datesArr.insert(date, atIndex: 0)
                                                    // add empty itemArr
                                                    var itemsArr1=[ZHKNewsItem]()
                                                    for i in 1...arr.count{
                                                        itemsArr1.append(ZHKNewsItem())
                                                    }
                                                    self.itemsArr.insert(itemsArr1, atIndex: 0)
                                                    
                                                    dispatch_semaphore_signal(semaphore)

                                                }catch let err as NSError {
                                                    print(err.description)
                                                }
                                            })
                                    }
                                    else{
                                        dispatch_semaphore_signal(semaphore)

                                }
                                }
                            
                        }catch let err as NSError {
                            print(err.description)
                        }
                        
                    })
                
                dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
                //insert the sections
                switch MARK{
                case 1:
                    self.tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: .Right)
                    break
                case 2:
                    self.tableView.insertSections(NSIndexSet.init(index: 0),withRowAnimation: .Right)
                    break
                default: break
                }
                isLoading=false
                
            }
        }
    }
    // MARK: - UITableViewDelegate
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
   
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header=tableView.dequeueReusableHeaderFooterViewWithIdentifier("header1")
        header?.contentView.backgroundColor=blue1
        header?.tintColor=UIColor.whiteColor()
        let label=(header?.textLabel)!
        //change form
        let str1=getTextFromBriefDate(datesArr[section])
        label.text=str1
        label.textAlignment = .Center
        label.backgroundColor=blue1
        label.textColor=UIColor.whiteColor()
        return header
    }
    override func tableView(tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int) {
        let y=tableView.rectForHeaderInSection(section).origin.y
        if y-tableView.contentOffset.y > 200 {
            return
        }
        let formatter=NSDateFormatter()
        formatter.dateFormat="yyyyMMdd"

        if section == 0 {
            self.navigationItem.titleView=nil
        }
        let str=datesArr[section]
        self.navigationItem.title=getTextFromBriefDate(str)
        
    }
    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let y=tableView.rectForHeaderInSection(section).origin.y
        if y-tableView.contentOffset.y > 200 {
            return
        }
        //first element? today?
        let formatter=NSDateFormatter()
        formatter.dateFormat="yyyyMMdd"

        if section == 0 {
            self.navigationItem.titleView=progress
        } else {
            let str=datesArr[section-1]
            self.navigationItem.title=getTextFromBriefDate(str)
        }
        
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let story=itemsArr[indexPath.section][indexPath.row]
        let id=story.id
        let webview=ZHKWebViewController.init(nibName: "ZHKWebViewController", bundle: nil)
        webview.id="\(id)"
        navigationController!.pushViewController(webview, animated: true)
    }
    // MARK: - func
    func getTextFromBriefDate(str:String)->String{
        let formatter=NSDateFormatter()
        formatter.dateFormat="yyyyMMdd"
        let date1=formatter.dateFromString(str)
        formatter.dateStyle = .FullStyle
        let str1=formatter.stringFromDate(date1!)
        return str1
    }
    func stringOfNextDay(currentDayStr:String!)->String{
        let formatter=NSDateFormatter()
        formatter.dateFormat="yyyyMMdd"
        let date1=formatter.dateFromString(currentDayStr)
        let date2=date1?.dateByAddingTimeInterval(24*60*60)
        let str=formatter.stringFromDate(date2!)
        return str
    }
    
    func thumbnail(image:UIImage)->UIImage!{
        let length=tableView.rowHeight
        UIGraphicsBeginImageContextWithOptions(CGSize.init(width: length, height: length), false, 0.0)
        let border:CGFloat=1.5
        let rect=CGRect.init(x: border, y: border, width: length-2*border, height: length-2*border)
        let path1=UIBezierPath.init(ovalInRect: rect)
        path1.lineWidth=2*border
        UIColor.redColor().setStroke()
        path1.stroke()
        
        path1.addClip()
        image.drawInRect(rect)
        let thumbnail=UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return thumbnail
    }
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
