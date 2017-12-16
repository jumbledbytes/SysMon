//
//  ServerGroup.swift
//  sysmon
//
//  Created by Jeff on 3/22/16.
//  Copyright © 2017 Jeff Batis. All rights reserved.
//

import Foundation


class ServerGroup {
    
    var groupName = "Group"
    var servers : [Server] = []
    
    func addServer(aServer : Server) {
        servers.append(aServer);
    }
    
    func getServerAtIndex(index : Int) -> Server {
        return servers[index]
    }
    
    func containsServer(serverName : String) -> Bool {
        var hasServer = false;
        for server in servers {
            if server.serverName == serverName {
                hasServer = true;
                break;
            }
        }
        return hasServer
    }
    
    func size() -> Int  {
        return servers.count
    }
    
}