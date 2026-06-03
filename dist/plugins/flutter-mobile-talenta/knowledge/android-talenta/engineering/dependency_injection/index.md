# dependency_injection — android-talenta

| Pattern | Description |
|---|---|
| `activity_binding` | `@ContributesAndroidInjector` wires Dagger injection for an Activity and its feature module. |
| `di_module` | Feature `@Module` with `@Provides` bindings — leaf-first: API → Mapper → Repository. |
| `di_principles` | Constructor injection preferred; field injection only for Activities/Fragments; modules in `di/` package. |
| `registration_order` | Leaf-first: Infrastructure → Mappers → Repositories → Use Cases — matches the dependency graph. |
| `scope_rules` | `@Singleton` for shared infra; `@ActivityScoped` for Presenters; unscoped (default) for stateless mappers. |
| `testing_with_di` | Bypass Dagger in unit tests — construct directly with `@Mock` dependencies; never share Dagger component across test classes. |
