---
platform: web
project: web
discipline: engineering
topic: data
pattern: http_client
---

## HTTP Client

Uses **Axios** with **axios-retry**. The `HTTPClient` interface keeps the Data layer decoupled from Axios internals — swap the implementation without touching repositories or data sources.

```typescript
// data/networking/HTTPClient.ts
export interface RequestOptions {
  params?: Record<string, unknown>;
  headers?: Record<string, string>;
  signal?: AbortSignal;
}

export interface HTTPClient {
  get<T>(path: string, options?: RequestOptions): Promise<T>;
  post<T>(path: string, body: unknown, options?: RequestOptions): Promise<T>;
  put<T>(path: string, body: unknown, options?: RequestOptions): Promise<T>;
  patch<T>(path: string, body: unknown, options?: RequestOptions): Promise<T>;
  delete<T>(path: string, options?: RequestOptions): Promise<T>;
}

// data/networking/NetworkError.ts
export type NetworkErrorType =
  | 'httpError'
  | 'noConnection'
  | 'timeout'
  | 'parseError'
  | 'unknown';

export class NetworkError extends Error {
  readonly type: NetworkErrorType;
  readonly statusCode?: number;

  constructor(type: NetworkErrorType, message?: string, statusCode?: number) {
    super(message ?? type);
    this.name = 'NetworkError';
    this.type = type;
    this.statusCode = statusCode;
  }
}
```

### Token Provider & Refresher Interfaces

```typescript
// data/networking/TokenProvider.ts
export interface TokenProvider {
  getAccessToken(): string | null;
}

export interface TokenRefresher {
  refreshToken(): Promise<void>;
}

export interface TokenStorage extends TokenProvider {
  getRefreshToken(): string | null;
  saveAccessToken(token: string): void;
  saveRefreshToken(token: string): void;
  getTokenExpiration(): Date | null;
}
```

### Axios HTTP Client (with Auth Interceptor & Retry)

Axios interceptors replace the manual `AuthInterceptor` and `RetryPolicy` classes entirely. `axios-retry` handles exponential backoff in a single configuration call.

```typescript
// data/networking/AxiosHTTPClient.ts
import axios, {
  AxiosInstance,
  AxiosError,
  InternalAxiosRequestConfig,
} from 'axios';
import axiosRetry from 'axios-retry';

export function createHTTPClient(
  baseURL: string,
  tokenProvider: TokenProvider,
  tokenRefresher: TokenRefresher
): HTTPClient {
  const instance: AxiosInstance = axios.create({
    baseURL,
    headers: { 'Content-Type': 'application/json' },
  });

  // --- Auth: attach Bearer token to every request ---
  instance.interceptors.request.use(
    (config: InternalAxiosRequestConfig) => {
      const token = tokenProvider.getAccessToken();
      if (token) {
        config.headers.Authorization = `Bearer ${token}`;
      }
      return config;
    }
  );

  // --- Auth: refresh token on 401 and retry once ---
  instance.interceptors.response.use(
    (response) => response,
    async (error: AxiosError) => {
      const config = error.config as InternalAxiosRequestConfig & { _retried?: boolean };

      if (error.response?.status === 401 && !config._retried) {
        config._retried = true;
        await tokenRefresher.refreshToken();
        return instance.request(config);
      }

      throw mapAxiosError(error);
    }
  );

  // --- Retry: exponential backoff for network errors and 5xx ---
  axiosRetry(instance, {
    retries: 3,
    retryDelay: axiosRetry.exponentialDelay,   // 1s, 2s, 4s
    retryCondition: (error) =>
      axiosRetry.isNetworkError(error) || axiosRetry.isRetryableError(error),
    onRetry: (retryCount, error) => {
      if (process.env.NODE_ENV === 'development') {
        console.warn(`Retry attempt ${retryCount} for ${error.config?.url}`);
      }
    },
  });

  // --- Development logger ---
  if (process.env.NODE_ENV === 'development') {
    instance.interceptors.request.use((config) => {
      console.log(`${config.method?.toUpperCase()} ${config.url}`);
      return config;
    });
    instance.interceptors.response.use((response) => {
      console.log(`${response.status} ${response.config.url}`);
      return response;
    });
  }

  return {
    get: (path, options) =>
      instance.get(path, { params: options?.params, headers: options?.headers, signal: options?.signal })
        .then((r) => r.data),
    post: (path, body, options) =>
      instance.post(path, body, { headers: options?.headers, signal: options?.signal })
        .then((r) => r.data),
    put: (path, body, options) =>
      instance.put(path, body, { headers: options?.headers, signal: options?.signal })
        .then((r) => r.data),
    patch: (path, body, options) =>
      instance.patch(path, body, { headers: options?.headers, signal: options?.signal })
        .then((r) => r.data),
    delete: (path, options) =>
      instance.delete(path, { headers: options?.headers, signal: options?.signal })
        .then((r) => r.data),
  };
}

export function createUnauthenticatedHTTPClient(baseURL: string): HTTPClient {
  const instance: AxiosInstance = axios.create({
    baseURL,
    headers: { 'Content-Type': 'application/json' },
  });

  axiosRetry(instance, {
    retries: 3,
    retryDelay: axiosRetry.exponentialDelay,
    retryCondition: (error) => axiosRetry.isNetworkError(error),
  });

  return {
    get: (path, options) => instance.get(path, { params: options?.params }).then((r) => r.data),
    post: (path, body) => instance.post(path, body).then((r) => r.data),
    put: (path, body) => instance.put(path, body).then((r) => r.data),
    patch: (path, body) => instance.patch(path, body).then((r) => r.data),
    delete: (path) => instance.delete(path).then((r) => r.data),
  };
}

function mapAxiosError(error: AxiosError): NetworkError {
  if (error.response) {
    return new NetworkError(
      'httpError',
      `HTTP ${error.response.status}`,
      error.response.status
    );
  }
  if (error.code === 'ECONNABORTED' || error.code === 'ERR_CANCELED') {
    return new NetworkError('timeout', error.message);
  }
  if (error.code === 'ERR_NETWORK') {
    return new NetworkError('noConnection', error.message);
  }
  return new NetworkError('unknown', error.message);
}
```

### Token Refresh Service

```typescript
// data/networking/TokenRefreshService.ts
export class TokenRefreshService implements TokenRefresher {
  private refreshPromise: Promise<void> | null = null;

  constructor(
    private readonly httpClient: HTTPClient,   // unauthenticated client
    private readonly tokenStorage: TokenStorage
  ) {}

  async refreshToken(): Promise<void> {
    // Serialize concurrent refresh calls — all callers await the same promise
    if (this.refreshPromise) {
      return this.refreshPromise;
    }

    this.refreshPromise = this.doRefresh().finally(() => {
      this.refreshPromise = null;
    });

    return this.refreshPromise;
  }

  private async doRefresh(): Promise<void> {
    if (!this.isTokenExpired()) return;

    const refreshToken = this.tokenStorage.getRefreshToken();
    if (!refreshToken) {
      throw new NetworkError('httpError', 'No refresh token available', 401);
    }

    const response = await this.httpClient.post<TokenRefreshResponse>(
      '/auth/refresh',
      { refresh_token: refreshToken }
    );

    this.tokenStorage.saveAccessToken(response.access_token);
    this.tokenStorage.saveRefreshToken(response.refresh_token);
  }

  private isTokenExpired(): boolean {
    const expiration = this.tokenStorage.getTokenExpiration();
    if (!expiration) return true;
    const bufferMs = 30_000; // 30 seconds buffer
    return Date.now() >= expiration.getTime() - bufferMs;
  }
}
```

**What's included:**

| Feature | Implementation |
|---------|----------------|
| **Auth Interceptor** | `axios.interceptors.request` — attaches Bearer token |
| **401 Refresh & Retry** | `axios.interceptors.response` — refreshes and retries once |
| **Retry Policy** | `axios-retry` — exponential backoff for network errors & 5xx |
| **Request Logger** | `axios.interceptors` (dev only) — logs method + URL |
| **Error Normalization** | `mapAxiosError()` — maps `AxiosError` to `NetworkError` |
| **Token Refresh** | `TokenRefreshService` — serialized with a shared Promise |
