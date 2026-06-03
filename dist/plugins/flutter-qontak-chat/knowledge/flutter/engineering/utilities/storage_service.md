---
platform: flutter
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

Abstracts key-value storage behind an interface. `SharedPreferences` for preferences; `FlutterSecureStorage` for tokens. Registered via `@LazySingleton(as: StorageService)`. Sensitive keys (tokens) must use the secure implementation.

## Code Pattern

```dart
// core/storage/storage_service.dart
abstract class StorageService {
  Future<void> set<T>(StorageKey key, T value);
  Future<T?> get<T>(StorageKey key);
  Future<void> remove(StorageKey key);
  Future<void> clearAll();
  Future<bool> contains(StorageKey key);
}

enum StorageKey {
  accessToken, refreshToken, tokenExpiration,
  userId, userEmail, lastSyncDate,
  onboardingCompleted, lastSelectedTab,
}
```

```dart
// core/storage/shared_preferences_storage_service.dart
@LazySingleton(as: StorageService)
class SharedPreferencesStorageService implements StorageService {
  final SharedPreferences _prefs;
  SharedPreferencesStorageService(this._prefs);

  @override
  Future<void> set<T>(StorageKey key, T value) async {
    final k = key.name;
    if (value is String) await _prefs.setString(k, value);
    else if (value is int) await _prefs.setInt(k, value);
    else if (value is bool) await _prefs.setBool(k, value);
    else await _prefs.setString(k, jsonEncode(value));
  }

  @override
  Future<T?> get<T>(StorageKey key) async {
    final k = key.name;
    if (T == String) return _prefs.getString(k) as T?;
    if (T == int) return _prefs.getInt(k) as T?;
    if (T == bool) return _prefs.getBool(k) as T?;
    final raw = _prefs.getString(k);
    return raw != null ? jsonDecode(raw) as T? : null;
  }

  @override
  Future<void> remove(StorageKey key) async => _prefs.remove(key.name);

  @override
  Future<void> clearAll() async {
    for (final key in StorageKey.values) { await remove(key); }
  }

  @override
  Future<bool> contains(StorageKey key) async => _prefs.containsKey(key.name);
}
```

```dart
// Secure storage for tokens
@Named('secure')
@LazySingleton(as: StorageService)
class SecureStorageService implements StorageService {
  final FlutterSecureStorage _storage;
  static const _sensitiveKeys = {StorageKey.accessToken, StorageKey.refreshToken};

  SecureStorageService(@Named('flutterSecureStorage') this._storage);

  @override
  Future<void> set<T>(StorageKey key, T value) async {
    if (_sensitiveKeys.contains(key)) {
      await _storage.write(key: key.name, value: value.toString());
    }
  }

  @override
  Future<T?> get<T>(StorageKey key) async => await _storage.read(key: key.name) as T?;

  @override
  Future<void> remove(StorageKey key) => _storage.delete(key: key.name);

  @override
  Future<void> clearAll() async => _storage.deleteAll();

  @override
  Future<bool> contains(StorageKey key) async =>
      (await _storage.read(key: key.name)) != null;
}
```
