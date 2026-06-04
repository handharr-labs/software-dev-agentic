> Template — seeds stub nodes for Flutter Clean Architecture patterns.
> Each ## section → one ChromaDB node. Stubs are overwritten when real content is seeded.

# Domain

## Domain Creation Order
### Theory
_Stub — sequence for building domain layer files in a new feature._
### Code Pattern
_Stub — ordered file creation sequence._

## Dependency Rule
### Theory
_Stub — what domain may and may not import._
### Code Pattern
_Stub — allowed vs forbidden import examples._

## Entity
### Theory
_Stub — pure domain object; no Flutter or framework dependencies._
### Definition
_Stub — structural contract (class shape, annotations)._
### Code Pattern
_Stub — canonical @freezed entity example._

## Repository Interface
### Theory
_Stub — abstract contract declared in domain, implemented in data._
### Definition
_Stub — abstract class with Either return types._
### Code Pattern
_Stub — canonical repository abstract class._

## Use Case
### Theory
_Stub — one business operation per class; calls one repository method._
### Definition
_Stub — class contract and call() signature._
### Code Pattern
_Stub — canonical use case implementation._

## Domain Enum
### Theory
_Stub — business-level constants; no UI strings._
### Code Pattern
_Stub — canonical enum with computed properties._

## Domain Error
### Theory
_Stub — typed failures returned via Either; never thrown._
### Code Pattern
_Stub — sealed class / freezed failure hierarchy._

## Domain Service
### Theory
_Stub — pure domain logic with no I/O; use only when logic spans multiple entities._
### Code Pattern
_Stub — canonical domain service example._

# Data

## Data Creation Order
### Theory
_Stub — sequence for building data layer files in a new feature._
### Code Pattern
_Stub — ordered file creation sequence._

## DTO
### Theory
_Stub — JSON-aware data object; never crosses into domain._
### Definition
_Stub — class shape with fromJson/toJson._
### Code Pattern
_Stub — canonical DTO with @JsonSerializable._

## Mapper
### Theory
_Stub — converts DTO ↔ Entity; lives in data layer._
### Code Pattern
_Stub — canonical mapper class._

## Data Source
### Theory
_Stub — remote data source contract and implementation._
### Definition
_Stub — abstract interface + implementation split._
### Code Pattern
_Stub — canonical remote data source with Dio._

## Local Data Source
### Theory
_Stub — SharedPreferences / Hive / SQLite access pattern._
### Code Pattern
_Stub — canonical local data source._

## Repository Implementation
### Theory
_Stub — implements domain interface; catches exceptions, returns Either._
### Code Pattern
_Stub — canonical repository impl with try/catch → Failure._

## HTTP Client
### Theory
_Stub — Dio setup, interceptors, base URL config._
### Code Pattern
_Stub — canonical Dio factory / interceptor setup._

## Exception
### Theory
_Stub — data-layer exception types caught by repository impl._
### Code Pattern
_Stub — exception hierarchy._

## Payload
### Theory
_Stub — request body object for POST/PUT calls._
### Code Pattern
_Stub — canonical payload with toJson._

# Presentation

## BLoC
### Theory
_Stub — event-driven state manager; calls use cases only._
### Definition
_Stub — Event / State / BLoC class structure._
### Code Pattern
_Stub — canonical BLoC with on<Event> handlers._

## Cubit
### Theory
_Stub — simplified BLoC for straightforward state; no events._
### Code Pattern
_Stub — canonical Cubit._

## Screen Structure
### Theory
_Stub — BlocProvider + BlocBuilder/Listener composition._
### Code Pattern
_Stub — canonical screen widget tree._

## Component
### Theory
_Stub — reusable presentation widget; no BLoC dependency._
### Code Pattern
_Stub — canonical stateless component._

## BLoC Listener
### Theory
_Stub — side effects (navigation, snackbar) in BlocListener; never in BlocBuilder._
### Code Pattern
_Stub — canonical BlocConsumer with listener + builder split._

# DI

## get_it
### Theory
_Stub — service locator setup; all registrations via injectable._
### Code Pattern
_Stub — canonical GetIt instance access._

## Registration Order
### Theory
_Stub — registration sequence to avoid dependency resolution errors._
### Code Pattern
_Stub — correct registration order example._

## External Dependencies
### Theory
_Stub — third-party registrations (Dio, SharedPreferences) in @module._
### Code Pattern
_Stub — canonical @module class._

# Navigation

## go_router
### Theory
_Stub — declarative routing setup; routes defined at app level._
### Code Pattern
_Stub — canonical GoRouter config._

## Navigate From BLoC
### Theory
_Stub — navigation triggered from BLoC listener; not from BLoC itself._
### Code Pattern
_Stub — context.go() in BlocListener._

## Deep Link
### Theory
_Stub — deep link route registration and parameter extraction._
### Code Pattern
_Stub — GoRoute with path parameters._

## Nested Navigation
### Theory
_Stub — ShellRoute for bottom nav / tab navigation._
### Code Pattern
_Stub — canonical ShellRoute._

# Error Handling

## Failure Types
### Theory
_Stub — sealed Failure hierarchy; one subtype per failure class._
### Code Pattern
_Stub — canonical Failure sealed class._

## App Exception
### Theory
_Stub — top-level exception → Failure mapping._
### Code Pattern
_Stub — exception handler._

## Error UI
### Theory
_Stub — how failures surface in the UI (error state, snackbar, dialog)._
### Code Pattern
_Stub — BlocBuilder mapping failure state to widget._

## Validation Errors
### Theory
_Stub — inline field validation pattern in forms._
### Code Pattern
_Stub — canonical form validator._

# Testing

## Test Pyramid
### Theory
_Stub — unit → widget → integration ratio and tooling._
### Code Pattern
_Stub — test file structure overview._

## Use Case Test
### Theory
_Stub — pure unit test; mock repository, assert Either output._
### Code Pattern
_Stub — canonical use case test with mocktail._

## Repository Test
### Theory
_Stub — mock data source; verify exception → Failure mapping._
### Code Pattern
_Stub — canonical repository test._

## Presenter Test
### Theory
_Stub — BLoC/Cubit unit test; emit sequence assertions._
### Code Pattern
_Stub — canonical bloc_test with expect._

## Mock Generation
### Theory
_Stub — @GenerateMocks / mocktail Mock<T> setup per layer._
### Code Pattern
_Stub — canonical mock generation annotation._

## Naming Convention
### Theory
_Stub — test file and test case naming rules._
### Code Pattern
_Stub — should/when naming examples._

# Cross-Cutting

## Date Service
### Theory
_Stub — abstracted DateTime access; never call DateTime.now() directly in domain._
### Code Pattern
_Stub — DateService interface + impl._

## Logger
### Theory
_Stub — structured logging setup; log levels and contexts._
### Code Pattern
_Stub — canonical logger usage._

## Storage Service
### Theory
_Stub — abstracted local storage; domain-facing interface._
### Code Pattern
_Stub — StorageService interface + impl._
