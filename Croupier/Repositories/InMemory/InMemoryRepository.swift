import Foundation

public final class InMemoryRepository<Response, Entity>: Repository where Entity: Equatable, Response: Serializable & Decodable, Response.Serialized == Entity {

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
                        var items = [Entity]()
                        response.serialize(forKey: key, context: nil, store: { (identifier, entity) in
                            self.map[identifier] = entity
                            items.append(entity)
                        })
                        let changes = self.createDiff(previous: Array(self.map.values), new: items)
                        return .success(changes)
                    } catch {
                        return .failure(error)
                    }
                })
                DispatchQueue.main.async { completion(result) }
            }
        }
    }

    private func createDiff(previous: [Entity], new: [Entity]) -> Changes<Entity> {
        if #available(iOS 13, *) {
            let diff = new.difference(from: previous)
            return Changes<Entity>(diff)
        } else {
            let removed = previous.filter{ !new.contains($0) }
            let inserted = new.filter{ !previous.contains($0) }
            return Changes<Entity>(deleted: removed, inserted: inserted)
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
