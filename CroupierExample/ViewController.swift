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

    override func viewDidLoad() {
        super.viewDidLoad()

        // Setup your CoreData stack as usual.
        let context = persistentContainer.viewContext
        context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump

        // Create a `Source` for your data. In this case we will use Croupier's `HTTPSource`.
        let url = URL(string: "http://www.mocky.io/v2/")!
        let source = HTTPSource(baseURL: url)

        /*
         Initialize the repository.

         Here you need to declare your response and entity types.
         For this example we are using `ConfigurationResponse` and `Configuration` in your implementation these will be different.

         As well as the source and context you will need to set the identifier for the repository.
         This is the name of the property that will be used to match the key against when fetching entities.
         */
        let repository = CoreDataRepository<GamesResponse, Game>(source: source, context: context, identifier: "identifier")
        repository.sync(key: "5d8beb5d350000f745d472a1") { (result) in
            switch result {
            case .success(let changes):
                print(changes)
            case .failure(let error):
                print(error)
            }
        }
    }
}

struct GamesResponse: Decodable {
    let games: [GameResponse]
}

extension GamesResponse: Serializable {
    func serialize(context: NSManagedObjectContext) -> [Game] {
        return games.compactMap({ (gameResponse) -> Game? in
            guard let game =  NSEntityDescription.insertNewObject(forEntityName: "Game", into: context) as? Game else { return nil }
            game.update(gameResponse)
            return game
        })
    }
}

struct GameResponse: Decodable {
    let identifier: String
    let name: String
}

struct Configuration: Equatable, Decodable, Serializable {
    let isValid: Bool
    let versionNumber: String
}

@objc(Game)
class Game: NSManagedObject {
    @NSManaged var identifier: String
    @NSManaged var name: String

    func update(_ game: GameResponse) {
        self.identifier = game.identifier
        self.name = game.name
    }
}
