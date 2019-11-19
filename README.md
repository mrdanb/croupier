#  Croupier 🃏

#### ⚠️ This is a pre-alpha library currently under development ⚠️

### The repository pattern library
Here to assist you your swift development by syncing, fetching and deleting your entity classes.

## Setup

### 🗃 CoreData
```swift
// Setup your CoreData stack as usual.
let context = persistentContainer.viewContext
context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump

// Create a `Source` for your data. In this case we will use Croupier's `HTTPSource`.
let url = URL(string: "http://www.example.api.com/")!
let source = HTTPSource(baseURL: url)

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

### 📱 In-memory
```
 Coming soon...
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

repository.sync(from: "/users/example-identifier") { (result) in
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

## Changes

When performing a sync the result success type will be a `Changes` object.
```swift
struct Changes<Entity>
```
This struct holds any entities that have been inserted, deleted or updated.

You can access these by using the three collections accessors: `changes.inserted`, `changes.deleted` and  `changes.updated`

Or by using the helper method `changes(for type:)`:
```swift
let inserted = changes.changes(for: .inserted)
```
