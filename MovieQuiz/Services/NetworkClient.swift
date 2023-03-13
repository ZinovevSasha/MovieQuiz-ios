import Foundation

protocol NetworkRouting {
    func fetch(url: URL, completion: @escaping (Result<Data, Errors>) -> Void)
}

struct NetworkClient: NetworkRouting {
    func fetch(url: URL, completion: @escaping (Result<Data, Errors>) -> Void) {
        let request = URLRequest(url: url)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if error != nil {
                completion(.failure(Errors.offline))
            }
            if let response = response as? HTTPURLResponse,
                (response.statusCode < 200) || (response.statusCode >= 300) {
                completion(.failure(Errors.invalidResponse))
                return
            }
            guard let data = data else { return }
            completion(.success(data))
        }
        task.resume()
    }
}
