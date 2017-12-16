//
//  ServerTableViewCell.swift
//  sysmon
//
//  Created by Jeff on 3/26/16.
//  Copyright © 2017 Jeff Batis. All rights reserved.
//

import UIKit

class ServerTableViewCell: UITableViewCell {
    @IBOutlet weak var serverView: UIView!
    @IBOutlet weak var serverNameLabel: UILabel!
    
    var test : ServerTest?;
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(inout serverTest: ServerTest) {
        self.test = serverTest;
        update();
    }
    
    func update() {
        if let serverTest = test {
            if let label = serverNameLabel {
                label.text = serverTest.testProtocol + ":" + serverTest.testHost;
            }
            let testColor = SysmonTheme.currentTheme.getResultColor(serverTest.getResult())
            self.contentView.backgroundColor = testColor;
            self.setNeedsLayout();
        }
    }

}
