import Foundation

public protocol Source {
    func data(for key: URL,
              parameters: [String: String]?,
              completion: @escaping (Result<Data, Error>) -> Void)
}
