import UIKit

// What my Delegate(any who listen to me, who conform to my protocol) want from me.
protocol QuestionFactoryProtocol {
    func loadData()
    func requestNextQuestion()
    func setDelegate(delegate: QuestionFactoryDelegate)
}

protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion)
    func didLoadDataFromServer()
    func didFailToLoadDataFromServer(with error: Errors)
}


class QuestionFactory: QuestionFactoryProtocol {
    weak var delegate: QuestionFactoryDelegate?
    private let moviesLoader: MoviesLoadingProtocol
    private let networkClient: NetworkRouting
    
    init(
        moviesLoader: MoviesLoadingProtocol = MoviesLoader(),
        networkClient: NetworkRouting = NetworkClient()
    ) {
        self.moviesLoader = moviesLoader
        self.networkClient = networkClient
    }
    
    private var movies: [OneMovie] = []

    func setDelegate(delegate: QuestionFactoryDelegate) {
        self.delegate = delegate
    }
    
    func loadData() {
        moviesLoader.loadMovies { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let mostPopularMovies):
                self.movies = mostPopularMovies
                self.delegate?.didLoadDataFromServer()
            case .failure(let error):
                self.delegate?.didFailToLoadDataFromServer(with: error)
            }
        }
    }

    func requestNextQuestion() {
        let index = (0..<self.movies.count).randomElement() ?? 0
        guard let question = self.movies[safe: index] else { return }
        let randomNumber = Int.random(in: 6...9)
        let correctAnswer = (question.rating > Double(randomNumber))
        let text = "Рейтинг этого фильма больше чем \(randomNumber)?"

        networkClient.fetch(url: question.resizedImageURL) { result in
            switch result {
            case .success(let data):
                let quizQuestion = QuizQuestion(
                    image: data,
                    text: text,
                    correctAnswer: correctAnswer)
                
                DispatchQueue.main.async {
                    self.delegate?.didReceiveNextQuestion(question: quizQuestion)
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.delegate?.didFailToLoadDataFromServer(with: error)
                }
            }
        }
    }
}
