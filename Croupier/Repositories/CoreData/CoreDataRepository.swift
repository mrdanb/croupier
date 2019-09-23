import Foundation
import CoreData

public extension RepositoryError {
    enum CoreData: Error {
        case objectNotFoundInContext
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

                let predicate = NSPredicate(format: "%k = %@", strongSelf.primaryKey, key)
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

    public func delete(forKey key: String,
                       completion: ((Result<ModelType?, Error>) -> Void)?) {
        context.perform { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.get(forKey: key, completion: { (result) in

                let result =
                result.flatMap({ (item) -> Result<ModelType?, Error> in
                    do {
                        strongSelf.context.delete(item)
                        try strongSelf.context.saveIfNeeded()
                        return .success(item)
                    } catch {
                        return .failure(error)
                    }
                })
                completion?(result)
            })
        }
    }

    public func store(item: ModelType,
                      forKey key: String,
                      completion: ((Result<ModelType, Error>) -> Void)?) {
        context.perform { [weak self] in
            guard let strongSelf = self else { return }
            item.setValue(key, forKey: strongSelf.primaryKey)
            strongSelf.context.insert(item)
            do {
                try strongSelf.context.saveIfNeeded()
                completion?(.success(item))
            } catch {
                completion?(.failure(error))
            }
        }
    }
}

private extension NSManagedObjectContext {

    func executeFetch<T>(predicate: NSPredicate? = nil) throws -> [T]? where T: NSManagedObject {
        let request = T.fetchRequest()
        request.predicate = predicate
        return try fetch(request) as? [T]
    }

    func saveIfNeeded() throws {
        guard hasChanges else { return }
        try save()
    }
}
