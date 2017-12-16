//
//  NoAuthentication.swift
//  sysmon
//
//  Created by Jeff on 4/24/16.
//  Copyright © 2017 Jeff Batis. All rights reserved.
//

import Foundation



class NoAuthentication : Authenticator {
    
    var host = "";
    var dataProtocol = "";
    var session : NSURLSession? = nil;
    var errorMessage = "";
    
    init(host : String, dataProtocol: String) {
        self.host = host;
        self.dataProtocol = dataProtocol;
    }
    
    func authenticate(onSuccess: (session: NSURLSession) -> Void, onError: (errorMessage: String) -> Void) -> Void {
        if(session == nil && isHostAvailable()) {
            session = NSURLSession.sharedSession();
            onSuccess(session: self.session!);
        } else {
            errorMessage = "Host '" + host + "' is not available" ;
            onError(errorMessage: self.errorMessage);
        }
    }
    
    func getHost() -> String {
        return self.host;
    }
    
    func isAuthenticated() -> Bool {
        return session != nil;
    }
    
    func getErrorMessage() -> String {
        return errorMessage;
    }
    
    func isHostAvailable() -> Bool {
        if(self.host == "" || self.dataProtocol == "") {
            return false;
        }
        var available = false;
        let url = NSURL(string: self.dataProtocol + "://" + self.host + "/version")!
        let request = NSMutableURLRequest(URL: url)
        let session = NSURLSession.sharedSession()
        session.sendSynchronousRequest(request, timeout: 3.0) { data, response, error in
            // TODO: check version compatibility
            available = response != nil;
        }
        return available;
    }
}