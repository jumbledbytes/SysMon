//
//  HttpResult.swift
//  sysmon
//
//  Created by Jeff on 4/16/16.
//  Copyright © 2017 Jeff Batis. All rights reserved.
//

import Foundation
import Gloss

class HttpResult : TestResult {
    
    let successCode = 200;
    
    var statusCode : Int = 0;
    
    static let testProtocol: String = "http";
    
    required init?(json : JSON) {
        self.statusCode = ("status_code" <~~ json)!;
        super.init(json : json);
        self.protocolName = HttpResult.testProtocol;
    }
    
    override init() {
        super.init();
        self.protocolName = HttpResult.testProtocol;
    }
    
    override func load(json: JSON) {
        self.statusCode = ("status_code" <~~ json)!;
        super.load(json);
    }
}