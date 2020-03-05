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
        source.data(for: path, parameters: nil) { data in
            DispatchQueue(label: "uk.co.dollop.decode.queue").async { [weak self] in
                guard let `self` = self else { return }
                let result = data.flatMap { data -> Result<Changes<Entity>,Error> in
                    do {
                        let response = try self.responseDecoder.decode(Response.self, from: data)
                        let snapshot = self.store
                        response.serialize(context: nil) { entity in
                            self.store.append(entity)
                        }
                        let changes = self.changes(from: snapshot, to: self.store)
                        return .success(changes)
                    } catch {
                        return .failure(error)
                    }
                }
                DispatchQueue.main.async { completion(result) }
            }
        }
    }

    private func changes(from: [Entity], to: [Entity]) -> Changes<Entity> {
        let diff = to.difference(from: from)
        return Changes<Entity>(diff)
    }

    public func get(predicate: NSPredicate, completion: @escaping (Result<[Entity], Error>) -> Void) {
        let result = self.store.filter{ predicate.evaluate(with: $0) }
        completion(.success(result))
    }

    public func getAll(completion: @escaping (Result<[Entity], Error>) -> Void) {
        completion(.success(store))
    }

    public func getAndWait(predicate: NSPredicate) throws -> [Entity] {
        return store.filter{ predicate.evaluate(with: $0) }
    }

    public func getAllAndWait() throws -> [Entity] {
        return store
    }

    public func delete(item: Entity, completion: @escaping (Result<Entity, Error>) -> Void) {
        store.removeAll(where: { $0 == item })
        completion(.success(item))
    }

    public func deleteAll(completion: @escaping (Result<Int, Error>) -> Void) {
        let count = store.count
        store.removeAll()
        completion(.success(count))
    }

    public func deleteAndWait(item: Entity) throws -> Entity {
        store.removeAll(where: { $0 == item })
        return item
    }

    public func deleteAllAndWait() throws -> Int {
        let count = store.count
        store.removeAll()
        return count
    }

    public func add(item: Entity, completion: @escaping (Result<Entity, Error>) -> Void) {
        store.append(item)
        completion(.success(item))
    }

    public func addAndWait(item: Entity) throws -> Entity {
        store.append(item)
        return item
    }
}
