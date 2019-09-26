import Foundation
import CoreData

public extension RepositoryError {
    enum CoreData: Error {
        case objectNotFoundInContext
        case failedToFindObjectAfterSave
    }
}

public class CoreDataRepository<Response,Entity>: NSObject, NSFetchedResultsControllerDelegate, Repository where Response: Serializable, Response: Decodable, Response.Serialized == Entity, Response.Context == NSManagedObjectContext, Entity: NSManagedObject {
    private let context: NSManagedObjectContext
    private let source: Source
    private let responseDecoder: Decoding
    private let identifier: String
    private var fetchResultsController: NSFetchedResultsController<Entity>?
    private var synced: ((Result<[Entity],Error>) -> Void)?

    public init(source: Source,
                responseDecoder: Decoding = JSONDecodableDecoder(),
                context: NSManagedObjectContext,
                identifier: String) {
        self.context = context
        self.source = source
        self.responseDecoder = responseDecoder
        self.identifier = identifier
    }

    private func createRequest() -> NSFetchRequest<Entity> {
        return NSFetchRequest(entityName: Entity.entity().name ?? String(describing: Entity.self))
    }

    private func performFetch(predicate: NSPredicate? = nil) throws {
        let request = createRequest()
        request.predicate = predicate
        request.sortDescriptors = [NSSortDescriptor(key: identifier, ascending: true)]
        fetchResultsController = NSFetchedResultsController(fetchRequest: request,
                                                            managedObjectContext: context,
                                                            sectionNameKeyPath: nil,
                                                            cacheName: nil)
        fetchResultsController?.delegate = self
        try fetchResultsController?.performFetch()
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

//        let predicate = NSPredicate(format: "%K = %@", identifier, key)
//        do {
//            prepareFetch(predicate: predicate)
//            try performFetch()
//            guard let result = fetchResultsController?.fetchedObjects?.first else {
//                throw RepositoryError.CoreData.objectNotFoundInContext
//            }
//            completion(.success(result))
//        } catch {
//            completion(.failure(error))
//        }
    }

    public func getAll(completion: @escaping (Result<[Entity], Error>) -> Void) {
        do {
            try performFetch()
            guard let result = fetchResultsController?.fetchedObjects else {
                throw RepositoryError.CoreData.objectNotFoundInContext
            }
            completion(.success(result))
        } catch {
            completion(.failure(error))
        }
    }

    public func sync(key: String,
                     completion: @escaping (Result<[Entity],Error>) -> Void) {

        do { try performFetch() } catch {
            completion(.failure(error))
            return
        }

        source.data(for: key, parameters: nil) { (result) in
            DispatchQueue(label: "uk.co.dollop.decode.queue").async {
                let result = result.flatMap({ (data) -> Result<[Entity],Error> in
                    do {
                        let response = try self.responseDecoder.decode(Response.self, from: data)
                        let updates = try self.context.createBackgroundContext().sync({ (context) -> [Entity] in
                            let result = response.serialize(context: context)
                            try context.saveIfNeeded()
                            return result
                        })
                        return .success(updates)
                    } catch {
                        return .failure(error)
                    }
                })
                DispatchQueue.main.async { completion(result) }
            }
        }
    }

    public func delete(item: Entity, completion: @escaping (Result<Entity, Error>) -> Void) {

    }

    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                           didChange anObject: Any,
                           at indexPath: IndexPath?,
                           for type: NSFetchedResultsChangeType,
                           newIndexPath: IndexPath?) {
        // use this after syncing...
    }

    public func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("Will change...")
    }
}

extension NSManagedObjectContext {
    func saveIfNeeded() throws {
        guard hasChanges else { return }
        try save()
    }

    func createBackgroundContext() -> NSManagedObjectContext {
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
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
