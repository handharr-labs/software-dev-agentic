## Route Constants

Each feature defines a `<Feature>RouteName` class with a `prefix` constant and named route constants derived from it. All route names are prefixed to avoid collisions across features.

```dart
class Jurnal<Feature>RouteName {
  static const String prefix = '/jurnal_<feature>';

  static const String main = prefix;
  static const String <featureDetail> = '${prefix}_detail';
  static const String <featureUpsert> = '${prefix}_upsert';
  // pattern: '${prefix}_<screen_variant>'
}
```

**Conventions:**
- Class name: `Jurnal<Feature>RouteName` (e.g. `JurnalProductRouteName`)
- `prefix` constant is the root route for this feature module
- Derived routes concatenate `'${prefix}_<variant>'`

---

## Navigator

Navigation is handled via a feature-level route factory function `getJurnal<Feature>RouteByName`. This function is passed to the host app's `onGenerateRoute` mechanism. No named router package is used — vanilla Flutter `Navigator`.

```dart
Widget getJurnal<Feature>RouteByName(String? name, dynamic arguments) {
  switch (name) {
    case Jurnal<Feature>RouteName.<featureDetail>:
      return <Feature>DetailScreen(argument: arguments as <Feature>DetailArgument);
    case Jurnal<Feature>RouteName.<featureUpsert>:
      return <Feature>UpsertScreen(argument: arguments as <Feature>UpsertArgument?);
    case Jurnal<Feature>RouteName.main:
    default:
      return const <Feature>Screen();
  }
}
```

**Conventions:**
- Function name: `getJurnal<Feature>RouteByName(String? name, dynamic arguments)`
- Each case casts `arguments` to the typed argument class for that screen
- Default case returns the feature's main screen
- Arguments are strongly typed data classes (defined in `argument.dart` as a `part` of the screen)
- Navigation call sites use `Navigator.of(context).pushNamed(Jurnal<Feature>RouteName.<screen>, arguments: <Argument>(...))` 
