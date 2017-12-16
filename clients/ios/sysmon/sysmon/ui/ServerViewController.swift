//
//  ServerViewController.swift
//  sysmon
//
//  Created by Jeff on 3/25/16.
//  Copyright © 2017 Jeff Batis. All rights reserved.
//

import UIKit

class ServerViewController: UIViewController {

    @IBOutlet weak var serverNameLabel: UILabel!
    
    var test = ServerTest()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        // Update server groups in case servers were added while navigated elsewhere
        //var index : NSIndexPath
        //cells.forEach({$0.reloadServerViews()})
        update();
        super.viewWillAppear(animated)
    }
    
    func setTest(test : ServerTest) {
        self.test = test
        update()
    }
    
    func update() {
        if let label = serverNameLabel {
            label.text = test.testProtocol + ":" + test.testHost
            label.frame = CGRectMake(2, 0, view.frame.width - 4, view.frame.height)
        }
        let testColor = SysmonTheme.currentTheme.getResultColor(self.test.getResult())
        view.backgroundColor = testColor;
    }
    
    func setFrameWidth(newWidth : CGFloat) {
        let edge : CGFloat = 4.0;
        let rect = CGRectInset(view.frame, edge, edge);
        serverNameLabel.frame = rect;
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
