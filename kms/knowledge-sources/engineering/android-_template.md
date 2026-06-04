> Template — seeds stub nodes for Android Clean Architecture patterns (Kotlin/MVP).
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
_Stub — pure domain object; no Android SDK or framework dependencies._
### Definition
_Stub — data class shape._
### Code Pattern
_Stub — canonical Kotlin entity._

## Repository Interface
### Theory
_Stub — abstract contract declared in domain, implemented in data._
### Definition
_Stub — interface with suspend / Flow return types._
### Code Pattern
_Stub — canonical repository interface._

## Use Case
### Theory
_Stub — one business operation per class; calls one repository method._
### Definition
_Stub — class with invoke() operator._
### Code Pattern
_Stub — canonical use case._

## Domain Error
### Theory
_Stub — typed failures; sealed class hierarchy returned from use cases._
### Code Pattern
_Stub — sealed DomainError class._

## Domain Service
### Theory
_Stub — pure domain logic with no I/O; use only when logic spans multiple entities._
### Code Pattern
_Stub — canonical domain service._

# Data

## Data Creation Order
### Theory
_Stub — sequence for building data layer files in a new feature._
### Code Pattern
_Stub — ordered file creation sequence._

## Data Dependency Rule
### Theory
_Stub — what data layer may and may not import._
### Code Pattern
_Stub — allowed vs forbidden import examples._

## Data Source
### Theory
_Stub — remote and local data source contracts and implementations._
### Definition
_Stub — interface + implementation split._
### Code Pattern
_Stub — canonical Retrofit / Room data source._

## DTO
### Theory
_Stub — JSON-aware data object using Gson/Moshi; never crosses into domain._
### Definition
_Stub — data class with @SerializedName annotations._
### Code Pattern
_Stub — canonical DTO._

## Mapper
### Theory
_Stub — converts DTO ↔ Entity; lives in data layer._
### Code Pattern
_Stub — canonical mapper._

## Repository Implementation
### Theory
_Stub — implements domain interface; maps exceptions to domain errors._
### Code Pattern
_Stub — canonical repository impl._

## Data Layer Invariants
### Theory
_Stub — rules that must hold throughout the data layer: no domain leakage, exception containment._
### Code Pattern
_Stub — invariant checklist._

# Presentation

## Presentation Creation Order
### Theory
_Stub — sequence for building presentation layer files in a new feature._
### Code Pattern
_Stub — ordered file creation sequence._

## Presentation Dependency Rule
### Theory
_Stub — what presentation layer may and may not import._
### Code Pattern
_Stub — allowed vs forbidden imports._

## MVP Contract
### Theory
_Stub — View interface + Presenter contract defined in one file._
### Definition
_Stub — interface structure for View and Presenter._
### Code Pattern
_Stub — canonical MVP contract file._

## Presenter
### Theory
_Stub — owns presentation logic; holds reference to View interface only._
### Code Pattern
_Stub — canonical Presenter._

## State Holder
### Theory
_Stub — immutable state object passed to View; no business logic._
### Code Pattern
_Stub — canonical state data class._

## State Management
### Theory
_Stub — how state flows from Presenter to View; update strategies._
### Code Pattern
_Stub — state update pattern._

## Screen Structure
### Theory
_Stub — Fragment/Activity + Presenter wiring; lifecycle binding._
### Code Pattern
_Stub — canonical Fragment + Presenter setup._

## Component
### Theory
_Stub — reusable custom View; no Presenter dependency._
### Code Pattern
_Stub — canonical custom View._

## Logging
### Theory
_Stub — structured logging in presentation; what to log and when._
### Code Pattern
_Stub — canonical log call._

# DI

## DI Module
### Theory
_Stub — Koin/Dagger/Hilt module definition per feature._
### Code Pattern
_Stub — canonical DI module._

## DI Principles
### Theory
_Stub — scoping rules, constructor injection preferred, no service locator in domain._
### Code Pattern
_Stub — scoping examples._

## Registration Order
### Theory
_Stub — correct module loading order to avoid resolution errors._
### Code Pattern
_Stub — module registration sequence._

## Scope Rules
### Theory
_Stub — singleton vs scoped vs factory — when to use each._
### Code Pattern
_Stub — scope declaration examples._

## Activity Binding
### Theory
_Stub — how DI binds to Activity/Fragment lifecycle._
### Code Pattern
_Stub — canonical activity binding._

## Testing with DI
### Theory
_Stub — how to inject mocks in unit tests._
### Code Pattern
_Stub — canonical test DI setup._

# Navigation

## Navigator
### Theory
_Stub — navigation abstraction; decouples Fragment from routing._
### Code Pattern
_Stub — canonical Navigator interface + impl._

## Route Constants
### Theory
_Stub — route name and parameter constant definitions._
### Code Pattern
_Stub — canonical route constants file._

# Error Handling

## Error Types
### Theory
_Stub — error taxonomy: network, server, domain, unknown._
### Code Pattern
_Stub — sealed error hierarchy._

## Error Handler
### Theory
_Stub — centralized error → user message mapping._
### Code Pattern
_Stub — canonical error handler._

## Error Interceptor
### Theory
_Stub — OkHttp/Retrofit interceptor for HTTP error normalization._
### Code Pattern
_Stub — canonical error interceptor._

## Error Response Models
### Theory
_Stub — API error response DTO structure._
### Code Pattern
_Stub — canonical error response DTO._

## Error Mapping
### Theory
_Stub — HTTP exception → domain error mapping rules._
### Code Pattern
_Stub — canonical error mapper._

## Error Flow
### Theory
_Stub — how errors propagate from data → domain → presentation._
### Code Pattern
_Stub — error flow diagram / sequence._

## Error Layer Invariants
### Theory
_Stub — rules: errors never swallowed silently; domain never receives raw HTTP codes._
### Code Pattern
_Stub — invariant checklist._

# Testing

## Test Pyramid
### Theory
_Stub — unit → integration → instrumented ratio and tooling (JUnit, Mockk, Espresso)._
### Code Pattern
_Stub — test file structure overview._

## Use Case Tests
### Theory
_Stub — pure unit test; mock repository, assert output._
### Code Pattern
_Stub — canonical use case test with Mockk._

## Presenter Tests
### Theory
_Stub — mock use cases, assert View method calls._
### Code Pattern
_Stub — canonical presenter test._

## Repository Tests
### Theory
_Stub — mock data source; verify exception → error mapping._
### Code Pattern
_Stub — canonical repository test._

## Mapper Tests
### Theory
_Stub — DTO → Entity mapping assertions._
### Code Pattern
_Stub — canonical mapper test._

## Unit Test Setup
### Theory
_Stub — TestCoroutineDispatcher, LifecycleOwner fakes, standard test boilerplate._
### Code Pattern
_Stub — canonical test base class._

## Mock vs Real
### Theory
_Stub — when to use Mockk mocks vs fake implementations vs real objects._
### Code Pattern
_Stub — decision table._

## Test Naming Convention
### Theory
_Stub — test function naming: given/when/then or should/when pattern._
### Code Pattern
_Stub — naming examples._

## What to Test
### Theory
_Stub — layer-by-layer testing priorities; what not to test._
### Code Pattern
_Stub — coverage checklist._

## Procedure
### Theory
_Stub — step-by-step process for running tests locally and in CI._
### Code Pattern
_Stub — ./gradlew test invocation._

# Registration

## Dependency Registration
### Theory
_Stub — how to register a feature's dependencies._
### Code Pattern
_Stub — canonical registration module._

## Route Registration
### Theory
_Stub — how to register a feature's navigation routes._
### Code Pattern
_Stub — canonical route registration._

## Module Registration
### Theory
_Stub — how to register a Koin/Dagger module in the app graph._
### Code Pattern
_Stub — module loading example._

## Deeplink Registration
### Theory
_Stub — deep link intent filter and parameter extraction._
### Code Pattern
_Stub — canonical deep link handler._

## Push Notification Registration
### Theory
_Stub — FCM token registration and payload routing._
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

## Hybrid Embedding
### Theory
_Stub — WebView embedding pattern for hybrid screens; JS bridge setup._
### Code Pattern
_Stub — canonical WebView fragment._

# Web Module

## Web Screen
### Theory
_Stub — standalone web module screen structure; how it receives Android context._
### Code Pattern
_Stub — canonical web module screen._

## Web Creation Order
### Theory
_Stub — sequence for building web module feature files._
### Code Pattern
_Stub — ordered file creation._

## Web Dependency Rule
### Theory
_Stub — web module layer dependency constraints._
### Code Pattern
_Stub — allowed vs forbidden imports._

## Web DI Wiring
### Theory
_Stub — DI setup specific to the web module._
### Code Pattern
_Stub — canonical web module DI._

## Web Layer Invariants
### Theory
_Stub — invariants specific to the web module layer._
### Code Pattern
_Stub — invariant checklist._

## Web Navigator
### Theory
_Stub — navigation abstraction within the web module._
### Code Pattern
_Stub — canonical web navigator._

## Planner Search Patterns
### Theory
_Stub — grep/glob patterns for the planner agent to locate web module artifacts._
### Code Pattern
_Stub — search pattern examples._

# Cross-Cutting

## Date Service
### Theory
_Stub — abstracted date/time access; never call System.currentTimeMillis() in domain._
### Code Pattern
_Stub — DateService interface + impl._

## Logger
### Theory
_Stub — structured logging setup; log levels._
### Code Pattern
_Stub — canonical logger usage._

## Storage Service
### Theory
_Stub — abstracted local storage (SharedPreferences / Room); domain-facing interface._
### Code Pattern
_Stub — StorageService interface + impl._

## Helper Extensions
### Theory
_Stub — shared Kotlin extension functions; naming and placement rules._
### Code Pattern
_Stub — canonical extension file._

## Null Safety Extensions
### Theory
_Stub — nullable handling helpers and safe-cast patterns._
### Code Pattern
_Stub — canonical nullable extension._
