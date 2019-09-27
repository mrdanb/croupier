#  Croupier 🃏

### The repository pattern library
Here to assist you your swift development by syncing, fetching and deleting your entity classes.

## Setup

### CoreData
```swift
// Setup your CoreData stack as usual.
let context = persistentContainer.viewContext
context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump

// Create a `Source` for your data. In this case we will use Croupier's `URLSessionDataSource`.
let url = URL(string: "http://www.example.api.com/")!
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

## Fetching
```swift
let repository: AnyRepository<Response, User> = …

repository.get(forKey: "example-identifier") { (result) in
    switch result {
    case .success(let item): // Use item of type `User`
    case .failure(let error): // handle error
    }
}

repository.getAll { (result) in
    switch result {
    case .success(let items): // Use items of type `[User]`
    case .failure(let error): // Handle error
    }
}
```

## Syncing
```swift
let repository: AnyRepository<Response, User> = …

repository.sync(key: "/users/example-identifier") { (result) in
    switch result {
    case .success(let changes): // Handle changes - represented by type `Changes<User>`
    case .failure(let error): // Handle error
    }
}

```

## Deleting
```swift
let repository: AnyRepository<Response, User> = …

let item: User
repository.delete(item: item) { (result) in
    switch result {
    case .success(let item): // Handle item of type `User`
    case .failure(let error): // Handle error
    }
}
```
