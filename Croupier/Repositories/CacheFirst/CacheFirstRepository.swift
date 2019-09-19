import Foundation

struct AnyCache<ModelType>: Cache {

    private let _put: (String, ModelType) -> Void
    private let _fresh: (String) -> ModelType?
    private let _stale: (String) -> ModelType?

    init<C: Cache>(_ cache: C) where C.ModelType == ModelType {
        _put = cache.put
        _fresh = cache.fresh
        _stale = cache.stale
    }

    func put(key: String, entry: ModelType) { _put(key, entry) }

    func fresh(key: String) -> ModelType? { return _fresh(key) }

    func stale(key: String) -> ModelType? { return _stale(key) }
}

public class CacheFirstRepository<ModelType>: Repository where ModelType: Codable {
    private let baseUrl: URL
    private let decoder: Decoding
    private let source: Source
    private let cache: AnyCache<ModelType>
    private lazy var baseKey: String = {
        guard let components = URLComponents(url: baseUrl, resolvingAgainstBaseURL: false) else {
            fatalError("Unable to create URL components from base URL")
        }
        return components.path
    }()

    init(baseUrl: URL, decoder: Decoding, source: Source, cache: AnyCache<ModelType>) {
        self.baseUrl = baseUrl
        self.decoder = decoder
        self.source = source
        self.cache = cache
    }

    public func get(forKey key: String,
                    options: [String : String]?,
                    completion: @escaping (Result<ModelType, Error>) -> Void) {

        if let fresh: ModelType = cache.fresh(key: key) {
            completion(.success(fresh))
            return
        }

        if let stale: ModelType = cache.stale(key: key) {
            // Pull and update cache...
            completion(.success(stale))
            return
        }

        let fullUrl = baseUrl.appendingPathComponent(key)
        fetchAndDecode(ModelType.self, at: fullUrl, completion: completion) //TODO
    }

    public func getAll(completion: @escaping (Result<[ModelType], Error>) -> Void) {

    }

    public func delete(forKey key: String,
                       completion: ((Result<ModelType?, Error>) -> Void)?) {

    }

    public func store(item: ModelType,
                      forKey key: String,
                      completion: ((Result<ModelType, Error>) -> Void)?) {

    }
}

private extension CacheFirstRepository {

   /* func fetchFromCacheOrSource<T>(_ type: T.Type,
                                   key: String,
                                   url: URL,
                                   completion: @escaping (Result<T,Error>) -> Void) where T: Decodable {
        if let cache = fetchFromCacheAndUpdateIfNeeded(T.self, key: key, url: url) {
            completion(.success(cache))
            return
        }

        fetchAndDecode(T.self, at: url) { (result) in
            switch result {
            case .success(let item):
//                self.cache.put(key: key, entry: item)
                completion(.success(item))
            case .failure(_):
                // Use cache on error?
                print("Failed to load...")
            }
        }
    }*/

//    func fetchFromCacheAndUpdateIfNeeded<T>(_ type: T.Type, key: String, url: URL) -> T? where T: Decodable {
//        if let fresh: T? = cache.fresh(key: key) {
//            return fresh
//        }
//
//        let stale: T? = cache.stale(key: key)
//        if stale != nil {
//            fetchAndDecode(T.self, at: url) { (result) in
//                if case .success(let item) = result {
//                    self.cache.put(key: key, entry: item)
//                }
//            }
//        }
//        return stale
//    }

    func fetchAndDecode<T>(_ type: T.Type, at url: URL, completion: @escaping (Result<T, Error>) -> Void) where T: Decodable {
        source.data(for: url, parameters: nil) { (result) in
            completion(
                result.flatMap({ (data) -> Result<T, Error> in
                    do {
                        let item = try self.decoder.decode(T.self, from: data)
                        return .success(item)
                    } catch {
                        return .failure(error)
                    }
                })
            )
        }
    }
}
