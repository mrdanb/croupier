import Foundation

public final class InMemoryRepository<Response, Entity>: Repository where Entity: Equatable, Response: Serializable & Decodable, Response.Serialized == Entity {

    private let source: Source
    private let responseDecoder: Decoding
    private lazy var store = [Entity]()

    public init(source: Source,
                responseDecoder: Decoding = JSONDecodableDecoder()) {
        self.source = source
        self.responseDecoder = responseDecoder
    }

    public func sync(from path: String, completion: @escaping (Result<Changes<Entity>,Error>) -> Void) {
        source.data(for: path, parameters: nil) { (data) in
            DispatchQueue(label: "uk.co.dollop.decode.queue").async {
                let result = data.flatMap({ (data) -> Result<Changes<Entity>,Error> in
                    do {
                        let response = try self.responseDecoder.decode(Response.self, from: data)
                        var items = [Entity]()
                        response.serialize(context: nil, store: { entity in
                            self.store.append(entity)
                            items.append(entity)
                        })
                        let changes = self.createDiff(previous: self.store, new: items)
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
        let diff = new.difference(from: previous)
        return Changes<Entity>(diff)
    }

    public func get(predicate: NSPredicate, completion: @escaping (Result<[Entity], Error>) -> Void) {
        let result = self.store.filter{ predicate.evaluate(with: $0) }
        completion(.success(result))
    }

    public func getAll(completion: @escaping (Result<[Entity], Error>) -> Void) {
        completion(.success(store))
    }

    public func delete(item: Entity, completion: @escaping (Result<Entity, Error>) -> Void) {
        store.forEach { (entity) in
            // Equatable?
        }
    }

    public func deleteAll(completion: @escaping (Result<Int, Error>) -> Void) {
        let count = store.count
        store = []
        completion(.success(count))
    }
}
