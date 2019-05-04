//
//  ServerTest.swift
//  MovieTestTests
//
//  Created by Rydus on 23/04/2019.
//  Copyright © 2019 Rydus. All rights reserved.
//

import Foundation
import XCTest
@testable import MovieTest

class ServerTest : XCTestCase {
    
    //  MARK:   similar we can check xct assert to test business logic, functionality through unit testing / component testing
    func testIsValidAPI_KEY() {
        let server = Server()
        XCTAssertTrue(server.IsValidAPI_KEY(api_key: "52db6e247a76c3527bf11a9b0606f5f7"))
    }
}
