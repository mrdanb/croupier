import Foundation

public protocol Deleting {
    associatedtype ModelType
    func delete(forKey key: String,
                completion: ((Result<ModelType?, Error>) -> Void)?)
}
