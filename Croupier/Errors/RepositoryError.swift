import Foundation

public enum RepositoryError: Error {
    case invalidKey
    case notFound
    case unableToWrite
}
