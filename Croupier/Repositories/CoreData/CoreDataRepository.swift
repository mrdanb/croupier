import Foundation
import CoreData

public extension RepositoryError {
    enum CoreData: Error {
        case objectNotFoundInContext
    }
}

public class CoreDataRepository<Response,Entity>: Repository where Response: Serializable, Response: Decodable, Response.Serialized == Entity, Response.Context == NSManagedObjectContext, Entity: NSManagedObject {
    private let context: NSManagedObjectContext
    private let source: Source
    private let responseDecoder: Decoding
    private let identifier: String
    private lazy var changes = Changes<Entity>()

    public init(source: Source,
                responseDecoder: Decoding = JSONDecodableDecoder(),
                context: NSManagedObjectContext,
                identifier: String) {
        self.context = context
        self.source = source
        self.responseDecoder = responseDecoder
        self.identifier = identifier

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(objectsDidChange),
                                               name: .NSManagedObjectContextObjectsDidChange,
                                               object: context)
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

    public func get(forKey key: String, completion: @escaping (Result<Entity, Error>) -> Void) {
        let request = createRequest()
        request.predicate = NSPredicate(format: "%K = %@", identifier, key)
        context.perform {
            do {
                guard let result = try self.context.fetch(request).first else {
                    completion(.failure(RepositoryError.CoreData.objectNotFoundInContext))
                    return
                }
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
        }
    }

    public func getAll(completion: @escaping (Result<[Entity], Error>) -> Void) {
        let request = createRequest()
        context.perform {
            do {
                let result = try self.context.fetch(request)
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

    private func serialize(data: Data) throws -> [Entity] {
        let response = try self.responseDecoder.decode(Response.self, from: data)
        let entities = try self.context.createBackgroundContext().sync({ (context) -> [Entity] in
            let result = response.serialize(context: context)
            try context.saveIfNeeded()
            return result
        })
        return entities
    }

    public func sync(key: String,
                     completion: @escaping (Result<Changes<Entity>,Error>) -> Void) {
        changes.empty()
        source.data(for: key, parameters: nil) { (result) in
            DispatchQueue(label: "uk.co.dollop.decode.queue").async {
                let result = result.flatMap({ (data) -> Result<[Entity], Error> in
                    do {
                        let entities = try self.serialize(data: data)
                        return .success(entities)
                    } catch {
                        return .failure(error)
                    }
                })
                DispatchQueue.main.async {
                    completion(
                        result.flatMap({ (_) -> Result<Changes<Entity>, Error> in
                            do {
                                try self.context.saveIfNeeded()
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

    }
}

extension NSManagedObjectContext {
    func saveIfNeeded() throws {
        guard hasChanges else { return }
        try save()
    }

    func createBackgroundContext() -> NSManagedObjectContext {
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.undoManager = nil
        context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        context.parent = self
        return context
    }

    // Check if we still need to do this with xcode 11
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
