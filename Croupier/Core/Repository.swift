import Foundation

public protocol Repository: Fetching, Syncing, Deleting, Adding {
    associatedtype Entity
    associatedtype Response
}
