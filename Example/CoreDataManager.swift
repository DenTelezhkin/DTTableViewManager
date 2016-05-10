//
//  CoreDataManager.swift
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 20.08.15.
//  Copyright (c) 2015 Denys Telezhkin. All rights reserved.
//

import Foundation
import CoreData

class CoreDataManager
{
    static let sharedInstance = CoreDataManager()
    private init(){
        let storeURL = self.applicationDocumentsDirectory.URLByAppendingPathComponent("Banks.sqlite")
        persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        try! persistentStoreCoordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeURL, options: nil)
        managedObjectContext = NSManagedObjectContext()
        managedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator
    }
    
    private var banksPreloaded : Bool {
        get {
            return NSUserDefaults.standardUserDefaults().boolForKey("UserDefaultsBanksPreloaded")
        }
        set {
            NSUserDefaults.standardUserDefaults().setBool(newValue, forKey: "UserDefaultsBanksPreloaded")
        }
    }
    
    private let applicationDocumentsDirectory = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).last!
    
    private let managedObjectModel : NSManagedObjectModel = {
            let url = NSBundle.mainBundle().URLForResource("Banks", withExtension: "momd")
            return NSManagedObjectModel(contentsOfURL: url!)!
    }()
    
    private let persistentStoreCoordinator : NSPersistentStoreCoordinator
    
    let managedObjectContext : NSManagedObjectContext
    
    func preloadData()
    {
        if banksPreloaded { return }
        
        if let filePath = NSBundle.mainBundle().pathForResource("Banks", ofType: "json"),
            let banksData = NSData(contentsOfFile: filePath),
        let banks = try! NSJSONSerialization.JSONObjectWithData(banksData, options: []) as? [[String:AnyObject]]
        {
            for bankInfo in banks {
                let _ = Bank(info: bankInfo, inContext: managedObjectContext)
            }
            
            try! managedObjectContext.save()
            banksPreloaded = true
        }
    }
}