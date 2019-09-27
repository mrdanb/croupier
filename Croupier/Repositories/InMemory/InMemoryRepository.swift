import Foundation

public final class InMemoryRepository<Response, Entity>: Repository where Response: Serializable & Decodable & Equatable, Response.Serialized == Entity, Response.Context == AnyRepository<Response,Entity> {

    private let source: Source
    private let responseDecoder: Decoding
    private lazy var map = [String: Entity]()

    public init(source: Source,
                responseDecoder: Decoding = JSONDecodableDecoder()) {
        self.source = source
        self.responseDecoder = responseDecoder
    }

    public func sync(key: String, completion: @escaping (Result<Changes<Entity>,Error>) -> Void) {
        source.data(for: key, parameters: nil) { (data) in
            DispatchQueue(label: "uk.co.dollop.decode.queue").async {
                let result = data.flatMap({ (data) -> Result<Changes<Entity>,Error> in
                    do {
                        let response = try self.responseDecoder.decode(Response.self, from: data)
                        _ = response.serialize(context: AnyRepository(self))
                        // Could potentially use the collection diffing API in Swift 5.1?
                        // Array(map.values).difference(from: result)
                        // What key do we use to store each entity as?
                        return .success(Changes<Entity>())
                    } catch {
                        return .failure(error)
                    }
                })
                DispatchQueue.main.async { completion(result) }
            }
        }
    }

    public func get(forKey key: String, completion: @escaping (Result<Entity, Error>) -> Void) {
        guard let item = map[key] else {
            completion(.failure(RepositoryError.notFound))
            return
        }
        completion(.success(item))
    }

    public func getAll(completion: @escaping (Result<[Entity], Error>) -> Void) {
        let all = Array(map.values)
        completion(.success(all))
    }

    public func delete(item: Entity, completion: @escaping (Result<Entity, Error>) -> Void) {
        map.values.forEach { (entity) in
            // Equatable?
        }
    }
}
