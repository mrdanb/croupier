import Foundation
import CoreData

class CoreDataDecoder: Decoding {

    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func decode<T>(_ type: T.Type, from data: Data) throws -> T where T: Decodable {
        let jsonDecoder = JSONDecoder()
        jsonDecoder.userInfo[.context] = context
        return try jsonDecoder.decode(type, from: data)
    }
}

private extension CodingUserInfoKey {
    static let context = CodingUserInfoKey(rawValue: "context")!
}
