//
//  Bank.swift
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 20.08.15.
//  Copyright (c) 2015 Denys Telezhkin. All rights reserved.
//

import Foundation
import CoreData

@objc(Bank)
class Bank : NSManagedObject
{
    @NSManaged var name : String
    @NSManaged var city : String
    @NSManaged var zip : Int
    @NSManaged var state : String
    
    convenience init(info : [String:Any], inContext context: NSManagedObjectContext)
    {
        let entity = NSEntityDescription.entity(forEntityName: "Bank", in: context)
        self.init(entity: entity!, insertInto: context)
        name = info["name"] as? String ?? ""
        city = info["city"] as? String ?? ""
        zip = info["zip"] as? Int ?? 0
        state = info["state"] as? String ?? ""
    }
}
