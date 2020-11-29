//
//  Config.swift
//  Movies
//
//  Created by Konstantin Medvedenko on 28.11.2020.
//

import UIKit

struct Config {
    
    // URLs with trailing slash
    static let baseUrl = URL(string: "https://api.themoviedb.org/3/")!
    static let imageBaseUrl = URL(string: "https://image.tmdb.org/t/p/")!
    
    static let apiKey = "1cc33b07c9aa5466f88834f7042c9258"
    static let defaultLanguage = "en"
    
    static let posterSizeThumb = "w154"
    static let posterSizeDetails = "w780"

    static let nextPageThreshold = 5 // start downloading next page when the scroll is this near the last item
    
    static let activityIndicatorSize: CGFloat = 60
    
    static let searchDebounceInterval: TimeInterval = 0.5
}
