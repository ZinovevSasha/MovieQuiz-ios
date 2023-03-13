import UIKit

protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(quiz step: QuizStepViewModel)
    func show(quiz result: QuizResultsViewModel)
    func highlightImageBorder(isCorrectAnswer: Bool)
    func showNetworkError(message: String)
    func hideLoadingIndicator()
    func showLoadingIndicator()
    func enableButtons()
    func disableButtons()
}

final class MovieQuizPresenter {
    private var correctAnswers = 0
    private let questionsAmount = 10
    private var currentQuestionIndex = 0
    private var currentQuestion: QuizQuestion?

    // MARK: - Dependency injections
    private weak var view: MovieQuizViewControllerProtocol?
    private var questionsFactory: QuestionFactoryProtocol?
    private var statisticService: StatisticService?
    
    init(
        view: MovieQuizViewControllerProtocol?,
        questionsFactory: QuestionFactoryProtocol?,
        statisticService: StatisticService?
    ) {
        self.view = view
        self.questionsFactory = questionsFactory
        self.statisticService = statisticService
        
        view?.showLoadingIndicator()
        questionsFactory?.setDelegate(delegate: self)
        questionsFactory?.loadData()
    }

    private func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }

    private func switchToNextQuestion() {
        currentQuestionIndex += 1
    }

    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        QuizStepViewModel(
            question: model.text,
            image: UIImage(data: model.image) ?? UIImage(),
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }

    private func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = isYes
        proceedWithAnswer(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }

    private func proceedWithAnswer(isCorrect: Bool) {
        if isCorrect {
            correctAnswers.increment()
        }
        view?.highlightImageBorder(isCorrectAnswer: isCorrect)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.proceedToNextQuestionOrResults()
        }
    }

    private func proceedToNextQuestionOrResults() {
        if isLastQuestion() {
            proceedToResultOfTheGame()
        } else {
            switchToNextQuestion()
            questionsFactory?.requestNextQuestion()
        }
    }

    private func proceedToResultOfTheGame() {
        if let statisticService = statisticService {
            statisticService.store(correct: correctAnswers, total: questionsAmount)
            let dateAndTime = statisticService.bestGame.date.dateTimeString

            let resultOfTheGame = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                message:
                    """
                    Ваш результат: \(correctAnswers)/\(questionsAmount)
                    Количество сыгранных квизов: \(statisticService.gamesCount)
                    Рекорд: \(statisticService.bestGame.correct)/\(questionsAmount) (\(dateAndTime))
                    Средняя точность: \(statisticService.totalAccuracy.myOwnRounded)%
                    """,
                buttonText: "Сыграть еще раз")

            view?.show(quiz: resultOfTheGame)
        }
    }
}
extension MovieQuizPresenter: MovieQuizPresenterProtocol {
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionsFactory?.loadData()
    }

    func noButtonPressed() {
        didAnswer(isYes: false)
        view?.disableButtons()
        view?.showLoadingIndicator()
    }

    func yesButtonPressed() {
        didAnswer(isYes: true)
        view?.disableButtons()
        view?.showLoadingIndicator()
    }
}

extension MovieQuizPresenter: QuestionFactoryDelegate {
    func didLoadDataFromServer() {
        questionsFactory?.requestNextQuestion()
    }

    func didFailToLoadDataFromServer(with error: Errors) {
        view?.showLoadingIndicator()
        view?.showNetworkError(message: error.errorDescription ?? "Неизвестная ошибка")
    }

    func didReceiveNextQuestion(question: QuizQuestion) {
        let viewModel = convert(model: question)
        currentQuestion = question
        
        view?.hideLoadingIndicator()
        view?.enableButtons()
        view?.show(quiz: viewModel)
    }
}
