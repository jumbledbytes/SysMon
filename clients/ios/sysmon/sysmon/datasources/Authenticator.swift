//
//  Authenticator.swift
//  sysmon
//
//  Created by Jeff on 4/24/16.
//  Copyright © 2017 Jeff Batis. All rights reserved.
//

import Foundation

protocol Authenticator {

    func authenticate(onSuccess: (session: NSURLSession) -> Void, onError: (errorMessage: String) -> Void) -> Void;
    func getHost() -> String;
    func isAuthenticated() -> Bool;
    func getErrorMessage() -> String;
}
