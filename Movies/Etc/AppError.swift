//
//  AppError.swift
//  Movies
//
//  Created by Konstantin Medvedenko on 28.11.2020.
//

import Foundation

enum AppError: String, Error {
    case urlError = "Error while forming API request URL"
    case emptyResponse = "Empty API response"
}

extension AppError: LocalizedError {
    public var errorDescription: String? {
        return rawValue
    }
}
