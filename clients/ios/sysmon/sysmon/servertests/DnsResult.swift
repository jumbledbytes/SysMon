//
//  DnsResult.swift
//  sysmon
//
//  Created by Jeff on 5/19/16.
//  Copyright © 2017 Jeff Batis. All rights reserved.
//

import Foundation
import Gloss

class DnsResult : TestResult {
    
    static let testProtocol: String = "dns";
    
    required init?(json : JSON) {
        super.init(json : json);
        self.protocolName = DnsResult.testProtocol;
    }
    
    override init() {
        super.init();
        self.protocolName = DnsResult.testProtocol;
    }
    
}