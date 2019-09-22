import Foundation

public protocol Cache {
    associatedtype ModelType
    func put(key: String, entry: [ModelType])
    func fresh(key: String) -> [ModelType]?
    func stale(key: String) -> [ModelType]?
}

extension Cache {

    func put(key: String, entry: ModelType) {
        self.put(key: key, entry: [entry])
    }

    func fresh(key: String) -> ModelType? {
        return nil
    }

    func stale(key: String) -> ModelType? {
        return nil
    }
}
