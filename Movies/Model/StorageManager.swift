//
//  StorageManager.swift
//  Movies
//
//  Created by Konstantin Medvedenko on 28.11.2020.
//

import Foundation
import CoreData

class StorageManager {
    private let api: ApiClient
    private let container: NSPersistentContainer
    
    init(api: ApiClient, container: NSPersistentContainer) {
        self.api = api
        self.container = container
    }
    
    // page starts from 1
    func fetchDiscover(page: Int, completion: @escaping (Error?) -> ()) {
        
        api.requestDiscover(page: page) { [weak self = self] (movieList, error) in
            
            guard let self = self else {
                return
            }
            
            guard let movieList = movieList else {
                completion(error ?? AppError.emptyResponse)
                return
            }
            
            let needsRefresh = (page == 1)
            
            self.updateStorage(movieList, refresh: needsRefresh)
            
            completion(nil)
        }
        
    }
    
    
    // MARK: -
    
    private func updateStorage(_ movieList: [Movie], refresh: Bool) {
        let updateContext = self.container.newBackgroundContext()
        updateContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
        
        updateContext.performAndWait {
            
            if refresh { // possible refresh
                clearAllDiscover(in: updateContext)
            }
            
            var order: Int64 = 0

            for movie in movieList {

                order += 1

                if let storedMovie = NSEntityDescription.insertNewObject(forEntityName: "StoredMovie", into: updateContext) as? StoredMovie {

                    storedMovie.update(with: movie)
                    storedMovie.metaOrder = order
                }
            }
            
            if updateContext.hasChanges {
                do {
                    try updateContext.save()
                } catch {
                    print("Saving error: \(error)")
                }
                updateContext.reset()
            }
        }
    }
    
    private func clearAllDiscover(in context: NSManagedObjectContext) {
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: StoredMovie.fetchRequest())
        deleteRequest.resultType = .resultTypeObjectIDs
        
        do {
            let result = try context.execute(deleteRequest) as? NSBatchDeleteResult
            
            if let idList = result?.result as? [NSManagedObjectID] {
                NSManagedObjectContext.mergeChanges(fromRemoteContextSave: [NSDeletedObjectsKey: idList],
                                                    into: [container.viewContext])
            }
        } catch {
            print("Error: \(error)")
        }
    }
}
