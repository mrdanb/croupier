import Foundation

public struct AnyRepository<Response,Entity>: Repository where Response: Serializable {

    private let _get: (String, @escaping (Result<Entity,Error>) -> Void) -> Void
    private let _getAll: (@escaping (Result<[Entity],Error>) -> Void) -> Void
    private let _sync: (String, @escaping (Result<Changes<Entity>,Error>) -> Void) -> Void
    private let _delete: (Entity, @escaping (Result<Entity,Error>) -> Void) -> Void
    public init<Repo>(_ repository: Repo) where Repo: Repository, Repo.Entity == Entity {
        _get = repository.get
        _getAll = repository.getAll
        _sync = repository.sync
        _delete = repository.delete
    }

    public func get(forKey key: String, completion: @escaping (Result<Entity, Error>) -> Void) {
        _get(key, completion)
    }

    public func getAll(completion: @escaping (Result<[Entity], Error>) -> Void) {
        _getAll(completion)
    }

    public func sync(from key: String, completion: @escaping (Result<Changes<Entity>, Error>) -> Void) {
        _sync(key, completion)
    }

    public func delete(item: Entity, completion: @escaping (Result<Entity, Error>) -> Void) {
        _delete(item, completion)
    }
}

