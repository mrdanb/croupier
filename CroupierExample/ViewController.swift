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

//    var repo: AnyRepository<Games>?

    override func viewDidLoad() {
        super.viewDidLoad()
        let context = persistentContainer.viewContext
        context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        let url = URL(string: "http://www.mocky.io/v2/")!
        let source = FoundationHTTPClient(baseURL: url)

        let repo = CoreDataRepository<GamesResponse, Game>(source: source, context: context, identifier: "identifier")
        repo.sync(key: "5d8beb5d350000f745d472a1") { (result) in
            switch result {
            case .success(let changes):
                print(changes)
            case .failure(let error):
                print(error)
            }
        }
        print(repo)

//        repo.getAll() { (result) in
//            switch result {
//            case .success(let items):
//                print(items)
//            case .failure(let error):
//                print(error)
//            }
//        }

//        repo.get(forKey: "123") { (result) in
//            print(result)
//        }
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

@objc(Game)
class Game: NSManagedObject {
    @NSManaged var identifier: String
    @NSManaged var name: String

    func update(_ game: GameResponse) {
        self.identifier = game.identifier
        self.name = game.name
    }
}
