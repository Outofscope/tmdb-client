//
//  ApiClientTests.swift
//  MoviesTests
//
//  Created by Konstantin Medvedenko on 28.11.2020.
//

import XCTest

class ApiClientTests: XCTestCase {
    
    override func setUp() {
        continueAfterFailure = false
    }

    func testDiscoverUrlGeneration() throws {
        
        let api = ApiClient(baseUrl: URL(string: "https://test.host.com/dir/subdir/")!,
                             apiKey: "123-test-key",
                             language: "uk-UA")
        
        //
        
        let discoverUrl = api.discoverUrl(page: 42)
        
        XCTAssertNotNil(discoverUrl)
        XCTAssertEqual(discoverUrl!.absoluteString,
                       "https://test.host.com/dir/subdir/discover/movie?api_key=123-test-key&language=uk-UA&page=42")
    }
    
    func testSearchUrlGeneration() throws {
        let api = ApiClient(baseUrl: URL(string: "https://api.themoviedb.org/3/")!,
                             apiKey: "aaabbbccc",
                             language: "de")
        
        //
                
        let searchUrl1 = api.searchUrl(query: "тіні забутих предків", page: 1)
        
        XCTAssertNotNil(searchUrl1)
        XCTAssertEqual(searchUrl1!.absoluteString,
                       "https://api.themoviedb.org/3/search/movie?api_key=aaabbbccc&query=%D1%82%D1%96%D0%BD%D1%96%20%D0%B7%D0%B0%D0%B1%D1%83%D1%82%D0%B8%D1%85%20%D0%BF%D1%80%D0%B5%D0%B4%D0%BA%D1%96%D0%B2&language=de&page=1")
        
        //
        
        let searchUrl2 = api.searchUrl(query: "", page: 1)
        
        XCTAssertNil(searchUrl2, "Empty query should lead to nil URL")
        
        //
        
        let searchUrl3 = api.searchUrl(query: "police acad", page: 1)
        
        XCTAssertNotNil(searchUrl3)
        XCTAssertEqual(searchUrl3!.absoluteString,
                       "https://api.themoviedb.org/3/search/movie?api_key=aaabbbccc&query=police%20acad&language=de&page=1")
    }
    
    func testDetailsUrlGeneration() throws {
        
        let api = ApiClient(baseUrl: URL(string: "http://google.com/")!,
                             apiKey: "keep-off",
                             language: "en-US")
        
        //
        
        let detailsUrl = api.detailsUrl(movieId: 12348765)
        
        XCTAssertNotNil(detailsUrl)
        XCTAssertEqual(detailsUrl?.absoluteString,
                       "http://google.com/movie/12348765?api_key=keep-off&language=en-US")
    }
}
