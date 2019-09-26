import Foundation

public typealias Repository = Fetching & Syncing & Deleting

public protocol Syncing {
    associatedtype Response: Serializing
    associatedtype ModelType
    func sync(key: String, completion: @escaping (Result<[ModelType],Error>) -> Void) // Maybe this could return a change delta
}

public protocol Serializing {
    associatedtype Serialized
    associatedtype Context
    func serialize(context: Context) -> [Serialized]
}
