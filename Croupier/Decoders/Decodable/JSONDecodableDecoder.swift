import Foundation

public class JSONDecodableDecoder: Decoding {

    public init() { }

    public func decode<T>(_ type: T.Type, from data: Data) throws -> T where T: Decodable {
        let jsonDecoder = JSONDecoder()
        return try jsonDecoder.decode(type, from: data)
    }
}
