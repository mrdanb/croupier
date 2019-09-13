import Foundation

public enum RepositoryError: Error {
    case invalidKey
    case notFound
    case unableToWrite
}

public protocol Repository {

    associatedtype ModelType: Codable

    func get(key: String,
             options: [String: String]?,
             completion: @escaping (Result<ModelType, Error>) -> Void)

    func getAll(completion: (Result<[ModelType], Error>) -> Void)

    func delete(item: ModelType,
                key: String,
                completion: ((Result<ModelType, Error>) -> Void)?)

    func store(item: ModelType,
               forKey key: String,
               completion: ((Result<ModelType, Error>) -> Void)?)
}

