#  Croupier 🃏

### The repository pattern library
Here to assist you your swift development by syncing, fetching and deleting your entity classes.

##  Actions

### Fetching
```
func get(forKey key: String, completion: @escaping (Result<Entity, Error>) -> Void)
func getAll(completion: @escaping (Result<[Entity], Error>) -> Void)
```

### Syncing
```
func sync(key: String,
completion: @escaping (Result<Changes<Entity>,Error>) -> Void)
```

### Deleting
```
func delete(item: Entity, completion: @escaping (Result<Entity, Error>) -> Void)
```

## Examples

### CoreData
```
// Setup your CoreData stack as usual.
let context = persistentContainer.viewContext
context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump

// Create a `Source` for your data. In this case we will use Croupier's `URLSessionDataSource`.
let url = URL(string: "http://www.mocky.io/v2/")!
let source = URLSessionDataSource(baseURL: url)

/*
 Initialize the repository.

 Here you need to declare your response and entity types.
 For this example we are using `ConfigurationResponse` and `Configuration` in your implementation these will be different.

 As well as the source and context you will need to set the identifier for the repository.
 This is the name of the property that will be used to match the key against when fetching entities.
*/
let repository = CoreDataRepository<GamesResponse, Game>(source: source, context: context, identifier: "identifier")

```
