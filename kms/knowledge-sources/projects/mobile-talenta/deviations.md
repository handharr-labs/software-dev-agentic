# Architecture Deviations — flutter-mobile-talenta

Deviations from the standard flutter platform architecture (`lib/core/knowledge/flutter/`).

## Deviations

| # | Deviation | Location | Notes |
|---|---|---|---|
| 1 | **Split DI strategy** | Host app uses manual `GetIt.instance` registration in `TalentaDependency.registerDependencies()`; `talenta_module` uses `@injectable`/`@InjectableInit` codegen | Inconsistency between host and module DI approach |
| 2 | **Duplicate `GetIt.instance`** | Both `coreDependency` and `talentaDependency` are assigned to the same `GetIt.instance` | Could cause registration collisions; `allowReassignment = true` mitigates but is fragile |
| 3 | **Two distinct `Endpoint` classes with same simple name** | `talenta_account`, `talenta_tm`, `talenta_tnt`, `talenta_inbox`, `talenta_performance`, and `shared` each declare their own top-level `class Endpoint {}` — no common base | Name clash risk if ever imported together; no shared interface |
| 4 | **`isV2` bool parameter on `networkClient.get`** | `CustomFieldRemoteDataSource` calls `networkClient.get(isV2: true, Endpoint.customField)` — a positional-flag pattern mixing named and positional args in non-standard order | Inconsistent with the `getV2()` method used by other datasources |
| 5 | **Raw `status != HttpStatus.ok` / `status != 200` checks in datasource** | `BankAccountRemoteDataSourceImpl` and `TaskRemoteDataSourceImpl` throw `TalentaException` inline rather than delegating to the network error handler | Bypasses central error handling pipeline |
| 6 | **Announcement local datasource but no offline-first strategy elsewhere** | `AnnouncementLocalDatasource` caches announcements; no other feature has a local datasource — inconsistent offline support | |
| 7 | **Host app `pubspec.yaml` re-declares `mekari_pixel` and several `dependency_overrides`** | `talenta_module` already pins these; host app repeats them with identical refs — maintenance duplication | |
| 8 | **`network_inspector` ref conflict** | `talenta_module/pubspec.yaml` overrides `network_inspector` to `network_inspector-1.3.2` while declaring it at `1.4.0` in direct deps; host app overrides to `network_inspector-1.3.3` — three different ref tags for the same package | |
