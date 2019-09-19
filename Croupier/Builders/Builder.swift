import Foundation
import CoreData

public struct Builder {

    private let baseUrl: URL
    private let urlSession: URLSession
    private let context: NSManagedObjectContext
    private let primaryKey: String
    private let freshLifetime: TimeInterval = 10
    private let staleLifetime: TimeInterval = 20

    public init(baseUrl: URL, urlSession: URLSession, context: NSManagedObjectContext, primaryKey: String) {
        self.baseUrl = baseUrl
        self.urlSession = urlSession
        self.context = context
        self.primaryKey = primaryKey
    }

//    public static func coreDataRepo<T: NSManagedObject>(for type: T.Type,
//                                                        url: URL,
//                                                        urlSession: URLSession,
//                                                        context: NSManagedObjectContext) -> CacheFirstRepository<CacheWithTTL<CoreDataRepository<T>>> {
//        let decoder = CoreDataDecoder(context: context)
//        let source = FoundationHTTPClient(session: urlSession)
//        let coreDataStore = CoreDataRepository<T>(context: context, primaryKey: "identifier")
//        let cache = CacheWithTTL(store: coreDataStore, freshLifetime: 1.0, staleLifetime: 5.0) { Date().timeIntervalSince1970 }
//        return CacheFirstRepository<CacheWithTTL<CoreDataRepository<T>>>(baseUrl: url,
//                                                                         decoder: decoder,
//                                                                         source: source,
//                                                                         cache: cache)
//    }

    public func coreDataDecoder() -> CoreDataDecoder {
        return CoreDataDecoder(context: context)
    }

    public func foundationHttpSource() -> FoundationHTTPClient {
        return FoundationHTTPClient(session: urlSession)
    }

    public func coreDataRepository<T>(for type: T.Type) -> CoreDataRepository<T> {
        return CoreDataRepository<T>(context: context, primaryKey: primaryKey)
    }

    public func cacheWithTTL<R: Repository>(store: R) -> CacheWithTTL<R> {
        return CacheWithTTL(store: store, freshLifetime: freshLifetime, staleLifetime: staleLifetime) { Date().timeIntervalSince1970 }
    }

    public func repositoryWithCache<C: Cache>(decoder: Decoding, source: Source, cache: C) -> CacheFirstRepository<C> {
        return CacheFirstRepository(baseUrl: baseUrl, decoder: decoder, source: source, cache: cache)
    }
}
