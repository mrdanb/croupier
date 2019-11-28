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
    func getFirst(predicate: NSPredicate? = nil,
                  completion: @escaping (Result<Entity, Error>) -> Void) {
        let handler = { (result: Result<[Entity],Error>) in
            completion(
                result.flatMap { items -> Result<Entity, Error> in
                    guard let item = items.first else {
                        return .failure(RepositoryError.notFound)
                    }
                    return .success(item)
                }
            )
        }
        if let filter = predicate {
            get(predicate: filter, completion: handler)
        } else {
            getAll(completion: handler)
        }
    }
}
