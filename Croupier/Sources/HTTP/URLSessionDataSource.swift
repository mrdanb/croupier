import Foundation

public final class URLSessionDataSource: Source {
    enum Error: Swift.Error {
        case invalidURL
        case invalidParameters
        case unexpectedResponse
    }

    private let session: URLSession
    private let baseURL: URL

    public init(baseURL: URL, session: URLSession = URLSession.shared) {
        self.baseURL = baseURL
        self.session = session
    }

    public func data(for key: String,
                    parameters: [String: String]? = nil,
                    completion: @escaping (Result<Data, Swift.Error>) -> Void) {

        let fullURL = baseURL.appendingPathComponent(key)
        guard var urlComponents = URLComponents(url: fullURL, resolvingAgainstBaseURL: false) else {
            completion(.failure(Error.invalidURL))
            return
        }
        urlComponents.queryItems = parameters?.map{ URLQueryItem(name: $0, value: $1) }

        guard let url = urlComponents.url else {
            completion(.failure(Error.invalidParameters))
            return
        }

        let task = session.dataTask(with: url) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data, data.count > 0 else {
                completion(.failure(Error.unexpectedResponse))
                return
            }
            completion(.success(data))
        }
        task.resume()
    }
}
