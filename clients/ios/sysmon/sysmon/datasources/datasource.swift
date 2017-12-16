//
//  datasource.swift
//  sysmon
//
//  Created by Jeff on 4/16/16.
//  Copyright © 2017 Jeff Batis. All rights reserved.
//

import Foundation

protocol DatasourceProtocol {
    func updateTests(onCompletion: (ServerTestGroup) -> Void,
                     onError: (errorMessage: String) -> Void) -> Void
    
    func updateResults(onCompletion : (ServerResultGroup) -> Void,
                       onError: (errorMessage: String) -> Void);
    
    func updateHistory(onCompletion : (ServerResultGroup) -> Void,
                       onError: (errorMessage: String) -> Void);
    
    func updateTheme(onCompletion : (SysmonTheme) -> Void,
         onError: (errorMessage: String) -> Void);
    
    func runTest(onCompletion : () -> Void, onError: (errorMessage: String) -> Void) -> Void;
    
    func isValid() -> Bool;
    
    func getErrorMessage() -> String;
    
    func setAuthenticator(auth : Authenticator);
    
    func saveDeviceToken(deviceName: String, deviceToken : String);
}

struct Datasource {
    
    class DatasourceInterface : DatasourceProtocol {
        func updateTests(onCompletion: (ServerTestGroup) -> Void,
                         onError: (errorMessage: String) -> Void) -> Void {
            
        }
        
        func updateResults(onCompletion : (ServerResultGroup) -> Void,
                           onError: (errorMessage: String) -> Void) -> Void {
            
        }
        
        func updateHistory(onCompletion : (ServerResultGroup) -> Void,
                           onError: (errorMessage: String) -> Void) -> Void {
            
        }
        
        
        func updateTheme(onCompletion : (SysmonTheme) -> Void,
                         onError: (errorMessage: String) -> Void) -> Void {
            
        }
        
        func runTest(onCompletion : () -> Void, onError: (errorMessage: String) -> Void) -> Void {
            
        }
        
        func isValid() -> Bool {
            return false;
        }
        
        func getErrorMessage() -> String {
            return "";
        }
        
        func setAuthenticator(auth: Authenticator) {
            // nothing
        }
        
        func saveDeviceToken(deviceName: String, deviceToken: String) {
            // nothing
        }
    }
    
    
}