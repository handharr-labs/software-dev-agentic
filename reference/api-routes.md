## 18. API Route Handlers

Route Handlers (`app/api/*/route.ts`) are Next.js's HTTP server endpoints. They are **not** the default for full-stack features in this architecture — Server Actions cover own-UI mutations. Use Route Handlers only when the HTTP interface itself is the requirement.

### 18.1 When to Use Route Handlers vs Server Actions

| Scenario | Use |
|----------|-----|
| Form submission / mutation from own UI | Server Action |
| Reading data in a Server Component | Direct use case call (`container.server.ts`) |
| Webhook receiver (Stripe, GitHub, etc.) | Route Handler |
| File upload endpoint | Route Handler |
| Public REST API consumed by mobile apps or third parties | Route Handler |
| Server-Sent Events (SSE) / streaming | Route Handler |
| OAuth callback | Route Handler |

**Default to Server Actions.** Add Route Handlers only when you have one of the above reasons.

### 18.2 Route Handler Pattern

```typescript
// app/api/[feature]/route.ts
import { NextRequest, NextResponse } from 'next/server';
import { z } from 'zod';
import { getEmployeesUseCase } from '@/di/container.server';
import { DomainError } from '@/domain/errors/DomainError';

// GET /api/employees?page=1&limit=20
export async function GET(request: NextRequest) {
  const { searchParams } = request.nextUrl;

  const params = getEmployeesSchema.safeParse({
    page: Number(searchParams.get('page') ?? 1),
    limit: Number(searchParams.get('limit') ?? 20),
  });

  if (!params.success) {
    return NextResponse.json(
      { error: 'Invalid parameters', details: params.error.flatten() },
      { status: 400 }
    );
  }

  try {
    const result = await getEmployeesUseCase().execute(params.data);
    return NextResponse.json({ data: result });
  } catch (error) {
    return handleRouteError(error);
  }
}

const getEmployeesSchema = z.object({
  page: z.number().int().min(1).default(1),
  limit: z.number().int().min(1).max(100).default(20),
});
```

### 18.3 Shared Error Handler

Centralize Route Handler error responses — do not inline try/catch error formatting in every handler:

```typescript
// lib/route-error.ts
import { NextResponse } from 'next/server';
import { DomainError } from '@/domain/errors/DomainError';

export function handleRouteError(error: unknown): NextResponse {
  if (error instanceof DomainError) {
    const status = domainErrorToStatus(error.code);
    return NextResponse.json({ error: error.message }, { status });
  }
  // Never leak internal error details in production
  if (process.env.NODE_ENV === 'development') {
    return NextResponse.json({ error: String(error) }, { status: 500 });
  }
  return NextResponse.json({ error: 'Internal server error' }, { status: 500 });
}

function domainErrorToStatus(code: string): number {
  const map: Record<string, number> = {
    unauthorized: 401,
    forbidden: 403,
    notFound: 404,
    conflict: 409,
    badRequest: 400,
    serverError: 500,
  };
  return map[code] ?? 500;
}
```

### 18.4 Webhook Pattern

```typescript
// app/api/webhooks/stripe/route.ts
import { NextRequest, NextResponse } from 'next/server';
import { headers } from 'next/headers';

export async function POST(request: NextRequest) {
  const body = await request.text(); // raw body needed for signature verification
  const signature = (await headers()).get('stripe-signature');

  // Verify webhook signature before processing
  if (!signature) {
    return NextResponse.json({ error: 'Missing signature' }, { status: 400 });
  }

  // Verify + parse event (use your payment provider's SDK)
  // const event = stripe.webhooks.constructEvent(body, signature, process.env.STRIPE_WEBHOOK_SECRET!);

  // Handle event type, call relevant use case
  // switch (event.type) { ... }

  return NextResponse.json({ received: true });
}

// Disable Next.js body parsing for webhook routes (raw body required for HMAC verification)
export const runtime = 'nodejs';
```

### 18.5 Response Shape Convention

All Route Handlers return consistent shapes:

```typescript
// Success:
{ data: T }                                    // single resource or collection
{ data: T, meta: { page, limit, total } }      // paginated collection

// Error:
{ error: string }                              // simple error message
{ error: string, details: ZodFlattenedErrors } // validation errors
```

### 18.6 Authentication in Route Handlers

```typescript
import { getServerSession } from 'next-auth';
import { authOptions } from '@/lib/auth';

export async function POST(request: NextRequest) {
  const session = await getServerSession(authOptions);
  if (!session?.user) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
  }
  // proceed with session.user.id
}
```

### 18.7 File Locations

```
src/app/api/
├── [feature]/
│   └── route.ts              ← collection: GET (list), POST (create)
├── [feature]/[id]/
│   └── route.ts              ← resource: GET (single), PUT (update), DELETE
└── webhooks/
    └── [provider]/
        └── route.ts          ← webhook receivers
```

---
