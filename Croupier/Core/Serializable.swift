import Foundation

public protocol Serializable {
    associatedtype Serialized
    associatedtype Context
    func serialize(forKey key: String, context: Context?, store: (String, Serialized) -> Void)
}

public extension Serializable {
    func serialize(forKey key: String,
                   context: Any?,
                   store: (String, Self) -> Void) {
        store(key, self)
    }
}
