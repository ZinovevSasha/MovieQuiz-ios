//
//  MovieQuizTests.swift
//  MovieQuizTests
//
//  Created by Александр Зиновьев on 06.12.2022.
//

import XCTest
@testable import MovieQuiz

final class ArrayTest: XCTestCase {
    
    func testArrayNotNil() throws {
        // Given
        let myArray = [1,2,3]
        
        // When
        let test = myArray[safe: 0]
        
        // Then
        XCTAssertNotNil(test)
        XCTAssertEqual(test, 1)
        
    }
    
    func testArrayNil() throws {
        // Given
        let myArray: [Int] = []
        
        // When
        let test = myArray[safe: 0]
        
        // Then
        XCTAssertNil(test)
        
    }
}
