//
//  ZHKSearchTableViewController.swift
//  UITest1
//
//  Created by zhk on 16/9/22.
//  Copyright © 2016年 zhk. All rights reserved.
//

import UIKit

class ZHKSearchTableViewController: UITableViewController ,UISearchBarDelegate{
        
    @IBOutlet weak var searchBar: UISearchBar!
    var itemsArr=[ZHKNewsItem]()
    var dbQueue:FMDatabaseQueue!
    let blue1=UIColor.init(red: 0, green: 210/255.0, blue: 1, alpha: 1)

    convenience init(dbqueue:FMDatabaseQueue!){
        self.init(nibName: "ZHKSearchTableViewController", bundle: nil)
        self.dbQueue=dbqueue
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title="Search Title"
        searchBar.delegate=self
        searchBar.becomeFirstResponder()
        self.tableView.registerClass(UITableViewCell.classForCoder(), forCellReuseIdentifier: "cell2")
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
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
    // MARK: - convenience func
    func getItemsFromSqliteWith(content:String)->Void
    {
        var item:ZHKNewsItem?
        self.dbQueue.inDatabase({ (db ) -> Void in
            
            let sql="select * from items where title like '%%\(content)%%'"
            do{
                
                let rs=try db.executeQuery(sql)
                while rs.next() {
                    print("get item")
                    let id=rs.intForColumn("id")
                    let title=rs.stringForColumn("title")
                    let image=UIImage.init(data: rs.dataForColumn("imageData"))
                    
                    item=ZHKNewsItem.init(id: Int(id), title: title)
                    item!.image=image!
                    self.itemsArr.append(item!)
                }
                rs.close()
            }catch let err as NSError {
                print("Cannot get:\(err.description)")
            }
        })
    }

    // MARK: - UISearchBarDelegate
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        
    }
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        let content=searchBar.text
        itemsArr.removeAll()
        getItemsFromSqliteWith(content!)
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return itemsArr.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell2", forIndexPath: indexPath)

        // Configure the cell...
        let item=itemsArr[indexPath.row]
        cell.imageView?.image=item.image
        cell.textLabel?.text=item.title
        return cell
    }
    // MARK: - UITableViewDelegate

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let story=itemsArr[indexPath.row]
        let id=story.id
        let webview=ZHKWebViewController.init(nibName: "ZHKWebViewController", bundle: nil)
        webview.id="\(id)"
        navigationController!.pushViewController(webview, animated: true)
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
