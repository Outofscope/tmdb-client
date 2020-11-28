//
//  ApiClient.swift
//  Movies
//
//  Created by Konstantin Medvedenko on 28.11.2020.
//

import Foundation

class ApiClient {
    
    private let baseUrl: URL
    private let apiKey: String
    private let language: String

    init(baseUrl: URL, apiKey: String, language: String) {
        self.baseUrl = baseUrl
        self.apiKey = apiKey
        self.language = language
    }
    
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
}
