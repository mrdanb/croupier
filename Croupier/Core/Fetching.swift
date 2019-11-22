import Foundation

public protocol Fetching {
    associatedtype Entity
    func get(predicate: NSPredicate,
             completion: @escaping (Result<[Entity], Error>) -> Void)

    func getAll(completion: @escaping (Result<[Entity], Error>) -> Void)
}

public extension Fetching {
    func getFirst(predicate: NSPredicate,
                  completion: @escaping (Result<Entity, Error>) -> Void) {
        get(predicate: predicate) { result in
            completion(
                result.flatMap { items -> Result<Entity, Error> in
                    guard let item = items.first else {
                        return .failure(RepositoryError.notFound)
                    }
                    return .success(item)
                }
            )
        }
    }
}
