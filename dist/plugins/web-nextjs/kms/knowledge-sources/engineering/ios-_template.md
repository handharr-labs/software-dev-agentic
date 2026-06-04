> Template — seeds stub nodes for iOS Clean Architecture patterns (Swift/UIKit).
> Each ## section → one ChromaDB node. Stubs are overwritten when real content is seeded.

# Domain

## Domain Creation Order
### Theory
_Stub — sequence for building domain layer files in a new feature._
### Code Pattern
_Stub — ordered file creation sequence._

## Domain Dependency Rule
### Theory
_Stub — what domain may and may not import._
### Code Pattern
_Stub — allowed vs forbidden import examples._

## Entity
### Theory
_Stub — pure domain object; no UIKit, networking, or framework dependencies._
### Definition
_Stub — struct/class shape, Equatable conformance._
### Code Pattern
_Stub — canonical Swift entity._

## Repository Interface
### Theory
_Stub — abstract protocol declared in domain, implemented in data._
### Definition
_Stub — protocol with async/await or Combine return types._
### Code Pattern
_Stub — canonical repository protocol._

## Use Case
### Theory
_Stub — one business operation per class; calls one repository method._
### Definition
_Stub — class/struct with execute() or async call._
### Code Pattern
_Stub — canonical use case implementation._

## Domain Enum
### Theory
_Stub — business-level constants; no UI strings._
### Code Pattern
_Stub — canonical Swift enum with computed properties._

## Domain Error
### Theory
_Stub — typed errors returned from use cases; not thrown directly to UI._
### Code Pattern
_Stub — Error conforming enum hierarchy._

## Domain Service
### Theory
_Stub — pure domain logic with no I/O; use only when logic spans multiple entities._
### Code Pattern
_Stub — canonical domain service._

# Data

## Data Source
### Theory
_Stub — remote and local data source contracts and implementations._
### Definition
_Stub — protocol + implementation split._
### Code Pattern
_Stub — canonical URLSession / Alamofire data source._

## Data Dependency Rule
### Theory
_Stub — what data layer may and may not import._
### Code Pattern
_Stub — allowed vs forbidden import examples._

## DTO
### Theory
_Stub — Codable data object; never crosses into domain._
### Definition
_Stub — struct conforming to Codable._
### Code Pattern
_Stub — canonical DTO with CodingKeys._

## HTTP Client
### Theory
_Stub — URLSession / Alamofire setup, interceptors, base URL config._
### Code Pattern
_Stub — canonical HTTP client factory._

## Mapper
### Theory
_Stub — converts DTO ↔ Entity; lives in data layer._
### Code Pattern
_Stub — canonical mapper._

## Repository Implementation
### Theory
_Stub — implements domain protocol; maps errors to domain error types._
### Code Pattern
_Stub — canonical repository impl._

# Presentation

## View Model
### Theory
_Stub — owns presentation logic; binds to ViewController via Combine / callbacks._
### Definition
_Stub — class with input/output contract._
### Code Pattern
_Stub — canonical ViewModel._

## Screen Structure
### Theory
_Stub — ViewController + ViewModel composition; lifecycle and binding setup._
### Code Pattern
_Stub — canonical ViewController + ViewModel wiring._

## Component
### Theory
_Stub — reusable UIView subclass; no ViewModel dependency._
### Code Pattern
_Stub — canonical UIView component._

## Shared Component Paths
### Theory
_Stub — where shared UI components live; naming conventions._
### Code Pattern
_Stub — component directory layout._

## Logging
### Theory
_Stub — structured logging in presentation layer; what to log and when._
### Code Pattern
_Stub — canonical logging call._

## DI Setup
### Theory
_Stub — dependency injection wiring for presentation; how ViewController receives ViewModel._
### Code Pattern
_Stub — canonical DI wiring._

## Registration Order
### Theory
_Stub — correct registration sequence for Swinject / manual DI._
### Code Pattern
_Stub — registration order example._

## Testing with DI
### Theory
_Stub — how to inject mocks in unit tests._
### Code Pattern
_Stub — canonical test setup with mock injection._

# Navigation

## Coordinator
### Theory
_Stub — owns navigation flow for a feature; decouples ViewController from routing._
### Definition
_Stub — Coordinator protocol + implementation._
### Code Pattern
_Stub — canonical Coordinator._

## Error Flow
### Theory
_Stub — how errors surface through navigation (error screen, alert, inline)._
### Code Pattern
_Stub — error navigation flow._

# Registration

## Dependency Registration
### Theory
_Stub — how to register a feature's dependencies in the DI container._
### Code Pattern
_Stub — canonical registration module._

## Route Registration
### Theory
_Stub — how to register a feature's routes._
### Code Pattern
_Stub — canonical route registration._

## Deeplink Registration
### Theory
_Stub — deep link URL scheme registration and parameter mapping._
### Code Pattern
_Stub — canonical deep link handler._

## Push Notification Registration
### Theory
_Stub — push notification payload handling and routing._
### Code Pattern
_Stub — canonical push handler._

## Feature Flag Registration
### Theory
_Stub — how to register and read feature flags._
### Code Pattern
_Stub — canonical feature flag usage._

## Analytics Constants
### Theory
_Stub — analytics event and property constant definitions._
### Code Pattern
_Stub — canonical analytics constants file._

# Testing

## Test Pyramid
### Theory
_Stub — unit → integration → UI ratio and tooling (XCTest, Quick/Nimble)._
### Code Pattern
_Stub — test file structure overview._

## Presenter Test
### Theory
_Stub — ViewModel unit test; mock use cases, assert output bindings._
### Code Pattern
_Stub — canonical ViewModel test._

## Repository Test
### Theory
_Stub — mock data source; verify error mapping._
### Code Pattern
_Stub — canonical repository test._

## Mapper Test
### Theory
_Stub — DTO → Entity mapping assertions._
### Code Pattern
_Stub — canonical mapper test._

## Procedure
### Theory
_Stub — step-by-step process for running tests locally and in CI._
### Code Pattern
_Stub — xcodebuild test invocation._

# Project

## Project Structure
### Theory
_Stub — module layout, folder conventions, target organization._
### Code Pattern
_Stub — directory tree._

## Conventions
### Theory
_Stub — file naming, class naming, extension file rules._
### Code Pattern
_Stub — naming examples._

# Cross-Cutting

## Date Service
### Theory
_Stub — abstracted Date access; never call Date() directly in domain._
### Code Pattern
_Stub — DateService protocol + impl._

## Logger
### Theory
_Stub — structured logging setup; log levels._
### Code Pattern
_Stub — canonical logger usage._

## Storage Service
### Theory
_Stub — abstracted local storage (UserDefaults / Keychain); domain-facing protocol._
### Code Pattern
_Stub — StorageService protocol + impl._

## Helper Extensions
### Theory
_Stub — shared Swift extensions; naming and placement rules._
### Code Pattern
_Stub — canonical extension file._

## Null Safety Extensions
### Theory
_Stub — optional unwrapping helpers and nil-coalescing patterns._
### Code Pattern
_Stub — canonical optional extension._
