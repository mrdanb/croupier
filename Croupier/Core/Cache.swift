import Foundation

protocol Cache {
    func put<ModelType>(key: String, entry: ModelType)
    func fresh<ModelType>(key: String) -> ModelType?
    func stale<ModelType>(key: String) -> ModelType?
}
