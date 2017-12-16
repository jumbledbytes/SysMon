//
//  Server.swift
//  sysmon
//
//  Created by Jeff on 3/22/16.
//  Copyright © 2017 Jeff Batis. All rights reserved.
//

import Foundation

class Server {
    
    var serverName = "";
    var serverTests = Array<ServerTest>();
    
    init(name : String) {
        serverName = name
    }
    
    func addTest(test : ServerTest) {
        serverTests.append(test);
    }
}