import Foundation

public class InMemoryRepository<ModelType: Codable>: Repository  {

    private var map: [String: ModelType]

    public init() {
        map = [:]
    }

    public func get(key: String,
                    options: [String : String]?,
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
                       key: String,
                       completion: ((Result<ModelType, Error>) -> Void)?) {

        map.removeValue(forKey: key)
        completion?(.success(item))
    }

    public func store(item: ModelType,
                      forKey key: String,
                      completion: ((Result<ModelType, Error>) -> Void)?) {

        map[key] = item
        completion?(.success(item))
    }
}

