import Foundation

public protocol HTTPClient {

    func get(url: URL,
             parameters: [String: String]?,
             completion: @escaping (Result<Data, Error>) -> Void)
}
