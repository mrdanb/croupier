import Foundation
import CoreData

public extension RepositoryError {
    enum CoreData: Error {
        case objectNotFoundInContext
        case failedToFindObjectAfterSave
    }
}

/*public final class CoreDataRepository<ModelType>: Repository where ModelType: NSManagedObject {

    private let context: NSManagedObjectContext
    private let primaryKey: String

    init(for type: ModelType.Type, context: NSManagedObjectContext, primaryKey: String) {
        self.context = context
        self.primaryKey = primaryKey
    }

    public func get(forKey key: String,
                    completion: @escaping (Result<ModelType, Error>) -> Void) {
        context.perform { [weak self] in
            guard let strongSelf = self else { return }
            do {
                let predicate = NSPredicate(format: "%K = %@", strongSelf.primaryKey, key)
                guard let result: ModelType = try strongSelf.context.executeFetch(predicate: predicate)?.first else {
                    throw RepositoryError.CoreData.objectNotFoundInContext
                }
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
        }
    }

    public func getAll(completion: @escaping (Result<[ModelType], Error>) -> Void) {
        context.perform { [weak context] in
            do {
                guard let result: [ModelType] = try context?.executeFetch() else {
                    throw RepositoryError.CoreData.objectNotFoundInContext
                }
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
        }
    }

    public func delete(item: ModelType,
                       completion: @escaping (Result<ModelType, Error>) -> Void) {
        context.perform { [weak context] in
            context?.delete(item)
            do {
                try context?.saveIfNeeded()
                completion(.success(item))
            } catch {
                completion(.failure(error))
            }
        }
    }

    public func store(item: ModelType,
                      completion: @escaping (Result<ModelType, Error>) -> Void) {
        do {
            guard let item: ModelType = try context.executeFetch(predicate: NSPredicate(format: "self = %@", item.objectID))?.first else {
                throw RepositoryError.CoreData.failedToFindObjectAfterSave
            }
            completion(.success(item))
        } catch {
            completion(.failure(error))
        }
    }

    // TODO: XCode 11 == NSBatchInsertRequest
    public func store(items: [ModelType],
                      completion: @escaping (Result<[ModelType], Error>) -> Void) {
        guard items.isEmpty == false else { return }
        let objectIDs = items.map({ $0.objectID })
        do {
            guard let results: [ModelType] = try context.executeFetch(predicate: NSPredicate(format: "self IN %@", objectIDs)),
                results.isEmpty == false else {
                throw RepositoryError.CoreData.failedToFindObjectAfterSave
            }
            try context.saveIfNeeded()
            completion(.success(results))
        } catch {
            completion(.failure(error))
        }
    }
}

private extension NSManagedObjectContext {

    func executeFetch<T>(predicate: NSPredicate? = nil) throws -> [T]? where T: NSManagedObject {
        let request = T.fetchRequest()
        request.predicate = predicate
        return try fetch(request) as? [T]
    }

    func performTaskInChildContext(task: @escaping (NSManagedObjectContext) -> Void) {
        let backgroundContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        backgroundContext.parent = self
        backgroundContext.perform {
            task(backgroundContext)
        }
    }
}*/


public class CoreDataRepository<ModelType>: NSObject, NSFetchedResultsControllerDelegate, Repository where ModelType: NSManagedObject {
    public typealias Context = NSManagedObjectContext
    private let context: NSManagedObjectContext
    private let source: Source
    private let responseDecoder: Decoding
    private let identifier: String
    private var fetchResultsController: NSFetchedResultsController<ModelType>?

    public init(for type: ModelType.Type,
                source: Source,
                responseDecoder: Decoding = JSONDecodableDecoder(),
                context: NSManagedObjectContext,
                identifier: String) {
        self.context = context
        self.source = source
        self.responseDecoder = responseDecoder
        self.identifier = identifier
    }

    private func createRequest() -> NSFetchRequest<ModelType> {
        return NSFetchRequest(entityName: ModelType.entity().name ?? String(describing: ModelType.self))
    }

    private func prepareFetch(predicate: NSPredicate? = nil) {
        let request = createRequest()
        request.predicate = predicate
        request.sortDescriptors = [NSSortDescriptor(key: identifier, ascending: true)]
        fetchResultsController = NSFetchedResultsController(fetchRequest: request,
                                                            managedObjectContext: context,
                                                            sectionNameKeyPath: nil,
                                                            cacheName: nil)
        fetchResultsController?.delegate = self
    }

    private func performFetch() throws {
        try fetchResultsController?.performFetch()
    }

    public func get(forKey key: String, completion: @escaping (Result<ModelType, Error>) -> Void) {
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

    public func getAll(completion: @escaping (Result<[ModelType], Error>) -> Void) {
        do {
            prepareFetch()
            try performFetch()
            guard let result = fetchResultsController?.fetchedObjects else {
                throw RepositoryError.CoreData.objectNotFoundInContext
            }
            completion(.success(result))
        } catch {
            completion(.failure(error))
        }
    }

    public func sync<ResponseType>(key: String,
                                   responseType: ResponseType.Type,
                                   serialise: @escaping (ResponseType, Context) -> [ModelType],
                                   completion: @escaping (Result<Bool,Error>) -> Void) where ResponseType: Decodable {

        prepareFetch()
        try? performFetch()

        source.data(for: key, parameters: nil) { (result) in
            switch result {
            case .success(let data):
                DispatchQueue(label: "uk.co.dollop.decode.queue").async {
                    do {
                        let response = try self.responseDecoder.decode(ResponseType.self, from: data)
                        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
                        context.parent = self.context
                        context.performAndWait {
                            let model = serialise(response, context)
                            print(model)
                            do {
                                try context.saveIfNeeded()
                            } catch {
                                completion(.failure(error))
                            }
                        }
                        DispatchQueue.main.async {
                            completion(.success(true))
//                            do {
//                                try self.context.saveIfNeeded()
//                                completion(.success(true))
//                            }
//                            catch {
//                                completion(.failure(error))
//                            }
                        }
                    }
                    catch {
                        print(error)
                    }
                }
            case .failure(let error):
                print(error)
            }
        }
    }

    public func delete(item: ModelType, completion: @escaping (Result<ModelType, Error>) -> Void) {

    }

    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                           didChange anObject: Any,
                           at indexPath: IndexPath?,
                           for type: NSFetchedResultsChangeType,
                           newIndexPath: IndexPath?) {
        // use this after syncing...
        print("Object changed: \(anObject)")
    }

    public func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("Will change...")
    }
}
