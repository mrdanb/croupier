import Foundation

public class SourceAndStoreRepository<SourceType: Repository, StoreType: Repository>: Repository where SourceType.ModelType == StoreType.ModelType {

    public typealias ModelType = SourceType.ModelType

    private let source: SourceType
    private let store: StoreType

    public init(source: SourceType, store: StoreType) {
        self.source = source
        self.store = store
    }

    public func get(key: String,
                    options: [String : String]?,
                    completion: @escaping (Result<ModelType, Error>) -> Void) {

        source.get(key: key, options: options) { (result) in

            if case .success(let item) = result {
                self.store.store(item: item, forKey: key) { (result) in
                    completion(result)
                }
            } else {
                completion(result)
            }

        }
    }

    public func getAll(completion: (Result<[ModelType], Error>) -> Void) {

        source.getAll { (result) in

            if case .success(_) = result {
                // Loop and store each one?
                fatalError("Unimplemented")
            } else {
                completion(result)
            }
        }
    }

    public func delete(item: ModelType,
                       key: String,
                       completion: ((Result<ModelType, Error>) -> Void)?) {

        source.delete(item: item, key: key) { (result) in

            if case .success = result {

                self.delete(item: item, key: key, completion: { (result) in
                    completion?(result)
                })
            } else {
                completion?(result)
            }
        }
    }

    public func store(item: ModelType,
                      forKey key: String,
                      completion: ((Result<ModelType, Error>) -> Void)?) {
        source.store(item: item, forKey: key) { (result) in

            if case .success = result {

                self.store.store(item: item, forKey: key, completion: { (result) in
                    completion?(result)
                })
            } else {
                completion?(result)
            }
        }
    }
}
