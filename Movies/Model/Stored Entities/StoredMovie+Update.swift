//
//  StoredMovie+Update.swift
//  Movies
//
//  Created by Konstantin Medvedenko on 28.11.2020.
//

import Foundation

extension StoredMovie {
    func update(with movie: Movie) {
        movieId = Int64(movie.id ?? 0)
        title = movie.title
        posterPath = movie.posterPath
        overview = movie.overview
        releaseDate = movie.releaseDate
        popularity = movie.popularity ?? 0
    }
}
