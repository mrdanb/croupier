import Foundation

public protocol Decoding {
    func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T
}
