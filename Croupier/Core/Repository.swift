import Foundation

public typealias Repository = Fetching & Syncing & Deleting

public protocol Syncing {
    associatedtype ModelType
    associatedtype Context
    func sync<ResponseType: Decodable>(key: String,
                                       responseType: ResponseType.Type,
                                       serialise: @escaping (ResponseType, Context) -> [ModelType],
                                       completion: @escaping (Result<Bool,Error>) -> Void) // Maybe this could return a change delta
}
