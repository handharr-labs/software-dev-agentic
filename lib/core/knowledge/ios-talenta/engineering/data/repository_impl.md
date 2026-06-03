---
platform: ios
project: ios-talenta
discipline: engineering
topic: data
pattern: repository_impl
---

## Theory

A **Repository Implementation** implements the domain repository interface using a DataSource and Mapper.

**Invariants:**
- Implements a domain repository interface — it is the bridge between Data and Domain
- Calls the DataSource for raw data, calls the Mapper to convert to domain entities
- Wraps all DataSource calls with error handling — maps transport errors to domain errors before returning
- Never lets raw HTTP errors, DB exceptions, or transport-layer types propagate to the domain
- Never calls another repository implementation directly

**When to create:** Last in the creation order — after DataSource interface and implementation exist.

---

## Repository Implementation

Repositories inject **mappers** and **datasources**, implement **domain protocols**.

```swift
// Data/RepositoriesImpl/LiveAttendanceRepositoryImpl.swift
class LiveAttendanceRepositoryImpl: LiveAttendanceRepository {
    // Singleton
    private static var _sharedInstance: LiveAttendanceRepositoryImpl?
    static var sharedInstance: LiveAttendanceRepositoryImpl {
        if _sharedInstance == nil {
            _sharedInstance = LiveAttendanceRepositoryImpl()
        }
        return _sharedInstance!
    }

    // Dependencies
    private let remoteDataSource: any LiveAttendanceRemoteDataSource
    private let requestLiveAttendanceMapper: any RequestLiveAttendanceModelMapperType
    private let cicoLocationValidationMapper: any CICOLocationValidationModelMapperType
    private let serverTimeMapper: any LiveAttendanceServerTimeModelMapperType
    private let baseErrorModelMapper: BaseErrorModelMapper

    init(
        remoteDataSource: any LiveAttendanceRemoteDataSource = LiveAttendanceRemoteDataSourceImpl(),
        requestLiveAttendanceMapper: any RequestLiveAttendanceModelMapperType = RequestLiveAttendanceModelMapper(),
        cicoLocationValidationMapper: any CICOLocationValidationModelMapperType = CICOLocationValidationModelMapper(),
        serverTimeMapper: any LiveAttendanceServerTimeModelMapperType = LiveAttendanceServerTimeModelMapper(),
        baseErrorModelMapper: BaseErrorModelMapper = BaseErrorModelMapper()
    ) {
        self.remoteDataSource = remoteDataSource
        self.requestLiveAttendanceMapper = requestLiveAttendanceMapper
        self.cicoLocationValidationMapper = cicoLocationValidationMapper
        self.serverTimeMapper = serverTimeMapper
        self.baseErrorModelMapper = baseErrorModelMapper
    }

    func postSubmitCico(
        params: PostSubmitCICOQueryParam,
        companyId: LiveAttendanceCICOPathParam,
        expected: @escaping (Result<RequestLiveAttendanceModel, BaseErrorModel>) -> Void
    ) {
        remoteDataSource.postSubmitCico(
            params: params.toDictionary().orEmpty(),
            companyId: companyId.companyId.orZero(),
            config: nil
        ) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let response):
                if let data = response.data {
                    let model = self.requestLiveAttendanceMapper.fromResponseToModel(from: data)
                    expected(.success(model))
                } else {
                    expected(.failure(BaseErrorModel(message: "No data available")))
                }
            case .error(let error):
                expected(.failure(self.baseErrorModelMapper.fromResponseToModel(from: error)))
            }
        }
    }
}
```

**Repository Rules:**
- Singleton pattern for shared instances
- Inject mappers via constructor with default parameters
- Inject datasources via constructor with default parameters
- Convert domain Params → dictionary for datasource
- Use mappers to convert Response → Domain Model
- Map errors to `BaseErrorModel`
- Return `Result<Model, BaseErrorModel>` via completion

### Advanced Repository Patterns

#### Offline Support with Cache Fallback

Use `NWPathMonitor` to check connectivity, fall back to cache when offline:

```swift
import Network

// Data/RepositoriesImpl/[Feature]RepositoryImpl.swift
final class AttendanceRepositoryImpl: AttendanceRepository {

    func getSchedule(
        param: GetAttendanceScheduleParam?,
        completion: @escaping (Result<ScheduleModel, BaseErrorModel>) -> Void
    ) {
        guard networkMonitor.isConnected else {
            if let cached = cacheManager.loadCachedSchedule() {
                completion(.success(cached))
            } else {
                completion(.failure(BaseErrorModel(message: "No internet connection.")))
            }
            return
        }

        dataSource.getSchedule(params: param?.toDictionary()) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let response):
                guard let data = response.data else {
                    completion(.failure(BaseErrorModel(message: "No data available")))
                    return
                }
                let model = self.mapper.map(from: data)
                self.cacheManager.cacheSchedule(model)
                completion(.success(model))
            case .error(let error):
                completion(.failure(self.baseErrorMapper.fromResponseToModel(from: error)))
            }
        }
    }
}
```

**Rules:**
- Inject `NetworkMonitorProtocol` and `CacheManagerProtocol` for testability
- Cache on successful fetch; serve cache when offline
- Return a clear error only when offline AND no cache exists

#### Parallel Requests with DispatchGroup

Combine multiple independent API calls into a single repository method:

```swift
// Data/RepositoriesImpl/DashboardRepositoryImpl.swift
final class DashboardRepositoryImpl: DashboardRepository {

    func getDashboardData(
        completion: @escaping (Result<DashboardDataModel, BaseErrorModel>) -> Void
    ) {
        var attendance: AttendanceModel?
        var announcements: [AnnouncementModel] = []
        var firstError: BaseErrorModel?
        let group = DispatchGroup()

        group.enter()
        attendanceDataSource.getToday { result in
            defer { group.leave() }
            switch result {
            case .success(let r): attendance = r.data.map { self.attendanceMapper.map(from: $0) }
            case .error(let e): firstError = self.baseErrorMapper.fromResponseToModel(from: e)
            }
        }

        group.enter()
        announcementDataSource.getList { result in
            defer { group.leave() }
            if case .success(let r) = result {
                announcements = (r.data ?? []).map { self.announcementMapper.map(from: $0) }
            }
        }

        group.notify(queue: .main) {
            if let error = firstError, attendance == nil {
                completion(.failure(error))
            } else {
                completion(.success(DashboardDataModel(attendance: attendance, announcements: announcements)))
            }
        }
    }
}
```

**Rules:**
- Use `DispatchGroup` for parallel independent calls
- `defer { group.leave() }` ensures leave is always called
- Decide on failure strategy: fail-fast (any error fails all) or partial success (return what you have)
- Call `group.notify(queue: .main)` to deliver result on main thread

### Creation Order

When building a new feature's data layer, create files in this sequence:

```
1. Data/Models/[Feature]/[Feature]Response.swift           ← DTO (Response struct, Decodable)
2. Data/Mapper/[Feature]ModelMapper.swift                  ← Mapper (protocol + class)
3. Data/DataSource/Remote/[Feature]RemoteDataSource.swift  ← DataSource protocol
   Data/DataSource/Remote/[Feature]RemoteDataSourceImpl.swift ← DataSource implementation
4. Data/RepositoriesImpl/[Feature]RepositoryImpl.swift     ← Repository implementation
```

Never create a repository implementation before the data source it depends on.

### Layer Invariants

- Import from domain layer only — never from presentation, ViewController, ViewModel, or Navigator files
- Raw transport errors (`TalentaBaseError`, `MoyaError`) never propagate upward — `RepositoryImpl` maps them to `BaseErrorModel` before calling the completion handler
- `*Response` and `*ResponseData` structs never cross into the domain layer — mappers (`fromResponseToModel`) are the boundary
- All `*RepositoryImpl` files conform to a domain protocol — no concrete type is referenced from outside the data layer
- `MoyaProvider` and `JSONDecoder` live only in DataSource implementations — never in Repository or Domain files
