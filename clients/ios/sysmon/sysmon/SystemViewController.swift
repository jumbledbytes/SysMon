//
//  SystemViewController.swift
//  sysmon
//
//  Created by Jeff on 3/21/16.
//  Copyright © 2017 Jeff Batis. All rights reserved.
//

import UIKit

class SystemViewController: UITableViewController {

    var systemViewController: SystemViewController? = nil;
    var groups = Dictionary<String /* group name */, Array<ServerTest>>()
    var groupNames = Array<String>()
    var cells = [ServerGroupTableViewCell]()
    var groupCount = 0
    var testList = Array<ServerTest>();
    var dataSource : Datasource.DatasourceInterface?;
    var testManager = ServerTestManager();
    var updateTimer = NSTimer();
    var updateInterval = 60.0;

    @IBOutlet var systemTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //self.navigationItem.leftBarButtonItem = self.editButtonItem()
        
        //let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "addServerGroup:")
        let reRunTestsButton = UIBarButtonItem(title: "Rerun", style: UIBarButtonItemStyle.Plain, target: self, action: "reRunTests");
        self.navigationItem.rightBarButtonItem = reRunTestsButton
        
        let logoutButton = UIBarButtonItem(title: "Logout", style: UIBarButtonItemStyle.Plain, target: self, action: "logout");
        self.navigationItem.leftBarButtonItem = logoutButton;
        
        self.systemTableView.separatorColor = UIColor.clearColor();
        self.systemTableView.separatorStyle = UITableViewCellSeparatorStyle.None;
        
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.systemViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? SystemViewController
            updateTimer.invalidate() // just in case this button is tapped multiple times
            
            // start the timer to regularly update the results
            updateTimer = NSTimer.scheduledTimerWithTimeInterval(updateInterval, target: self, selector: "loadResults", userInfo: nil, repeats: true)
            
        }
        
        self.navigationController?.setNavigationBarHidden(false, animated: true);
        self.refreshControl?.addTarget(self, action: "handleRefresh:", forControlEvents: UIControlEvents.ValueChanged)
        
    }

    override func viewWillAppear(animated: Bool) {
        // Update server groups in case servers were added while navigated elsewhere
        //var index : NSIndexPath
        //cells.forEach({$0.reloadServerViews()})
        update(self.testList.count == 0);
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.collapsed
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func logout() {
        self.performSegueWithIdentifier("logout", sender: self);
    }
    
    func handleError(message: String) {
        dispatch_async(dispatch_get_main_queue(), {
            self.showAlert(message);
            self.resetTests();
            self.cells.forEach({$0.update()});
        });
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message,  preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func resetTests() {
        // set all test scores to -1
        for test in self.testList {
            test.getResult().testScore = -1;
        }
    }
    
    func setDatasource(datasource :Datasource.DatasourceInterface) {
        self.dataSource = datasource;
    }
    
    func update(loadTests : Bool = false) {
        dispatch_async(dispatch_get_main_queue(), {
            if(loadTests) {
                self.loadTheme();
                self.loadTests();
            }
            self.loadResults();
            self.loadHistory();
        });
    }
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        
        update(false);
        
        //self.tableView.reloadData()
        refreshControl.endRefreshing()
    }
    
    func loadTheme() {
        dataSource?.updateTheme({ (SysmonTheme) -> Void in
            dispatch_async(dispatch_get_main_queue(), {
                // update the display
                self.cells.forEach({$0.update()});
            })
        },
                                onError: {(errorMessage: String) -> Void in
                                    self.handleError(errorMessage);
        });
    }
    
    func loadTests() {
        dataSource?.updateTests({ (tests : ServerTestGroup) -> Void in
            dispatch_async(dispatch_get_main_queue(), {
                self.groups.removeAll();
                self.testList = tests.getTests();
                self.groupCount = 0
                self.cells.removeAll();
                self.groupNames.removeAll();
                self.tableView.reloadData();
                for test in self.testList {
                    if var _ = self.groups[test.testGroup] {
                        // test group exists, add test to group
                        self.groups[test.testGroup]?.append(test)
                    } else {
                        // test group doesn't exist, create the group and add the test to the new group
                        self.groups[test.testGroup] = Array<ServerTest>();
                        self.groups[test.testGroup]!.append(test);
                        self.groupNames.append(test.testGroup)
                        
                        // add the group to the table
                        let indexPath = NSIndexPath(forRow: self.groupCount, inSection: 0)
                        self.groupCount++;
                        self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
                    }
                }
                // Configure the test group cells with the group info for the cell
                for(var i=0; i<self.groupNames.count; i++) {
                    let groupName = self.groupNames[i]
                    self.cells[i].configure(groupName, serverGroup: self.groups[groupName]!)
                }
                
                // update the display
                self.cells.forEach({$0.reloadServerViews()});
                
                // Update results for any new tests loaded
                self.loadResults();
            })
        },
            onError: {(errorMessage: String) -> Void in
                self.showAlert(errorMessage);
        });
    }
    
    func loadResults() {
        dataSource?.updateResults({ (results : ServerResultGroup ) -> Void in
            dispatch_async(dispatch_get_main_queue(), {
                // update the display
                self.cells.forEach({$0.update()});
            })
            },
                                  onError: {(errorMessage: String) -> Void in
                                     self.handleError(errorMessage);
        });
    }
    
    func loadHistory() {
        dataSource?.updateHistory({ (results : ServerResultGroup ) -> Void in
            // process history if necessary
            },
                                  onError: {(errorMessage: String) -> Void in
                                     self.handleError(errorMessage);
        });
    }
    
    func reRunTests() {
        resetTests();
        
        dataSource?.runTest({() -> Void in
            dispatch_async(dispatch_get_main_queue(), {
                // update the display
                self.cells.forEach({$0.update()});
            })
            },
                            onError: {(errorMessage: String) -> Void in
                                self.handleError(errorMessage);
        });
    }
    
    func addServerGroup(sender: AnyObject) {
        /*let newGroup = ServerGroup();
        newGroup.groupName = "Group \(groupCount)"
        groupCount++
        groups.insert(newGroup, atIndex: 0)
        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
        self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        
        cells.forEach({$0.reloadServerViews()})*/
        
    }

    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        cells.forEach({$0.reloadServerViews()});
    }
    
    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showGroup" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let groupName = self.groupNames[indexPath.row]
                let controller = (segue.destinationViewController as! UINavigationController).topViewController as! GroupViewController
                controller.configure(&groups[groupName]!)
                controller.setDatasource(self.dataSource!);
                controller.groupName = groupName;
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
        if segue.identifier == "logout" {
            let controller = (segue.destinationViewController as! LoginViewController)
            controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
            controller.navigationItem.leftItemsSupplementBackButton = true
        }
    }

    // MARK: - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(self.groupCount == 0) {
            let emptyTestsLabel = UILabel();
            emptyTestsLabel.text = "No tests are published by server"
            emptyTestsLabel.textColor = UIColor.blackColor();
            emptyTestsLabel.numberOfLines = 0;
            emptyTestsLabel.textAlignment = NSTextAlignment.Center;
            emptyTestsLabel.sizeToFit();
            
            self.tableView.backgroundView = emptyTestsLabel;
            self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None;
        } else {
            self.tableView.backgroundView = nil;
        }
        return self.groupCount;
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ServerGroupCell", forIndexPath: indexPath) as! ServerGroupTableViewCell

        let groupName = groupNames[indexPath.row]
        cell.configure(groupName, serverGroup: self.groups[groupName]!)
        cells.append(cell)
        return cell
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // TODO: Delete group?
            // tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }


}

