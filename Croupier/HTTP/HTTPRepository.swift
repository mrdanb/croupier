import Foundation

public class HTTPRepository<ModelType: Codable>: Repository {

    private let baseUrl: URL
    private let httpClient: HTTPClient
    private lazy var jsonDecoder = JSONDecoder()

    public init(baseUrl: URL, httpClient: HTTPClient) {
        self.baseUrl = baseUrl
        self.httpClient = httpClient
    }

    public func get(key: String,
                    options: [String: String]? = nil,
                    completion: @escaping (Result<ModelType, Error>) -> Void) {

        let fullUrl = baseUrl.appendingPathComponent(key)
        httpClient.get(url: fullUrl, parameters: options) { (result) in

            completion(
                result.flatMap({ (data) -> Result<ModelType, Swift.Error> in
                    do {
                        let model = try self.jsonDecoder.decode(ModelType.self, from: data)
                        return .success(model)
                    } catch {
                        return .failure(error)
                    }
                })
            )
        }
    }

    public func getAll(completion: (Result<[ModelType], Error>) -> Void) {
        fatalError("Unimplemented")
    }

    public func delete(item: ModelType,
                       key: String,
                       completion: ((Result<ModelType, Error>) -> Void)?) {
        fatalError("Unimplemented")
    }

    public func store(item: ModelType,
                      forKey key: String,
                      completion: ((Result<ModelType, Error>) -> Void)?) {
        fatalError("Unimplemented")
    }
}

public extension HTTPRepository {
    convenience init(baseUrl: URL, urlSession: URLSession) {

        let client = FoundationHTTPClient(session: urlSession)
        self.init(baseUrl: baseUrl, httpClient: client)
    }
}
