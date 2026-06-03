---
platform: web
project: web
discipline: engineering
topic: utilities
pattern: logger
---

## Theory

**Logger** is the centralized logging abstraction with severity levels. All log output goes through this interface.

**Invariants:**
- Severity levels: `debug`, `info`, `warning`, `error` — each with distinct routing (debug stripped in production)
- No `print` / `console.log` / `Log.d` calls at call sites — always use the Logger interface
- Sensitive data (tokens, PII) must never appear in log output
- The implementation routes to Crashlytics or the platform crash reporter for `error`-level events

**When to use:** Any layer that needs diagnostic output. Inject `Logger` — never call the platform logging API directly.

---

## Logger

Structured logging abstraction. Swap implementation per environment.

```typescript
// core/logger/Logger.ts
export type LogLevel = 'debug' | 'info' | 'warn' | 'error';

export interface Logger {
  debug(message: string, context?: Record<string, unknown>): void;
  info(message: string, context?: Record<string, unknown>): void;
  warn(message: string, context?: Record<string, unknown>): void;
  error(message: string, error?: Error, context?: Record<string, unknown>): void;
}

export class ConsoleLogger implements Logger {
  constructor(private readonly prefix = '[App]') {}

  debug(message: string, context?: Record<string, unknown>): void {
    if (process.env.NODE_ENV !== 'production') {
      console.debug(`${this.prefix} ${message}`, context ?? '');
    }
  }

  info(message: string, context?: Record<string, unknown>): void {
    console.info(`${this.prefix} ${message}`, context ?? '');
  }

  warn(message: string, context?: Record<string, unknown>): void {
    console.warn(`${this.prefix} ${message}`, context ?? '');
  }

  error(message: string, error?: Error, context?: Record<string, unknown>): void {
    console.error(`${this.prefix} ${message}`, error, context ?? '');
  }
}

// Singleton for app-wide logging
export const logger: Logger = new ConsoleLogger();
```
