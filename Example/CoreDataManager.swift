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
        let storeURL = try! self.applicationDocumentsDirectory.appendingPathComponent("Banks.sqlite")
        persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        try! persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: nil)
        managedObjectContext = NSManagedObjectContext()
        managedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator
    }
    
    private var banksPreloaded : Bool {
        get {
            return UserDefaults.standard.bool(forKey: "UserDefaultsBanksPreloaded")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "UserDefaultsBanksPreloaded")
        }
    }
    
    private let applicationDocumentsDirectory = FileManager.default.urlsForDirectory(.documentDirectory, inDomains: .userDomainMask).last!
    
    private let managedObjectModel : NSManagedObjectModel = {
            let url = Bundle.main.urlForResource("Banks", withExtension: "momd")
            return NSManagedObjectModel(contentsOf: url!)!
    }()
    
    private let persistentStoreCoordinator : NSPersistentStoreCoordinator
    
    let managedObjectContext : NSManagedObjectContext
    
    func preloadData()
    {
        if banksPreloaded { return }
        
        if let filePath = Bundle.main.pathForResource("Banks", ofType: "json"),
            let url = URL(string: filePath),
            let banksData = try? Data(contentsOf: url),
            let banks = try! JSONSerialization.jsonObject(with: banksData, options: []) as? [[String:AnyObject]]
        {
            for bankInfo in banks {
                let _ = Bank(info: bankInfo, inContext: managedObjectContext)
            }
            
            try! managedObjectContext.save()
            banksPreloaded = true
        }
    }
}
