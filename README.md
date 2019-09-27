#  Croupier 🃏

### The repository pattern library
Here to assist you your swift development by syncing, fetching and deleting your entity classes.

## Fetching
```swift
let repository = Repository<Response, Entity> = ...

repository.get(forKey: "example-identifier") { (result) in
    switch result {
    case .success(let item): // Use item of type `Entity` ...
    case .failure(let error): // handle error...
    }
}

repository.getAll { (result) in
    switch result {
    case .success(let items): // Use items...
    case .failure(let error): // Handle error...
    }
}
```

## Syncing
```swift
func sync(key: String,
completion: @escaping (Result<Changes<Entity>,Error>) -> Void)
```

## Deleting
```swift
func delete(item: Entity, completion: @escaping (Result<Entity, Error>) -> Void)
```

## Examples

### CoreData
```swift
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
let repository = CoreDataRepository<GamesResponse, Game>(source: source, 
                                                        context: context, 
                                                        identifier: "identifier")

```
