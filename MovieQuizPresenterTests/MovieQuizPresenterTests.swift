import XCTest
@testable import MovieQuiz

final class MovieQuizViewControllerProtocolSpy: MovieQuizViewControllerProtocol {
    var image: UIImage?
    var question: String?
    var questionNumber: String?
    var hideLoadingIndicatorCalled = false
    var enableButtonsCalled = false
    var networkErrorMessage: String?
    var showLoadingIndicatorCalled = false
    
    
    func disableButtons() {}
    func enableButtons() {
        enableButtonsCalled = true
    }
    func show(quiz step: MovieQuiz.QuizStepViewModel) {
        image = step.image
        question = step.question
        questionNumber = step.questionNumber
    }
    func show(quiz result: MovieQuiz.QuizResultsViewModel) {}
    func highlightImageBorder(isCorrectAnswer: Bool) {}
    func showNetworkError(message: String) {
        print(message)
        networkErrorMessage = message
    }
    func hideLoadingIndicator() {
        hideLoadingIndicatorCalled = true
    }
    func showLoadingIndicator() {
        showLoadingIndicatorCalled = true
    }
}

final class QuestionFactorySpy: QuestionFactoryProtocol {
    var requestNextQuestionCalled = false
    
    func loadData() {}
    
    func requestNextQuestion() {
        requestNextQuestionCalled = true
    }
    
    func setDelegate(delegate: MovieQuiz.QuestionFactoryDelegate) {}
}

final class MovieQuizPresenterTests: XCTestCase {
    func testDidReceiveNextQuestionWorksCorrect() throws {
        let viewControllerSpy = MovieQuizViewControllerProtocolSpy()
        let movieQuizPresenter = MovieQuizPresenter(
            view: viewControllerSpy,
            questionsFactory: nil,
            statisticService: nil
        )
        // Given
        let emptyData = Data()
        let question = QuizQuestion(
            image: emptyData,
            text: "Question Text",
            correctAnswer: true
        )
        // When
        movieQuizPresenter.didReceiveNextQuestion(question: question)
        // Then
        XCTAssertNotNil(viewControllerSpy.image)
        XCTAssertEqual(viewControllerSpy.question, "Question Text")
        XCTAssertEqual(viewControllerSpy.questionNumber, "1/10")
        XCTAssertTrue(viewControllerSpy.enableButtonsCalled)
        XCTAssertTrue(viewControllerSpy.hideLoadingIndicatorCalled)
    }
    
    func testDidFailToLoadDataFromServer() {
        // Given
        let viewControllerSpy = MovieQuizViewControllerProtocolSpy()
        let movieQuizPresenter = MovieQuizPresenter(
            view: viewControllerSpy,
            questionsFactory: nil,
            statisticService: nil
        )
        
        // When
        movieQuizPresenter.didFailToLoadDataFromServer(with: Errors.offline)
        
        // Then
        XCTAssertTrue(viewControllerSpy.showLoadingIndicatorCalled)
        XCTAssertEqual(viewControllerSpy.networkErrorMessage, "Нет подключения к интернету")
    }
    
    func testDidLoadDataFromServer() {
        // Given
        let questionFactorySpy = QuestionFactorySpy()
        let movieQuizPresenter = MovieQuizPresenter(
            view: MovieQuizViewControllerProtocolSpy(),
            questionsFactory: questionFactorySpy,
            statisticService: nil
        )
        
        // When
        movieQuizPresenter.didLoadDataFromServer()
        
        // Then
        XCTAssertTrue(questionFactorySpy.requestNextQuestionCalled)
    }
}
