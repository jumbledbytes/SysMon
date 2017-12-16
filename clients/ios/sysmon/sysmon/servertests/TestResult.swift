//
//  TestResult.swift
//  sysmon
//
//  Created by Jeff on 5/19/16.
//  Copyright © 2017 Jeff Batis. All rights reserved.
//

import Foundation
import Gloss

class TestResult : Decodable {
    
    var host : String = "";
    var testScore : Float = 0.0;
    var message : String = "";
    var protocolName : String = "";
    var resultTime : NSDate = NSDate();
    
    required init?(json : JSON) {
        load(json);
    }
    
    init(protocolName : String, testHost : String, testScore : Float) {
        self.protocolName = protocolName;
        self.host = testHost;
        self.testScore = testScore;
    }
    
    init() {
        
    }
    
    func load(json : JSON) {
        var testTimeSeconds : Double!;
        self.host = ("host" <~~ json)!;
        self.testScore = ("test_score" <~~ json)!;
        testTimeSeconds = ("record_time" <~~ json)!
        self.resultTime = NSDate(timeIntervalSince1970: testTimeSeconds)
        guard let jsonMessage: String = "message" <~~ json else {
            return;
        }
        self.message = jsonMessage;
    }

}