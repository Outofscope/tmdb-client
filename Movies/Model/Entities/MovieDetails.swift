//
//  MovieDetails.swift
//  Movies
//
//  Created by Konstantin Medvedenko on 28.11.2020.
//

import Foundation

struct MovieDetails: Decodable {
    let id: Int?
    let title: String?
    let posterPath: String?
    let overview: String?
    let releaseDate: String?
    
    let budget: Int?
    let revenue: Int?
    let runtime: Int?
}
