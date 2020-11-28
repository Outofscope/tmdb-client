//
//  Parser.swift
//  Movies
//
//  Created by Konstantin Medvedenko on 28.11.2020.
//

import Foundation

struct Parser {
    static func parseMovieList(_ data: Data) -> Envelope? {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        let result: Envelope?
        
        do {
            result = try decoder.decode(Envelope.self, from: data)
        } catch {
            result = nil
            print("Parsing error: \(error)")
        }
        
        return result
    }
}
