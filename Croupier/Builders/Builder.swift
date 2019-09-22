import Foundation
import CoreData

class Builder<ModelType> where ModelType: Codable {

    init(for type: ModelType.Type) { }

    private var decoder: Decoding?
    private var source: Source?
    private var store: Source?

    @discardableResult
    public func withCoreDataDecoder(context: NSManagedObjectContext) -> Builder {
        decoder = CoreDataDecoder(context: context)
        return self
    }

    @discardableResult
    public func foundationHTTPClient(urlSession: URLSession) -> Builder {
        source = FoundationHTTPClient(session: urlSession)
        return self
    }

    @discardableResult
    public func coreDataRepository(urlSession: URLSession) -> Builder {
        source = FoundationHTTPClient(session: urlSession)
        return self
    }

    func build<C>(url: URL,
                  source: Source,
                  decoder: Decoding,
                  cache: C) -> CacheFirstRepository<C> where C: Cache, C.ModelType == ModelType {
        return CacheFirstRepository(for: ModelType.self, baseUrl: url, decoder: decoder, source: source, cache: cache)
    }
}


class TestFoo: NSManagedObject, Codable {
    required init(from decoder: Decoder) throws {
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        guard let entity = NSEntityDescription.entity(forEntityName: "TestFoo", in: context) else {
            fatalError("Could not create entity")
        }
        super.init(entity: entity, insertInto: nil)
    }
}

func test() {
    let url = URL(string: "http://www.google.com")!
    let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
    let session = URLSession.shared

    let decoder = CoreDataDecoder(context: context)
    let source = FoundationHTTPClient(session: session)
    let store = CoreDataRepository(for: TestFoo.self, context: context, primaryKey: "identifier")
    let cache = CacheWithTTL(store: store, freshLifetime: 32, staleLifetime: 50) { NSDate().timeIntervalSince1970 }

    let repo = Builder(for: TestFoo.self).build(url: url,
                                                source: source,
                                                decoder: decoder,
                                                cache: cache)
}
