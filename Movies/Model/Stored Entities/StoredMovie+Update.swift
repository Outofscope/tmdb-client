//
//  StoredMovie+Update.swift
//  Movies
//
//  Created by Konstantin Medvedenko on 28.11.2020.
//

import Foundation

extension StoredMovie {
    func update(with movie: Movie) {
        title = movie.title
        posterPath = movie.posterPath
        overview = movie.overview
        releaseDate = movie.releaseDate
    }
}