# Mock Template

```typescript
// __tests__/mocks/Mock[InterfaceName].ts
import { vi } from 'vitest';
import type { [InterfaceName] } from '@/[path-to-interface]';

export class Mock[InterfaceName] implements [InterfaceName] {
  [methodOne] = vi.fn<Parameters<[InterfaceName]['[methodOne]']>, ReturnType<[InterfaceName]['[methodOne]']>>();
  [methodTwo] = vi.fn<Parameters<[InterfaceName]['[methodTwo]']>, ReturnType<[InterfaceName]['[methodTwo]']>>();
  // one line per interface method
}
```

