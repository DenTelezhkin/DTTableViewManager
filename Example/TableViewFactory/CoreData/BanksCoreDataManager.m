//
//  BanksCoreDataManager.m
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 07.12.13.
//  Copyright (c) 2013 Denys Telezhkin. All rights reserved.
//

#import "BanksCoreDataManager.h"
#import <CoreData/CoreData.h>
#import "Bank.h"

@interface BanksCoreDataManager()
@property (readwrite, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readwrite, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readwrite, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@end

static NSString * const kBanksDataPreloaded = @"UserDefaultsBanksPreloaded";

@implementation BanksCoreDataManager

+ (instancetype)sharedInstance
{
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

-(void)preloadData
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kBanksDataPreloaded]) {
        return;
    }
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"Banks" ofType:@"json"];
    NSData * banksData = [NSData dataWithContentsOfFile:filePath];
    NSArray * banks = [NSJSONSerialization JSONObjectWithData:banksData
                                                      options:NSJSONReadingAllowFragments
                                                        error:nil];
    for (NSDictionary * bank in banks)
    {
        [Bank insertBankWithInfo:bank inManagedObjectContext:self.managedObjectContext];
    }
    
    [self saveContext];
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kBanksDataPreloaded];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Core Data stack

- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Banks" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Banks.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
