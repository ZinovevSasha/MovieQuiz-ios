import XCTest
@testable import MovieQuiz

final class MovieQuizViewControllerProtocolMock: MovieQuizViewControllerProtocol {
    func enableButtons() { }

    func show(quiz step: MovieQuiz.QuizStepViewModel) {}

    func show(quiz result: MovieQuiz.QuizResultsViewModel) {}

    func highlightImageBorder(isCorrectAnswer: Bool) {}

    func showNetworkError(message: String) {}

    func hideLoadingIndicator() {}

    func showLoadingIndicator() {}
}

final class MovieQuizPresenterTests: XCTestCase {
    func testPresenterConvertModel() throws {
        let viewControllerMock = MovieQuizViewControllerProtocolMock()
        let movieQuizPresenter = MovieQuizPresenter(viewController: viewControllerMock)
        // Given
        let emptyData = Data()
        let question = QuizQuestion(
            image: emptyData,
            text: "Question Text",
            correctAnswer: true)
        // When
        let viewModel = movieQuizPresenter.convert(model: question)
        // Then
        XCTAssertNotNil(viewModel.image)
        XCTAssertEqual(viewModel.question, "Question Text")
        XCTAssertEqual(viewModel.questionNumber, "1/10")
    }
}
