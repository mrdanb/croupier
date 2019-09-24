import Foundation

public protocol Storing {
    associatedtype ModelType
    func store(item: ModelType,
               completion: @escaping (Result<ModelType, Error>) -> Void)
    func store(items: [ModelType],
               completion: @escaping (Result<[ModelType], Error>) -> Void)
}

public extension Storing {
    func store(items: [ModelType], completion: @escaping (Result<[ModelType], Error>) -> Void) {
        let dispatchGroup = DispatchGroup()
        items.forEach { (item) in
            dispatchGroup.enter()
            self.store(item: item, completion: { (result) in
                dispatchGroup.leave()
                if case .failure(let error) = result {
                    completion(.failure(error))
                    return
                }
            })
        }
        dispatchGroup.wait()
        completion(.success(items))
    }
}
