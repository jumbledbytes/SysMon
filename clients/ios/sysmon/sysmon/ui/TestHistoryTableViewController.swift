//
//  TestResultTableViewController.swift
//  sysmon
//
//  Created by Jeff on 5/21/16.
//  Copyright © 2017 Jeff Batis. All rights reserved.
//

import UIKit

class TestHistoryTableViewController: UITableViewController {
    
    var serverTest : ServerTest = ServerTest() {
        didSet {
            self.reloadHistory();
        }
    }
    var results : Array<TestResult> = Array<TestResult>();
    
    func reloadHistory() {
        results.removeAll();
        
        for(result) in serverTest.getHistory() {
            if(result.host == serverTest.testHost && result.protocolName == serverTest.testProtocol) {
                results.append(result);
            }
        }
        
        if(self.tableView != nil) {
            self.tableView.reloadData();
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let historySize = self.results.count;
        
        if(historySize == 0) {
            let emptyTestsLabel = UILabel();
            emptyTestsLabel.text = "No history available for " + serverTest.testProtocol + "://" + serverTest.testHost;
            emptyTestsLabel.textColor = UIColor.blackColor();
            emptyTestsLabel.numberOfLines = 0;
            emptyTestsLabel.textAlignment = NSTextAlignment.Center;
            emptyTestsLabel.sizeToFit();
            
            self.tableView.backgroundView = emptyTestsLabel;
            self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None;
        } else {
            self.tableView.backgroundView = nil;
        }
        return historySize;
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TestHistoryCell", forIndexPath: indexPath);
       
        let result = results[results.count - indexPath.row - 1];
        let formatter = NSDateFormatter()
        formatter.locale = NSLocale(localeIdentifier: "US_en")
        formatter.dateFormat = "MM/dd HH:mm:ss"
        let dateString = formatter.stringFromDate(result.resultTime);
        let resultText = dateString + "  " + String(result.testScore) + "  " + result.message;
        cell.textLabel!.text = resultText;
        
        return cell
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return false;
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
