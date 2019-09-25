import Foundation
import CoreData

/*public class CoreData {

    private static var _builder: CoreData?

    public class func setup(context: NSManagedObjectContext) {
        _builder = CoreData(context: context)
    }

    public static var builder: CoreData {
        guard let instance = _builder else {
            fatalError("You must call CoreData.setup(context:) before accessing the builder")
        }
        return instance
    }

    private let context: NSManagedObjectContext
    init(context: NSManagedObjectContext) {
        self.context = context
    }

    public func decoder() -> Decoding {
        return CoreDataDecoder(context: context)
    }

    public func repository<ModelType>(for type: ModelType.Type, primaryKey: String) -> CoreDataRepository<ModelType> {
        return CoreDataRepository(for: ModelType.self, context: context, primaryKey: primaryKey)
    }
}
*/
