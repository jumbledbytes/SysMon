//
//  NSURLSession.extensions.swift
//  sysmon
//
//  Created by Jeff on 5/12/16.
//  Copyright © 2017 Jeff Batis. All rights reserved.
//

import Foundation

extension NSURLSession {
    func sendSynchronousRequest(request: NSURLRequest, timeout: Double, completionHandler: (NSData?, NSURLResponse?, NSError?) -> Void) {
        let semaphore = dispatch_semaphore_create(0)
        let task = self.dataTaskWithRequest(request) { data, response, error in
            completionHandler(data, response, error)
            dispatch_semaphore_signal(semaphore)
        }
        
        task.resume()
        
        dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, Int64(timeout * Double(NSEC_PER_SEC))));
    }
}