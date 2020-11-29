//
//  DisplayedMovie.swift
//  Movies
//
//  Created by Konstantin Medvedenko on 29.11.2020.
//

import Foundation

struct DisplayedMovie {
    let id: Int?
    let title: String?
    let posterPath: String?
    let overview: String?
    let releaseDate: String?
    let popularity: Double?
    
    init(movie: Movie) {
        id = movie.id
        title = movie.title
        posterPath = movie.posterPath
        overview = movie.overview
        releaseDate = movie.releaseDate
        popularity = movie.popularity
    }
    
    init(storedMovie: StoredMovie) {
        id = storedMovie.movieId > 0 ? Int(storedMovie.movieId) : nil
        title = storedMovie.title
        posterPath = storedMovie.posterPath
        overview = storedMovie.overview
        releaseDate = storedMovie.releaseDate
        popularity = storedMovie.popularity
    }
}
