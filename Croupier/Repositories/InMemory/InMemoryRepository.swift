import Foundation

public final class InMemoryRepository<ModelType>: Repository where ModelType: Item {

    private var map: [String: ModelType]

    public init() {
        map = [:]
    }

    public func get(forKey key: String,
                    completion: @escaping (Result<ModelType, Error>) -> Void) {
        if let item = map[key] {
            completion(.success(item))
        } else {
            completion(.failure(RepositoryError.notFound))
        }
    }

    public func getAll(completion: (Result<[ModelType], Error>) -> Void) {
        let all = Array(map.values)
        completion(.success(all))
    }

    public func delete(item: ModelType,
                       completion: @escaping (Result<ModelType, Error>) -> Void) {
        map.removeValue(forKey: item.primaryKey)
        completion(.success(item))
    }

    public func store(item: ModelType,
                      completion: @escaping (Result<ModelType, Error>) -> Void) {
        map[item.primaryKey] = item
        completion(.success(item))
    }
}

public protocol Item {
    var primaryKey: String { get }
}
