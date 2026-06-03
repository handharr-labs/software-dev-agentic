---
platform: web
project: web
discipline: engineering
topic: domain
pattern: domain_error
---

## Theory

A **Domain Error** is the unified error type returned from all repository and use case operations. It decouples the domain from transport-layer error types (HTTP status codes, network errors).

**Invariants:**
- Domain operations return a Result/Either typed with the domain error — they never propagate raw network errors upward
- Repositories map transport errors to domain errors before returning
- Error codes are business-meaningful (`notFound`, `validationFailed`, `unauthorized`) — not HTTP status codes

---

## Domain Errors

```typescript
// domain/errors/DomainError.ts
export type DomainErrorCode =
  | 'notFound'
  | 'validationFailed'
  | 'unauthorized'
  | 'networkUnavailable'
  | 'serverError'
  | 'unknown';

export class DomainError extends Error {
  readonly code: DomainErrorCode;
  readonly context?: Record<string, unknown>;

  constructor(code: DomainErrorCode, context?: Record<string, unknown>) {
    super(code);
    this.name = 'DomainError';
    this.code = code;
    this.context = context;
  }

  static notFound(resource: string, id: string): DomainError {
    return new DomainError('notFound', { resource, id });
  }

  static validationFailed(field: string, reason: string): DomainError {
    return new DomainError('validationFailed', { field, reason });
  }

  static unauthorized(): DomainError {
    return new DomainError('unauthorized');
  }

  static networkUnavailable(): DomainError {
    return new DomainError('networkUnavailable');
  }

  static serverError(message: string): DomainError {
    return new DomainError('serverError', { message });
  }
}
```
