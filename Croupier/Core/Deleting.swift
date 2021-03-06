import Foundation

public protocol Deleting {
    associatedtype Entity
    func delete(item: Entity,
                completion: @escaping (Result<Entity, Error>) -> Void)
    func deleteAll(completion: @escaping (Result<Int, Error>) -> Void)

    func deleteAndWait(item: Entity) throws -> Entity
    func deleteAllAndWait() throws -> Int
}
