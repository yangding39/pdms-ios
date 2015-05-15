//
//  pdms-ios.swift
//  pdms-ios
//
//  Created by IMEDS on 15-5-14.
//  Copyright (c) 2015年 unimedsci. All rights reserved.
//

import Foundation
import CoreData

class UserLocal: NSManagedObject {

    @NSManaged var id: NSNumber
    @NSManaged var name: String
    @NSManaged var loginName: String
    @NSManaged var mobile: String
    @NSManaged var email: String
    @NSManaged var address: String
    @NSManaged var title: String
    @NSManaged var hospital: String
    @NSManaged var department: String
    @NSManaged var token: String

}
