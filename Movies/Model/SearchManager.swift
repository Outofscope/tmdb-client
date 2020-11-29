//
//  SearchManager.swift
//  Movies
//
//  Created by Konstantin Medvedenko on 29.11.2020.
//

import Foundation


protocol SearchManagerDelegate: AnyObject {
    func searchManagerDidUpdateResults()
}


class SearchManager {
    
    weak var delegate: SearchManagerDelegate?
    
    private let api: ApiClient
    
    init(api: ApiClient) {
        self.api = api
    }
    
    //
    
    private var currentQuery = ""
    
    // pages are numbered starting from 1
    private var totalPageCount = 0
    private var lastDownloadedPage = 0

    private var movieList = [Movie]()
    
    private var searchFetchIsInProgress = false
    
    var hasMoreResults: Bool {
        totalPageCount > lastDownloadedPage
    }
    
    var movieCount: Int {
        return movieList.count
    }
    
    func movie(atIndex index: Int) -> Movie {
        return movieList[index]
    }
    
    // call and completion in the main queue
    func search(_ query: String, page: Int = 1, completion: @escaping (Error?) -> ()) {
        
        currentQuery = query
        
        if query.count == 0 {
            movieList.removeAll()
            lastDownloadedPage = 0
            totalPageCount = 0
            delegate?.searchManagerDidUpdateResults()
            return
        }
        
        //
        
        if searchFetchIsInProgress {
            return
        }
        
        searchFetchIsInProgress = true
        
        //
        
        if page == 1 {
            movieList.removeAll()
            delegate?.searchManagerDidUpdateResults()
        }
        
        api.requestSearch(query: query, page: page) { [weak self = self] (movieList, totalPages, error) in
            guard let self = self else {
                return
            }
            
            guard let movieList = movieList, let totalPages = totalPages else {
                DispatchQueue.main.async {
                    self.searchFetchIsInProgress = false
                    completion(error ?? AppError.emptyResponse)
                }
                return
            }
            
            DispatchQueue.main.async {
                self.lastDownloadedPage = page
                self.totalPageCount = totalPages
                self.searchFetchIsInProgress = false
                
                self.movieList.append(contentsOf: movieList)
                self.delegate?.searchManagerDidUpdateResults()
            }
        }
    }
    
    func fetchNextPageIfNeeded(completion: @escaping (Error?) -> ()) {
        
        if !hasMoreResults {
            return
        }
        
        let nextPage = lastDownloadedPage + 1
        search(currentQuery, page: nextPage, completion: completion)
    }
}
