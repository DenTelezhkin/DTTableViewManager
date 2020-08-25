//
//  CoreDataManager.swift
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 20.08.15.
//  Copyright (c) 2015 Denys Telezhkin. All rights reserved.
//

import Foundation
import CoreData
import UIKit

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
        loadData()
    }
    
    private func loadData() {
        if let data = NSDataAsset(name: "Banks")?.data,
           let banks = try? JSONSerialization.jsonObject(with: data, options: []) as? [[String:AnyObject]]
        {
            for bankInfo in banks {
                let _ = Bank(info: bankInfo, inContext: managedObjectContext)
            }
            try! managedObjectContext.save()
            banksPreloaded = true
        }
    }
    
    func resetData() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Bank")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try persistentStoreCoordinator.execute(deleteRequest, with: managedObjectContext)
        } catch {
            print("Failed to reset the database")
        }
        banksPreloaded = false
        loadData()
    }
    
    func banksFetchController() -> NSFetchedResultsController<Bank> {
        let context = CoreDataManager.sharedInstance.managedObjectContext
        let request = NSFetchRequest<Bank>()
        request.entity = NSEntityDescription.entity(forEntityName: "Bank", in: context)
        request.fetchBatchSize = 20
        request.sortDescriptors = [NSSortDescriptor(key: "zip", ascending: true)]
        
        let fetchResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: "state", cacheName: nil)
        try! fetchResultsController.performFetch()
        return fetchResultsController
    }
}
