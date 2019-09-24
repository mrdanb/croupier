import Foundation

public protocol Source {
    func data(for key: String,
              parameters: [String: String]?,
              completion: @escaping (Result<Data, Error>) -> Void)
}
