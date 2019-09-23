import Foundation

public protocol Storing {
    associatedtype ModelType
    func store(item: ModelType,
               forKey key: String,
               completion: ((Result<ModelType, Error>) -> Void)?)
}

public protocol SynchronousStoring {
    associatedtype ModelType
    func store(item: ModelType, forKey key: String) throws
}
