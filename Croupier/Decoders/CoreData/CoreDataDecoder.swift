import Foundation
import CoreData

public class CoreDataDecoder: Decoding {

    private let context: NSManagedObjectContext

    public init(context: NSManagedObjectContext) {
        self.context = context
    }

    public func decode<T>(_ type: T.Type, from data: Data) throws -> T where T: Decodable {
        let jsonDecoder = JSONDecoder()
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.parent = self.context
        jsonDecoder.userInfo[.managedObjectContext] = context
        return try jsonDecoder.decode(type, from: data)
    }
}

private extension CodingUserInfoKey {
    static let managedObjectContext = CodingUserInfoKey(rawValue: "uk.co.dollop.croupier.context")!
}

public extension Decoder {
    var managedObjectContext: NSManagedObjectContext? {
        get {
            return self.userInfo[.managedObjectContext] as? NSManagedObjectContext
        }
    }
}
