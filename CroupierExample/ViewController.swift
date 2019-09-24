import UIKit
import CoreData
import Croupier

class ViewController: UIViewController {

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "CroupierExample")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    var repo: AnyRepository<Games>?

    override func viewDidLoad() {
        super.viewDidLoad()

        createRepo()
    }

    func createRepo() {
        let url = URL(string: "http://www.mocky.io/v2/5d8a71053000005300b9a96c")!
        let session = URLSession.shared
        let context = persistentContainer.viewContext
        context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump

        CoreData.setup(context: context)

        let decoding = CoreData.builder.decoder()
        let source = FoundationHTTPClient(session: session, baseURL: url)
        let store = CoreData.builder.repository(for: Games.self, primaryKey: "identifier")
        let repo = RepositoryWithCache(for: Games.self,
                                       decoder: decoding,
                                       source: source,
                                       cache: store)
        self.repo = AnyRepository(repo)

        self.repo?.getAll(completion: { (result) in
            switch result {
            case .success(let items):
                print(items)
            case .failure(let error):
                print(error)
            }
        })

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
