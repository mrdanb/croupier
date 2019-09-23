import Foundation

public protocol Cache {
    associatedtype ModelType
    func store(entry: ModelType, forKey key: String) throws
    func fresh(forKey key: String) -> ModelType?
    func stale(forKey key: String) -> ModelType?
    func any(forKey key: String) throws -> ModelType
}

//extension Cache {
//
//    func put(key: String, entry: ModelType) {
//        self.put(key: key, entry: [entry])
//    }
//
//    func fresh(key: String) -> ModelType? {
//        return nil
//    }
//
//    func stale(key: String) -> ModelType? {
//        return nil
//    }
//}
