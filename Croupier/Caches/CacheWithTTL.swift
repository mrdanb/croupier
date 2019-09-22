import Foundation
import CoreData

public class CacheWithTTL<Store>: Cache where Store: Fetching & Storing {
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

    public func put(key: String, entry: [ModelType]) {
        lastFetched[key] = currentTime()
    }

    public func fresh<ModelType>(key: String) -> [ModelType]? {
        return nil
    }

    public func stale<ModelType>(key: String) -> [ModelType]? {
        return nil
    }
    //    public func fresh(key: String) -> ModelType? {
    //        let expiresAt = calculateExpiryTime(key: key, lifetime: freshLifetime)
    //        guard currentTime() <= expiresAt else { return nil }
    //        return nil
    //    }
    //
    //    public func stale(key: String) -> ModelType? {
    //        let expiresAt = calculateExpiryTime(key: key, lifetime: staleLifetime)
    //        guard currentTime() <= expiresAt else { return nil }
    //        return nil
    //    }
    //
    //    private func calculateExpiryTime(key: String, lifetime: TimeInterval) -> TimeInterval {
    //        let lastFetchedAt = lastFetched[key] ?? 0
    //        return lastFetchedAt + lifetime
    //    }
}

