import Foundation

public protocol Serializable {
    associatedtype Serialized
    associatedtype Context
    func serialize(context: Context) -> [Serialized]
}
