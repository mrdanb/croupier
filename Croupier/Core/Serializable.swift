import Foundation

public protocol Serializable {
    associatedtype Serialized
    associatedtype Context
    func serialize(context: Context?, store: (Serialized) -> Void)
}

public extension Serializable {
    func serialize(context: Any?,
                   store: (Self) -> Void) {
        store(self)
    }
}
