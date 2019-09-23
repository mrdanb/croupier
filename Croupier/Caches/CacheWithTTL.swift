import Foundation
import CoreData

public class CacheWithTTL<Store>: Cache where Store: SynchronousFetching & SynchronousStoring {
    public typealias ModelType = Store.ModelType
    private var lastFetched = [String: TimeInterval]()
    private let store: Store
    private let freshLifetime: TimeInterval
    private let staleLifetime: TimeInterval
    private let currentTime: () -> TimeInterval

    public init(store: Store,
                freshLifetime: TimeInterval,
                staleLifetime: TimeInterval,
                currentTime: @escaping () -> TimeInterval) {
        self.store = store
        self.freshLifetime = freshLifetime
        self.staleLifetime = staleLifetime
        self.currentTime = currentTime
    }

    public func store(entry: ModelType, forKey key: String) throws {
        lastFetched[key] = currentTime()
        try store.store(item: entry, forKey: key)
    }

    public func fresh(forKey key: String) -> ModelType? {
        let expiresAt = calculateExpiryTime(key: key, lifetime: freshLifetime)
        guard currentTime() <= expiresAt else { return nil }
        return try? store.get(forKey: key)
        
    }

    public func stale(forKey key: String) -> ModelType? {
        let expiresAt = calculateExpiryTime(key: key, lifetime: staleLifetime)
        guard currentTime() <= expiresAt else { return nil }
        return try? store.get(forKey: key)
    }

    public func any(forKey key: String) throws -> ModelType {
        return try store.get(forKey: key)
    }

    private func calculateExpiryTime(key: String, lifetime: TimeInterval) -> TimeInterval {
        let lastFetchedAt = lastFetched[key] ?? 0
        return lastFetchedAt + lifetime
    }
}

