import Foundation
import CoreData

class TestFoo: NSManagedObject, Codable {
    required init(from decoder: Decoder) throws {
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        guard let entity = NSEntityDescription.entity(forEntityName: "TestFoo", in: context) else {
            fatalError("Could not create entity")
        }
        super.init(entity: entity, insertInto: nil)
    }
}

/*class Builder<ModelType> where ModelType: Codable {

    init(for type: ModelType.Type) { }

    private var source: Source?
    private var decoder: Decoding?

    @discardableResult
    public func withCoreDataDecoder(context: NSManagedObjectContext) -> Builder {
        decoder = CoreDataDecoder(context: context)
        return self
    }

    @discardableResult
    public func withFoundationHTTPClient(urlSession: URLSession) -> Builder {
        source = FoundationHTTPClient(session: urlSession)
        return self
    }

    @discardableResult
    public func coreDataRepository(urlSession: URLSession) -> Builder {

        return self
    }

    func build<C>(url: URL,
                  source: Source,
                  decoder: Decoding,
                  cache: C) -> CacheFirstRepository<C> where C: Cache, C.ModelType == ModelType {
        return CacheFirstRepository(for: ModelType.self, baseUrl: url, decoder: decoder, source: source, cache: cache)
    }
}
*/
