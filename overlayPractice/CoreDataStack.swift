//
//  CoreDataStack.swift
//  overlayPractice
//
//  Created by Anna Rogers on 8/6/16.
//  Copyright © 2016 Anna Rogers. All rights reserved.
//

import CoreData

struct CoreDataStack {
    
    // MARK:  - Properties
    private let model : NSManagedObjectModel
    private let coordinator : NSPersistentStoreCoordinator
    private let modelURL : NSURL
    private let dbURL : NSURL
    private let persistingContext : NSManagedObjectContext
    private let backgroundContext : NSManagedObjectContext
    let context : NSManagedObjectContext
    
    
    // MARK:  - Initializers
    init?(modelName: String){
        
        // Assumes the model is in the main bundle
        guard let modelURL = NSBundle.mainBundle().URLForResource(modelName, withExtension: "momd") else {
            print("Unable to find \(modelName)in the main bundle")
            return nil}
        
        self.modelURL = modelURL
        
        // Try to create the model from the URL
        guard let model = NSManagedObjectModel(contentsOfURL: modelURL) else{
            print("unable to create a model from \(modelURL)")
            return nil
        }
        self.model = model
        
        // Create the store coordinator
        coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        
        // Create a persistingContext (private queue) and a child one (main queue)
        // create a context and add connect it to the coordinator
        persistingContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        persistingContext.persistentStoreCoordinator = coordinator
        
        context = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        context.parentContext = persistingContext
        
        // Create a background context child of main context
        backgroundContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        backgroundContext.parentContext = context
        
        // Add a SQLite store located in the documents folder
        let fm = NSFileManager.defaultManager()
        
        guard let docUrl = fm.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first else{
            print("Unable to reach the documents folder")
            return nil
        }
        
        self.dbURL = docUrl.URLByAppendingPathComponent("model.sqlite")
        
        //options for migration: want to migrate and want to get it to find out how to migrate
        let options = [
            NSInferMappingModelAutomaticallyOption: true,
            NSMigratePersistentStoresAutomaticallyOption: true
        ]
        
        //use the migrations when we add a store coordinator
        do{
            try addStoreCoordinator(NSSQLiteStoreType, configuration: nil, storeURL: dbURL, options: options)
        }catch{
            print("unable to add store at \(dbURL)")
        }
        
    }
    
    // MARK:  - Utils
    func addStoreCoordinator(storeType: String,
                             configuration: String?,
                             storeURL: NSURL,
                             options : [NSObject : AnyObject]?) throws{
        
        try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: dbURL, options: nil)
        
    }
    
    func countEntities () {
        print("count entities called")
        let moc = context
        let fetchRequest = NSFetchRequest(entityName: "Game")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "created_at", ascending: false)]
        
        var entities: [Game]
        do {
            entities = try moc.executeFetchRequest(fetchRequest) as! [Game]
        } catch {
            fatalError("Failed to fetch employees: \(error)")
        }
        // set the current game - if the finish date is nil
        print("entities.count", entities.count)
        if entities.count > 0 {
            for entity in entities {
                print(entity.continent)
                if entity.match_length != nil {
                    print("length",entity.match_length)
                }
            }
        }
    }
}


// MARK:  - Removing data
extension CoreDataStack  {
    
    func dropAllData() throws{
        // delete all the objects in the db. This won't delete the files, it will
        // just leave empty tables.
        try coordinator.destroyPersistentStoreAtURL(dbURL, withType:NSSQLiteStoreType , options: nil)
        
        try addStoreCoordinator(NSSQLiteStoreType, configuration: nil, storeURL: dbURL, options: nil)
    }
}

// MARK:  - Batch processing in the background
extension CoreDataStack{
    typealias Batch=(workerContext: NSManagedObjectContext) -> ()
    
    func performBackgroundBatchOperation(batch: Batch){
        
        backgroundContext.performBlock(){
            batch(workerContext: self.backgroundContext)
            
            // Save it to the parent context, so normal saving
            // can work
            do{
                try self.backgroundContext.save()
            }catch{
                fatalError("Error while saving backgroundContext: \(error)")
            }
        }
    }
}

// MARK:  - Save
extension CoreDataStack {
    
    func save() {
        context.performBlockAndWait(){
            if self.context.hasChanges{
                print("HAS CHANGES")
                do {
                    try self.context.save()
                } catch {
                    fatalError("Error while saving main context: \(error)")
                }
                
                // now we save in the background
                self.persistingContext.performBlock(){
                    do{
                        try self.persistingContext.save()
                    } catch {
                        fatalError("Error while saving persisting context: \(error)")
                    }
                }
            }
        }
    }
    
    
    func autoSave(delayInSeconds : Int){
        if delayInSeconds > 0 {
            print("Autosaving")
            save()
            
            let delayInNanoSeconds = UInt64(delayInSeconds) * NSEC_PER_SEC
            let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delayInNanoSeconds))
            
            dispatch_after(time, dispatch_get_main_queue(), {
                self.autoSave(delayInSeconds)
            })
        }
    }
}
















