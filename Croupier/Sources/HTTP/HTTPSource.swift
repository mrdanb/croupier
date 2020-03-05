import Foundation

public extension RepositoryError {
    enum HTTP: Error {
        case invalidURL
        case invalidParameters
        case unexpectedResponse
    }
}

public final class HTTPSource: Source {

    private let session: URLSession
    private let baseUrl: URL

    public init(baseURL: URL, session: URLSession = URLSession.shared) {
        self.baseUrl = baseURL
        self.session = session
    }

    public func data(for key: String,
                    parameters: [String: String]? = nil,
                    completion: @escaping (Result<Data, Swift.Error>) -> Void) {

        let fullUrl = baseUrl.appendingPathComponent(key)
        guard var urlComponents = URLComponents(url: fullUrl, resolvingAgainstBaseURL: false) else {
            completion(.failure(RepositoryError.HTTP.invalidURL))
            return
        }
        urlComponents.queryItems = parameters?.map{ URLQueryItem(name: $0, value: $1) }

        guard let url = urlComponents.url else {
            completion(.failure(RepositoryError.HTTP.invalidParameters))
            return
        }

        let task = session.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data, data.count > 0 else {
                completion(.failure(RepositoryError.HTTP.unexpectedResponse))
                return
            }
            completion(.success(data))
        }
        task.resume()
    }
}
