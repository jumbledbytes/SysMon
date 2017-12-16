//
//  ServerGroupTableViewCell.swift
//  sysmon
//
//  Created by Jeff on 3/26/16.
//  Copyright © 2017 Jeff Batis. All rights reserved.
//

import UIKit

class ServerGroupTableViewCell: UITableViewCell {

    @IBOutlet weak var groupView: UIView!
    @IBOutlet weak var serverView: UIView!
    @IBOutlet weak var serverGroupLabel: UILabel!
    
    var serverViews = [ServerViewController]()
    var serverDict = Dictionary<String, ServerViewController>()
    var viewsDict = Dictionary<String, UIView>()
    var metricsDict = Dictionary<String, Float>()
    var serverTests = Array<ServerTest>()
    var testGroupName = ""
    var cellHeight :CGFloat = 30.0
    var cellWidth : CGFloat = 16.0
    var groupWidth : CGFloat = 60.0
    var cellSpacing : CGFloat = 1.0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    func configure(groupName : String, serverGroup : Array<ServerTest>) {
        self.testGroupName = groupName
        self.serverTests.removeAll()
        self.serverDict.removeAll()
        serverGroup.forEach({addTest($0)})
    }
    
    func update() {
        self.serverViews.forEach({
            $0.update()
        })
    }
    
    func addTest(test: ServerTest) {
        if(serverDict[test.testHost] == nil ){
            serverTests.append(test)
            reloadServerViews()
        }
    }
    
    func reloadServerViews() {
        serverViews.removeAll()
        serverDict.removeAll()
        
        serverTests.forEach({
            let serverView = ServerViewController()
            serverView.setTest($0)
            serverView.view.translatesAutoresizingMaskIntoConstraints = false
            serverView.view.frame = CGRectMake(0, 0, 50, 16)
            serverViews.append(serverView)
            serverDict[$0.testProtocol + ":" + $0.testHost] = serverView
        })
        
        layoutServerViews()
        
    }
    
    func layoutServerViews() {
        dispatch_async(dispatch_get_main_queue(), {
            
            let serverWidth = (self.bounds.size.width) - self.groupWidth - (CGFloat(self.serverViews.count) * self.cellSpacing)
            if(self.serverViews.count > 0) {
                self.cellWidth =  serverWidth / (CGFloat(self.serverViews.count))
            }
            
            let stackView   = UIStackView()
            stackView.axis  = UILayoutConstraintAxis.Horizontal
            stackView.distribution  = UIStackViewDistribution.Fill
            stackView.alignment = UIStackViewAlignment.Leading
            stackView.spacing   = self.cellSpacing
            
            let groupNameView = UIView()
            groupNameView.backgroundColor=UIColor.blackColor()
            let groupNameLabel = UILabel(frame: CGRectMake(2, 0, self.groupWidth-4, self.cellHeight))
            groupNameLabel.textColor = UIColor.whiteColor()
            groupNameLabel.text = self.testGroupName
            groupNameLabel.font = groupNameLabel.font.fontWithSize(10)
            groupNameView.addSubview(groupNameLabel)
            self.serverView.addSubview(groupNameView)
            groupNameView.heightAnchor.constraintEqualToConstant(self.cellHeight).active = true;
            groupNameView.widthAnchor.constraintGreaterThanOrEqualToConstant(self.groupWidth).active = true;
            
            stackView.addArrangedSubview(groupNameView)
            self.serverViews.forEach({
                $0.update()
                self.serverView.addSubview($0.view)
                
                $0.view.layer.borderWidth=1
                $0.view.heightAnchor.constraintEqualToConstant(self.cellHeight).active = true
                $0.view.widthAnchor.constraintEqualToConstant(self.cellWidth).active = true
                
                stackView.addArrangedSubview($0.view)
                
                $0.setFrameWidth(self.cellWidth)
            })
            
            stackView.translatesAutoresizingMaskIntoConstraints = false;
            stackView.backgroundColor = UIColor.blueColor()
            
            self.serverView.addSubview(stackView)
            
            //Constraints
            stackView.centerXAnchor.constraintEqualToAnchor(self.serverView.centerXAnchor).active = false
            stackView.centerYAnchor.constraintEqualToAnchor(self.serverView.centerYAnchor).active = true
            stackView.frame = self.serverView.frame
        })
        
    }
    
    func addView(stackView : UIStackView, view : UIView) {
        view.widthAnchor.constraintGreaterThanOrEqualToConstant(16.0).active = true
        view.heightAnchor.constraintGreaterThanOrEqualToConstant(16.0).active = true
        view.backgroundColor = UIColor.redColor()
        serverView.addSubview(view)
        stackView.addArrangedSubview(view)
    }
    
}
