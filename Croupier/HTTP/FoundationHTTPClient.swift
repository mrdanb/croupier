import Foundation

public class FoundationHTTPClient: HTTPClient {

    enum Error: Swift.Error {
        case invalidURL
        case invalidParameters
        case unexpectedResponse
    }

    private let session: URLSession

    public init(session: URLSession) {
        self.session = session
    }

    public func get(url: URL,
                    parameters: [String: String]? = nil,
                    completion: @escaping (Result<Data, Swift.Error>) -> Void) {

        guard var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
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

