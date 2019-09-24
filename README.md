#  Croupier 🃏

## The repository pattern library
Here to assist you with your swift development by dealing with and distrubuting your model classes with ease.

### Examples

#### CoreData:
```
CoreData.setup(context: context) // Must be called before using CoreData.builder

let source = FoundationHTTPClient(session: session)
let decoding = CoreData.builder.decoder()
let store = CoreData.builder.repository(for: Games.self, primaryKey: "identifier")
let repo = RepositoryWithCache(for: Games.self, baseUrl: url, decoder: decoding, source: source, cache: store)

self.repo = AnyRepository(repo)

```
