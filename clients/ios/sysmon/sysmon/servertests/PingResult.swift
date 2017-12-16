//
//  PingResult.swift
//  sysmon
//
//  Created by Jeff on 4/16/16.
//  Copyright © 2017 Jeff Batis. All rights reserved.
//

import Foundation
import Gloss

class PingResult : TestResult {
    
    var sent : Int = 0;
    var received : Int = 0;
    var minTime : Float = 0;
    var maxTime : Float = 0;
    var avgTime : Float = 0;
    var meanDeviation : Float = 0;
    
    static let testProtocol = "ping";
    
    required init?(json : JSON) {
        super.init(json : json);
        self.protocolName = PingResult.testProtocol;

    }
    
    override init() {
        super.init();
        self.protocolName = PingResult.testProtocol;
    }
    
    override func load(json: JSON) {
        self.sent = ("sent" <~~ json)!;
        self.received = ("received" <~~ json)!;
        //self.minTime = ("min" <~~ json)!;
        //self.maxTime = ("max" <~~ json)!;
        //self.avgTime = ("avg" <~~ json)!;
        //self.meanDeviation = ("mdev" <~~ json)!;
        super.load(json);
    }
}