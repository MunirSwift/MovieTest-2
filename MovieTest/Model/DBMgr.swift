//
//  DBMgr.swift
//  MovieTest
//
//  Created by Rydus on 20/04/2019.
//  Copyright © 2019 Rydus. All rights reserved.
//

import Foundation

import Foundation
import CoreData

final class DBMgr {
    
    private init() {}
    static let shared = DBMgr()
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "MovieTest")
        let description = NSPersistentStoreDescription()
        description.shouldMigrateStoreAutomatically = true
        description.shouldInferMappingModelAutomatically = true
        //container.persistentStoreDescriptions = [description]
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    lazy var context = persistentContainer.viewContext
    
    // MARK: - Core Data Saving support
    
    func save () {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    //  MARK:   Get Main Movie
    func getMainMovie(completion: @escaping (_ obj: MainMovie)->()) {
        do {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName:"MainMovie")
            request.fetchLimit = 1
            if try context.count(for:request)>0 {
                let result = try context.fetch(request) as! [MainMovie]
                completion(result.first!)
            }
        } catch {
            completion(MainMovie());
        }
    }    
    
    //  MARK:   Del Rows
    func delRows(entity:String) {
        do {
            let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
            let request = NSBatchDeleteRequest(fetchRequest: fetch)
            _ = try context.execute(request)
        }catch{}
    }
    
    //  MARK:   Get Num Rows
    func getNumRows(entity:String)->Int {
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        do {
            let c = try context.count(for:fetch)
            return c
        } catch {
            return 0;
        }
    }
}
