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
    fileprivate init(){
        let storeURL = self.applicationDocumentsDirectory.appendingPathComponent("Banks.sqlite")
        persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        try! persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: nil)
        managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator
    }
    
    fileprivate var banksPreloaded : Bool {
        get {
            return UserDefaults.standard.bool(forKey: "UserDefaultsBanksPreloaded")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "UserDefaultsBanksPreloaded")
        }
    }
    
    fileprivate let applicationDocumentsDirectory = FileManager.default.urls(for :.documentDirectory, in: .userDomainMask).last!
    
    fileprivate let managedObjectModel : NSManagedObjectModel = {
        let modelURL = Bundle.main.url(forResource: "Banks", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    fileprivate let persistentStoreCoordinator : NSPersistentStoreCoordinator
    
    let managedObjectContext : NSManagedObjectContext
    
    func preloadData()
    {
        if banksPreloaded { return }
        
        if let filePath = Bundle.main.path(forResource: "Banks", ofType: "json"),
            let url = URL(string: "file://\(filePath)"),
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
