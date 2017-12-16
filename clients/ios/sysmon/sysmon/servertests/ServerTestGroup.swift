//
//  ServerTestGroup.swift
//  sysmon
//
//  Created by Jeff on 4/16/16.
//  Copyright © 2017 Jeff Batis. All rights reserved.
//

import Foundation
import Gloss

class ServerTestGroup : Decodable {
    
    /*[{"test_name":"SysTest","protocol":"ping","group":"Ping","host":"iMac","test_interval":5,"notification_threshold":50},{"test_name":"SysTest","protocol":"ping","group":"Ping","host":"TestServer","test_interval":5,"notification_threshold":50},{"test_name":"SysTest","protocol":"ping","group":"Ping","host":"router","test_interval":5,"notification_threshold":50},{"test_name":"SysTest","protocol":"http","group":"Http","host":"TestServer","test_interval":5,"notification_threshold":50},{"test_name":"SysTest","protocol":"http","group":"Http","host":"router","test_interval":5,"notification_threshold":50}]*/
    
    
    private var serverTests = Array<ServerTest>();
    
    required init(json : JSON) {
        loadTests([json])
    }
    
    init(json : [JSON]) {
        loadTests(json);
    }
    
    func loadTests(json : [JSON]) {
        serverTests = [ServerTest].fromJSONArray(json);
    }
    
    func addTest(serverTest : ServerTest) {
        serverTests.append(serverTest);
    }
    
    func getTests() ->Array<ServerTest>{
        return Array(serverTests);
    }
    
}
