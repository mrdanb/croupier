import Foundation
import CoreData

public protocol Source {
    func data(for key: String,
              parameters: [String: String]?,
              completion: @escaping (Result<Data, Error>) -> Void)
}

protocol Repo {
    associatedtype ResponseType
    associatedtype ModelType
}

class CroupierRepo<ResponseType, ModelType>: Repo {

    init() { }

    func sync(key: String, serialise: (ResponseType) -> [ModelType]) {

        // pull data.
        // decode to response type
        // open new context
    }
}

func test() {
    
}

struct GamesResponse {
}

struct Games {
}
