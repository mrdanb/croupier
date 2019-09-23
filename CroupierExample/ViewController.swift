import UIKit
import CoreData
import Croupier

class ViewController: UIViewController {

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "CroupierExample")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        createRepo()
    }

    func createRepo() {
        let url = URL(string: "http://www.mocky.io/v2/")!
        let session = URLSession.shared
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
//        let repo = Builder.buildCoreDataRepo<Games>(url: url,
//                                                    urlSession: session,
//                                                    context: persistentContainer.viewContext)
//
//        repo.get(forKey: "5d81415b30000010006995c5", options: nil) { (result) in
//            print(result)
//        }
//        repo.get(forKey: "5d81415b30000010006995c5", options: nil) { (result) in
//            print(result)
//        }
//        let builder = Builder(baseUrl: url,
//                              urlSession: session,
//                              context: persistentContainer.viewContext,
//                              primaryKey: "identifier")
//
//        let repo =  builder.repositoryWithCache(decoder: builder.coreDataDecoder(),
//                                                source: builder.foundationHttpSource(),
//                                                cache: builder.cacheWithTTL(store: builder.coreDataRepository(for: Games.self)))
    }
}

@objc(Games)
class Games: NSManagedObject, Codable {
    @NSManaged var identifier: String
    @NSManaged var name: String

    private enum CodingKeys: String, CodingKey {
        case identifier
        case name
    }

    required convenience init(from decoder: Decoder) throws {
        guard let context = decoder.managedObjectContext,
            let entity = NSEntityDescription.entity(forEntityName: "Games", in: context) else {
            fatalError("No context found")
        }
        self.init(entity: entity, insertInto: context)

        let container = try decoder.container(keyedBy: CodingKeys.self)
        identifier = try container.decode(String.self, forKey: .identifier)
        name = try container.decode(String.self, forKey: .name)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(identifier, forKey: .identifier)
        try container.encode(name, forKey: .name)
    }
}
