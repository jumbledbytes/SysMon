//
//  NSDate.extension.swift
//  sysmon
//
//  Created by Jeff on 5/22/16.
//  Copyright © 2017 Jeff Batis. All rights reserved.
//

import Foundation

extension NSDate
{
    func day() -> Int
    {
        //Get Hour
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components(.Day, fromDate: self)
        let day = components.day
        
        //Return Hour
        return day
    }
    
    func hour() -> Int
    {
        //Get Hour
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components(.Hour, fromDate: self)
        let hour = components.hour
        
        //Return Hour
        return hour
    }
    
    
    func minute() -> Int
    {
        //Get Minute
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components(.Minute, fromDate: self)
        let minute = components.minute
        
        //Return Minute
        return minute
    }
    
    func toShortTimeString() -> String
    {
        //Get Short Time String
        let formatter = NSDateFormatter()
        formatter.timeStyle = .ShortStyle
        let timeString = formatter.stringFromDate(self)
        
        //Return Short Time String
        return timeString
    }
}