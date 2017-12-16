//
//  servertest.swift
//  sysmon
//
//  Created by Jeff on 4/16/16.
//  Copyright © 2017 Jeff Batis. All rights reserved.
//

import Foundation
import Gloss

class ServerTest : Decodable {
    //{"test_name":"SysTest","protocol":"ping","group":"Ping","host":"iMac","test_interval":5,"notification_threshold":50}
    
    let testName : String;
    let testProtocol : String;
    let testGroup : String;
    let testHost: String;
    let testInterval : Float;
    let notificationThreshold : Float;
    
    private var testResult = TestResult();
    private var testHistory = Array<TestResult>();
    
    required init?(json: JSON) {
        self.testName = ("test_name" <~~ json)!
        self.testProtocol = ("protocol" <~~ json)!
        self.testGroup = ("group_name" <~~ json)!
        self.testHost = ("host" <~~ json)!
        self.testInterval = ("test_interval" <~~ json)!
        self.notificationThreshold = 100; //("notification_threshold" <~~ json)!
    }
    
    init(testName : String, testProtocol : String, testGroup : String, testHost : String, testInterval : Float, notificationThreshold : Float) {
        self.testName = testName;
        self.testProtocol = testProtocol;
        self.testGroup = testGroup;
        self.testHost = testHost;
        self.testInterval = testInterval;
        self.notificationThreshold = notificationThreshold;
    }
    
    init() {
        self.testName = "";
        self.testProtocol = "";
        self.testGroup = "";
        self.testHost = "";
        self.testInterval = 0.0;
        self.notificationThreshold = 100.0;
    }
    
    func setResult(result: TestResult) {
        testResult = result;
    }
    
    func getResult() -> TestResult {
        return testResult;
    }
    
    func saveHistory(result: TestResult) {
        testHistory.append(result);
    }
    
    func getHistory() -> Array<TestResult> {
        return testHistory;
    }
    
    func clearHistory() {
        testHistory.removeAll();
    }
    
}