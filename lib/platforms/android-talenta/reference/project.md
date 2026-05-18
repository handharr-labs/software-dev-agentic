# Android — Project Structure & Conventions

## Project Structure <!-- 30 -->

Feature modules follow this layout. Package prefix is `co.talenta.feature_[module]`:

```
feature_[module]/src/main/java/co/talenta/feature_[module]/
├── data/
│   ├── mapper/       [Entity]Mapper.kt          extends BaseMapper<Response, Entity>
│   ├── request/      [Action]Request.kt
│   └── response/     [Entity]Response.kt         all fields @SerializedName + nullable
├── di/
│   ├── [Module]Module.kt                          @Provides factory methods
│   └── [Module]ActivityModule.kt                  @ContributesAndroidInjector bindings
├── domain/
│   ├── entity/       [Entity].kt                  pure Kotlin data class
│   ├── repository/   [Module]Repository.kt        interface only
│   └── usecase/      [Action][Entity]UseCase.kt   extends SingleUseCase<T, Params>
├── presentation/
│   └── [feature]/
│       ├── [Feature]Contract.kt                   View : BaseMvpView + Presenter : BaseMvpPresenter<View>
│       ├── [Feature]Presenter.kt                  extends BasePresenter<View>
│       └── [Feature]Activity.kt                   extends BaseMvpVbActivity<Binding, Presenter>
└── service/
    └── [Module]Api.kt                             Retrofit interface
```

Shared modules: `domain/` and `data/` at project root for cross-feature entities/repositories.
Core libraries: `lib_core_[name]` (e.g. `lib_core_network`, `lib_core_helper`).
Base classes: `base/` module — `BaseMvpVbActivity`, `BaseMvpVbFragment`, `BasePresenter`.

## Conventions & Naming <!-- 14 -->

- Classes/interfaces/enums — PascalCase (`AttendancePresenter`)
- Methods/properties/variables — camelCase (`onCheckInClicked`)
- Constants — UPPER_SNAKE_CASE
- Resources — snake_case with component prefixes (`talenta_primary_button`)
- Test files — `*Test.kt`, placed in `src/test/` mirroring main source structure
- Test method naming — `test_given[Condition]_when[Action]_then[ExpectedResult]`
- Base classes: `BasePresenter`, `BaseMvpVbActivity<Binding, Presenter>`, `BaseMvpVbFragment`
- Contract base types: `BaseMvpView`, `BaseMvpPresenter<View>`
- Null-safety extensions — `com.mekari.commons.extension`: `.orEmpty()`, `.orZero()`, `.orFalse()`, `.orTrue()`
- Disposable cleanup — `addToDisposables()` (never `addToDisposeBag()`)
- Loading pattern — `doOnSubscribe { showLoading() }.doFinally { hideLoading() }`

## Build Commands <!-- 14 -->

```bash
./gradlew assembleDevelopDebug    # dev debug build
./gradlew assembleProdRelease     # production release
./gradlew test                    # all unit tests
./gradlew :feature_[name]:test    # per-module unit tests
./gradlew ktlint                  # check code style
./gradlew ktlintFormat            # auto-fix style
./gradlew detekt                  # static analysis
./gradlew lint                    # Android lint
./gradlew createDebugCoverageReport  # Jacoco coverage
```

## Key Dependencies <!-- 8 -->

- Kotlin 1.9.25, AGP 8.6.0, min SDK 23, target SDK 35
- DI: Dagger 2.50 (`@Module`, `@Provides`, `@ContributesAndroidInjector`)
- Async: RxJava 3.0.6 + RxAndroid
- Network: Retrofit 2, OkHttp 3, Gson, `RxJava3CallAdapterFactory`
- UI: ViewBinding (no `findViewById`), Mekari Pixel design system
- Testing: JUnit4, Mockito + mockito-kotlin, JUnitForger (Elmyr), BDDMockito
