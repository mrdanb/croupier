import UIKit
import CoreData
import Croupier

class ViewController: UIViewController {

    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "CroupierExample")
        container.loadPersistentStores(completionHandler: { storeDescription, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    var repository: CoreDataRepository<UserResponse, User>?

    override func awakeFromNib() {
        super.awakeFromNib()

        // 1. Setup your CoreData stack as usual.
        let context = persistentContainer.viewContext
        context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump

        // 2. Create a `Source` for your data. In this case we will use Croupier's `HTTPSource`.
        let url = URL(string: "http://www.mocky.io/v2/")!
        let source = HTTPSource(baseURL: url)

        // 3. Initialize the repository.
        // Here you will need to declare your response and entity types.
        // For this example we are using `UserResponse` and `User` in your implementation these might be different.
        //
        // As well as the response and entity types you will need to provide a `ContextProvider`.
        // This is a very simple protocol that is capable of providing a `mainContext` as well as
        // creating a new background context. Here we are simply providing the persistentContainer as we have
        // extended `NSPersistentContainer` to act as a `ContextProvider` (see below).
        repository = CoreDataRepository<UserResponse, User>(source: source, contextProvider: persistentContainer)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        sync()
    }

    private func sync() {
        repository?.sync(from: "5e617f9b3000005400762c43") { result in
            switch result {
            case .success:
                self.fetch()
            case .failure(let error):
                print(error)
            }
        }
    }

    private func fetch() {
        guard let result = try? repository?.getAllAndWait() else { return }
        print(result)

        repository?.delete(item: <#T##User#>, completion: <#T##(Result<User, Error>) -> Void#>)
    }

    @IBAction func performSync(_ sender: UIButton) {
        sync()
    }
}

// Extend `NSPersistentContainer` so it can act as a `ContextProvider`.
extension NSPersistentContainer: ContextProvider {
    public var mainContext: NSManagedObjectContext {
        return viewContext
    }
}

struct UserResponse: Decodable {
    let identifier: String
    let name: String
    let age: Int
}

extension UserResponse: Serializable {
    func serialize(context: NSManagedObjectContext?,
                   store: (User) -> Void) {
        guard let context = context else { return }
        let user = User(context: context, response: self)
        store(user)
    }
}

@objc(User)
class User: NSManagedObject {
    @NSManaged var identifier: String
    @NSManaged var name: String
    @NSManaged var age: NSNumber

    func update(_ response: UserResponse) {
        identifier = response.identifier
        name = response.name
        age = NSNumber(value: response.age)
    }
}

extension User {
    convenience init(context: NSManagedObjectContext, response: UserResponse) {
        self.init(context: context)
        update(response)
    }
}
