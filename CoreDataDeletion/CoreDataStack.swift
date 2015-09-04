//
//  CoreDataStack.swift
//  CoreDataDeletion
//
//  Created by Nikita Tuk on 04/09/15.
//  Copyright (c) 2015 Nikita Took. All rights reserved.
//

import CoreData

class CoreDataStack {
    
    let context:NSManagedObjectContext
    private let writingContext:NSManagedObjectContext
    private let psc:NSPersistentStoreCoordinator
    private let model:NSManagedObjectModel
    private let store:NSPersistentStore?
    
    init() {
        let bundle = NSBundle.mainBundle()
        let modelURL = bundle.URLForResource("CoreDataDeletion", withExtension:"momd")
        model = NSManagedObjectModel(contentsOfURL: modelURL!)!
        
        psc = NSPersistentStoreCoordinator(managedObjectModel:model)
        writingContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        writingContext.persistentStoreCoordinator = psc
        context = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        context.parentContext = writingContext
        let documentsURL = CoreDataStack.applicationDocumentsDirectory()
        let storeURL = documentsURL.URLByAppendingPathComponent("CoreDataDeletion")
        let options = [NSMigratePersistentStoresAutomaticallyOption: true]
        var error: NSError? = nil
        
        store = psc.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeURL, options: options, error:&error)
        
        if store == nil {
            println("Error adding persistent store: \(error)")
            abort()
        }
    }
    
    func childContext() -> NSManagedObjectContext {
        let childContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        childContext.parentContext = context
        return childContext
    }
    
    private static func applicationDocumentsDirectory() -> NSURL {
        let fileManager = NSFileManager.defaultManager()
        let urls = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask) as! [NSURL]
        return urls[0]
    }
    
}

extension NSManagedObjectContext {
    func saveToDb(completion:(Void -> Void)?) {
        performBlock({
            _ in
            var error: NSError?
            if self.save(&error) == false {
                println("Coundn't save context: \(error)")
            } else if let parentContext = self.parentContext {
                parentContext.saveToDb(completion)
            } else {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    if let completion = completion {
                        completion()
                    }
                })
            }
        })
    }
}
