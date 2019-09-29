import Foundation
import CoreData

public protocol Serializable {
    associatedtype Serialized
    associatedtype Context
    func serialize(context: Context) -> [Serialized]
    func serialize() -> [Serialized]
}

public extension Serializable {
    func serialize() -> [Self] {
         return [self]
    }

    func serialize(context: Any) -> [Self] {
        return [self]
    }
}
