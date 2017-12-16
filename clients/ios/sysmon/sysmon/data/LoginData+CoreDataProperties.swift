//
//  LoginData+CoreDataProperties.swift
//  sysmon
//
//  Created by Jeff on 5/14/16.
//  Copyright © 2017 Jeff Batis. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension LoginData {

    @NSManaged var username: String?
    @NSManaged var password: String?
    @NSManaged var hostname: String?
    @NSManaged var rememberMe: Bool
    @NSManaged var validateSSL: Bool

}
