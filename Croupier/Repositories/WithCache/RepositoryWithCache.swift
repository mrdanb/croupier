import Foundation

public class RepositoryWithCache<Store>: Repository where Store: Fetching & Storing, Store.ModelType: Codable {
    public typealias ModelType = Store.ModelType
    private let baseUrl: URL
    private let decoder: Decoding
    private let source: Source
    private let cache: Store
    private lazy var baseKey: String = {
        guard let components = URLComponents(url: baseUrl, resolvingAgainstBaseURL: false) else {
            fatalError("Unable to create URL components from base URL")
        }
        return components.path
    }()
    private lazy var decodeQueue = DispatchQueue(label: "uk.co.dollop.concierge.decodequeue")

    public init(for type: ModelType.Type, baseUrl: URL, decoder: Decoding, source: Source, cache: Store) {
        self.baseUrl = baseUrl
        self.decoder = decoder
        self.source = source
        self.cache = cache
    }

    public func get(forKey key: String,
                    completion: @escaping (Result<ModelType, Error>) -> Void) {
        let fullUrl = baseUrl.appendingPathComponent(key)

        fetchAndDecode(ModelType.self, at: fullUrl) { (result) in
            switch result {
            case .success(let item):
                self.cache.store(item: item, completion: completion)
            case .failure:
                self.cache.get(forKey: key, completion: completion)
            }
        }
    }

    public func getAll(completion: @escaping (Result<[ModelType], Error>) -> Void) {

        fetchAndDecode([ModelType].self, at: baseUrl) { (result) in
            switch result {
            case .success(let items):
                print(items)
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

    public func store(item: ModelType,
                      completion: @escaping (Result<ModelType, Error>) -> Void) {
        // perform PUT to API
    }
}

private extension RepositoryWithCache {

    func fetchAndDecode<T>(_ type: T.Type, at url: URL, completion: @escaping (Result<T, Error>) -> Void) where T: Decodable {
        source.data(for: url, parameters: nil) { (result) in

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
