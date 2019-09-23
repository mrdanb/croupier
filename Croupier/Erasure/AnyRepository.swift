import Foundation

public struct AnyRepository<ModelType>: Repository {

    private let _get: (String, @escaping (Result<ModelType,Error>) -> Void) -> Void
    private let _getAll: (@escaping (Result<[ModelType],Error>) -> Void) -> Void
    private let _store: (ModelType, @escaping (Result<ModelType,Error>) -> Void) -> Void
    private let _delete: (ModelType, @escaping (Result<ModelType,Error>) -> Void) -> Void
    public init<Repo>(_ repository: Repo) where Repo: Repository, Repo.ModelType == ModelType {
        _get = repository.get
        _getAll = repository.getAll
        _store = repository.store
        _delete = repository.delete
    }

    public func get(forKey key: String, completion: @escaping (Result<ModelType, Error>) -> Void) {
        _get(key, completion)
    }

    public func getAll(completion: @escaping (Result<[ModelType], Error>) -> Void) {
        _getAll(completion)
    }

    public func store(item: ModelType, completion: @escaping (Result<ModelType, Error>) -> Void) {
        _store(item, completion)
    }

    public func delete(item: ModelType, completion: @escaping (Result<ModelType, Error>) -> Void) {
        _delete(item, completion)
    }
}
