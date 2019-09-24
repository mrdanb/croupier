import Foundation
import CoreData

public extension RepositoryError {
    enum CoreData: Error {
        case objectNotFoundInContext
        case failedToFindObjectAfterSave
    }
}

public final class CoreDataRepository<ModelType>: Repository where ModelType: NSManagedObject {

    private let context: NSManagedObjectContext
    private let primaryKey: String

    public init(for type: ModelType.Type, context: NSManagedObjectContext, primaryKey: String) {
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
//            strongSelf.get(forKey: item.primaryKey, completion: { (result) in
//                completion?(
//                    result.map({ (item) -> Persisting in
//                        strongSelf.context.delete(item)
//                        return strongSelf
//                    })
//                )
//            })
        }
    }

    public func store(item: ModelType,
                      completion: @escaping (Result<ModelType, Error>) -> Void) {
        context.perform { [weak context] in
            guard let context = context else { return }
            let objectID = item.objectID
            context.insert(item)
            do {
                try context.saveIfNeeded()
                guard let result = context.object(with: objectID) as? ModelType else {
                    throw RepositoryError.CoreData.failedToFindObjectAfterSave
                }
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
        }
    }

    // Note: XCode 11 == NSBatchInsertRequest
    public func store(items: [ModelType],
                      completion: @escaping (Result<[ModelType], Error>) -> Void) {
        let objectIDs = items.map({ $0.objectID })
        do {
            let results: [ModelType]? = try context.executeFetch(predicate: NSPredicate(format: "self IN %@", objectIDs))
            print(results)
        } catch {
            print(error)
        }
        // Check if the items are in the correct context....
        // Move them over if not....
        // Save the context
        /*context.performTaskInChildContext { (childContext) in
            var objectIDs = [NSManagedObjectID]()
            items.forEach({ (item) in
                objectIDs.append(item.objectID)
                childContext.insert(item)
            })
            do {
                print(items)
                try childContext.saveIfNeeded()
//                guard let results: [ModelType] = try self.context.executeFetch(predicate: NSPredicate(format: "self IN %@", objectIDs)) else {
//                    throw RepositoryError.CoreData.failedToFindObjectAfterSave
//                }
                completion(.success(items))
            } catch {
                print(error)
                completion(.failure(error))
            }
        }*/
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
}
