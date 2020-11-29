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
    private var lastDownloadedPage = 0
    
    private var movieList = [Movie]()
    
    var movieCount: Int {
        return movieList.count
    }
    
    func movie(atIndex index: Int) -> Movie {
        return movieList[index]
    }
    
    // call and completion in the main queue
    func search(_ query: String, page: Int = 1, completion: @escaping (Error?) -> ()) {
        
        if page == 1 {
            movieList.removeAll()
            delegate?.searchManagerDidUpdateResults()
        }
        
        currentQuery = query
        
        api.requestSearch(query: query, page: page) { [weak self = self] (movieList, error) in
            guard let self = self else {
                return
            }
            
            guard let movieList = movieList else {
                completion(error ?? AppError.emptyResponse)
                return
            }
            
            self.lastDownloadedPage = page
            
            DispatchQueue.main.async {
                self.movieList.append(contentsOf: movieList)
                self.delegate?.searchManagerDidUpdateResults()
            }
        }
    }
    
    func fetchNextPageIfNeeded(completion: @escaping (Error?) -> ()) {
        let nextPage = lastDownloadedPage + 1
        search(currentQuery, page: nextPage, completion: completion)
    }
}
