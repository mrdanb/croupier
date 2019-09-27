import Foundation

public protocol Syncing {
    associatedtype Response: Serializable
    associatedtype Entity
    func sync(key: String,
              completion: @escaping (Result<Changes<Entity>,Error>) -> Void) // Maybe this could return a change delta
}