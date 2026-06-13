# Mekari Pixel — iOS Design System Catalog

## Package Info

- **Platform:** iOS (UIKit). Distributed as a CocoaPod.
- **Podspec:** `MekariPixel.podspec`
- **Prefix:** `MP` (e.g. `MPButton`, `MPTextField`, `MPToast`)
- **Bundle identifier:** `.mekariPixelBundle` (used for asset/font loading)
- **Dependencies:** RxSwift, RxCocoa, SnapKit, FloatingPanel
- **Source path:** `../talenta-ios/MekariPixel/MekariPixel/`

---

# Design Tokens

## Colors — `MPColor`

All tokens are `static var` on `public class MPColor`. Access via `MPColor.<name>`.

### Neutral / Gray

| Token | Hex | Usage |
|---|---|---|
| `MPColor.white` | `#FFFFFF` | Backgrounds, cards |
| `MPColor.black` | `#000000` | — |
| `MPColor.dark` | `#232933` | Default text color |
| `MPColor.gray25` | `#F8F9FB` | Subtle backgrounds |
| `MPColor.gray50` | `#EDF0F2` | Disabled backgrounds |
| `MPColor.gray100` | `#D0D6DD` | Dividers, borders |
| `MPColor.gray200` | `#BFC5CE` | — |
| `MPColor.gray300` | `#A8AFB9` | — |
| `MPColor.gray400` | `#8B95A5` | Placeholder, disabled text |
| `MPColor.gray500` | `#77808F` | — |
| `MPColor.gray600` | `#626B79` | Ghost button text, secondary text |
| `MPColor.gray700` | `#4D5562` | — |
| `MPColor.gray800` | `#38404C` | — |
| `MPColor.gray900` | `#232933` | Same as `dark` |
| `MPColor.background` | `#F2EFED` | Screen / page background |
| `MPColor.overlay` | `#232933` @ 80% | Modal overlays |
| `MPColor.shimer` | `#E7E7E7` | Skeleton / shimmer |
| `MPColor.ash100` | `#E7EDF5` | — |

### Blue (Primary / Brand)

| Token | Hex | Usage |
|---|---|---|
| `MPColor.blue50` | `#EAECFB` | Pressed secondary button bg |
| `MPColor.blue100` | `#D5DEFF` | — |
| `MPColor.blue400` | `#4B61DD` | Primary button, active indicator |
| `MPColor.blue500` | `#1C44D5` | Pressed primary button, focus border |
| `MPColor.blue600` | `#1E40AF` | — |
| `MPColor.blue700` | `#0031BE` | — |
| `MPColor.iconBrand` | `#4B61DC` | Selected tab icon, selected text |
| `MPColor.textSelected` | `#4B61DC` | Same as iconBrand |

### Red (Danger / Error)

| Token | Hex | Usage |
|---|---|---|
| `MPColor.red50` | `#FDECEE` | Error backgrounds |
| `MPColor.red400` | `#DA473F` | Error divider, error icon, danger button |
| `MPColor.red500` | `#C83E39` | Pressed danger button |
| `MPColor.red600` | `#DC2626` | — |
| `MPColor.red700` | `#AB3129` | — |
| `MPColor.talenta` | `#F22929` | Talenta brand color |

### Green (Success)

| Token | Hex | Usage |
|---|---|---|
| `MPColor.green50` | `#E8F5EB` | Success backgrounds |
| `MPColor.green400` | `#68BE79` | — |
| `MPColor.green500` | `#4FB262` | Success toast border |
| `MPColor.green600` | `#16A34A` | — |
| `MPColor.green700` | `#3C914D` | — |

### Orange (Warning)

| Token | Hex | Usage |
|---|---|---|
| `MPColor.orange50` | `#FBF3DD` | — |
| `MPColor.orange400` | `#E0AB00` | — |
| `MPColor.orange500` | `#DE9400` | Warning toast border |
| `MPColor.orange600` | `#EA580C` | — |
| `MPColor.orange700` | `#DB8000` | — |
| `MPColor.orange900` | `#7C2D12` | — |
| `MPColor.backgroundWarning` | `#FDF6DD` | Warning state backgrounds |
| `MPColor.iconWarning` | `#E46910` | Warning icon color |

### Semantic / Role Colors

| Token | Hex | Usage |
|---|---|---|
| `MPColor.textDefault` | `#272B32` | Body text default |
| `MPColor.iconDefault` | `#758195` | Unselected tab icons |
| `MPColor.textSelected` | `#4B61DC` | Active/selected text |

### Extended Palette

| Token | Hex |
|---|---|
| `MPColor.sky100` | `#60A5FA` |
| `MPColor.sky400` | `#3B82F6` |
| `MPColor.teal100` | `#2DD4BF` |
| `MPColor.teal400` | `#1FB8A6` |
| `MPColor.violet100` | `#A78BFA` |
| `MPColor.violet400` | `#8B5CF6` |
| `MPColor.purple50` | `#FAF5FF` |
| `MPColor.purple700` | `#7E22CE` |
| `MPColor.purple900` | `#581C87` |
| `MPColor.amber100` | `#FBBF24` |
| `MPColor.amber400` | `#F59E0B` |
| `MPColor.rose100` | `#F87171` |
| `MPColor.rose400` | `#EF4444` — badge background |
| `MPColor.stone100` | `#A1A1AA` |
| `MPColor.stone400` | `#71717A` |
| `MPColor.lime100` | `#A3E635` |
| `MPColor.lime400` | `#84CC16` |
| `MPColor.pink100` | `#F472B6` |
| `MPColor.pink400` | `#EC4899` |
| `MPColor.ice50` | `#E0EEFF` |
| `MPColor.ice100` | `#B4D3F2` |
| `MPColor.apricot400` | `#F97316` |
| `MPColor.leaf400` | `#22C55E` |
| `MPColor.aqua100` | `#22D3EE` |
| `MPColor.chartCat01Bold` | `#387CEB` |
| `MPColor.chartCat06Bold` | `#E2483D` |

### Mekari Product Colors

| Token | Hex | Product |
|---|---|---|
| `MPColor.Mekari` | `#651FFF` | Mekari |
| `MPColor.capital` | `#2F5573` | Mekari Capital |
| `MPColor.eSign` | `#00C853` | e-Sign |
| `MPColor.expense` | `#183883` | Expense |
| `MPColor.flex` | `#7C4DFF` | Flex |
| `MPColor.jurnal` | `#40C3FF` | Jurnal |
| `MPColor.klikPajak` | `#FF9100` | KlikPajak |
| `MPColor.qontak` | `#2979FF` | Qontak |
| `MPColor.university` | `#448AFF` | University |

---

## Typography — `MPTextStyle`

Font family: **Inter** (loaded via `UIFont.loadFonts()` at app start — call once in AppDelegate).

### Text Roles

| Role (enum case) | Size | Line Height | Default Weight | Notes |
|---|---|---|---|---|
| `.largeTitle` | 24pt | 32pt | SemiBold | Center aligned by default |
| `.sectionTitle` | 20pt | 28pt | SemiBold | Center aligned by default |
| `.label` | 16pt | 24pt | Regular or SemiBold | Left aligned by default |
| `.body` | 14pt | 20pt | Regular or SemiBold | Left aligned by default |
| `.caption` | 12pt | 16pt | Regular or SemiBold | Left aligned by default |
| `.captionSmall` | 11pt | 14pt | Regular or SemiBold | Left aligned by default |
| `.overline` | 10pt | 12pt | Regular or SemiBold | Left aligned by default |

### Font Styles — `MPFontStyle`

| Case | Effect |
|---|---|
| `.semibold` | Inter SemiBold weight |
| `.regular` | Inter Regular weight |
| `.textlink` | Underline with `MPColor.sky400` |
| `.strike` | Strikethrough with `MPColor.dark` |

### Usage

```swift
// Applying to UILabel
label.setupLabel(text: "Hello", with: .body(style: .regular, color: MPColor.dark))

// Inline init
let label = UILabel(text: "Title", with: .sectionTitle(color: MPColor.dark))

// Mixed styles
label.setupLabel(
    text: "Click here to learn more",
    with: .body(style: .regular),
    substring: "here",
    substyle: .body(style: .textlink, color: MPColor.blue400)
)

// UIView extension (works on UILabel, UIButton, UITextField, UITextView)
view.setText(text: "Value", with: .label(style: .semibold), substring: nil, substyle: nil)

// Load fonts (call once)
UIFont.loadFonts()
```

---

# Components

## MPButton

**File:** `Components/Button/MPButton.swift`  
**Base:** `UIButton`

### Variants — `ButtonVariants`

| Variant | Enabled bg | Enabled text | Pressed bg | Disabled bg |
|---|---|---|---|---|
| `.Primary` | `blue400` | white | `blue500` | `gray50` |
| `.Secondary` | white | `blue400` | `blue50` | `gray50` |
| `.Ghost` | clear | `gray600` | `gray50` | clear |
| `.Danger` | `red400` | white | `red500` | `gray50` |
| `.Custom` | clear | clear | — | clear |

### Style — `ButtonStyle`

| Style | Layout |
|---|---|
| `.Basic` | Text only |
| `.LeftIcon(icon:)` | Icon left of text |
| `.RightIcon(icon:)` | Icon right of text |
| `.LeftTitleRightIcon(icon:)` | Title left-aligned, icon pinned right |

### State — `ButtonState`

| State | Behavior |
|---|---|
| `.Default` | Interactive, full color |
| `.Disable` | `isEnabled = false`, muted colors |

### Init

```swift
let button = MPButton(
    title: "Submit",
    fontText: .label(style: .semibold),
    variants: .Primary,
    style: .Basic,
    state: .Default
) { btn in
    // tap handler
}
```

### Loading

```swift
button.showButtonLoadingIndicatorAtCenter()
button.hideButtonLoadingIndicator()

// RxSwift binding
viewModel.isLoading.bind(to: button.rx.isAnimating).disposed(by: disposeBag)
```

### Layout constants

- `cornerRadius`: 12pt
- Button height: 48pt (enforced by `MPActionGroup`)

---

## MPActionGroup

**File:** `Components/Action Group/MpActionGroup.swift`  
**Base:** `UIView`

Container that stacks 1–3 `MPButton` instances vertically with 8pt spacing. Each button is constrained to 48pt height.

```swift
let group = MPActionGroup(type: .doubleBtn(
    firstBtn: MPButton(title: "Confirm", variants: .Primary, style: .Basic, state: .Default),
    secondBtn: MPButton(title: "Cancel", variants: .Ghost, style: .Basic, state: .Default)
))
```

### Types — `ActionGroupType`

| Type | Buttons |
|---|---|
| `.singleBtn(firstBtn:)` | 1 button |
| `.doubleBtn(firstBtn:secondBtn:)` | 2 buttons |
| `.tripleBtn(firstBtn:secondBtn:thirdButton:)` | 3 buttons |

---

## MPTextField

**File:** `Components/TextField/MPTextField.swift`  
**Base:** `UIView`

Floating-label text field with optional icon, prefix/suffix, helper text, divider, and inline error display.

### Types — `MPTextFieldType`

| Type | Behavior |
|---|---|
| `.normal` | Interactive, white background |
| `.disabled` | Non-interactive, `gray50` background |
| `.password` | Secure entry, show/hide eye toggle |

### Init

```swift
let field = MPTextField(
    title: "Email",
    helperText: "We'll never share your email",
    placeholderText: "Enter email...",
    type: .normal,
    leftIcon: MPAssets.Icon.EnvelopeIcon.outline,
    prefixText: nil,
    suffixText: nil,
    focusable: true,
    shouldShowError: { text in
        let invalid = !text.contains("@")
        return (isError: invalid, message: "Enter a valid email")
    },
    defaultValue: nil,
    isRequired: true
)
```

### Key public API

```swift
// Validation
field.setErrorValidator { text in (isError: text.isEmpty, message: "Required") }
field.setErrorValidationEnabled(true)
field.showErrorMessage(messageText: "Something went wrong")
field.refreshValidationState()

// Character limits
field.setMaxCharacterLimit(100, errorMessage: "Too long", shouldEnforce: true, showErrorWhenLimitReached: false)

// Type change
field.setType(type: .disabled)

// Input filtering
field.setAllowedCaracterSet(with: .decimalDigits)
field.setTextValidator(with: .taskOutputProgress)

// UI
field.hideDividerWhenUnfocused()

// RxSwift
field.rx.text           // ControlProperty<String?>
field.rx.value          // ControlProperty<String?> — also drives float label
field.rx.errorMessage   // Binder<String?> — shows/hides error under divider
field.onTextChangedEvent  // PublishSubject<String>
field.onFocusEvent        // PublishRelay<Void>
```

### Divider colors by state

| State | Color |
|---|---|
| Focused | `blue400` |
| Error | `red400` |
| Default | `gray100` |

---

## MPSelect

**File:** `Components/MPSelect/MPSelect.swift`  
**Base:** `UIView`

Read-only dropdown trigger (floating label + chevron icon + divider). Tap triggers `onTapView` — caller presents a bottom sheet. Supports tag-style multi-select display via `MPSelectTag`.

### Types — `MPSelectType`

| Type | Label color | Background |
|---|---|---|
| `.normal` | `dark` | clear |
| `.disabled` | `gray400` | `gray50` |

---

## MPSearch

**File:** `Components/Search/MPSearch.swift`  
**Base:** `UIView`  
**Height:** 56pt

Search bar with optional Cancel and Filter buttons, 1000ms debounce on text changes.

```swift
let search = MPSearch()
search.hintText = "Search employee..."
search.isHasCancel = true
search.isHasFilter = false
search.onSearchTextChanged = { text in /* debounced */ }
search.onCancelTapped = { /* handle */ }
search.onFilterTapped = { /* handle */ }
```

### Key properties

| Property | Type | Default |
|---|---|---|
| `hintText` | `String` | `"Search..."` |
| `cancelText` | `String` | `"Cancel"` |
| `filterText` | `String` | `"FIlter"` |
| `isReadOnly` | `Bool` | `false` |
| `isHasCancel` | `Bool` | `true` |
| `isHasFilter` | `Bool` | `true` |
| `searchBarImage` | `UIImage?` | search outline icon |

Border turns `blue500` on focus, `gray600` on blur.

---

## MPToast

**File:** `Components/Toast/MPToast.swift`

Static utility. Shows a toast pinned to the bottom safe area that auto-dismisses after 3 seconds.

```swift
MPToast.show(self, message: "Saved successfully", type: .success)
MPToast.show(self, message: "Upload failed", type: .error, maxLine: 2, bottomMargin: 80)
```

### Types — `ToastType`

| Type | Border color | Icon |
|---|---|---|
| `.info` | `blue500` | `ic-info-duotone` |
| `.error` | `red500` | `ic-error-duotone` |
| `.success` | `green500` | `ic-done-duotone` |
| `.warning` | `orange500` | `ic-warning-triangle-duotone` |

Layout: white rounded card (radius 8), 1pt colored border, icon 24×24, 16pt horizontal margins.

---

## MPDialog

**File:** `Components/Dialog/MpDialog.swift`  
**Base:** `UIViewController` (presented modally with `.overCurrentContext`)

Modal alert dialog with title, message, and up to 3 action buttons.

```swift
let dialog = MPDialog(title: "Delete Record?", message: "This cannot be undone.")
dialog.addAction(MPDialogAction(title: "Delete", style: .primaryDanger) { dialog in
    // confirm
})
dialog.addAction(MPDialogAction(title: "Cancel", style: .ghost, action: nil))
dialog.enableOverlayDismissal = true
present(dialog, animated: true)
```

### Action styles — `MPDialogActionStyle`

| Style | Background | Text color |
|---|---|---|
| `.primary` | `blue400` | white |
| `.primaryDanger` | `red400` | white |
| `.secondary` | white + 1pt `gray100` border | `blue400` |
| `.ghost` | clear | `gray600` |

Layout: white container (radius 16), title section with `background` (#F2EFED) header bg.

---

## MPBottomSheet

**File:** `Components/Bottom Sheet/MPBottomSheet.swift`  
**Dependency:** FloatingPanel

Static utility for presenting bottom sheets. Three main entry points:

```swift
// Fire-and-forget (no result)
MPBottomSheet.showBottomSheet(self, headerTitle: "Select Period", ...)

// Observable result (RxSwift)
MPBottomSheet.showSheet(self, headerTitle: "Pick Status", dataList: items, ...)
    .subscribe(onNext: { result in /* handle selection */ })
    .disposed(by: disposeBag)

// Custom content (any UIView)
MPBottomSheet.showEmptySheet(self, headerTitle: "Filters", contentView: filterView)
    .subscribe(...)
    .disposed(by: disposeBag)

// Get the FloatingPanelController without presenting
let panel = MPBottomSheet.getBottomSheet(...)
```

### Sheet types — `BottomSheetType`

| Type | Content |
|---|---|
| `.BaseOnly(contentView:)` | Arbitrary `UIView` |
| `.SingleSelect` | Single-tap selection list |
| `.MultipleSelect` | Checkbox multi-select list |

### Result — `MPBottomSheetListResult`

Emitted on Done tap, carries selected `[MPBottomSheetListProtocol]` items.

### Layout constants

- Corner radius: 12pt, horizontal inset: 4pt from safe area
- Default cell height: 48pt, empty state: 264pt height

---

## MPTabBarViewController

**File:** `Components/Tab Bar/MPTabBarViewController.swift`  
**Base:** `UIViewController`

Horizontally scrollable or fixed tab bar with page content. Tabs support icons, badges, and custom indicator color.

```swift
let tabs = MPTabBarViewController(
    subControllers: [
        (title: "Home", controller: HomeVC(), image: MPAssets.Icon.HomeIcon.outline, selectedImage: MPAssets.Icon.HomeIcon.fill),
        (title: "Inbox", controller: InboxVC(), image: MPAssets.Icon.InboxIcon.outline, selectedImage: MPAssets.Icon.InboxIcon.fill)
    ],
    type: .fixed
)
```

### Types — `MPTabBarType`

| Type | Behavior |
|---|---|
| `.fixed` | Each tab takes equal width |
| `.scrollable` | Tab width sized to content |

### Key API

```swift
tabs.selectViewController(at: 1, animated: true)
tabs.setBadgesForIndex(at: 0, with: 5)
tabs.hideHeader()
tabs.showHeader()
tabs.disableSwipeable()
tabs.onIndexChanges = { index in /* */ }
tabs.headerBackgroundColor = MPColor.white
```

Indicator color: `MPColor.blue400`. Separator: 1pt `gray100`.

---

## Bottom Navigation Bar

**File:** `Components/BottomNavbar/BottomNavbar.swift`  
Extensions on `UITabBar` and `UITabBarItem`.

```swift
// Apply Pixel styling to UITabBar
tabBar.setPrimaryAppearance()

// Tab bar item badge
tabBarItem.setBadgeValue(with: "3")

// Tab bar item text styling
tabBarItem.setTabBarTextStyle()
```

Colors: unselected `iconDefault` (#758195), selected `iconBrand` (#4B61DC). Badge background: `rose400`.

---

## App Bar

**File:** `Components/App Bar/`  
**Base class:** `MPBaseAppBar: UIView`

| Class | Purpose |
|---|---|
| `MPBaseAppBar` | Base class — background, shadow, height |
| `MPTextAppBar` | Title + optional back/action buttons |
| `MPSearchAppBar` | App bar with embedded search |
| `MPLogoAppBar` | Logo-centered bar |
| `MPProfileAppBar` | Profile avatar bar |
| `MPEmptyAppBar` | Transparent/empty bar |

### MPBaseAppBar properties

```swift
appBar.bgColor = MPColor.white
appBar.bgOpacity = 1.0
appBar.height = 56          // pt
appBar.elevation = 0.0      // shadow radius
```

Embed in VC via `MPBaseViewController` subclass.

---

## MPDatePickerView

**File:** `Components/DatePicker/MPDatePickerView.swift`

Custom date picker rendered as a table view. Used inside bottom sheets for native-style wheel or flat list date selection.

---

# Assets

## Icons — `MPAssets.Icon`

Each icon group has `.outline`, `.duoTone`, `.fill` variants unless noted.  
Access: `MPAssets.Icon.<Group>.<variant>` → `UIImage?`

### Alert icons

`DoneIcon`, `ErrorIcon`, `HelpIcon`, `InfoIcon`, `PendingIcon`, `ProgressIcon`, `CircularWarningIcon`, `TriangleWarningIcon`  
`PriorityIcon` (`.high`, `.medium`, `.low`)

### Document icons

`BlankIcon`, `CopyIcon`, `DocIcon`, `FolderCloseIcon`, `FolderOpenIcon`, `IdCardIcon`, `ImageIcon`, `PdfIcon`, `ZipIcon`  
`DocumentIcon` (`.image`, `.pdf`, `.word`, `.excel`)  
`FileAudioIcon`, `FileCodeIcon`, `FileImageIcon`, `FileVideoIcon`, `FileMusicIcon`

### Interface / Essential icons

`AddCircularIcon`, `ArrowIcon` (up/down/left/right), `AttachmentIcon`, `BackspaceIcon`, `BurgerIcon` (left/right), `CalendarIcon`, `CameraIcon`, `CaretIcon` (up/down/right), `ChevronIcon` (up/down/left/right), `CollapseIcon`, `DeleteIcon`, `DownloadIcon`, `EditIcon`, `EmptyIcon`, `EmojiIcon`, `ExpandIcon`, `FaceIdIcon`, `FallbackIcon`, `FingerprintIcon`, `FlashOnIcon`, `FlashOffIcon`, `FlipCameraIcon`, `ForwardIcon`, `HelpCenterIcon`, `HideIcon`, `IndicatorIcon` (square/circle), `JumpIcon` (previous/forward), `LinkIcon` (internal/external), `MinusCircularIcon`, `MoveTaskIcon`, `NewTabIcon`, `PaintBucketIcon`, `PauseIcon`, `PinIcon`, `RedoIcon`, `RefreshIcon`, `ReplyIcon`, `SearchIcon`, `SettingIcon`, `ShowIcon`, `SignInIcon`, `SignOutIcon`, `SortIcon` (list/ascending/descending/default), `TableViewColumnIcon`, `TableViewFieldIcon`, `TableViewFilterIcon`, `TableViewListIcon`, `TableViewSortIcon`, `TaskIcon`, `TextEditorIcon`, `TimeIcon`, `UndoIcon`, `UploadIcon`, `VerifiedIcon`

Single-image icons: `addIcon`, `applyAllIcon`, `checkIcon`, `closeIcon`, `cropIcon`, `dragIcon`, `fitIcon`, `fullscreenIcon`, `loaderIcon`, `menuKebabIcon`, `menuMeatballIcon`, `minusIcon`, `resetIcon`, `shortcutIcon`, `sliderIcon`, `taskDoneIcon`, `taskInReviewIcon`, `taskOnProgressIcon`, `taskTodoIcon`

### Feature icons

`AnnouncementIcon` / `Announcement`, `Apps`, `BriefcaseIcon`, `ChartOfAccountIcon`, `CommmentIcon`, `ConnectedAppIcon`, `EmployeeIcon`, `EmploymentIcon`, `EnvelopeIcon` / `EnvelopeFeature`, `ExpenseIcon`, `FilterIcon`, `GoalIcon`, `HomeIcon`, `InboxIcon`, `LocationIcon`, `MutedIcon`, `NotificationIcon`, `OrganizationsIcon`, `OvertimeIcon`, `PayslipIcon`, `PeopleIcon`, `PerformanceIcon`, `PhoneIcon` / `PhoneFeature`, `PlayVideoIcon`, `ProfileIcon`, `ReimbursementIcon`, `SecurityIcon` / `Security`, `SentIcon`, `ShiftIcon`, `TeamIcon`, `WhatsappIcon` / `WhatsappFeature`

Feature.`LogIcon`

### Enable tint color

```swift
imageView.image = MPAssets.Icon.EditIcon.outline?.enableTintColor()
imageView.tintColor = MPColor.blue400
```

## Illustrations — `MPAssets.Illustration`

| Name | Key |
|---|---|
| Access Restricted | `accessRestricted` |
| Announcement Interlaced | `announcementInterlaced` |
| Check Location | `checkLocation` |
| Live Tracking | `liveTracking` |

## Logos — `MPAssets.Logo`

- `eSignLogo`

## Avatars — `MPAssets.Avatar`

- `rizalChandraAvatar` (sample)

## Tour — `MPAssets.Tour`

- `welcoming`

---

# Setup

## CocoaPods

```ruby
pod 'MekariPixel', :path => '../MekariPixel'
```

## AppDelegate

```swift
import MekariPixel

func application(_ application: UIApplication, didFinishLaunchingWithOptions ...) -> Bool {
    UIFont.loadFonts()  // Required — registers Inter font family
    return true
}
```

## Tab bar styling

```swift
tabBarController.tabBar.setPrimaryAppearance()
```
