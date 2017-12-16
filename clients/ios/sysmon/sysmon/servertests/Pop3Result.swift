//
//  Pop3Result.swift
//  sysmon
//
//  Created by Jeff on 5/21/16.
//  Copyright © 2017 Jeff Batis. All rights reserved.
//
import Foundation
import Gloss

class Pop3Result : TestResult {
    
    static let testProtocol: String = "pop3";
    
    required init?(json : JSON) {
        super.init(json : json);
        self.protocolName = ImapsResult.testProtocol;
    }
    
    override init() {
        super.init();
        self.protocolName = ImapsResult.testProtocol;
    }
    
}
