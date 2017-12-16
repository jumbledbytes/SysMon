//
//  SmtpResult.swift
//  sysmon
//
//  Created by Jeff on 5/20/16.
//  Copyright © 2017 Jeff Batis. All rights reserved.
//

import Foundation
import Gloss

class SmtpResult : TestResult {
    
    static let testProtocol: String = "smtp";
    
    required init?(json : JSON) {
        super.init(json : json);
        self.protocolName = SmtpResult.testProtocol;
    }
    
    override init() {
        super.init();
        self.protocolName = SmtpResult.testProtocol;
    }
    
}