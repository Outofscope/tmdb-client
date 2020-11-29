//
//  MoviesTests.swift
//  MoviesTests
//
//  Created by Konstantin Medvedenko on 28.11.2020.
//

import XCTest
@testable import Movies

class MoviesTests: XCTestCase {
    
    override func setUp() {
        continueAfterFailure = false
    }
    
    func testDiscoverParsing() throws {
        let data = loadData(fromJsonFile: "movie-discover")
        let envelope = Parser.parseMovieList(data)
        
        XCTAssertNotNil(envelope, "Could not parse movie-discover response envelope")
        XCTAssertEqual(envelope!.page, 1)
        XCTAssertEqual(envelope!.totalPages, 500)
        XCTAssertNotNil(envelope!.results, "Could not parse movie-discover results list")
        XCTAssertEqual(envelope!.results!.count, 20, "Wrong movie count parsed")
        
        //
        
        let hardKill = envelope!.results![1]
        XCTAssertEqual(hardKill.id, 724989)
        XCTAssertEqual(hardKill.title, "Hard Kill")
        XCTAssertEqual(hardKill.posterPath, "/ugZW8ocsrfgI95pnQ7wrmKDxIe.jpg")
        XCTAssertNotNil(hardKill.overview)
        XCTAssertEqual(hardKill.releaseDate, "2020-10-23")
        XCTAssertEqual(hardKill.popularity, 1025.42)

        // intentionally removed some data from this record
        let theWitches = envelope!.results![2]
        XCTAssertNil(theWitches.id)
        XCTAssertNil(theWitches.title)
        XCTAssertNil(theWitches.posterPath)
        XCTAssertNil(theWitches.overview)
        XCTAssertNil(theWitches.releaseDate)
    }
    
    func testSearchParsing() throws {
        let data = loadData(fromJsonFile: "search-movies")
        let envelope = Parser.parseMovieList(data)
        
        XCTAssertNotNil(envelope, "Could not parse movie-discover response envelope")
        XCTAssertEqual(envelope!.page, 2)
        XCTAssertEqual(envelope!.totalPages, 4)
        XCTAssertNotNil(envelope!.results, "Could not parse movie-discover results list")
        XCTAssertEqual(envelope!.results!.count, 18, "Wrong movie count parsed") // removed two last items intentionally
        
        //
        
        let goldenEye = envelope!.results![3]
        XCTAssertEqual(goldenEye.id, 710)
        XCTAssertEqual(goldenEye.title, "GoldenEye")
        XCTAssertEqual(goldenEye.posterPath, "/bFzjdy6ucvNlXmJwoSoYfufV6lP.jpg")
        XCTAssertNotNil(goldenEye.overview)
        XCTAssertEqual(goldenEye.releaseDate, "1995-11-16")
        
        // intentionally removed some data from this record
        let casinoRoyale = envelope!.results![4]
        XCTAssertNil(casinoRoyale.id)
        XCTAssertNil(casinoRoyale.title)
        XCTAssertNil(casinoRoyale.posterPath)
        XCTAssertNil(casinoRoyale.overview)
        XCTAssertNil(casinoRoyale.releaseDate)
    }
    
    func testDetailsParsing() throws {
        let data = loadData(fromJsonFile: "get-movie-details")
        let butterflyEffect = Parser.parseMovieDetails(data)
        
        XCTAssertNotNil(butterflyEffect, "Could not parse get-movie-details response")
        
        XCTAssertEqual(butterflyEffect!.id, 1954)
        XCTAssertEqual(butterflyEffect!.title, "The Butterfly Effect")
        XCTAssertEqual(butterflyEffect!.posterPath, "/jY0hIz8eolynHqWN8vrTo0cypBI.jpg")
        XCTAssertNotNil(butterflyEffect!.overview)
        XCTAssertEqual(butterflyEffect!.releaseDate, "2004-01-22")
        
        XCTAssertEqual(butterflyEffect!.budget, 13000000)
        XCTAssertEqual(butterflyEffect!.revenue, 96060858)
        XCTAssertEqual(butterflyEffect!.runtime, 113)
    }
}


extension MoviesTests {
    func loadData(fromJsonFile jsonFileName: String) -> Data {
        let bundle = Bundle(for: type(of: self))
        let path = bundle.path(forResource: jsonFileName, ofType: "json")
        let data = try! Data(contentsOf: URL(fileURLWithPath: path!))
        return data
    }
}
