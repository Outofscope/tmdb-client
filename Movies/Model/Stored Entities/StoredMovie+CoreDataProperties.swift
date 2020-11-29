//
//  StoredMovie+CoreDataProperties.swift
//  Movies
//
//  Created by Konstantin Medvedenko on 28.11.2020.
//
//

import Foundation
import CoreData


extension StoredMovie {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<StoredMovie> {
        return NSFetchRequest<StoredMovie>(entityName: "StoredMovie")
    }

    @NSManaged public var title: String?
    @NSManaged public var posterPath: String?
    @NSManaged public var overview: String?
    @NSManaged public var releaseDate: String?
    @NSManaged public var movieId: Int64
    @NSManaged public var popularity: Double
    @NSManaged public var budget: Int64
    @NSManaged public var revenue: Int64
    @NSManaged public var runtime: Int64

}

extension StoredMovie : Identifiable {

}
