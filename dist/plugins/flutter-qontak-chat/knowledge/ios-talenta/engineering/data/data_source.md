---
platform: ios
project: ios-talenta
discipline: engineering
topic: data
pattern: data_source
---

## Theory

A **DataSource** is an abstract interface for raw data access — remote (HTTP) or local (DB, cache).

**Invariants:**
- Interface only in the data layer — implementation is injected, never instantiated directly
- Methods return raw data (DTOs or primitives) — never domain entities
- One DataSource per data origin (remote API, local DB, cache) — do not mix sources in one interface
- Throws or returns transport-layer errors — the repository implementation maps these to domain errors

**When to create:** One DataSource interface per data origin per feature. Created after the DTO and mapper, before the repository implementation.

---

## Data Sources

Abstract the data origin (remote API, local storage, cache).

```swift
// Data/DataSource/Remote/LiveAttendanceRemoteDataSource.swift
protocol LiveAttendanceRemoteDataSource {
    func postSubmitCico(
        params: [String: Any],
        companyId: Int,
        config: TMRequestConfig?,
        completion: @escaping (APIResult<RequestLiveAttendanceResponse>) -> Void
    )

    func getServerTime(
        params: [String: Any],
        config: TMRequestConfig?,
        completion: @escaping (APIResult<LiveAttendanceServerTimeResponse>) -> Void
    )
}

// Data/DataSource/Remote/LiveAttendanceRemoteDataSourceImpl.swift
class LiveAttendanceRemoteDataSourceImpl: LiveAttendanceRemoteDataSource {
    private let provider: MoyaProvider<TimeManagementAPI>

    init(provider: MoyaProvider<TimeManagementAPI> = MoyaProvider<TimeManagementAPI>()) {
        self.provider = provider
    }

    func postSubmitCico(
        params: [String: Any],
        companyId: Int,
        config: TMRequestConfig?,
        completion: @escaping (APIResult<RequestLiveAttendanceResponse>) -> Void
    ) {
        provider.request(.postSubmitCico(params: params, companyId: companyId, config: config)) { result in
            switch result {
            case .success(let response):
                do {
                    let decoded = try JSONDecoder().decode(RequestLiveAttendanceResponse.self, from: response.data)
                    completion(.success(decoded))
                } catch {
                    completion(.error(TalentaBaseError(message: error.localizedDescription)))
                }
            case .failure(let error):
                completion(.error(TalentaBaseError(message: error.localizedDescription)))
            }
        }
    }
}
```

**DataSource Rules:**
- Protocol for abstraction, Impl for implementation
- Takes raw params as `[String: Any]` (converted from domain Params)
- Returns `APIResult<ResponseType>` (custom result enum)
- Uses Moya for HTTP requests
- Error handling: catch decode + network errors
