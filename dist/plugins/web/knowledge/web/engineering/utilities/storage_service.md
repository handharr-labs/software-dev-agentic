---
platform: web
project: web
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

Abstracts key-value storage. Used for auth tokens, user preferences, cached data.

```typescript
// core/storage/StorageService.ts
export type StorageKey =
  // Auth
  | 'accessToken'
  | 'refreshToken'
  | 'tokenExpiration'
  // User
  | 'userId'
  | 'userEmail'
  | 'lastSyncDate'
  // App State
  | 'onboardingCompleted'
  | 'lastSelectedTab'
  | 'themePreference';

export interface StorageService {
  get<T>(key: StorageKey): T | null;
  set<T>(key: StorageKey, value: T): void;
  remove(key: StorageKey): void;
  clearAll(): void;
  has(key: StorageKey): boolean;
}

// localStorage implementation (client-side)
export class LocalStorageService implements StorageService {
  get<T>(key: StorageKey): T | null {
    if (typeof window === 'undefined') return null;
    try {
      const item = localStorage.getItem(key);
      return item ? (JSON.parse(item) as T) : null;
    } catch {
      return null;
    }
  }

  set<T>(key: StorageKey, value: T): void {
    if (typeof window === 'undefined') return;
    try {
      localStorage.setItem(key, JSON.stringify(value));
    } catch {
      // ignore write errors (e.g., quota exceeded)
    }
  }

  remove(key: StorageKey): void {
    if (typeof window === 'undefined') return;
    localStorage.removeItem(key);
  }

  clearAll(): void {
    if (typeof window === 'undefined') return;
    const keys: StorageKey[] = [
      'accessToken', 'refreshToken', 'tokenExpiration',
      'userId', 'userEmail', 'lastSyncDate',
      'onboardingCompleted', 'lastSelectedTab', 'themePreference',
    ];
    keys.forEach((key) => this.remove(key));
  }

  has(key: StorageKey): boolean {
    return this.get(key) !== null;
  }
}

// Secure in-memory storage (for sensitive data — cleared on page unload)
export class InMemoryStorageService implements StorageService {
  private store = new Map<StorageKey, unknown>();

  get<T>(key: StorageKey): T | null {
    return (this.store.get(key) as T) ?? null;
  }

  set<T>(key: StorageKey, value: T): void {
    this.store.set(key, value);
  }

  remove(key: StorageKey): void {
    this.store.delete(key);
  }

  clearAll(): void {
    this.store.clear();
  }

  has(key: StorageKey): boolean {
    return this.store.has(key);
  }
}

// Composite: in-memory for tokens, localStorage for preferences
export class SecureStorageService implements StorageService {
  private readonly sensitiveKeys: Set<StorageKey> = new Set([
    'accessToken',
    'refreshToken',
  ]);

  constructor(
    private readonly memoryStorage = new InMemoryStorageService(),
    private readonly localStorageService = new LocalStorageService()
  ) {}

  private serviceFor(key: StorageKey): StorageService {
    return this.sensitiveKeys.has(key) ? this.memoryStorage : this.localStorageService;
  }

  get<T>(key: StorageKey): T | null { return this.serviceFor(key).get(key); }
  set<T>(key: StorageKey, value: T): void { this.serviceFor(key).set(key, value); }
  remove(key: StorageKey): void { this.serviceFor(key).remove(key); }
  clearAll(): void { this.memoryStorage.clearAll(); this.localStorageService.clearAll(); }
  has(key: StorageKey): boolean { return this.serviceFor(key).has(key); }
}
```
