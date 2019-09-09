//
//  DataController.swift
//  github-usersbook
//
//  Created by Lukasz on 27/07/2019.
//  Copyright © 2019 Lukasz. All rights reserved.
//

import Foundation
import CoreData

// Mark: - CoreData stack

class DataController {
    
    let persistanceContainer: NSPersistentContainer
    let persistentStoreCoordinator = NSPersistentStoreCoordinator()
    
    var viewContext: NSManagedObjectContext {
        return persistanceContainer.viewContext
    }
    
    var backgroundContext: NSManagedObjectContext!
    
    init (modelName: String) {
        persistanceContainer = NSPersistentContainer(name: modelName)
    }
    
   
    
    func configureContexts() {
        
        backgroundContext = persistanceContainer.newBackgroundContext()
        
        viewContext.automaticallyMergesChangesFromParent = true
        backgroundContext.automaticallyMergesChangesFromParent = true
        
        viewContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
        backgroundContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        
    }
    
    //completion for background context prepared for future usage
    func load(completion: (() -> Void)? = nil) {
        
        persistanceContainer.loadPersistentStores { (storeDescription, error) in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
            self.autoSaveViewContext()
            self.configureContexts()
            completion?()
        }
    }
}


//MARK: - Autosave
//Autosave every 30 secs

extension DataController {
    func autoSaveViewContext(interval: TimeInterval = 30) {
        guard interval > 0 else {
            return
        }
        if viewContext.hasChanges {
            try? viewContext.save()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
            self.autoSaveViewContext(interval: interval)
        }
    }
}
