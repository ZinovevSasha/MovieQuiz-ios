import UIKit

final class MovieQuizPresenter {
    private var currentQuestionIndex = 0
    private var currentQuestion: QuizQuestion?
    private var correctAnswers = 0
    private let questionsAmount = 10
    // MARK: - Dependencies
    private var statisticService: StatisticService?
    private var questionsFactory: QuestionFactoryProtocol?
    private weak var viewController: MovieQuizViewController?
    init(viewController: MovieQuizViewController) {
        self.viewController = viewController
        statisticService = StatisticServiceImplementation()
        questionsFactory = QuestionFactory(delegate: self)
        questionsFactory?.loadData()
    }

    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }

    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionsFactory?.loadData()
    }

    func noButtonPressed() {
        didAnswer(isYes: false)
    }

    func yesButtonPressed() {
        didAnswer(isYes: true)
    }
}

extension MovieQuizPresenter {
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
        didAnswer(isCorrect: isCorrect)
        viewController?.highlightImageBorder(isCorrectAnswer: isCorrect)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.proceedToNextQuestionOrResults()
        }
    }

    private func didAnswer(isCorrect: Bool) {
        if isCorrect {
            correctAnswers.increment()
        }
    }

    private func proceedToNextQuestionOrResults() {
        if self.isLastQuestion() {
            proceedToResultOfTheGame()
        } else {
            self.switchToNextQuestion()
            questionsFactory?.requestNextQuestion()
        }
    }

    private func proceedToResultOfTheGame() {
        guard let statisticService = statisticService else {
            return
        }
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

        viewController?.show(quiz: resultOfTheGame)
    }
}

extension MovieQuizPresenter: QuestionFactoryDelegate {
    func didLoadDataFromServer() {
        questionsFactory?.requestNextQuestion()
    }

    func didFailToLoadDataFromServer(with error: Errors) {
        viewController?.showLoadingIndicator()
        viewController?.showNetworkError(message: error.errorDescription ?? "Неизвестная ошибка")
    }

    func didReceiveNextQuestion(question: QuizQuestion) {
        let viewModel = convert(model: question)
        currentQuestion = question
        viewController?.hideLoadingIndicator()

        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
}
