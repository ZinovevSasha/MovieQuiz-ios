import Foundation

struct NetworkClient: NetworkRouting {
    func fetch(url: URL, handler: @escaping (Result<Data, Errors>) -> Void) {
        let request = URLRequest(url: url)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if error != nil {
                handler(.failure(Errors.offline))
            }
            if let response = response as? HTTPURLResponse,
            (response.statusCode < 200) || (response.statusCode >= 300) {
                handler(.failure(Errors.invalidResponse))
            return
            }
            guard let data = data else { return }
            handler(.success(data))
        }
        task.resume()
    }
}
