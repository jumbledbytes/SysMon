//
//  BasicHttpAuthenticator.swift
//  sysmon
//
//  Created by Jeff on 4/24/16.
//  Copyright © 2017 Jeff Batis. All rights reserved.
//

import Foundation



class BasicHttpAuthenticator : NSObject, Authenticator, NSURLSessionDelegate, NSURLSessionTaskDelegate {
    var userName = "";
    var password = "";
    var hostName = "";
    var session : NSURLSession?;
    var errorMessage = "";
    
    init(host: String, user : String, password : String) {
        self.userName = user;
        self.password = password;
        self.hostName = host;
    }
    
    func authenticate(onSuccess: (session: NSURLSession) -> Void, onError: (errorMessage: String) -> Void) -> Void {
        if(session != nil) {
            onSuccess(session: self.session!);
            return;
        }
        if(session == nil) {
            let config = NSURLSessionConfiguration.defaultSessionConfiguration()
            let userPasswordString = userName+":"+password
            let userPasswordData = userPasswordString.dataUsingEncoding(NSUTF8StringEncoding)
            let base64EncodedCredential = userPasswordData!.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue:0))
            let authString = "Basic \(base64EncodedCredential)"
            config.HTTPAdditionalHeaders = ["Authorization" : authString]
            
            session = NSURLSession(configuration: config, delegate: self, delegateQueue:NSOperationQueue.mainQueue())
            
            let url = NSURL(string: "https://" + self.hostName + "/config")
            
            // http is async, but make the authenticate call block until a response is received
            let request = NSMutableURLRequest(URL: url!)
            session!.sendSynchronousRequest(request, timeout: 3.0) { data, response, error in
                // TODO: check version compatibility
                if(response == nil) {
                    self.errorMessage = "Host '" + self.hostName + "' is not available";
                    onError(errorMessage: self.errorMessage);
                } else {
                    let status = (response as! NSHTTPURLResponse).statusCode
                    if (status == 200) {
                        // success
                        self.errorMessage = "";
                        onSuccess(session: self.session!);
                    } else {
                        // connection failed, so don't continue the session
                        self.errorMessage = "Invalid username or password";
                        self.session = nil;
                        onError(errorMessage: self.errorMessage);
                    }
                }
            }
            
        } else {
            errorMessage = "Host '" + hostName + "' is not available";
            onError(errorMessage: errorMessage);
        }
    }

    func getHost() -> String {
        return self.hostName;
    }
    
    func isAuthenticated() -> Bool {
        return session != nil;
    }
    
    func getErrorMessage() -> String {
        return errorMessage;
    }
    
    func isHostAvailable() -> Bool {
        if(self.hostName == "") {
            return false;
        }
        var available = false;
        let url = NSURL(string: "https://" + self.hostName + "/version")!
        let request = NSMutableURLRequest(URL: url)
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: config, delegate: self, delegateQueue:NSOperationQueue.mainQueue())
        session.sendSynchronousRequest(request, timeout: 3.0) { data, response, error in
            // TODO: check version compatibility
            available = response != nil;
        }
        return available;
    }
    
    @objc func URLSession(session: NSURLSession, didBecomeInvalidWithError error: NSError?) {
        // TODO; handle error
        
    }
    
    @objc func URLSession(session: NSURLSession, didReceiveChallenge challenge: NSURLAuthenticationChallenge, completionHandler: (NSURLSessionAuthChallengeDisposition, NSURLCredential?) -> Void) {
        completionHandler(NSURLSessionAuthChallengeDisposition.UseCredential, NSURLCredential(forTrust: challenge.protectionSpace.serverTrust!))
    }
    
}