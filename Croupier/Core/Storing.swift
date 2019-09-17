import Foundation

public protocol Storing {
    associatedtype ModelType
    func store(item: ModelType,
               forKey key: String,
               completion: ((Result<ModelType, Error>) -> Void)?)
}
