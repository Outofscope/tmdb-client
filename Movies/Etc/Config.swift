//
//  Config.swift
//  Movies
//
//  Created by Konstantin Medvedenko on 28.11.2020.
//

import Foundation

struct Config {
    static let baseUrl = URL(string: "https://api.themoviedb.org/3/")! // with trailing slash
    static let apiKey = "1cc33b07c9aa5466f88834f7042c9258"
    static let defaultLanguage = "en"
    
    static let nextPageThreshold = 5 // start downloading next page when the scroll is this near the last item
}
