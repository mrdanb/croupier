import Foundation
import CoreData

public extension RepositoryError {
    enum CoreData: Error {
        case objectNotFoundInContext
    }
}

public protocol ContextProvider {
    var mainContext: NSManagedObjectContext { get }
    func newBackgroundContext() -> NSManagedObjectContext
}

public class CoreDataRepository<Response,Entity>: Repository where Response: Serializable & Decodable, Response.Serialized == Entity, Response.Context == NSManagedObjectContext, Entity: NSManagedObject {
    private let contextProvider: ContextProvider
    private let source: Source
    private let responseDecoder: Decoding
    private lazy var changes = Changes<Entity>()

    public init(source: Source,
                contextProvider: ContextProvider,
                responseDecoder: Decoding = JSONDecodableDecoder()) {
        self.source = source
        self.contextProvider = contextProvider
        self.responseDecoder = responseDecoder

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(objectsDidChange),
                                               name: .NSManagedObjectContextObjectsDidChange,
                                               object: contextProvider.mainContext)
    }

    @objc func objectsDidChange(notification: NSNotification) {
        guard let userInfo = notification.userInfo else { return }
        if let inserts = userInfo[NSInsertedObjectsKey] as? Set<Entity>, inserts.count > 0 {
            inserts.forEach { changes.inserted($0) }
        }

        if let updates = userInfo[NSUpdatedObjectsKey] as? Set<Entity>, updates.count > 0 {
            updates.forEach { changes.updated($0) }
        }

        if let deletes = userInfo[NSDeletedObjectsKey] as? Set<Entity>, deletes.count > 0 {
            deletes.forEach { changes.deleted($0) }
        }
    }

    private func createRequest() -> NSFetchRequest<Entity> {
        return NSFetchRequest(entityName: Entity.entity().name ?? String(describing: Entity.self))
    }

    public func get(predicate: NSPredicate, completion: @escaping (Result<[Entity], Error>) -> Void) {
        let request = createRequest()
        request.predicate = predicate
        contextProvider.mainContext.perform {
            do {
                let result = try self.contextProvider.mainContext.fetch(request)
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
        }
    }

    public func getAll(completion: @escaping (Result<[Entity], Error>) -> Void) {
        let request = createRequest()
        contextProvider.mainContext.perform {
            do {
                let result = try self.contextProvider.mainContext.fetch(request)
                guard result.count > 0 else {
                    completion(.failure(RepositoryError.CoreData.objectNotFoundInContext))
                    return
                }
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
        }
    }

    public func getAndWait(predicate: NSPredicate) throws -> [Entity] {
        let request = createRequest()
        request.predicate = predicate
        return try contextProvider.mainContext.sync { context -> [Entity] in
            return try context.fetch(request)
        }
    }

    public func getAllAndWait() throws -> [Entity] {
        let request = createRequest()
        return try contextProvider.mainContext.sync { context -> [Entity] in
            let result = try self.contextProvider.mainContext.fetch(request)
            guard result.count > 0 else { throw RepositoryError.CoreData.objectNotFoundInContext }
            return result
        }
    }

    private func serialize(data: Data, forKey key: String) throws -> [Entity] {
        let response = try self.responseDecoder.decode(Response.self, from: data)
        let backgroundContext = contextProvider.newBackgroundContext()
        backgroundContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        let entities = try backgroundContext.sync({ (context) -> [Entity] in
            var items = [Entity]()
            response.serialize(context: context, store: { entity in
                items.append(entity)
            })
            try context.saveIfNeeded()
            return items
        })
        return entities
    }

    public func sync(from path: String,
                     completion: @escaping (Result<Changes<Entity>,Error>) -> Void) {
        changes.empty()
        source.data(for: path, parameters: nil) { (result) in
            DispatchQueue(label: "uk.co.dollop.decode.queue").async {
                let result = result.flatMap({ (data) -> Result<[Entity], Error> in
                    do {
                        let entities = try self.serialize(data: data, forKey: path)
                        return .success(entities)
                    } catch {
                        return .failure(error)
                    }
                })
                DispatchQueue.main.async {
                    completion(
                        result.flatMap({ (_) -> Result<Changes<Entity>, Error> in
                            do {
                                try self.contextProvider.mainContext.saveIfNeeded()
                                return .success(self.changes)
                            } catch {
                                return .failure(error)
                            }
                        })
                    )
                }
            }
        }
    }

    public func delete(item: Entity, completion: @escaping (Result<Entity, Error>) -> Void) {
        contextProvider.mainContext.perform {
            self.contextProvider.mainContext.delete(item)
            do {
                try self.contextProvider.mainContext.saveIfNeeded()
                completion(.success(item))
            } catch {
                completion(.failure(error))
            }
        }
    }

    public func deleteAll(completion: @escaping (Result<Int, Error>) -> Void) {

        // Rather than perform a `NSBatchDeleteRequest` we delete entities individually
        // Apparently `NSBatchDeleteRequest` doesn't handle relationship rules.
        // Am yet to check this theory however.
        let request = NSFetchRequest<NSManagedObjectID>(entityName: Entity.entity().name ?? String(describing: Entity.self))
        request.resultType = .managedObjectIDResultType

        let mainContext = contextProvider.mainContext

        mainContext.perform {
            do {
                let result = try mainContext.fetch(request)
                let count = result.count
                result.forEach { id in
                    mainContext.delete(mainContext.object(with: id))
                }
                try mainContext.saveIfNeeded()
                completion(.success(count))
            } catch {
                completion(.failure(error))
            }
        }
    }
}

extension NSManagedObjectContext {
    func saveIfNeeded() throws {
        guard hasChanges else { return }
        try save()
    }

    // This isn't nice but we because performAndWait doesn't rethrow then we need to dot it...
    func sync<T>(_ task: (NSManagedObjectContext) throws -> T) throws -> T {
        var result: Result<T,Error>? = nil
        performAndWait {
            result = Result { try task(self) }
        }
        switch result! {
        case .success(let value): return value
        case .failure(let error): throw error
        }
    }
}

extension CoreDataRepository: CustomDebugStringConvertible {
    public var debugDescription: String {
        let address = Unmanaged<AnyObject>.passUnretained(self as AnyObject).toOpaque()
        return "<CoreDataRepository: \(address)> (source: \(source), decoder: \(responseDecoder))"
    }
}
