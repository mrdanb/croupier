import Foundation

public class JSONDecodableDecoder: Decoding {

    private let decoder: JSONDecoder
    public init() {
        decoder = JSONDecoder()
    }

    public func decode<T>(_ type: T.Type, from data: Data) throws -> T where T: Decodable {
        return try decoder.decode(type, from: data)
    }
}
