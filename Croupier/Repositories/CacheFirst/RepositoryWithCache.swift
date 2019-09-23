import Foundation

public class RepositoryWithCache<CacheType>: Repository where CacheType: Cache, CacheType.ModelType: Codable {
    public typealias ModelType = CacheType.ModelType
    private let baseUrl: URL
    private let decoder: Decoding
    private let source: Source
    private let cache: CacheType
    private lazy var baseKey: String = {
        guard let components = URLComponents(url: baseUrl, resolvingAgainstBaseURL: false) else {
            fatalError("Unable to create URL components from base URL")
        }
        return components.path
    }()

    init(for type: ModelType.Type, baseUrl: URL, decoder: Decoding, source: Source, cache: CacheType) {
        self.baseUrl = baseUrl
        self.decoder = decoder
        self.source = source
        self.cache = cache
    }

    public func get(forKey key: String,
                    completion: @escaping (Result<ModelType, Error>) -> Void) {
        let fullUrl = baseUrl.appendingPathComponent(key)
        if let fresh = cache.fresh(forKey: key) {
            completion(.success(fresh))
            return
        }
        if let stale = cache.stale(forKey: key) {
            completion(.success(stale))
            fetchAndDecode(ModelType.self, at: fullUrl) { (result) in
                if case .success(let item) = result {
                    try? self.cache.store(entry: item, forKey:key)
                }
            }
        }
        fetchAndDecode(ModelType.self, at: fullUrl) { (result) in
            completion(
                result.flatMapError({ (_) -> Result<ModelType, Error> in
                    do {
                        let item = try self.cache.any(forKey: key)
                        return .success(item)
                    } catch {
                        return .failure(error)
                    }
                })
            )
        }
    }

    public func getAll(completion: @escaping (Result<[ModelType], Error>) -> Void) {
//        if let fresh = cache.fresh(key: baseKey) {
//            completion(.success(fresh))
//            return
//        }
//
//        if let stale = cache.stale(key: baseKey) {
//            // Pull and update cache...
//            completion(.success(stale))
//            return
//        }

        fetchAndDecode([ModelType].self, at: baseUrl, completion: completion)
    }

    public func delete(forKey key: String,
                       completion: ((Result<ModelType?, Error>) -> Void)?) {

    }

    public func store(item: ModelType,
                      forKey key: String,
                      completion: ((Result<ModelType, Error>) -> Void)?) {

    }
}

private extension RepositoryWithCache {

    func fetchFromCacheAndUpdateIfNeeded(key: String, url: URL) -> [ModelType]? {
//        if let fresh = cache.fresh(key: key) {
//            return fresh
//        }
//        let stale: T? = cache.stale(key: key)
//        if stale != nil {
//            fetchAndDecode(T.self, at: url) { (result) in
//                if case .success(let item) = result {
//                    self.cache.put(key: key, entry: item)
//                }
//            }
//        }
//        return stale
        return nil
    }

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
