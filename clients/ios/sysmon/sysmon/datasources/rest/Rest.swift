//
//  rest.swift
//  sysmon
//
//  Created by Jeff on 4/16/16.
//  Copyright © 2017 Jeff Batis. All rights reserved.
//

import Foundation
import Gloss

extension Datasource  {
    class Rest : Datasource.DatasourceInterface {
        
        let protocolType = "https";
        var authenticator : Authenticator;
        let testManager : ServerTestManager;
        let updateLock = dispatch_queue_create("datasource.rest.updateLock", nil)
        var errorMessage = "";
        var session : NSURLSession? = nil;
        
        init(testManager: ServerTestManager, testServer : String) {
            self.testManager = testManager;
            self.authenticator = NoAuthentication(host: testServer, dataProtocol: protocolType);
        }
        
        override func setAuthenticator(newAuthenticator : Authenticator) {
            self.authenticator = newAuthenticator
        }
        
        override func isValid() -> Bool {
            if session == nil {
                // authentication failed
                errorMessage = authenticator.getErrorMessage();
                return false;
            }
            self.errorMessage = ""
            return true;
        }
        
        override func getErrorMessage() -> String {
            return errorMessage;
        }
        
        
        func sendQuery(url: NSURL, onCompletion:(data: NSData?, statusCode: Int?, error: NSError?) -> Void) {
            authenticator.authenticate({(session: NSURLSession) -> Void in
                self.session = session;
                let testServer = self.authenticator.getHost();
                let loadDataTask = session.dataTaskWithURL(url) { (data, response, error) -> Void in
                    if let responseError = error {
                        print(error!.localizedDescription)
                        onCompletion(data: nil, statusCode: 0, error: responseError)
                    } else if let httpResponse = response as? NSHTTPURLResponse {
                        var error : NSError? = nil;
                        if(httpResponse.statusCode != 200) {
                            error = NSError(domain:testServer, code:httpResponse.statusCode, userInfo:[NSLocalizedDescriptionKey : "HTTP status code \(httpResponse) indicates error."])
                        }
                        onCompletion(data: data, statusCode: httpResponse.statusCode, error: error);
                    }
                }
                
                loadDataTask.resume()
            },
            onError: {(errorMessage: String) -> Void in
                self.errorMessage = errorMessage;
            });
           
            
        }
        
        func queryServer(action : String, queryType : String, onCompletion: (data : NSData) -> Void,
                         onError: (errorMessage: String) -> Void) {
            let testServer = authenticator.getHost();
            let testServerUrl = protocolType + "://"+testServer;
            let path = testServerUrl + "/" + action + "/" + queryType;
            sendQuery(NSURL(string: path)!, onCompletion: { (data, statusCode, error) -> Void in
                if let data = data {
                    onCompletion(data: data);
                }
                if(error != nil) {
                    onError(errorMessage: (error?.localizedDescription)!);
                }
            })
            
        }
        
        override func updateTests(onUpdate : (ServerTestGroup) -> Void, onError : (errorMessage : String) -> Void) -> Void {
            queryServer("show", queryType: "test", onCompletion: {(data : NSData) -> Void in
                dispatch_sync(self.updateLock) {
                    do {
                        let json = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions()) as? Array<JSON>
                        let allTests = ServerTestGroup(json: json!)
                        self.testManager.addTests(allTests)
                        onUpdate(allTests)
                    } catch {
                        onError(errorMessage: "Failed to load test data from server");
                    }
                }
            },
                        onError: {(errorMessage: String) -> Void in
                            onError(errorMessage: errorMessage);
            });
        };
        
        override func updateResults(onCompletion : (ServerResultGroup) -> Void, onError : (errorMessage : String) -> Void) -> Void {
            queryServer("show", queryType: "results", onCompletion: {(data : NSData) -> Void in
                dispatch_sync(self.updateLock) {
                    do {
                        let json = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions()) as? JSON
                        let allResults = ServerResultGroup(json: json!)
                        self.testManager.saveResults(allResults!)
                        onCompletion(allResults!)
                    } catch {
                        onError(errorMessage: "Failed to load result data from server");
                    }
                }
            },
                        onError: {(errorMessage: String) -> Void in
                            onError(errorMessage: errorMessage);
            })
        };

        override func updateHistory(onCompletion : (ServerResultGroup) -> Void, onError : (errorMessage : String) -> Void) -> Void {
            queryServer("show", queryType: "history", onCompletion: {(data : NSData) -> Void in
                dispatch_sync(self.updateLock) {
                    do {
                        let json = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions()) as? JSON
                        let history = ServerResultGroup(json: json!)
                        self.testManager.saveHistory(history!)
                        onCompletion(history!)
                    } catch {
                        onError(errorMessage: "Failed to load test history data from server");
                    }
                }
                },
                        onError: {(errorMessage: String) -> Void in
                            onError(errorMessage: errorMessage);
            });
        };
        
        override func updateTheme(onCompletion: (SysmonTheme) -> Void, onError : (errorMessage : String) -> Void) {
            queryServer("show", queryType: "theme", onCompletion: {(data : NSData) -> Void in
                do {
                    let json = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions()) as? JSON
                    SysmonTheme.currentTheme = SysmonTheme(json: json!)!
                    onCompletion(SysmonTheme.currentTheme)
                } catch {
                    onError(errorMessage: "Unable to load theme data from server");
                }
            },
                        onError: {(errorMessage: String) -> Void in
                            onError(errorMessage: errorMessage);
            });
        }
        
        override func runTest(onCompletion: () -> Void, onError: (errorMessage: String) -> Void) {
            queryServer("run", queryType: "test", onCompletion: {(data : NSData) -> Void in
                onCompletion();
            },
                        onError: {(errorMessage: String) -> Void in
                            onError(errorMessage: errorMessage);
            });
        }
        
        override func saveDeviceToken(deviceName: String, deviceToken: String) {
            let allowedCharacters = NSCharacterSet.URLQueryAllowedCharacterSet().mutableCopy()
            allowedCharacters.addCharactersInString("")
            let escapedName = deviceName.stringByAddingPercentEncodingWithAllowedCharacters(allowedCharacters as! NSCharacterSet);
            queryServer("save", queryType: "devicetoken/" + escapedName! + "/" + deviceToken, onCompletion: {(data : NSData) -> Void in
                // nothing for now
            },
                        onError: {(errorMessage: String) -> Void in
                            // nothing for now
            });
        }
    }
}