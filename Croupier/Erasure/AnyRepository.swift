import Foundation

public struct AnyRepository<Response,Entity>: Repository where Response: Serializable {
    private let _get: (NSPredicate, @escaping (Result<[Entity],Error>) -> Void) -> Void
    private let _getAll: (@escaping (Result<[Entity],Error>) -> Void) -> Void
    private let _getAndWait: (NSPredicate) throws -> [Entity]
    private let _getAllAndWait: () throws -> [Entity]
    private let _sync: (String, @escaping (Result<Changes<Entity>,Error>) -> Void) -> Void
    private let _delete: (Entity, @escaping (Result<Entity,Error>) -> Void) -> Void
    private let _deleteAll: (@escaping (Result<Int,Error>) -> Void) -> Void
    private let _deleteAndWait: (Entity) throws -> Entity
    private let _deleteAllAndWait: () throws -> Int
    private let _add: (Entity, @escaping (Result<Entity,Error>) -> Void) -> Void
    private let _addAndWait: (Entity) throws -> Entity

    public init<Repo>(_ repository: Repo) where Repo: Repository, Repo.Entity == Entity {
        _get = repository.get
        _getAll = repository.getAll
        _getAndWait = repository.getAndWait
        _getAllAndWait = repository.getAllAndWait
        _sync = repository.sync
        _delete = repository.delete
        _deleteAll = repository.deleteAll
        _deleteAndWait = repository.deleteAndWait
        _deleteAllAndWait = repository.deleteAllAndWait
        _add = repository.add
        _addAndWait = repository.addAndWait
    }

    public func get(predicate: NSPredicate, completion: @escaping (Result<[Entity], Error>) -> Void) {
        _get(predicate, completion)
    }

    public func getAll(completion: @escaping (Result<[Entity], Error>) -> Void) {
        _getAll(completion)
    }

    public func getAndWait(predicate: NSPredicate) throws -> [Entity] {
        return try _getAndWait(predicate)
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

    public func deleteAndWait(item: Entity) throws -> Entity {
        return try _deleteAndWait(item)
    }

    public func deleteAllAndWait() throws -> Int {
        return try _deleteAllAndWait()
    }

    public func add(item: Entity, completion: @escaping (Result<Entity, Error>) -> Void) {
        _add(item, completion)
    }

    public func addAndWait(item: Entity) throws -> Entity {
        return try _addAndWait(item)
    }
}

