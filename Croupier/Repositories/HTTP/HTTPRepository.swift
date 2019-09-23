import Foundation

public final class HTTPRepository<ModelType>: Repository where ModelType: Codable {

    private let baseUrl: URL
    private let httpClient: Source
    private let decoder: Decoding

    public init(baseUrl: URL, httpClient: Source, decoder: Decoding) {
        self.baseUrl = baseUrl
        self.httpClient = httpClient
        self.decoder = decoder
    }

    public func get(forKey key: String,
                    completion: @escaping (Result<ModelType, Error>) -> Void) {

        let fullUrl = baseUrl.appendingPathComponent(key)
        httpClient.data(for: fullUrl, parameters: nil) { (result) in

            completion(
                result.flatMap({ (data) -> Result<ModelType, Swift.Error> in
                    do {
                        let model = try self.decoder.decode(ModelType.self, from: data)
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

    public func delete(forKey key: String,
                       completion: ((Result<ModelType?, Error>) -> Void)?) {
        fatalError("Unimplemented")
    }

    public func store(item: ModelType,
                      forKey key: String,
                      completion: ((Result<ModelType, Error>) -> Void)?) {
        fatalError("Unimplemented")
    }
}

public extension HTTPRepository {
    convenience init(baseUrl: URL, urlSession: URLSession, decoder: Decoding) {
        let client = FoundationHTTPClient(session: urlSession)
        self.init(baseUrl: baseUrl, httpClient: client, decoder: decoder)
    }
}
