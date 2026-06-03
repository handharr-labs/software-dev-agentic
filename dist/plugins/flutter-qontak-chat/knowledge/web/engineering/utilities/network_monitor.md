---
platform: web
project: web
discipline: engineering
topic: utilities
pattern: network_monitor
---

## NetworkMonitor

Connectivity state observation using the browser's `navigator.onLine` and `online`/`offline` events.

```typescript
// core/network/NetworkMonitor.ts
export type NetworkStatus = 'online' | 'offline';

export interface NetworkMonitor {
  readonly status: NetworkStatus;
  subscribe(callback: (status: NetworkStatus) => void): () => void;
}

export class BrowserNetworkMonitor implements NetworkMonitor {
  get status(): NetworkStatus {
    return typeof navigator !== 'undefined' && !navigator.onLine ? 'offline' : 'online';
  }

  subscribe(callback: (status: NetworkStatus) => void): () => void {
    const handleOnline = () => callback('online');
    const handleOffline = () => callback('offline');

    window.addEventListener('online', handleOnline);
    window.addEventListener('offline', handleOffline);

    return () => {
      window.removeEventListener('online', handleOnline);
      window.removeEventListener('offline', handleOffline);
    };
  }
}

// React hook
// core/network/useNetworkStatus.ts
import { useState, useEffect } from 'react';

export function useNetworkStatus(monitor = new BrowserNetworkMonitor()) {
  const [status, setStatus] = useState<NetworkStatus>(monitor.status);

  useEffect(() => {
    const unsubscribe = monitor.subscribe(setStatus);
    return unsubscribe;
  }, [monitor]);

  return { isOnline: status === 'online', status };
}
```
