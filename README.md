#  Croupier 🃏

### The repository pattern library
Here to assist your swift development by syncing, fetching and deleting your entity classes.

- [Installation](#installation)
- [Setup](#setup)
- [Fetching](#fetching)
- [Syncing](#syncing)
- [Deleting](#deleting)
- [Changes](#changes)

## Installation

### Swift Package Manager

Install via [Swift Package Manager](https://swift.org/package-manager/).

Use Croupier as a dependency by adding it to the `dependencies` value of your `Package.swift`.

```swift
dependencies: [
    .package(url: "https://github.com/mrdanb/croupier.git", .upToNextMajor(from: "1.0.0"))
]
```

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
// extended `NSPersistentContainer` to act as a `ContextProvider`.
let repository = CoreDataRepository<UserResponse, User>(source: source, contextProvider: persistentContainer)
```

### 📱 In-memory
```swift
// 1. In order to setup an in-memory repository you need to provide a `Source`.
// In this example we have extended `UserDefaults` to implement Croupier's `Source` protocol.
// This allows us to pass in`UserDefaults` to the in-memory repository.

let repository = InMemoryRepository<UserResponse, User>(source: UserDefaults.standard)

extension UserDefaults: Source {
    public func data(for key: String,
                     parameters: [String : String]? = nil,
                     completion: @escaping (Result<Data, Error>) -> Void) {
        guard let data = self.data(forKey: key) else {
            completion(.failure(RepositoryError.notFound))
            return
        }
        completion(.success(data))
    }
}
```

## 🔄 Syncing
Syncing allows you to update your repository with data from a given source. 
When you ask Croupier to `sync` it will:
* Ask the source you provided to return some `Data` for a given key
* Decode that data in to your  `Response` type
* Serialize the response to your  `Entity` type
* Store the results

The result is a `Changes` object listing what has been added, updated or deleted. See [Changes](#Changes)

```swift
let repository: AnyRepository<Response, User> = …

repository.sync(from: "/users/example-identifier") { result in
    switch result {
    case .success(let changes): // Handle changes - represented by type `Changes<User>`
    case .failure(let error): // Handle error
    }
}
```

### Serializing
When setting up your repository, the `Response` type you provide must be a `Serializable` type. This means Croupier is able to serialize the `Entity` objects from the response.
If your `Response` and `Entity` type are the same (i.e. you wish to store the response) you can use the default implementation. You can do this b simply adding the `Serializable` protocol to your type 
```swift
extension UserResponse: Serializable { }
```

Otherwise it is up to you to provide an implementation that generates the entites you are storing. 

For example, if you are using the `CoreDataRepository`  your implementation will need to generate the managed objects. An example might look as follows:
```swift
extension UserResponse: Serializable {
    func serialize(context: NSManagedObjectContext?,
                   store: (User) -> Void) {
        // Create your NSManagedObject object and pass it to the `store` closure.
        guard let context = context else { return }
        let user = User(context: context, response: self)
        store(user)
    }
}
```
Once the entity has been created, call the `store` closure passing in the object. 

## ⬇️ Fetching
Fetching can be done both asynchronously and synchronously. There are also methods to fetch the first item or multiple items.
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
    case .success(let item): // .. item is of type `User`
    case .failure(let error): // Handle error
    }
}

let users = try? repository.getAllAndWait() // Returns an array of entities. e.g. `[User]`

let user = try? repository.getFirstAndWait() // Returns a single entity. e.g. `User`
```

## 🗑 Deleting
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

## 🔀 Changes

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
