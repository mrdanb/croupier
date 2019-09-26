import Foundation

public typealias Repository = Fetching & Syncing & Deleting

public protocol Syncing {
    associatedtype Response: Serializing
    associatedtype Entity
    func sync(key: String, completion: @escaping (Result<[Entity],Error>) -> Void) // Maybe this could return a change delta
}

public protocol Serializing {
    associatedtype Serialized
    associatedtype Context
    func serialize(context: Context) -> [Serialized]
}
