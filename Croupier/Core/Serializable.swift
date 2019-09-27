import Foundation
import CoreData

public protocol Serializable {
    associatedtype Serialized
    associatedtype Context
    func serialize(context: Context) -> [Serialized]
}

public extension Serializable {
    func serialize(context: EmptyContext) -> [Self] {
        return [self]
    }
}

public extension Serializable where Self: NSManagedObject {
    func serialize(context: NSManagedObjectContext) -> [Self] {
        let name = self.entity.name ?? String(describing: self)
        guard let object =  NSEntityDescription.insertNewObject(forEntityName: name, into: context) as? Self else {
            return []
        }
        return [object]
    }
}

public protocol EmptyContext {}
