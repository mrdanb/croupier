import Foundation

public final class InMemoryRepository<ModelType>: Repository  {

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

    public func delete(forKey key: String,
                       completion: ((Result<ModelType?, Error>) -> Void)?) {
        let result = map.removeValue(forKey: key)
        completion?(.success(result))
    }

    public func store(item: ModelType,
                      forKey key: String,
                      completion: ((Result<ModelType, Error>) -> Void)?) {
        map[key] = item
        completion?(.success(item))
    }
}

