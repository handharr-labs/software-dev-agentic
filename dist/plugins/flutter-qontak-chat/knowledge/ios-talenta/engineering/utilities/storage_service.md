---
platform: ios
project: ios-talenta
discipline: engineering
topic: utilities
pattern: storage_service
---

## Theory

**StorageService** is an interface-based key-value store for persisting tokens, user preferences, and cached data across app sessions.

**Invariants:**
- The interface lives in the infrastructure layer — never in domain or data
- All keys are typed constants (enum or sealed class) — never raw strings at call sites
- Implementations are swappable per environment (e.g. in-memory for tests, secure storage for production)
- `clearAll()` is only called on logout — never on individual feature teardown

**When to use:** Any layer that needs to read or write persistent state. Inject the interface — never access the concrete implementation directly.

---

## StorageService

Abstract key-value storage for tokens, preferences, cached data.

```swift
// Core/Storage/StorageService.swift
protocol StorageService: Sendable {
    func get<T: Codable>(_ key: StorageKey) -> T?
    func set<T: Codable>(_ value: T, for key: StorageKey)
    func remove(_ key: StorageKey)
    func clearAll()
    func contains(_ key: StorageKey) -> Bool
}

enum StorageKey: String, Sendable {
    // Auth
    case accessToken
    case refreshToken
    case tokenExpiration

    // User
    case userId
    case userEmail
    case lastSyncDate

    // App State
    case onboardingCompleted
    case lastSelectedTab
}

// UserDefaults Implementation
final class UserDefaultsStorageService: StorageService {
    private let defaults: UserDefaults
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    init(
        defaults: UserDefaults = .standard,
        encoder: JSONEncoder = .init(),
        decoder: JSONDecoder = .init()
    ) {
        self.defaults = defaults
        self.encoder = encoder
        self.decoder = decoder
    }

    func get<T: Codable>(_ key: StorageKey) -> T? {
        guard let data = defaults.data(forKey: key.rawValue) else { return nil }
        return try? decoder.decode(T.self, from: data)
    }

    func set<T: Codable>(_ value: T, for key: StorageKey) {
        guard let data = try? encoder.encode(value) else { return }
        defaults.set(data, forKey: key.rawValue)
    }

    func remove(_ key: StorageKey) {
        defaults.removeObject(forKey: key.rawValue)
    }

    func clearAll() {
        StorageKey.allCases.forEach { remove($0) }
    }

    func contains(_ key: StorageKey) -> Bool {
        defaults.object(forKey: key.rawValue) != nil
    }
}

// Keychain Implementation (for sensitive data)
final class KeychainStorageService: StorageService {
    // ... keychain implementation
}

// Composite (Keychain + UserDefaults)
final class SecureStorageService: StorageService {
    private let keychain = KeychainStorageService()
    private let userDefaults = UserDefaultsStorageService()

    private let sensitiveKeys: Set<StorageKey> = [
        .accessToken,
        .refreshToken
    ]

    private func service(for key: StorageKey) -> StorageService {
        sensitiveKeys.contains(key) ? keychain : userDefaults
    }

    func get<T: Codable>(_ key: StorageKey) -> T? { service(for: key).get(key) }
    func set<T: Codable>(_ value: T, for key: StorageKey) { service(for: key).set(value, for: key) }
    func remove(_ key: StorageKey) { service(for: key).remove(key) }
    func clearAll() { keychain.clearAll(); userDefaults.clearAll() }
    func contains(_ key: StorageKey) -> Bool { service(for: key).contains(key) }
}
```

**Usage:** Use `StorageHelper.getStringValue(key:)` for simple token reads. Use `StorageService` protocol for injectable, testable components.
