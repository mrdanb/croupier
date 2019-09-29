import Foundation

public protocol Serializable {
    associatedtype Serialized
    associatedtype Context
    func serialize(context: Context) -> [Serialized]
}

public extension Serializable {
    func serialize(context: Any) -> [Self] {
        return [self]
    }
}
