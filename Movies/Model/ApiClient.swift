//
//  ApiClient.swift
//  Movies
//
//  Created by Konstantin Medvedenko on 28.11.2020.
//

import Foundation

class ApiClient {
    
    private let session = URLSession.shared
    
    private let baseUrl: URL
    private let apiKey: String
    private let language: String

    init(baseUrl: URL, apiKey: String, language: String) {
        self.baseUrl = baseUrl
        self.apiKey = apiKey
        self.language = language
    }
    
    
    // MARK: - URLs
    
    func discoverUrl(page: Int) -> URL? {
        return URL(string: "discover/movie?api_key=\(apiKey)&language=\(language)&page=\(page)",
                   relativeTo: baseUrl)
    }
    
    func searchUrl(query: String, page: Int) -> URL? {
        
        if query.count == 0 {
            return nil
        }
        
        guard let escapedQuery = query.addingPercentEncoding(withAllowedCharacters: .alphanumerics) else {
            return nil
        }
        
        return URL(string: "search/movie?api_key=\(apiKey)&query=\(escapedQuery)&language=\(language)&page=\(page)",
                   relativeTo: baseUrl)
    }
    
    func detailsUrl(movieId: Int) -> URL? {
        return URL(string: "movie/\(movieId)?api_key=\(apiKey)&language=\(language)",
                   relativeTo: baseUrl)
    }
    
    
    // MARK: - Requests
    
    // page starts from 1
    func requestDiscover(page: Int, completion: @escaping ([Movie]?, Error?) -> ()) {
        
        guard let url = discoverUrl(page: page) else {
            completion(nil, AppError.urlError)
            return
        }
        
        sendRequest(withUrl: url, completion: completion)
    }
    
    func requestSearch(query: String, page: Int, completion: @escaping ([Movie]?, Error?) -> ()) {
        
        guard let url = searchUrl(query: query, page: page) else {
            completion(nil, AppError.urlError)
            return
        }
        
        sendRequest(withUrl: url, completion: completion)
    }
    
    private func sendRequest(withUrl url: URL, completion: @escaping ([Movie]?, Error?) -> ()) {
        let task = session.dataTask(with: url) { (data, response, error) in
            if error != nil {
                completion(nil, error)
            } else {
                if let data = data {
                    if let movieList = Parser.parseMovieList(data)?.results {
                        completion(movieList, nil)
                    } else {
                        completion(nil, AppError.emptyResponse)
                    }
                } else {
                    completion(nil, AppError.emptyResponse)
                }
            }
        }
        
        task.resume()
    }
}
