> Template — seeds stub nodes for security threat models and control patterns.
> Each ## section → one ChromaDB node. Universal scope.

## Authentication
### Theory
_Stub — identity verification: token types, session lifecycle, multi-factor._
### Definition
_Stub — supported auth flows and token storage rules._
### Code Pattern
_Stub — canonical auth token handling._

## Authorization
### Theory
_Stub — access control: role-based, resource-based; enforcement points._
### Definition
_Stub — permission model and role taxonomy._
### Code Pattern
_Stub — canonical permission check._

## JWT Handling
### Theory
_Stub — JWT validation, expiry handling, refresh flow, storage rules._
### Definition
_Stub — required claims, validation checklist._
### Code Pattern
_Stub — canonical JWT refresh flow._

## Session Management
### Theory
_Stub — session lifetime, logout, token revocation, concurrent session rules._
### Code Pattern
_Stub — session cleanup on logout._

## API Security
### Theory
_Stub — HTTPS enforcement, rate limiting, input validation, CORS policy._
### Definition
_Stub — security headers required on all API responses._
### Code Pattern
_Stub — canonical secure API call._

## Secret Management
### Theory
_Stub — no secrets in code; vault / CI secrets management; rotation cadence._
### Definition
_Stub — secret classification and storage rules per environment._
### Code Pattern
_Stub — canonical secret access pattern._

## SQL Injection
### Theory
_Stub — parameterized queries only; ORM safe usage; never interpolate user input._
### Code Pattern
_Stub — safe query vs vulnerable query example._

## XSS Prevention
### Theory
_Stub — output encoding, CSP headers, safe HTML rendering rules._
### Code Pattern
_Stub — safe render vs vulnerable render example._

## Data Encryption
### Theory
_Stub — at-rest and in-transit encryption requirements; key management._
### Definition
_Stub — encryption algorithm standards and key rotation policy._
### Code Pattern
_Stub — canonical encryption call._

## Sensitive Data Handling
### Theory
_Stub — PII classification, masking in logs, data minimization rules._
### Definition
_Stub — PII field inventory and handling rules._
### Code Pattern
_Stub — canonical PII masking._

## Certificate Pinning
### Theory
_Stub — mobile certificate pinning; when required, how to implement, rotation process._
### Code Pattern
_Stub — canonical pinning setup per platform._

## Dependency Vulnerability Scanning
### Theory
_Stub — scanning cadence, severity thresholds, remediation SLA._
### Checklist
_Stub — scan on CI, block on critical, report on high, review weekly._
### Pass Criteria
_Stub — no critical vulnerabilities in production dependencies._
