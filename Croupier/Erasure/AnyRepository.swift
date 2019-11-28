import Foundation

public struct AnyRepository<Response,Entity>: Repository where Response: Serializable {
    private let _get: (NSPredicate, @escaping (Result<[Entity],Error>) -> Void) -> Void
    private let _getAll: (@escaping (Result<[Entity],Error>) -> Void) -> Void
    private let _getAndWait: (NSPredicate) throws -> [Entity]
    private let _getAllAndWait: () throws -> [Entity]

    private let _sync: (String, @escaping (Result<Changes<Entity>,Error>) -> Void) -> Void
    private let _delete: (Entity, @escaping (Result<Entity,Error>) -> Void) -> Void
    private let _deleteAll: (@escaping (Result<Int,Error>) -> Void) -> Void

    public init<Repo>(_ repository: Repo) where Repo: Repository, Repo.Entity == Entity {
        _get = repository.get
        _getAll = repository.getAll
        _getAndWait = repository.getAndWait
        _getAllAndWait = repository.getAllAndWait

        _sync = repository.sync
        _delete = repository.delete
        _deleteAll = repository.deleteAll
    }

    public func get(predicate: NSPredicate, completion: @escaping (Result<[Entity], Error>) -> Void) {
        _get(predicate, completion)
    }

    public func getAll(completion: @escaping (Result<[Entity], Error>) -> Void) {
        _getAll(completion)
    }

    public func getAndWait(predicate: NSPredicate) throws -> [Entity] {
        return try getAndWait(predicate: predicate)
    }

    public func getAllAndWait() throws -> [Entity] {
        return try _getAllAndWait()
    }

    public func sync(from key: String, completion: @escaping (Result<Changes<Entity>, Error>) -> Void) {
        _sync(key, completion)
    }

    public func delete(item: Entity, completion: @escaping (Result<Entity, Error>) -> Void) {
        _delete(item, completion)
    }

    public func deleteAll(completion: @escaping (Result<Int, Error>) -> Void) {
        _deleteAll(completion)
    }
}

