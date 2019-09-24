import Foundation

public final class HTTPRepository<ModelType>: Repository where ModelType: Codable {

    private let httpClient: Source
    private let decoder: Decoding

    public init(httpClient: Source, decoder: Decoding) {
        self.httpClient = httpClient
        self.decoder = decoder
    }

    public func get(forKey key: String,
                    completion: @escaping (Result<ModelType, Error>) -> Void) {

        httpClient.data(for: key, parameters: nil) { (result) in

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

    public func delete(item: ModelType,
                       completion: @escaping (Result<ModelType, Error>) -> Void) {
        fatalError("Unimplemented")
    }

    public func store(item: ModelType,
                      completion: @escaping (Result<ModelType, Error>) -> Void) {
        fatalError("Unimplemented")
    }
}

public extension HTTPRepository {
    convenience init(baseUrl: URL, urlSession: URLSession, decoder: Decoding) {
        let client = FoundationHTTPClient(session: urlSession, baseURL: baseUrl)
        self.init(httpClient: client, decoder: decoder)
    }
}
