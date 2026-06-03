---
platform: web
project: web
discipline: engineering
topic: utilities
pattern: image_cache
---

## ImageCache

Asynchronous image loading leveraging Next.js `<Image>` component and browser cache.

```typescript
// core/image/ImageCache.ts

// In Next.js, most image caching is handled by the <Image> component.
// This utility handles cases where you need programmatic image prefetching.

export interface ImageCache {
  preload(urls: string[]): void;
  clearCache(): void;
}

export class BrowserImageCache implements ImageCache {
  private cache = new Map<string, HTMLImageElement>();

  preload(urls: string[]): void {
    urls.forEach((url) => {
      if (this.cache.has(url)) return;
      const img = new Image();
      img.src = url;
      this.cache.set(url, img);
    });
  }

  clearCache(): void {
    this.cache.clear();
  }
}

// React hook for image loading state
export function useImage(src: string) {
  const [status, setStatus] = useState<'loading' | 'loaded' | 'error'>('loading');

  useEffect(() => {
    if (!src) { setStatus('error'); return; }
    const img = new Image();
    img.onload = () => setStatus('loaded');
    img.onerror = () => setStatus('error');
    img.src = src;
  }, [src]);

  return { isLoading: status === 'loading', isError: status === 'error', isLoaded: status === 'loaded' };
}
```
