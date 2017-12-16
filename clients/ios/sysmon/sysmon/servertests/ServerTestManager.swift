//
//  ServerTestManager.swift
//  sysmon
//
//  Created by Jeff on 4/16/16.
//  Copyright © 2017 Jeff Batis. All rights reserved.
//

import Foundation
import Gloss

class ServerTestManager {
    
    typealias ProtocolTest = Dictionary<String /*Protocol*/, ServerTest>;
    typealias HostTest = Dictionary<String /*Host*/, ProtocolTest>;
    
    var serverTests = Dictionary<String /* Test Name */, HostTest>();
    var serverResults = Dictionary<String, Array<TestResult>>();
    var serverHistory = Dictionary<String, Array<TestResult>>();
    
    var historyDuration = 24;
    
    func addTest(serverTest : ServerTest) -> Void {
        let testExists = serverTests[serverTest.testName] != nil;
        if !testExists {
            serverTests[serverTest.testName] = HostTest();
            serverTests[serverTest.testName]![serverTest.testProtocol] = ProtocolTest();
        }
        if serverTests[serverTest.testName]![serverTest.testProtocol] == nil {
            serverTests[serverTest.testName]![serverTest.testProtocol] = ProtocolTest();
        }
        serverTests[serverTest.testName]![serverTest.testProtocol]![serverTest.testHost] = serverTest;
    }
    
    func addTests(serverTests : ServerTestGroup) -> Void {
        let tests = serverTests.getTests();
        for test in tests {
            addTest(test);
        }
    }
    
    func getTest(testName : String, testHost : String, testProtocol : String) -> ServerTest? {
        var test : ServerTest? = nil;
        let testExists = serverTests[testName] != nil;
        if testExists {
            let hostExists = serverTests[testName]![testHost] != nil;
            if hostExists {
                test = serverTests[testName]![testHost]![testProtocol];
            }
        }
        return test;
    }
    
    func getTests(testName : String) -> Array<ServerTest> {
        var tests = Array<ServerTest>();
        if let testList = serverTests[testName] {
            for (_, protocolTests) in testList {
                for(_, test) in protocolTests {
                    tests.append(test);
                }
            }
        }
        return tests;
    }
    
    func getTests(testName : String, protocolName: String) -> Array<ServerTest> {
        var tests = Array<ServerTest>();
        if let testList = serverTests[testName] {
            for (testProtocol, protocolTests) in testList {
                if(testProtocol == protocolName) {
                    for(_, test) in protocolTests {
                        tests.append(test);
                    }
                }
            }
        }
        return tests;
    }
    
    func getAllTests(hostName : String, protocolName: String) -> Array<ServerTest> {
        var tests = Array<ServerTest>();
        for (_, testList) in serverTests {
            if let protocolTests = testList[protocolName] {
                for(testHost, test) in protocolTests {
                    if(hostName == testHost) {
                        tests.append(test);
                    }
                }
            }
        }
        return tests;
    }
    
    func saveResult(testName : String, testHost : String, testProtocol : String, result : TestResult) {
        if let test = getTest(testName, testHost: testHost, testProtocol: testProtocol) {
            test.setResult(result)
        }
    }
    
    func saveResult(testHost : String, testProtocol : String, result : TestResult) {
        let tests = getAllTests(testHost, protocolName: testProtocol)
        for test in tests {
            test.setResult(result);
        }
    }
    
    func saveResults(testResults: ServerResultGroup) {
        let results = testResults.results;
        for (testProtocol, protocolResults) in results {
            for result in protocolResults {
                saveResult(result.host, testProtocol: testProtocol, result: result)
            }
        }
    }
    
    func clearHistory() {
        for (_, testList) in serverTests {
            for (_, protocolTests) in testList {
                for(_, hostTest) in protocolTests {
                    hostTest.clearHistory();
                }
            }
        }
    }
    
    func saveHistory(testHost : String, testProtocol : String, result : TestResult) {
        let calendar = NSCalendar.currentCalendar()
        let historyStartDate = calendar.dateByAddingUnit(
            NSCalendarUnit.Hour, // adding hours
            value: -self.historyDuration,
            toDate: NSDate(),
            options: NSCalendarOptions(rawValue: 0)
        )
        let tests = getAllTests(testHost, protocolName: testProtocol)
        for test in tests {
            // only save history that isn't older than the period defined by the historyDuration
            if result.resultTime.earlierDate(historyStartDate!).isEqualToDate(historyStartDate!) {
                test.saveHistory(result);
            }
        }
    }
    
    func saveHistory(testResults: ServerResultGroup) {
        clearHistory();
        let results = testResults.results;
        for (testProtocol, protocolResults) in results {
            for result in protocolResults {
                saveHistory(result.host, testProtocol: testProtocol, result: result)
            }
        }
    }
    
    func getResults(testName : String, testCount : Int) -> Array<TestResult> {
        var results = Array<TestResult>();
        var count = testCount;
        
        if let testResults = serverResults[testName] {
            if testResults.count > testCount {
                count = testResults.count;
            }
            if(testCount > 0) {
                results = Array(testResults[(testResults.count - count) ..< count]).reverse();
            }
        }
        
        return results;
    }
    
}