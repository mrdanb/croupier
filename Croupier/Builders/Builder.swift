import Foundation
import CoreData

public struct Builder<T> where T: Codable {

    public static func buildCoreDataRepo(url: URL,
                                         urlSession: URLSession,
                                         context: NSManagedObjectContext) -> CacheFirstRepository<T> {
        let decoder = CoreDataDecoder(context: context)
        let source = FoundationHTTPClient(session: urlSession)
        let coreDataStore = CoreDataRepository(context: context, primaryKey: "identifier")
        let cache = CacheWithTTL(store: coreDataStore, freshLifetime: 1.0, staleLifetime: 5.0) { Date().timeIntervalSince1970 }
        return CacheFirstRepository<T>(baseUrl: url, decoder: decoder, source: source, cache: cache)
    }
}
