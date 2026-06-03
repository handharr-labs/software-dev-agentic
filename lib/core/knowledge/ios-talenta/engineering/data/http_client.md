---
platform: ios
project: ios-talenta
discipline: engineering
topic: data
pattern: http_client
---

## HTTP Client

Talenta iOS uses **Moya** for type-safe networking.

```swift
// Shared/Network/API/TimeManagementAPI.swift
enum TimeManagementAPI {
    case postSubmitCico(params: [String: Any], companyId: Int, config: TMRequestConfig?)
    case getServerTime(params: [String: Any], config: TMRequestConfig?)
    case postCicoValidateLocation(params: [String: Any], companyId: Int, config: TMRequestConfig?)
}

extension TimeManagementAPI: TargetType {
    var baseURL: URL {
        return URL(string: AppEnvironment.shared.baseURL)!
    }

    var path: String {
        switch self {
        case .postSubmitCico(_, let companyId, _):
            return "/api/v1/companies/\(companyId)/live-attendance"
        case .getServerTime:
            return "/api/v1/server-time"
        case .postCicoValidateLocation(_, let companyId, _):
            return "/api/v1/companies/\(companyId)/live-attendance/validate-location"
        }
    }

    var method: Moya.Method {
        switch self {
        case .postSubmitCico, .postCicoValidateLocation:
            return .post
        case .getServerTime:
            return .get
        }
    }

    var task: Task {
        switch self {
        case .postSubmitCico(let params, _, _), .postCicoValidateLocation(let params, _, _):
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case .getServerTime(let params, _):
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        }
    }

    var headers: [String: String]? {
        return [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(StorageHelper.getStringValue(key: .accessToken).orEmpty())"
        ]
    }
}
```

**Moya Pattern:**
- Enum cases for endpoints
- Conform to `TargetType` protocol
- Use `.requestParameters` for body/query
- Headers include auth tokens from storage
- MoyaProvider handles HTTP requests
