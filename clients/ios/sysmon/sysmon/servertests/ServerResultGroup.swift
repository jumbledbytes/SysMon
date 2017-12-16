//
//  ServerResultGroup.swift
//  sysmon
//
//  Created by Jeff on 4/17/16.
//  Copyright © 2017 Jeff Batis. All rights reserved.
//

import Foundation
import Gloss

class ServerResultGroup : Decodable {
    
    typealias TestList = Array<TestResult>;
    typealias TestResults = Dictionary<String /* protocol */, Array<TestResult>>;
    
    var results : TestResults;
    
    /*{"test_name":"SysTest","ping":[
    [{"rowid":1,"host":"iMac","connection":null,"sent":5,"received":0,"min":null,"avg":null,"max":null,"mdev":null}],
    [{"rowid":2,"host":"TestServer","connection":null,"sent":5,"received":5,"min":null,"avg":null,"max":null,"mdev":null}],[{"rowid":3,"host":"router","connection":null,"sent":5,"received":5,"min":null,"avg":null,"max":null,"mdev":null}]],
    "http":[[{"rowid":1,"host":"TestServer","status_code":403,"message":""}],[{"rowid":4,"host":"router","status_code":200,"message":""}]]}*/
    
    private var testResults = Array<TestResult>()
    
    required init?(json: JSON) {
        self.results = TestResults();
        self.results = loadResults(json);
    }
    
    func loadResults(json : JSON) -> TestResults {
        var testResults = TestResults();
//        guard let jsonMessage: String = "message" <~~ json else { return; }
        let pingData = json["ping"] as? Array<JSON>;
        let httpData = json["http"] as? Array<JSON>;
        let imapsData = json["imaps"] as? Array<JSON>;
        let dnsData = json["dns"] as? Array<JSON>;
        let smtpData = json["smtp"] as? Array<JSON>;
        let pop3Data = json["pop3"] as? Array<JSON>;
        
        if(dnsData != nil) { testResults["dns"] = [DnsResult].fromJSONArray(dnsData!); }
        if(pingData != nil) { testResults["ping"] = [PingResult].fromJSONArray(pingData!) };
        if(httpData != nil) { testResults["http"] = [HttpResult].fromJSONArray(httpData!) };
        if(imapsData != nil) { testResults["imaps"] = [ImapsResult].fromJSONArray(imapsData!) };
        if(smtpData != nil) { testResults["smtp"] = [SmtpResult].fromJSONArray(smtpData!) };
        if(pop3Data != nil) { testResults["pop3"] = [Pop3Result].fromJSONArray(pop3Data!) };
        
        return testResults;
    }
    
    
    
    
}