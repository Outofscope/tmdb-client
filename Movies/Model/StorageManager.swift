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
    
    private let totalPageCountKey = "totalPageCount"
    private let lastDownloadedPageKey = "lastDownloadedPage"

    private var totalPageCount: Int {
        set {
            UserDefaults.standard.setValue(newValue, forKey: totalPageCountKey)
        }
        get {
            UserDefaults.standard.integer(forKey: totalPageCountKey)
        }
    }
    
    private var lastDownloadedPage: Int {
        set {
            UserDefaults.standard.setValue(newValue, forKey: lastDownloadedPageKey)
        }
        get {
            UserDefaults.standard.integer(forKey: lastDownloadedPageKey)
        }
    }
    
    private var discoverFetchIsInProgress = false
    
    var hasMoreResults: Bool {
        totalPageCount > lastDownloadedPage
    }
    
    
    init(api: ApiClient, container: NSPersistentContainer) {
        self.api = api
        self.container = container
    }
    
    // page starts from 1
    private func fetchDiscover(page: Int, completion: @escaping (Int?, Error?) -> ()) {
        api.requestDiscover(page: page) { [weak self = self] (movieList, totalPages, error) in
            
            guard let self = self else {
                return
            }
            
            guard let movieList = movieList, let totalPages = totalPages else {
                completion(nil, error ?? AppError.emptyResponse)
                return
            }
            
            let needsRefresh = (page == 1)
            
            self.updateStorage(movieList, refresh: needsRefresh)
            
            completion(totalPages, nil)
        }
    }
    
    // call and completion in the main queue
    func fetchNextDiscoverPageIfNeeded(completion: ((Error?) -> ())? = nil) {
        
        if discoverFetchIsInProgress {
            return
        }
        
        discoverFetchIsInProgress = true
        
        let page = lastDownloadedPage + 1
        
        fetchDiscover(page: page) { [weak self = self] (totalPages, error) in
            
            guard let self = self else {
                return
            }
            
            DispatchQueue.main.async {
                self.totalPageCount = totalPages ?? 0
                self.lastDownloadedPage = page
                self.discoverFetchIsInProgress = false
                completion?(error)
            }
        }
    }
    
    func storedMovie(forMovieId movieId: Int64) -> StoredMovie? {
        let request: NSFetchRequest<StoredMovie> = StoredMovie.fetchRequest()
        request.predicate = NSPredicate(format: "movieId == %ld", movieId)
        
        do {
            let result = try container.viewContext.fetch(request)
            return result.first
        } catch {
            print("Movie fetch by ID error: \(error)")
            return nil
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
