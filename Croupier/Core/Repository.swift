import Foundation

public enum RepositoryError: Error {
    case invalidKey
    case notFound
    case unableToWrite
}

public protocol Repository {

    associatedtype ModelType

    func get(forKey key: String,
             options: [String: String]?,
             completion: @escaping (Result<ModelType, Error>) -> Void)

    func getAll(completion: @escaping (Result<[ModelType], Error>) -> Void)

    func delete(forKey key: String,
                completion: ((Result<ModelType?, Error>) -> Void)?)

    func store(item: ModelType,
               forKey key: String,
               completion: ((Result<ModelType, Error>) -> Void)?)
}

