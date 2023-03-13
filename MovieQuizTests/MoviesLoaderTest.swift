import XCTest
@testable import MovieQuiz

struct StubNetworkClient: NetworkRouting {
    let emulateError: Bool

    func fetch(url: URL, completion: @escaping (Result<Data, Errors>) -> Void) {
        if emulateError {
            completion(.failure(.testError))
        } else {
            completion(.success(expectedResponse))
        }
    }

    private var expectedResponse: Data {
        """
            {
            "errorMessage" : "",
                "items" : [
                    {
                    "crew" : "Dan Trachtenberg (dir.), Amber Midthunder, Dakota Beavers",
                    "fullTitle" : "Prey (2022)",
                    "id" : "tt11866324",
                    "imDbRating" : "7.2",
                    "imDbRatingCount" : "93332",
                    "image" : "https://m.media-amazon.com/images/M/MV5BMDBlMDYxMDktOTUxMS00MjcxLWE2YjQtNjNhMjNmN2Y3ZDA1XkEyXkFqcGdeQXVyMTM1MTE1NDMx._V1_Ratio0.6716_AL_.jpg",
                    "rank" : "1",
                    "rankUpDown" : "+23",
                    "title" : "Prey",
                    "year" : "2022"
                },
                {
                    "crew" : "Anthony Russo (dir.), Ryan Gosling, Chris Evans",
                    "fullTitle" : "The Gray Man (2022)",
                    "id" : "tt1649418",
                    "imDbRating" : "6.5",
                    "imDbRatingCount" : "132890",
                    "image" : "https://m.media-amazon.com/images/M/MV5BOWY4MmFiY2QtMzE1YS00NTg1LWIwOTQtYTI4ZGUzNWIxNTVmXkEyXkFqcGdeQXVyODk4OTc3MTY@._V1_Ratio0.6716_AL_.jpg",
                    "rank" : "2",
                    "rankUpDown" : "-1",
                    "title" : "The Gray Man",
                    "year" : "2022"
                }
            ]
            }
            """.data(using: .utf8) ?? Data()
    }
}

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
