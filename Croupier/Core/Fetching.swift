import Foundation

public protocol Fetching {
    associatedtype Entity
    func get(forKey key: String,
             completion: @escaping (Result<Entity, Error>) -> Void)

    func getAll(completion: @escaping (Result<[Entity], Error>) -> Void)
}
