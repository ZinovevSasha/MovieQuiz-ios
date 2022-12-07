import XCTest
@testable import MovieQuiz

final class MoviesLoaderTest: XCTestCase {
    func testSuccessLoading() throws {
        // Given
        let stubNetworkClient = StubNetworkClient(emulateError: false)
        let loader = MoviesLoader(networkClient: stubNetworkClient)
        // When
        let expectation = expectation(description: "Loading Expectation")
        loader.loadMovies { result in
            // Then
            switch result {
            case .success(let movies):
                XCTAssertEqual(2, movies.count)
                expectation.fulfill()
            case .failure:
                XCTFail("Unexpected error")
            }
        }
        waitForExpectations(timeout: 1)
    }

    func testFailureLoading() throws {
        // Given
        let stubNetworkClient = StubNetworkClient(emulateError: true)
        let loader = MoviesLoader(networkClient: stubNetworkClient)
        // When
        let expectation = expectation(description: "Failure Loading expectation")
        loader.loadMovies { result in
            // Then
            switch result {
            case .failure(let error):
                XCTAssertNotNil(error)
                XCTAssertEqual(error.errorDescription, "Test Error")
                expectation.fulfill()
            case .success:
                XCTFail("Unexpected error")
            }
        }
        waitForExpectations(timeout: 1)
    }
}
