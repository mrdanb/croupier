import Foundation

public protocol Cache {
    associatedtype ModelType
    func put(key: String, entry: ModelType)
    func fresh(key: String) -> ModelType?
    func stale(key: String) -> ModelType?
}
