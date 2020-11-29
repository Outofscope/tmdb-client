//
//  DateHelper.swift
//  Movies
//
//  Created by Konstantin Medvedenko on 29.11.2020.
//

import Foundation

struct DateHelper {
    static func formattedDate(withStr inputStr: String) -> String {
        let readFormatter = DateFormatter()
        readFormatter.dateFormat = "yyyy-MM-dd"
        
        if let date = readFormatter.date(from: inputStr) {
            let writeFormatter = DateFormatter()
            writeFormatter.dateStyle = .long
            return writeFormatter.string(from: date)
        } else {
            return inputStr
        }
    }
}
