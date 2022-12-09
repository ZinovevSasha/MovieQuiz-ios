import XCTest
@testable import MovieQuiz

final class MovieQuizUITests: XCTestCase {
    // swiftlint:disable:next implicitly_unwrapped_optional
    var app: XCUIApplication!

    override func setUpWithError() throws {
        try super.setUpWithError()

        app = XCUIApplication()
        app .launch()
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()

        app.terminate()
        app = nil
    }

    func testYesButton() throws {
        let firstPoster = app.images["Poster"]
        let indexLabel = app.staticTexts["Index"]
        app.buttons["Yes"].tap()
        let secondPoster = app.images["Poster"]
        sleep(3)
        XCTAssertFalse(firstPoster == secondPoster)
        XCTAssertTrue(indexLabel.label == "2/10")
    }

    func testNoButton() throws {
        let firstPoster = app.images["Poster"]
        let indexLabel = app.staticTexts["Index"]
        app.buttons["No"].tap()
        let secondPoster = app.images["Poster"]
        sleep(3)
        XCTAssertFalse(firstPoster == secondPoster)
        XCTAssertTrue(indexLabel.label == "2/10")
    }

    func testEndOfRoundAlert() {
        for _ in 1...10 {
            app.buttons["No"].tap()
            sleep(1)
        }
        let alert = app.alerts["Этот раунд окончен!"]
        sleep(2)

        XCTAssertTrue(app.alerts["Этот раунд окончен!"].exists)
        XCTAssertTrue(alert.label == "Этот раунд окончен!")
        XCTAssertTrue(alert.buttons.firstMatch.label == "Сыграть еще раз")
    }

    func testAlertDismiss() {
        for _ in 1...10 {
            app.buttons["No"].tap()
            sleep(1)
        }
        let alert = app.alerts["Этот раунд окончен!"]
        alert.buttons.firstMatch.tap()

        sleep(2)
        let indexLabel = app.staticTexts["Index"]
        XCTAssertFalse(app.alerts["Этот раунд окончен!"].exists)
        XCTAssertTrue(indexLabel.label == "1/10")
    }
}
