import XCTest
@testable import MovieQuiz

final class GamesRecordModelTest: XCTestCase {
    func testModelCanBeCompared() throws {
        // Given
        let model1 = GameRecord(correct: 4, total: 7, date: Date())
        let model2 = GameRecord(correct: 5, total: 9, date: Date())
        // When
        let resultOfComparison1 = model1 < model2
        // Then
        XCTAssertTrue(resultOfComparison1)
    }
}
