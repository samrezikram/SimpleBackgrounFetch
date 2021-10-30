//
//  ExchangeRateViewModelTests.swift
//  SimpleBackgroundFetchTests
//
//  Created by Samrez Ikram on 31/10/2021.
//

import Foundation
import XCTest
@testable import SimpleBackgroundFetch

class ExchangeRateViewModelTests: XCTestCase {
    
    override func setUp() {
        super.setUp()

    }

    override func tearDown() {
        super.tearDown()
    }
    
    func testChangeLocationUpdatesLocationName() {
        // Given A apiservice
        let expect = XCTestExpectation(description: "Data has been fetched from cache or network")
        
        NetworkManager.getBitoinExchangeRate { exchangeRates in
            expect.fulfill()
            XCTAssertEqual( exchangeRates?.chartName , "Bitcoin")
            XCTAssertNotNil(exchangeRates?.time.updated)
        }

        wait(for: [expect], timeout: 15.0)

    }

    
}
