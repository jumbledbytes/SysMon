//
//  GroupViewController.swift
//  sysmon
//
//  Created by Jeff on 3/21/16.
//  Copyright © 2017 Jeff Batis. All rights reserved.
//

import UIKit

class GroupViewController: UITableViewController {
    
    var groupViewController: GroupViewController? = nil
    var serverGroup = Array<ServerTest>()
    var serverCount = 0
    var cells = [ServerTableViewCell]()
    var dataSource : Datasource.DatasourceInterface?;
    @IBOutlet weak var testGroupTitleLabel: UINavigationItem!
    var groupName : String = "Server Group" {
        didSet {
            if(self.testGroupTitleLabel != nil) {
                self.testGroupTitleLabel.title = groupName;
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.groupViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? GroupViewController
        }
        
        self.refreshControl?.addTarget(self, action: "handleRefresh:", forControlEvents: UIControlEvents.ValueChanged)
    }
    
    override func viewWillAppear(animated: Bool) {
        //self.update();
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.collapsed;
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configure(inout serverGroup : Array<ServerTest>) {
        self.serverGroup = serverGroup
    }
    
    func setDatasource(datasource : Datasource.DatasourceInterface) {
        self.dataSource = datasource;
    }
    
    func addServer(sender: AnyObject) {
        /*let server = Server(name: "Server \(serverCount)")
        serverGroup.addServer(server)
        let indexPath = NSIndexPath(forRow: serverCount, inSection: 0)
        self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        serverCount = serverCount + 1*/
    }
    
    func update() {
        dispatch_async(dispatch_get_main_queue(), {
            // update the display
            self.cells.forEach({$0.update()});
        })
    }
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        
        self.update();
        
        //self.tableView.reloadData()
        refreshControl.endRefreshing()
    }
    
    
    // MARK: - Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let server = serverGroup[indexPath.row]
                let controller = (segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController
                controller.detailTest = server
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }
    
    // MARK: - Table View
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return serverGroup.count;
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ServerCell", forIndexPath: indexPath) as! ServerTableViewCell
        ;
        var server = serverGroup[indexPath.row]
        cell.configure(&server)
        cells.append(cell);
        return cell
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete server from group?
            // tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
    
    
}

