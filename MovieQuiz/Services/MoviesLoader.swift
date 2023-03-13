import Foundation

protocol MoviesLoadingProtocol {
    func loadMovies(handler: @escaping (Result<[OneMovie], Errors>) -> Void)
}

struct MoviesLoader: MoviesLoadingProtocol {
    typealias Handler = (Result<[OneMovie], Errors>) -> Void
    // MARK: - NetworkClient
    let networkClient: NetworkRouting
    init(networkClient: NetworkRouting = NetworkClient()) {
        self.networkClient = networkClient
    }
    // MARK: - URL
    private var mostPopularMoviesUrl: URL {
        guard let url = URL(string: "https://imdb-api.com/en/API/Top250Movies/k_6nnz4gev") else { preconditionFailure("Unable to construct mostPopularMoviesUrl")
        }
        return url
    }

    func loadMovies(handler: @escaping Handler) {
        networkClient.fetch(url: mostPopularMoviesUrl) { result in
            let fulfillCompletion: (Result<[OneMovie], Errors>) -> Void = { result in
                DispatchQueue.main.async {
                    handler(result)
                }
            }
            switch result {
            case .success(let data):
                let decoder = JSONDecoder()
                let converter = FromOptionalResultToNonOptional()
                do {
                    let model = try decoder.decode(MostPopularMoviesResult.self, from: data)
                    guard let errorMessage = model.errorMessage,
                        errorMessage.isEmpty
                    else {
                        fulfillCompletion(.failure(.exceedAPIRequestLimit))
                        return
                    }
                    let items = model.items.compactMap { converter.convert(result: $0) }
                    guard !items.isEmpty else {
                        fulfillCompletion(.failure(.itemsEmpty))
                        return
                    }
                    fulfillCompletion(.success(items))
                } catch {
                    fulfillCompletion(.failure(.parsingError))
                }
            case .failure(let failure):
                fulfillCompletion(.failure(failure))
            }
        }
    }
}
