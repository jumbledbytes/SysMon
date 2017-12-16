//
//  ImapsResult.swift
//  sysmon
//
//  Created by Jeff on 5/19/16.
//  Copyright © 2017 Jeff Batis. All rights reserved.
//

import Foundation
import Gloss

class ImapsResult : TestResult {
    
    static let testProtocol: String = "imaps";
    
    required init?(json : JSON) {
        super.init(json : json);
        self.protocolName = ImapsResult.testProtocol;
    }
    
    override init() {
        super.init();
        self.protocolName = ImapsResult.testProtocol;
    }

}