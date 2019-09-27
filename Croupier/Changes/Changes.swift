import Foundation

public struct Changes<Entity> {

    public private(set) var deleted = [Entity]()
    public private(set) var inserted = [Entity]()
    public private(set) var updated = [Entity]()

    public init() { }

    public mutating func deleted(_ entity: Entity) {
        deleted.append(entity)
    }

    public mutating func inserted(_ entity: Entity) {
        inserted.append(entity)
    }

    public mutating func updated(_ entity: Entity) {
        updated.append(entity)
    }

    public mutating func empty() {
        deleted.removeAll()
        inserted.removeAll()
        updated.removeAll()
    }

    public func changes(for type: ChangeType) -> [Entity] {
        switch type {
        case .deleted: return deleted
        case.inserted: return inserted
        case .updated: return updated
        }
    }
}

public  extension Changes {
    enum ChangeType {
        case inserted
        case deleted
        case updated
    }
}

extension Changes: CustomDebugStringConvertible {
    public var debugDescription: String {
        let description =  """
        Changes(
            Updated: \(updated.count)
            Inserted: \(inserted.count)
            Deleted: \(deleted.count)
        )
        """
        return description
    }
}
