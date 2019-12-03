import Foundation

public protocol Adding {
    associatedtype Entity
    func add(item: Entity, completion: @escaping (Result<Entity, Error>) -> Void)

    func addAndWait(item: Entity) throws -> Entity
}
