---
platform: flutter
discipline: engineering
topic: navigation
pattern: deep_link
---

## Theory

**Deep Links** are external URLs or URIs that navigate directly to a specific in-app destination.

**Invariants:**
- URI schemes and host patterns declared in platform manifests/info.plist — not in application code
- Deep link paths match route constant definitions exactly — no separate deep-link-only paths
- Screen always has a fallback when extra/prefetched data is unavailable (e.g., fetch by ID from path parameter)
- Auth guard applies to deep-linked routes — unauthenticated deep links redirect to login first

**When to create:** When a feature destination must be reachable from a notification, email link, or external app. Added alongside the route constant for that destination.

---

go_router handles deep links automatically when incoming URIs match declared route paths. Native intent-filter / URL scheme registration is required; no extra Dart configuration needed beyond route definitions.

## Code Pattern

```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<intent-filter android:autoVerify="true">
  <action android:name="android.intent.action.VIEW" />
  <category android:name="android.intent.category.DEFAULT" />
  <category android:name="android.intent.category.BROWSABLE" />
  <data android:scheme="https" android:host="example.com" />
</intent-filter>
```

```xml
<!-- ios/Runner/Info.plist -->
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLSchemes</key>
    <array><string>https</string></array>
  </dict>
</array>
```

go_router routes that match the incoming URL are activated automatically. Ensure route paths align with the deep link URI paths:

```dart
GoRoute(
  path: '/employees/:id',
  builder: (context, state) => EmployeeScreen(
    employeeId: state.pathParameters['id']!,
  ),
),
```
