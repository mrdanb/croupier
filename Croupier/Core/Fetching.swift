import Foundation

public protocol Fetching {
    associatedtype Entity
    func get(predicate: NSPredicate,
             completion: @escaping (Result<[Entity], Error>) -> Void)

    func getAll(completion: @escaping (Result<[Entity], Error>) -> Void)

    func getAndWait(predicate: NSPredicate) throws -> [Entity]

    func getAllAndWait() throws -> [Entity]
}

public extension Fetching {
    func getFirstAndWait() throws -> Entity {
        let results = try getAllAndWait()
        guard let item = results.first else { throw RepositoryError.notFound }
        return item
    }

    func getFirstAndWait(predicate: NSPredicate) throws -> Entity {
        let results = try getAndWait(predicate: predicate)
        guard let item = results.first else { throw RepositoryError.notFound }
        return item
    }

    func getFirst(predicate: NSPredicate, completion: @escaping (Result<Entity, Error>) -> Void) {
        get(predicate: predicate) { result in
            completion(
                result.flatMap{ items -> Result<Entity, Error> in
                    guard let item = items.first else { return .failure(RepositoryError.notFound) }
                    return .success(item)
                }
            )
        }
    }

    func getFirst(completion: @escaping (Result<Entity, Error>) -> Void) {
        getAll { result in
            completion(
                result.flatMap{ items -> Result<Entity, Error> in
                    guard let item = items.first else { return .failure(RepositoryError.notFound) }
                    return .success(item)
                }
            )
        }
    }
}
