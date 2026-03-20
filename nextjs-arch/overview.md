# Next.js StarterKit — Architecture Design

## Table of Contents

1. [Overview](#1-overview)
   - [What This Is](#what-this-is)
   - [Core Principles](#core-principles)
   - [Minimum Requirements](#minimum-requirements)
   - [Key Architecture Choices](#key-architecture-choices)
2. [Architecture Layers](#2-architecture-layers)
   - [Dependency Rule](#dependency-rule)
3. [Domain Layer](#3-domain-layer)
   - 3.1 [Entities](#31-entities)
   - 3.2 [Repository Interfaces](#32-repository-interfaces)
   - 3.3 [Use Cases](#33-use-cases)
   - 3.4 [Services](#34-services)
   - 3.5 [Domain Errors](#35-domain-errors)
4. [Data Layer](#4-data-layer)
   - 4.1 [DTOs (Data Transfer Objects)](#41-dtos-data-transfer-objects)
   - 4.2 [Mappers](#42-mappers)
   - 4.3 [Data Sources](#43-data-sources)
   - 4.4 [Repository Implementation](#44-repository-implementation)
   - 4.5 [HTTP Client](#45-http-client)
     - [Auth Interceptor & Retry Policy](#auth-interceptor--retry-policy)
     - [Token Refresh Service](#token-refresh-service)
5. [Presentation Layer](#5-presentation-layer)
   - 5.1 [QueryState](#51-querystate)
   - 5.2 [ViewModel Hook](#52-viewmodel-hook)
   - 5.3 [ViewModel Hook with Service Integration](#53-viewmodel-hook-with-service-integration)
   - 5.4 [React Component (View)](#54-react-component-view)
6. [Navigation (Router)](#6-navigation-router)
   - 6.1 [Why Next.js App Router](#61-why-nextjs-app-router)
   - 6.2 [Route Constants](#62-route-constants)
   - 6.3 [AppRouter Hook](#63-approuter-hook)
   - 6.4 [Route Resolution (Page Components)](#64-route-resolution-page-components)
   - 6.5 [Root Layout with Navigation](#65-root-layout-with-navigation)
   - 6.6 [Tab Navigation](#66-tab-navigation)
   - 6.7 [Result Passing Between Pages](#67-result-passing-between-pages)
7. [Dependency Injection](#7-dependency-injection)
   - 7.1 [DI Container](#71-di-container)
   - 7.2 [App Entry Point](#72-app-entry-point)
   - 7.3 [DI Principles](#73-di-principles)
8. [Error Handling](#8-error-handling)
   - 8.1 [Error Flow](#81-error-flow)
   - 8.2 [Error Types](#82-error-types)
   - 8.3 [Error Mapping](#83-error-mapping)
9. [Core Services & Utilities](#9-core-services--utilities)
   - 9.1 [StorageService](#91-storageservice)
   - 9.2 [DateService](#92-dateservice)
   - 9.3 [Null Safety Utilities](#93-null-safety-utilities)
   - 9.4 [Logger](#94-logger)
   - 9.5 [NetworkMonitor](#95-networkmonitor)
   - 9.6 [Validator](#96-validator)
   - 9.7 [ImageCache](#97-imagecache)
10. [Testing Strategy](#10-testing-strategy)
    - 10.1 [Test Pyramid](#101-test-pyramid)
    - 10.2 [Service Tests](#102-service-tests)
    - 10.3 [ViewModel Hook Tests](#103-viewmodel-hook-tests)
    - 10.4 [Repository Tests](#104-repository-tests)
    - 10.5 [Mapper Tests](#105-mapper-tests)
11. [Modular Architecture (Large-Scale)](#11-modular-architecture-large-scale)
    - 11.1 [When to Modularize](#111-when-to-modularize)
    - 11.2 [Module Structure (Turborepo)](#112-module-structure-turborepo)
    - 11.3 [Package Dependencies](#113-package-dependencies)
    - 11.4 [Package Configuration](#114-package-configuration)
    - 11.5 [Feature Module Public API](#115-feature-module-public-api)
    - 11.6 [App-Level Composition](#116-app-level-composition)
    - 11.7 [Cross-Feature Communication](#117-cross-feature-communication)
    - 11.8 [Benefits at Scale](#118-benefits-at-scale)
12. [Project Structure](#12-project-structure)
    - 12.1 [Single-App Layout (Starting Point)](#121-single-app-layout-starting-point)
13. [Conventions & Naming](#13-conventions--naming)
    - 13.1 [File & Type Naming](#131-file--type-naming)
    - 13.2 [Code Conventions](#132-code-conventions)
    - 13.3 [Feature Module Structure](#133-feature-module-structure)
14. [Design Decisions & Rationale](#14-design-decisions--rationale)
    - 14.1 [TanStack Query Over Custom Fetch Logic](#141-tanstack-query-over-custom-fetch-logic)
    - 14.2 [Custom Hooks as ViewModels Over Class-Based VMs](#142-custom-hooks-as-viewmodels-over-class-based-vms)
    - 14.3 [Next.js App Router Over Pages Router](#143-nextjs-app-router-over-pages-router)
    - 14.4 [No Base Hook / No Shared State Logic Inheritance](#144-no-base-hook--no-shared-state-logic-inheritance)
    - 14.5 [Services in Domain (Not a Separate Layer)](#145-services-in-domain-not-a-separate-layer)
    - 14.6 [Manual DI Over Frameworks](#146-manual-di-over-frameworks)
    - 14.7 [Interface-Based Mappers Over Utility Functions](#147-interface-based-mappers-over-utility-functions)
15. [Server vs Client Rendering Reference](#15-server-vs-client-rendering-reference)
    - 15.1 [Next.js Rendering Rules (Quick Recap)](#151-nextjs-rendering-rules-quick-recap)
    - 15.2 [Domain Layer — Isomorphic](#152-domain-layer--isomorphic)
    - 15.3 [Data Layer — Isomorphic Code, Split Instantiation](#153-data-layer--isomorphic-code-split-instantiation)
    - 15.4 [DI Layer — Strictly Split](#154-di-layer--strictly-split)
    - 15.5 [Presentation Layer — Mostly Client](#155-presentation-layer--mostly-client)
    - 15.6 [Navigation & App Directory](#156-navigation--app-directory)
    - 15.7 [Core Services — Mixed](#157-core-services--mixed)
    - 15.8 [Third-Party Libraries](#158-third-party-libraries)
    - 15.9 [Complete Rendering Map](#159-complete-rendering-map-quick-reference)
    - 15.10 [Common Mistakes to Avoid](#1510-common-mistakes-to-avoid)
- [Appendix A: Quick Reference Card](#appendix-a-quick-reference-card)
  - [Adding a New Feature](#adding-a-new-feature)
  - [Layer Import Rules](#layer-import-rules)
  - [Data Flow (Complete)](#data-flow-complete)

---

## 1. Overview

### What This Is

A reusable Next.js project starter kit built with **Clean Architecture** and **TypeScript**. Designed to bootstrap any new web frontend project with a solid, testable, and scalable foundation — following the same architectural principles as the SwiftUI StarterKit.

### Core Principles

| Principle | How |
|-----------|-----|
| **Clean Architecture** | Data → Domain → Presentation with strict dependency rules |
| **React-native patterns** | Custom hooks as ViewModels, Server Components where possible |
| **Modern TypeScript** | Strict typing, interfaces for boundaries, generics for reuse |
| **Interface-driven** | All layer boundaries defined by TypeScript interfaces for testability |
| **Dependencies** | TanStack Query for server state; Axios + axios-retry for networking; Zustand for global state |

### Minimum Requirements

- Node.js 20+
- Next.js 15+
- TypeScript 5.5+
- React 19+

### Key Architecture Choices

| Concern | Approach |
|---------|----------|
| UI Framework | Next.js 15 (App Router) + React 19 |
| Server State | TanStack Query (useQuery / useMutation) |
| Global State | Zustand |
| Navigation | Next.js App Router (file-based) + route constants |
| ViewModel | Custom hooks (`use[Feature]ViewModel`) |
| DI | Lightweight manual factory functions + React Context |
| Business Logic | Domain Services (pure TypeScript classes) |
| Networking | Axios + axios-retry |
| State | QueryState enum + TanStack Query states |

---

## 2. Architecture Layers

```
┌─────────────────────────────────────────────────────┐
│                 PRESENTATION LAYER                   │
│  React Components → ViewModel Hooks → Router        │
│  (Knows about: Domain)                              │
└──────────────────────┬──────────────────────────────┘
                       │ depends on
┌──────────────────────▼──────────────────────────────┐
│                   DOMAIN LAYER                       │
│  Entities, Repository interfaces, UseCases, Services │
│  (Knows about: nothing — innermost layer)           │
└──────────────────────┬──────────────────────────────┘
                       │ implemented by
┌──────────────────────▼──────────────────────────────┐
│                    DATA LAYER                        │
│  Repository impls, DataSources, DTOs, Mappers       │
│  (Knows about: Domain interfaces)                   │
└─────────────────────────────────────────────────────┘
```

### Dependency Rule

Inner layers never know about outer layers:
- **Domain** depends on nothing (entities, repository interfaces, use cases, services)
- **Data** implements Domain interfaces
- **Presentation** depends on Domain

---

