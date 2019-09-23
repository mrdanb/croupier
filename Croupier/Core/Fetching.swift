import Foundation

public protocol Fetching {
    associatedtype ModelType
    func get(forKey key: String,
             completion: @escaping (Result<ModelType, Error>) -> Void)

    func getAll(completion: @escaping (Result<[ModelType], Error>) -> Void)
}

public protocol SynchronousFetching {
    associatedtype ModelType
    func get(forKey key: String) throws -> ModelType
    func getAll() throws -> [ModelType]
}
