#  Croupier 🃏

### The repository pattern library
Here to assist you your swift development by syncing, fetching and deleting your entity classes.

## Setup

### 🗃 CoreData
```swift
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

```

### 📱 In-memory
```
 Coming soon...
```

## Fetching
```swift
let repository: AnyRepository<Response, User> = …

repository.getAll() { result in
    switch result {
    case .success(let items): // ..items are of type `[User]`
    case .failure(let error): // handle error
    }
}

repository.getFirst(predicate: NSPredicate(format: "identifier = %@", "3y7oef0fef")) { result in
    switch result {
    case .success(let item): // .. item is of type [User`
    case .failure(let error): // Handle error
    }
}
```

## Syncing
```swift
let repository: AnyRepository<Response, User> = …

repository.sync(from: "/users/example-identifier") { result in
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
repository.delete(item: user) { result in
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
