//
//  ServerResultFactory.swift
//  sysmon
//
//  Created by Jeff on 4/17/16.
//  Copyright © 2017 Jeff Batis. All rights reserved.
//

import Foundation

class ServerResultFactory {
    
    static func getResult(protocolType : String) -> TestResult {
        var result : TestResult;
        switch(protocolType) {
            case PingResult.testProtocol:
                result = PingResult();
                break;
            case HttpResult.testProtocol:
                result = HttpResult();
                break;
            default:
                result = TestResult();
                result.protocolName = protocolType;
            break;
        }
        return result;
    }
    
}