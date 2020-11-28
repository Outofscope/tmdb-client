//
//  Wrap.swift
//  Movies
//
//  Created by Konstantin Medvedenko on 28.11.2020.
//

import Foundation

struct Envelope: Decodable {
    let page: Int?
    let totalPages: Int?
    let results: [Movie]?
}
