import Foundation

public protocol Deleting {
    associatedtype ModelType
    func delete(item: ModelType,
                completion: @escaping (Result<ModelType, Error>) -> Void)
}
