import Foundation

/*public class RepositoryWithCache<Store>: Repository where Store: Fetching & Deleting {
    public typealias ModelType = Store.ModelType
    private let decoder: Decoding
    private let source: Source
    private let cache: Store
    private lazy var decodeQueue = DispatchQueue(label: "uk.co.dollop.concierge.decodequeue")

    public init(for type: ModelType.Type, decoder: Decoding, source: Source, cache: Store) {
        self.decoder = decoder
        self.source = source
        self.cache = cache
    }

    public func get(forKey key: String,
                    completion: @escaping (Result<ModelType, Error>) -> Void) {

        fetchAndDecode(ModelType.self, forKey: key) { (result) in
            switch result {
            case .success(let item):
                self.cache.store(item: item, completion: completion)
            case .failure:
                self.cache.get(forKey: key, completion: completion)
            }
        }
    }

    public func getAll(completion: @escaping (Result<[ModelType], Error>) -> Void) {

        fetchAndDecode([ModelType].self, forKey: "") { (result) in
            switch result {
            case .success(let items):
                self.cache.store(items: items, completion: completion)
            case.failure:
                self.cache.getAll(completion: completion)
            }
        }
    }

    public func delete(item: ModelType,
                       completion: @escaping (Result<ModelType, Error>) -> Void) {
        // perform DELETE to API
    }

    public func sync(completion: @escaping (Result<Bool, Error>) -> Void) {

    }

    public func store(item: ModelType,
                      completion: @escaping (Result<ModelType, Error>) -> Void) {
        // perform PUT to API
    }
}

private extension RepositoryWithCache {

    func fetchAndDecode<T>(_ type: T.Type, forKey key: String, completion: @escaping (Result<T, Error>) -> Void) where T: Decodable {
        source.data(for: key, parameters: nil) { (result) in

            self.decodeQueue.async {
                let result = result.flatMap({ (data) -> Result<T, Error> in
                    do {
                        let item = try self.decoder.decode(T.self, from: data)
                        return .success(item)
                    } catch {
                        return .failure(error)
                    }
                })
                DispatchQueue.main.async {
                    completion(result)
                }
            }
        }
    }
}
*/
