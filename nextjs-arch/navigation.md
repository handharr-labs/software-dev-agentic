## 6. Navigation (Router)

### 6.1 Why Next.js App Router

The **Next.js App Router** is the standard navigation solution — file-based, type-safe with typed routes, and Server Component-first:

- **File-based** — Routes defined by folder structure in `app/`
- **Type-safe** — `next/navigation` + typed route constants eliminate typos
- **Server Components** — Data fetching at the server level reduces client bundle
- **Parallel routes** — Tabs, modals, and split-panes natively supported
- **Nested layouts** — Persistent UI across navigation (sidebars, tabs)

### 6.2 Route Constants

```typescript
// presentation/navigation/routes.ts
export const ROUTES = {
  // Auth
  login: '/login',
  forgotPassword: '/forgot-password',

  // Main
  home: '/',
  profile: '/profile',
  settings: '/settings',

  // Employee
  employeeList: '/employees',
  employeeDetail: (id: string) => `/employees/${id}`,
  employeeEdit: (id: string) => `/employees/${id}/edit`,

  // Leave
  leaveRequest: '/leave/request',
  leaveHistory: '/leave/history',
  leaveDetail: (id: string) => `/leave/${id}`,
} as const;

// Type-safe route params for dynamic routes
export interface EmployeeDetailParams {
  id: string;
}
```

### 6.3 AppRouter Hook

Wraps `next/navigation` with convenience methods. Consumed by ViewModel hooks for navigation actions.

```typescript
// presentation/navigation/useAppRouter.ts
'use client';

import { useRouter, usePathname, useSearchParams } from 'next/navigation';
import { ROUTES } from './routes';

export function useAppRouter() {
  const router = useRouter();
  const pathname = usePathname();
  const searchParams = useSearchParams();

  return {
    // Current state
    currentPath: pathname,
    searchParams,

    // Navigation actions
    push: (href: string) => router.push(href),
    replace: (href: string) => router.replace(href),
    back: () => router.back(),
    refresh: () => router.refresh(),

    // Typed route navigation
    goToLogin: () => router.push(ROUTES.login),
    goToEmployeeList: () => router.push(ROUTES.employeeList),
    goToEmployeeDetail: (id: string) => router.push(ROUTES.employeeDetail(id)),
    goToLeaveRequest: () => router.push(ROUTES.leaveRequest),
  };
}
```

### 6.4 Route Resolution (Page Components)

In Next.js, page components in the `app/` directory replace the `ViewFactory`. Each route is a file.

```typescript
// app/employees/page.tsx
import { EmployeeListView } from '@/presentation/features/employee-list/EmployeeListView';

export default function EmployeesPage() {
  return (
    <main>
      <h1 className="text-2xl font-bold mb-4">Employees</h1>
      <EmployeeListView />
    </main>
  );
}

// app/employees/[id]/page.tsx
import { EmployeeDetailView } from '@/presentation/features/employee-detail/EmployeeDetailView';

interface Props {
  params: Promise<{ id: string }>;
}

export default async function EmployeeDetailPage({ params }: Props) {
  const { id } = await params;
  return <EmployeeDetailView employeeId={id} />;
}
```

### 6.5 Root Layout with Navigation

```typescript
// app/layout.tsx  ← Server Component — no DIProvider here
import { QueryClientProvider } from '@/presentation/providers/QueryClientProvider';
import { Toaster } from '@/presentation/common/Toaster';

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body>
        <QueryClientProvider>
          {children}
          <Toaster />
        </QueryClientProvider>
      </body>
    </html>
  );
}

// app/(main)/layout.tsx  ← Client layout — DIProvider only where needed
'use client';
import { DIProvider } from '@/di/DIContext';

export default function MainLayout({ children }: { children: React.ReactNode }) {
  return (
    <DIProvider>
      <div className="flex flex-col min-h-screen">
        <main className="flex-1 pb-16">{children}</main>
        <BottomNav />
      </div>
    </DIProvider>
  );
}
```

### 6.6 Tab Navigation

```typescript
// app/(main)/layout.tsx — layout with persistent bottom nav
export default function MainLayout({ children }: { children: React.ReactNode }) {
  return (
    <div className="flex flex-col min-h-screen">
      <main className="flex-1 pb-16">{children}</main>
      <BottomNav />
    </div>
  );
}

// presentation/common/BottomNav.tsx
'use client';

import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { ROUTES } from '@/presentation/navigation/routes';

const tabs = [
  { href: ROUTES.home, label: 'Home', icon: 'home' },
  { href: ROUTES.employeeList, label: 'Employees', icon: 'users' },
  { href: ROUTES.leaveHistory, label: 'Leave', icon: 'calendar' },
  { href: ROUTES.profile, label: 'Profile', icon: 'user' },
];

export function BottomNav() {
  const pathname = usePathname();

  return (
    <nav className="fixed bottom-0 inset-x-0 bg-white border-t border-base-200">
      <div className="flex">
        {tabs.map((tab) => (
          <Link
            key={tab.href}
            href={tab.href}
            className={`flex-1 flex flex-col items-center py-2 text-xs ${
              pathname === tab.href ? 'text-primary' : 'text-base-content'
            }`}
          >
            <span>{tab.icon}</span>
            <span>{tab.label}</span>
          </Link>
        ))}
      </div>
    </nav>
  );
}
```

### 6.7 Result Passing Between Pages

```typescript
// Option 1: URL search params (for simple scalar results)
router.push(`${ROUTES.leaveRequest}?employeeId=${employee.id}`);

// Option 2: Zustand store (for complex cross-page state)
// stores/employeeSelectionStore.ts
import { create } from 'zustand';

interface EmployeeSelectionStore {
  selectedEmployee: Employee | null;
  setSelectedEmployee: (employee: Employee | null) => void;
}

export const useEmployeeSelectionStore = create<EmployeeSelectionStore>((set) => ({
  selectedEmployee: null,
  setSelectedEmployee: (employee) => set({ selectedEmployee: employee }),
}));

// Option 3: Callback via query param + sessionStorage (for modal flows)
// Caller writes callback key to sessionStorage, callee reads and resolves it
```

---

