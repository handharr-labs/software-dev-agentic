# View + Page Templates

## Client Component path (hook pattern)

### View
```typescript
// src/presentation/features/[feature]/[Feature]View.tsx
'use client';
import { useDI } from '@/di/DIContext';
import { use[Feature]ViewModel } from './use[Feature]ViewModel';

export function [Feature]View() {
  const { [verbFeature]UseCase } = useDI();
  const { data, isLoading, isError, errorMessage } = use[Feature]ViewModel({ [verbFeature]UseCase });

  if (isLoading) return <div>Loading...</div>;
  if (isError) return <div>{errorMessage ?? 'Something went wrong'}</div>;
  return ( /* render data */ );
}
```

### Page
```typescript
// src/app/[route]/page.tsx
import { [Feature]View } from '@/presentation/features/[feature]/[Feature]View';

export default function [Feature]Page() {
  return <[Feature]View />;
}
```

---

## Server Component path (build*ViewModel pattern)

### View (add 'use client' only if interactivity needed)
```typescript
// src/presentation/features/[feature]/[Feature]View.tsx
import type { [Feature]ViewModel } from './build[Feature]ViewModel';

interface Props {
  viewModel: [Feature]ViewModel;
}

export function [Feature]View({ viewModel }: Props) {
  const { [fields] } = viewModel;
  return ( /* render */ );
}
```

### Page (async Server Component)
```typescript
// src/app/[route]/page.tsx
import { [verb][Feature]UseCase } from '@/di/container.server';
import { build[Feature]ViewModel } from '@/presentation/features/[feature]/build[Feature]ViewModel';
import { [Feature]View } from '@/presentation/features/[feature]/[Feature]View';

export default async function [Feature]Page() {
  const data = await [verb][Feature]UseCase().execute({ /* params */ });
  const viewModel = build[Feature]ViewModel({ data });
  return <[Feature]View viewModel={viewModel} />;
}
```

---

## Route constant
```typescript
// src/presentation/navigation/routes.ts — add:
[feature]: '/[route]',
```
