# Metadata

- **Platform:** Flutter only. Non-Flutter platforms: N/A.
- **Import:** `package:mekari_pixel/mekari_pixel.dart`
- **Prefix:** `Mp` (e.g. `MpButton`, `MpAvatar`, `MpListTileX`)
- **Last extracted:** 2026-06-14

---

# Atoms

Atoms are basic building blocks that cannot be broken down further without losing functionality. Atoms do not accept Widget parameters.

## Atoms — Overview

Atoms are the foundational layer of the Mekari Pixel design system. Each atom is a single-responsibility Flutter widget that cannot be decomposed further without losing its purpose — buttons, badges, avatars, checkboxes, icons, and similar primitives.

**Constraints:** Atoms do not accept `Widget` parameters. They compose only primitive values: strings, numbers, colors, callbacks, and enums. This keeps them predictable, independently testable, and safe to reuse anywhere.

**Usage rule:** Always prefer atoms over raw Flutter widgets when a Pixel equivalent exists. Compose atoms inside components — never nest components inside atoms.

---

## MpActionText

A tappable text label used to trigger an action. Disabled automatically when `onTap` is null.

**When to use:** Use inside `MpTextAppBar`, `MpBottomSheetHeader`, `MpListTileX`, or `MpBottomSheetAction` for inline text actions — not for standalone buttons.

**Variants:**
- `MpActionText.value()` — styled as a value/secondary display (lighter color) rather than a call-to-action

**Key params:**
- `onTap` — null disables the widget automatically; no separate `enabled` flag needed
- `style` — override color and text style

**Usage:**
```dart
MpActionText(
  label: 'Action',
  onTap: () { /* action */ },
)
```

**Figma:** https://www.figma.com/design/djepS92jOSLv9ayVBIcH4M/Mobile-Pixel-2.4?node-id=17806-4384

---

## MpAvatar

Displays a user or entity representation as a circular or rounded-rectangle container. Supports images, icons, text initials, and loading/error states.

**When to use:** Use for profile pictures, user identifiers, entity icons in list tiles, and anywhere a compact visual identity is needed. Prefer `MpAvatar.adaptive()` when the content type (URL vs icon vs text) is unknown at build time.

**Variants:**
- `MpAvatar.image(path:)` — network or asset image; use for actual profile photos
- `MpAvatar.text(text:)` — shows initials; fallback when no image is available
- `MpAvatar.icon(icon:)` — `IconData` icon inside avatar container
- `MpAvatar.iconImage(path:)` — asset path to icon image (e.g. `/icons/` path); for branded icons
- `MpAvatar.loading()` — shimmer placeholder while avatar data loads
- `MpAvatar.error()` — fallback when image fails to load; defaults to profile icon
- `MpAvatar.adaptive(value:)` — auto-selects variant based on value type (URL → image, IconData → icon, String → text)

**Key params:**
- `size` — `MpAvatarSize.s20()` through `MpAvatarSize.s64()`; defaults to `s24`
- `shape` — `MpAvatarShape.circular` (default) or `MpAvatarShape.roundedRectangle`
- `onTap` — makes avatar tappable
- `errorBuilder` — custom error widget; prefer `MpAvatar.error()` return value
- `placeholder` — custom loading widget for network images

**Usage:**
```dart
MpAvatar.image(
  path: MpAvatars.photo.s20,
  size: MpAvatarSize.s20,
)
```

**Figma:** https://www.figma.com/design/djepS92jOSLv9ayVBIcH4M/Mobile-Pixel-2.4?node-id=513-3509

---

## MpBadge

A compact label used to convey status, counts, or categorical information with color-coded semantic meaning.

**When to use:** Use `MpBadge.negative` for error counts or alerts (e.g. notification counts). Use semantic color variants to communicate meaning — `positive` for success states, `notice` for warnings, `informative` for neutral info. Use `*Status` variants (outlined style) for in-line status labels inside list tiles.

**Variants:**
- `MpBadge.informative()` — neutral/default info (blue); use for general counts or states
- `MpBadge.neutral()` — no semantic color; use when color meaning is irrelevant
- `MpBadge.notice()` — warning/caution context (yellow/orange)
- `MpBadge.positive()` — success/completion context (green)
- `MpBadge.negative()` — error/danger/overdue context (red); also used for notification counts
- `MpBadge.informativeStatus()` — outlined informative; for inline status labels
- `MpBadge.neutralStatus()` — outlined neutral
- `MpBadge.noticeStatus()` — outlined notice/warning
- `MpBadge.positiveStatus()` — outlined positive/success
- `MpBadge.negativeStatus()` — outlined negative/error

**Key params:**
- `text` — required label text
- `icon` — optional leading icon asset path
- `size` — `MpBadgeSize.normal` (default) or `MpBadgeSize.small`

**Usage:**
```dart
MpBadge.negative(
  text: '+99',
  size: MpBadgeSize.small,
)
```

**Figma:** https://www.figma.com/design/djepS92jOSLv9ayVBIcH4M/Mobile-Pixel-2.4?node-id=17337-1048

---

## MpButton

The standard button for all user-triggered actions. Disabled when both `onPressed` and `onLongPress` are null.

**When to use:** Use `MpButton.primary()` for the single main CTA on a screen (max one per view). Use `secondary` for supporting actions alongside primary. Use `tertiary` or `ghost` for low-emphasis or repeated inline actions. Use `danger` only for destructive/irreversible actions (delete, revoke, sign out).

**Variants:**
- `MpButton.primary()` — filled brand color (`brandBold` bg); highest emphasis; main CTA
- `MpButton.secondary()` — outlined brand border, transparent bg; supporting action
- `MpButton.tertiary()` — subtle fill; low-emphasis actions
- `MpButton.ghost()` — no background; minimal-ink contexts (toolbars, dense lists)
- `MpButton.danger()` — critical/destructive intent (`bgCritical` token); irreversible actions only

**Key params:**
- `onPressed` / `onLongPress` — both null → button is disabled automatically
- `isLoading` — shows spinner and disables interaction; use during async operations
- `size` — `MpButtonSize.normal()` (48px, default) or `MpButtonSize.small()` (<40px)
- `icon` — optional leading or trailing icon widget
- `style.iconPosition` — `MpButtonIconPosition.left` (default) or `right`

**Usage:**
```dart
MpButton.primary(
  label: 'Label',
  onPressed: () { },
)
```

**Figma:** https://www.figma.com/design/djepS92jOSLv9ayVBIcH4M/Mobile-Pixel-2.4?node-id=17323-74724

---

## MpButtonIcon

An icon-only button with a rectangular ink splash. Disabled when both `onPressed` and `onLongPress` are null.

**When to use:** Use for icon actions that appear in content areas (cards, list tiles, toolbars). Do NOT use inside `AppBar.actions` — use `MpIconButton` there instead.

**Key params:**
- `icon` — asset path string (use `MpIcons.*`)
- `active` — visual active/selected state; defaults to `false`
- `hasDropdown` — shows a chevron indicator for dropdown affordance
- `onPressed` / `onLongPress` — both null → disabled

**Usage:**
```dart
MpButtonIcon(
  icon: MpIcons.interfaceEssential.arrowLeft,
  onPressed: () { },
)
```

**Figma:** https://www.figma.com/file/Lp6VSWJnP5wI4SdztB5H2f/Mobile-Kit-2.1?type=design&node-id=6940-60334

---

## MpCheckbox

A tri-state capable checkbox for boolean or indeterminate selection. Disabled when `onTap` is null.

**When to use:** Use standalone for a single boolean option. For lists of checkboxes, prefer `MpCheckboxList` (component) or `MpCheckboxListTileX` (template).

**Key params:**
- `value` — `true` (checked), `false` (unchecked), `null` (indeterminate, requires `tristate: true`)
- `onTap` — callback with new value; null disables the widget
- `tristate` — enables null/indeterminate state; shows dash when `value` is null

**Usage:**
```dart
MpCheckbox(
  value: _value,
  onTap: (value) => setState(() => _value = value),
)
```

**Figma:** https://www.figma.com/design/djepS92jOSLv9ayVBIcH4M/Mobile-Pixel-2.4?node-id=17320-73079

---

## MpChip

A compact interactive label for selections, filters, and action triggers. Supports leading/trailing widgets.

**When to use:** Use for filter selections, multi-select tags, and categorical choices. Prefer `MpChip.outline` for unselected state and `MpChip.fill` or `MpChip.duoTone` for selected/active state.

**Variants:**
- `MpChip` — base/default chip; customizable colors
- `MpChip.outline()` — border-only style; use for unselected filter chips
- `MpChip.duoTone()` — dual-color style; use for selected/active chips with icon
- `MpChip.fill()` — filled background; use for active/selected chips

**Key params:**
- `text` — required label
- `leading` — widget before text (icon, avatar, image)
- `trailing` — widget after text (close icon, count badge)
- `onTap` — makes chip interactive

**Usage:**
```dart
MpChip.outline(
  text: 'Category',
  onTap: () {},
)
```

**Figma:** https://www.figma.com/design/djepS92jOSLv9ayVBIcH4M/Mobile-Pixel-2.4?node-id=17403-50814

---

## MpDatePickerCell

A single interactive date cell for use inside calendar/date picker views. Handles today, selected, in-range, disabled, and preview visual states.

**When to use:** Use as a building block when building a custom calendar layout. For standard date pickers, use `MpDatePicker.showDayPicker()` (component) or `MpCalendar` (page) instead.

**Key params:**
- `date` — the `DateTime` this cell represents
- `isToday` / `isSelected` / `isInRange` / `isDisabled` — visual state flags
- `style` — `MpDatePickerCellStyle` for visual customization
- `onDateSelected` — tap callback

**Figma:** https://www.figma.com/file/Lp6VSWJnP5wI4SdztB5H2f/Mobile-Kit-2.1-(In-test)?node-id=2526%3A11105

---

## MpFloatingActionButton

A floating action button supporting icon, label, and animated show/hide.

**When to use:** Use as the primary screen-level action when it should float over content (e.g. compose, add, scan). Place via `Scaffold.floatingActionButton` or wrap content in `MpFloatingActionButtonStack` to animate on scroll.

**Key params:**
- `icon` — widget to display (either `icon` or `label` required)
- `label` — text label for extended FAB
- `collapse` — hides label when both icon and label are provided (collapsed extended FAB)
- `style` — visual appearance override

**Usage:**
```dart
Scaffold(
  floatingActionButton: MpFloatingActionButton(
    icon: MpIcons.interfaceEssential.add.toIcon(color: MpColors.white),
    onPressed: () {},
  ),
)
```

**Figma:** https://www.figma.com/design/Lp6VSWJnP5wI4SdztB5H2f/Mobile-Kit-2.1?node-id=17587-13389

---

## MpHomeIndicator

Renders the OS home indicator bar (iOS pill or Android gesture bar) for use in custom layouts.

**When to use:** Use at the bottom of bottom sheets, pages, or overlays that replace the system chrome. Automatically adapts to iOS vs Android style.

**Key params:**
- `isAndroid` — override OS detection; null follows device platform
- `indicatorColor` — defaults to inverse background color from theme
- `backgroundColor` — container background

**Usage:**
```dart
MpHomeIndicator()
```

---

## MpIcon

Renders an icon from an asset path or URL. Supports SVG, PNG, JPG, GIF, and duotone multi-color icons.

**When to use:** Use for all icons in the app — prefer `MpIcons.*` asset paths. For clickable icons, prefer `MpIconButton` (AppBar) or `MpButtonIcon` (inline). Use `customColor` only for duotone icons that need per-layer color control.

**Key params:**
- `filepath` — asset path or URL; SVG paths with `/icons/` prefix are treated as icon images
- `size` — overrides `MpIconTheme` size; defaults to `24.0`
- `color` — single-color tint via `BlendMode.srcIn`; for multi-color use `customColor`
- `onTap` — makes icon tappable
- `tooltip` — shows on long press when `onTap` is set; on tap otherwise

**Usage:**
```dart
MpIcon(filepath: 'assets/done.svg')
```

---

## MpIconButton

An icon button with circular splash, intended for use in `AppBar.actions` and similar nav chrome.

**When to use:** Use in `AppBar.actions`, navigation bars, and header icon controls. For icon buttons in content areas, use `MpButtonIcon` instead — it has rectangular splash and active state.

**Key params:**
- `icon` — asset path (use `MpIcons.*` or `MpLogos.*`)
- `onPressed` — null disables the button
- `color` / `disabledColor` — icon color overrides
- `splashRadius` — tap target size; must be > 0 if set

**Usage:**
```dart
MpIconButton(
  icon: MpIcons.interfaceEssential.arrowLeft,
  onPressed: () { },
)
```

---

## MpImage

Renders an image from an asset path or URL with theming support. Supports SVG, PNG, JPG, GIF.

**When to use:** Use for content images (illustrations, banners, product images). For icons, use `MpIcon`. For avatars, use `MpAvatar`. Wrap in `DefaultMpImageTheme` to apply consistent color or fit to a group of images.

**Key params:**
- `filepath` — asset path or URL
- `theme` — `MpImageTheme` for color, size, fit, placeholder, and error builder
- `useThemeColor` — when `true`, inherits color from `DefaultMpImageTheme` wrapper

**Usage:**
```dart
MpImage(filepath: 'assets/done.svg')
```

---

## MpKeypad

A single key for use inside a custom numeric keyboard. Part of `MpCustomKeyboard`.

**When to use:** Use only as a building block inside `MpCustomKeyboard`. For a full keyboard, use `MpCustomKeyboard` directly.

**Variants:**
- `MpKeypad.text(text:)` — displays a text label (number or symbol)
- `MpKeypad.icon(icon:)` — displays an icon (e.g. backspace)

**Figma:** https://www.figma.com/file/Lp6VSWJnP5wI4SdztB5H2f/Mobile-Kit-2.1?type=design&node-id=2570-12372

---

## MpRadioButton

A single radio button indicator for mutually exclusive selection. Generic over value type `T`.

**When to use:** Use standalone for a single option or when building a custom radio layout. For a list of radio options, prefer `MpRadioButtonListX` (component) or `MpRadioButtonListTileX` (template).

**Key params:**
- `value` — the value this radio represents
- `selected` — whether this radio is the currently selected one
- `onRadioClick` — callback with the selected value; null disables the widget

**Usage:**
```dart
MpRadioButton(
  value: '1',
  selected: false,
  onRadioClick: (value) => setState(() => _selected = value),
)
```

**Figma:** https://www.figma.com/file/Lp6VSWJnP5wI4SdztB5H2f/Mobile-Kit-2.1-(In-test)?node-id=439%3A4675

---

## MpShimmer

Animated skeleton loading placeholder with shape variants.

**When to use:** Use while async content is loading to prevent layout shift. Match the shimmer shape to the content it replaces (circle for avatars, rectangle for text lines, rounded rectangle for cards).

**Variants:**
- `MpShimmer.square(size:)` — fixed-size square
- `MpShimmer.circle(size:)` — circle; use for avatar placeholders
- `MpShimmer.rectangle(width:, height:)` — rectangle; use for text line placeholders
- `MpShimmer.roundedRectangle(width:, height:)` — rounded corners; use for card placeholders

**Key params:**
- `enabled` — stops animation when false (shows static placeholder)
- `duration` — animation cycle duration; defaults to 1500ms

**Usage:**
```dart
MpShimmer.square(size: 30)
```

**Figma:** https://www.figma.com/file/Lp6VSWJnP5wI4SdztB5H2f/Mobile-Kit-2.1?type=design&node-id=9312-18626

---

## MpSlideToAction

A slide-to-confirm control for high-stakes irreversible actions. Uses brand color (`brandBold`) for slider track.

**When to use:** Use instead of a button when an action is irreversible and requires deliberate user intent (e.g. "Slide to clock out", "Slide to submit"). Do NOT use for routine actions.

**Key params:**
- `sliderCaption` — instructional text shown on the slider track
- `onSubmitCallback` — triggered when slider reaches max position
- `isLoading` — shows loading state after submission
- `isFinished` — `ValueNotifier<bool>` that locks the slider in completed state

**Usage:**
```dart
MpSlideToAction(
  sliderCaption: 'Slide to action',
  onSubmitCallback: () async => _onSlideAction(),
  isLoading: _isLoading,
  isFinished: _isFinished,
)
```

**Figma:** https://www.figma.com/design/djepS92jOSLv9ayVBIcH4M/Mobile-Pixel-2.4?node-id=18084-55692

---

## MpHorizontalSpace / MpVerticalSpace

Layout spacing widgets based on `MpSpacing` tokens. Use inside `Row`/`Column` to add semantic gaps between widgets.

**When to use:** Use instead of `SizedBox` for spacing. Named constructors map to design tokens — do not use arbitrary pixel values.

**Key constructors (both classes):**
- `.s4()` — 4px (xxxs)
- `.s8()` — 8px (xxs)
- `.s12()` — 12px (xs / small)
- `.s16()` — 16px (s / medium)
- `.s20()` — 20px (m / large)
- `.s24()` — 24px (l / xLarge)

**Usage:**
```dart
MpHorizontalSpace.s12()
```

**Figma:** https://www.figma.com/design/djepS92jOSLv9ayVBIcH4M/Mobile-Pixel-2.4?node-id=10-6811

---

## MpStatusBar

A mock status bar widget showing time and icons, used in design mockups and custom full-screen overlays.

**When to use:** Use inside launch screens, walkthrough screens, or any full-screen overlay that needs to render its own status bar. Not needed for regular app screens where the system status bar is visible.

**Key params:**
- `time` — time string to display
- `icons` — list of icon widgets (battery, signal, etc.)
- `isAndroid` — override platform detection

---

## MpTag

A selectable label for filter/selection contexts with a selected/unselected state.

**When to use:** Use in filter bars where users can toggle individual categories. For chips in multi-select or compact chip layouts, use `MpChip` instead.

**Variants:**
- `MpTag` — default selectable tag
- `MpTag.error()` — visual error state (red styling)
- `MpTag.disable()` — permanently disabled appearance

**Key params:**
- `label` — required text
- `selected` — selected state (affects background/border color)
- `onPressed` — tap callback; null renders as non-interactive

**Usage:**
```dart
MpTag(
  label: "Filter label",
  selected: false,
  onPressed: () {},
)
```

**Figma:** https://www.figma.com/file/Lp6VSWJnP5wI4SdztB5H2f/Mobile-Kit-2.1?type=design&node-id=5225-38439

---

## MpTextField

The standard form text input field with label, hint, helper, error, prefix/suffix, and validation support.

**When to use:** Use for all text input in forms. For phone numbers with country code, use `MpPhoneTextField`. For rich text editing, use `MpTextEditor`. For read-only select inputs, use `MpSelect`.

**Key params:**
- `label` — floating label text above the field
- `hint` — placeholder text when field is empty
- `error` — error message shown below field (also triggers error visual state)
- `helper` — helper text shown below field (hidden when error is shown)
- `required` — shows required indicator
- `obscure` — password/obscured mode
- `readOnly` — tappable but not editable; use with `onPressed` to open a picker
- `disable` — fully disabled state
- `enableClearButton` — shows X button to clear field; defaults to `true`
- `validator` — form validation function
- `autoValidate` — validate on every change rather than on submit

**Usage:**
```dart
MpTextField(
  label: "Full name",
  hint: "e.g Jonathan Cody Fisher",
  helper: "Include your middle name if you have one.",
  textInputAction: TextInputAction.next,
  validator: _validateName,
)
```

**Figma:** https://www.figma.com/design/djepS92jOSLv9ayVBIcH4M/Mobile-Pixel-2.4?node-id=17440-11210

---

## MpToggle

A boolean on/off switch. Disabled when `onChanged` is null.

**When to use:** Use for settings and preferences that take effect immediately without requiring a save action. For form-based boolean fields that require explicit save, consider `MpCheckbox` instead.

**Key params:**
- `value` — required current state
- `onChanged` — callback with new bool value; null disables the widget
- `duration` — animation duration; defaults to 200ms

**Usage:**
```dart
MpToggle(
  value: _value,
  onChanged: (value) => setState(() => _value = value),
)
```

**Figma:** https://www.figma.com/design/djepS92jOSLv9ayVBIcH4M/Mobile-Pixel-2.4?node-id=1112-17581

---

# Components

Components are composite widgets built from atoms. They handle more complex interaction patterns.

## Components — Overview

Components are the mid-layer of the Mekari Pixel design system. Each component composes one or more atoms (and sometimes other components) to encapsulate a distinct, reusable interaction pattern or multi-part UI structure.

**Examples:** app bars, list tiles, bottom sheets, form fields, banners, search bars, carousels, tooltips — anything that combines multiple visual or interactive elements into a coherent unit.

**Constraints:** Components may accept `Widget` parameters to allow slot-based composition (e.g. a custom leading or trailing widget in a list tile). They should not embed business logic or call repositories directly.

**Usage rule:** Reach for a component before building a custom composite from scratch. If no component fits, check whether atoms can be composed directly; only add a new component when the pattern recurs across features.

---

## MpTextAppBar

The standard app bar with a text title and optional description, actions, and leading widget.

**When to use:** Use as the `appBar` for all standard screens. Use `MpLogoAppBar` for brand/home screens, `MpProfileAppBar` for profile screens, `MpEmptyAppBar` for screens that need no visible title.

**Key params:**
- `title` — required screen title
- `description` — secondary text below title; changes title style to semibold when present
- `actions` — list of `MpIconButton` widgets for the right side
- `centerTitle` — defaults to `true`
- `automaticallyImplyLeading` — auto-adds back button; defaults to `true`

**Usage:**
```dart
MpTextAppBar(
  title: 'Main page',
  actions: [
    MpIconButton(icon: MpIcons.alert.info, onPressed: () {}),
  ],
)
```

**Figma:** https://www.figma.com/file/Lp6VSWJnP5wI4SdztB5H2f/Mobile-Kit-2.1-(WIP)?node-id=44%3A558

---

## MpAvatarGroup

Displays a horizontal stack of overlapping avatars with an overflow counter badge.

**When to use:** Use when showing a list of users/participants in a compact space (e.g. "assigned to", "attendees"). When the avatar count exceeds `show`, a `+N` counter badge appears.

**Key params:**
- `avatars` — list of `MpAvatar` widgets
- `show` — max avatars before overflow badge; defaults to `2`
- `size` — applied to all avatars uniformly via `MpAvatarTheme`

**Usage:**
```dart
MpAvatarGroup(
  show: 3,
  size: const MpAvatarSize.s40(),
  avatars: [
    MpAvatar.image(path: MpAvatars.photo.s40),
    MpAvatar.text(text: 'John Doe'),
  ],
)
```

**Figma:** https://www.figma.com/design/djepS92jOSLv9ayVBIcH4M/Mobile-Pixel-2.4?node-id=13950-51798

---

## MpBanner

A full-width inline informational or warning message with optional title, message, dismiss, close, and action buttons.

**When to use:** Use to communicate page-level messages that require attention but don't block the user (not modal). Prefer semantic variants — `info` for neutral information, `warning` for caution states. Dismiss (`dismissable`) allows swipe-to-hide; `closeable` shows an X button.

**Variants:**
- `MpBanner` — base; use when info/warning variants don't fit
- `MpBanner.info()` — informative (blue); general notifications or tips
- `MpBanner.warning()` — caution (yellow/orange); degraded state or important caveats

**Key params:**
- `title` / `message` — text content; use `titleRich` / `messageRich` for styled spans
- `dismissable` — enables swipe to dismiss
- `closeable` — shows X close button
- `actions` — list of `MpBannerAction` buttons

**Usage:**
```dart
MpBanner.info(
  title: "Title banner",
  message: "A message should be a short and complete sentence.",
  closeable: true,
  actions: [MpBannerAction(text: 'Preferred', onTap: () {})],
)
```

---

## MpBlankSlate

An empty or error state display with illustration/icon, label, message, and optional actions.

**When to use:** Use when a list, page, or section has no content to display. Choose the variant that matches your available asset: `illustration` for full empty-state graphics, `icon` for feature icons, `empty` for text-only states.

**Variants:**
- `MpBlankSlate.illustration(illustration:)` — uses `MpIllustrations.*` asset
- `MpBlankSlate.icon(icon:)` — uses `MpIcons.*` path at 56px
- `MpBlankSlate.empty()` — text only, no visual

**Key params:**
- `label` — primary heading
- `message` — supporting explanation
- `actions` — optional `MpButton` widgets

**Usage:**
```dart
MpBlankSlate.illustration(
  illustration: MpIllustrations.blankSlate.noData,
  label: 'No data yet',
  message: 'Your data will display here',
)
```

**Figma:** https://www.figma.com/file/Lp6VSWJnP5wI4SdztB5H2f/Mobile-Kit-2.1-(WIP)?node-id=44%3A827

---

## MpBottomNavBar

The app-level bottom navigation bar with icon tabs and optional badge support.

**When to use:** Use as the `bottomNavigationBar` in the root `Scaffold` for main navigation between top-level sections. Supports up to 5 items.

**Key params:**
- `items` — list of `MpBottomNavBarItemData` (icon as String path) or `MpBottomNavBarItemWidgetData` (icon as Widget)
- `currentIndex` — active tab index
- `onTap` — called with index when a tab is tapped
- `elevation` — shadow; defaults to `0`

**Usage:**
```dart
MpBottomNavBar(
  items: [
    MpBottomNavBarItemData(
      label: 'Home',
      icon: MpIcons.feature.home,
      badge: MpBadge.negativeMenu(text: '9+'),
    ),
  ],
  currentIndex: 0,
  onTap: (index) => setState(() => _index = index),
)
```

**Figma:** https://www.figma.com/file/Lp6VSWJnP5wI4SdztB5H2f/Mobile-Kit-2.1-(WIP)?node-id=44%3A827

---

## MpBroadcast

A top-of-screen announcement bar for system-level messages like promos, alerts, or maintenance notices.

**When to use:** Use for persistent, screen-spanning messages that need to surface above content (different from `MpBanner` which is inline). Use semantic variants to convey urgency.

**Variants:**
- `MpBroadcast` — default; no semantic color
- `MpBroadcast.announcement()` — promotional/celebratory context
- `MpBroadcast.information()` — informational (blue)
- `MpBroadcast.important()` — high-urgency alert (red/critical)

**Key params:**
- `label` — required primary text
- `description` — secondary text below label
- `leading` — left icon widget
- `trailing` — list of right action widgets

**Usage:**
```dart
MpBroadcast.information(
  label: 'System maintenance tonight',
  trailing: [Icon(Icons.close)],
)
```

**Figma:** https://www.figma.com/file/Lp6VSWJnP5wI4SdztB5H2f/Mobile-Kit-2.1-(In-test)?node-id=915%3A24757

---

## MpBubbleChatBasic

A chat message bubble for messaging UIs, supporting self and direct (received) alignment.

**When to use:** Use for chat message rendering. `MpBubbleChatBasic.self` for outgoing messages (right-aligned), `MpBubbleChatBasic.direct` for incoming (left-aligned). For group chats with profiles, use `MpBubbleChatGroup`.

**Variants:**
- `MpBubbleChatBasic.self()` — outgoing message (right-aligned, brand color bg)
- `MpBubbleChatBasic.direct()` — incoming message (left-aligned, surface bg)

**Key params:**
- `chatText` — required message text
- `timestamp` — time string
- `read` — read receipt state
- `readIndicator` — custom read receipt widget

**Usage:**
```dart
MpBubbleChatBasic.self(
  chatText: "Lorem ipsum dolor sit amet consectetur.",
  timestamp: "2:46 AM",
)
```

**Figma:** https://www.figma.com/design/djepS92jOSLv9ayVBIcH4M/Mobile-Pixel-2.4?node-id=17635-2770

---

## MpContextualMenu

A long-press context menu that wraps any widget, showing vertical and/or horizontal action items.

**When to use:** Use to expose secondary actions on a tappable element via long press (similar to iOS/Android context menus). Choose `vertical` for list-style menu, `horizontal` for icon action strip, or `verticalHorizontal` for both.

**Variants:**
- `MpContextualMenu.vertical(child:, verticalMenuItems:)` — vertical list menu
- `MpContextualMenu.horizontal(child:, horizontalMenuItems:)` — horizontal icon strip
- `MpContextualMenu.verticalHorizontal(child:, ...)` — combined

**Key params:**
- `child` — the widget that triggers the context menu on long press
- `previewChild` — custom preview widget shown above the menu
- `verticalMenuItems` / `horizontalMenuItems` — list of `MpContextualMenuItem`

**Usage:**
```dart
MpContextualMenu.vertical(
  child: Container(child: Text('Long press me')),
  verticalMenuItems: [
    MpContextualMenuItem.verticalSectionTitle(title: "Action", onTap: () {}),
  ],
)
```

**Figma:** https://www.figma.com/file/Lp6VSWJnP5wI4SdztB5H2f/Mobile-Kit-2.1?type=design&node-id=5824-58261

---

## MpCustomKeyboard

A full numeric keyboard component for custom PIN, amount, or code entry flows.

**When to use:** Use when the system keyboard is unsuitable (OTP, PIN entry, currency input). Provides a 12-key numeric layout with configurable action key and backspace.

**Key params:**
- `onTapNumber` — callback when number key tapped
- `onTapBackspace` — callback for backspace
- `actionBuilder` — custom widget for the bottom-left action key
- `thousandZero` — when `true`, replaces action key with `000` key
- `height` — keyboard height; defaults to `304`

**Usage:**
```dart
MpCustomKeyboard(
  onTapBackspace: () {},
  onTapNumber: (value) { /* do logic */ },
)
```

**Figma:** https://www.figma.com/design/djepS92jOSLv9ayVBIcH4M/Mobile-Pixel-2.4?node-id=17305-693

---

## MpDatePicker

Shows a date or date-range picker inside a bottom sheet. Returns the selected `DateTime` via Future.

**When to use:** Use `MpDatePicker.showDayPicker()` for single date selection. Use `MpDatePicker.showRangePicker()` for date range. For embedded calendar display, use `MpCalendar` (page) instead.

**Key methods:**
- `MpDatePicker.showDayPicker(context, ...)` — single date
- `MpDatePicker.showRangePicker(context, ...)` — date range

**Key params:**
- `firstDate` / `lastDate` — constrains the selectable range
- `date` / `selectedDate` — initial selection
- `selectionMode` — `scrollView` or `gridView` layout
- `showTodayButton` / `showClearButton` — optional action buttons

**Usage:**
```dart
MpDatePicker.showDayPicker(
  context,
  onSaveButtonPressed: (date) { /* handle */ },
)
```

---

## MpFilter

A horizontal scrollable filter bar combining a filter button with tag chips.

**When to use:** Use at the top of list screens to let users narrow content by category. The filter button opens a detailed filter panel; tags provide quick single-filter toggles.

**Key params:**
- `tags` — list of `MpFilterTagData` with label and selection state
- `buttonLabel` — text for the filter button (defaults to none)
- `onTapFilter` — called when filter button is tapped; receives selected count
- `onTapTag` — called when a tag is tapped; receives index and tag data
- `onTapTagSuffix` — called when a tag's remove icon is tapped

**Usage:**
```dart
MpFilter(
  buttonLabel: 'Filter',
  tags: items,
  onTapFilter: onTapFilter,
  onTapTag: onTapTag,
)
```

**Figma:** https://www.figma.com/design/djepS92jOSLv9ayVBIcH4M/Mobile-Pixel-2.4?node-id=17391-18567

---

## MpCheckboxList

A group of checkboxes rendered as a list, backed by `List<MpCheckboxListItem>`.

**When to use:** Use when users need to select multiple items from a list. For a single checkbox, use `MpCheckbox` atom. For richer list tiles with avatars/icons, use `MpCheckboxListTileX` (template).

**Key params:**
- `values` — list of `MpCheckboxListItem` (each has `value` bool and `label`)
- `onChanged` — callback with updated values
- `style` — visual overrides

**Usage:**
```dart
MpCheckboxList(
  values: [
    MpCheckboxListItem(value: true, label: 'Label One'),
    MpCheckboxListItem(value: false, label: 'Label Two'),
  ],
  onChanged: (values) {},
)
```

---

## MpLoadingAnimation

An animated three-dot loading indicator using brand colors.

**When to use:** Use for full-page loading states or section-level async loading. For inline/skeleton loading, use `MpShimmer` instead.

**Key params:**
- `size` — dot size; defaults to `24.0`
- `spacing` — gap between dots; defaults to `12.0`
- `duration` — animation cycle; defaults to `1250ms`

**Usage:**
```dart
const MpLoadingAnimation(size: 8.0, spacing: 4.0)
```

**Figma:** https://www.figma.com/file/Lp6VSWJnP5wI4SdztB5H2f/Mobile-Kit-2.1?type=design&node-id=6416-55659

---

## MpPageControl

A row of dot indicators for paged content (carousels, onboarding).

**When to use:** Use with `PageView` to show the current page and total page count. Place below a `PageView` with synced `currentIndex`.

**Key params:**
- `length` — total number of pages
- `currentIndex` — active page (0-based); must be < `length`
- `size` — dot size; defaults to `6.0`
- `activeColor` / `inactiveColor` — color overrides

**Usage:**
```dart
MpPageControl(
  length: 5,
  currentIndex: _currentPage,
)
```

---

## MpPhoneTextField

A phone number input field with integrated country code picker.

**When to use:** Use instead of `MpTextField` whenever the input is a phone number. Handles country code formatting, flag display, and dial code prepending automatically.

**Key params:**
- Same as `MpTextField` for label/hint/error/helper/validator
- `prefixIcon` — replace default country flag picker if needed

**Usage:**
```dart
MpPhoneTextField(
  hint: "12345",
  validator: _validatePhone,
)
```

**Figma:** https://www.figma.com/design/djepS92jOSLv9ayVBIcH4M/Mobile-Pixel-2.4?node-id=17440-11709

---

## MpRadioButtonListX

A list of radio button options with optional avatar/icon leading widgets.

**When to use:** Use when users must choose exactly one option from a list. For a single radio button, use `MpRadioButton`. For richer layout customization, use `MpRadioButtonListTileX` (template).

**Key params:**
- `values` — list of `MpRadioButtonListXItem` with `value`, `label`, optional `caption` and `leading`
- `currentValue` — the currently selected value
- `onRadioClick` — callback with selected value

**Usage:**
```dart
MpRadioButtonListX(
  values: [
    MpRadioButtonListXItem(value: 1, label: 'Option One'),
    MpRadioButtonListXItem(value: 2, label: 'Option Two'),
  ],
  currentValue: 1,
  onRadioClick: (value) => setState(() => _selected = value),
)
```

---

## MpSearch

A search input bar with hero animation support, debounce, and cancel action.

**When to use:** Use for search screens opened as a route (push). Wrap in a `Hero` with the `heroTag` parameter for smooth search bar expansion animation from the triggering widget.

**Key params:**
- `heroTag` — required for Hero animation; must match the trigger widget's Hero tag
- `autoFocus` — focuses the field after 500ms delay on init; defaults to false
- `onTextChanged` — debounced search callback; use to load results
- `onCancelPressed` — callback for cancel button (typically pops the route)

**Usage:**
```dart
MpSearch(
  heroTag: "search",
  autoFocus: true,
  onTextChanged: (value) => _loadData(query: value),
  onCancelPressed: () => Navigator.of(context).pop(),
)
```

**Figma:** https://www.figma.com/design/djepS92jOSLv9ayVBIcH4M/Mobile-Pixel-2.4?node-id=17356-6423

---

## MpSegmentedControl

A tab-style segmented selector where each segment is a mutually exclusive option.

**When to use:** Use to switch between views or filter contexts on a single screen (e.g. "Day / Week / Month", "Active / Archived"). For main navigation between screens, use `MpBottomNavBar` or `MpTabs`.

**Key params:**
- `items` — list of `MpSegmentedControlItem`; each item has a unique `name` key
- `initialSelectedItem` — `name` of the initially selected item
- `isScrollable` — enables horizontal scroll when items overflow; defaults to `false`
- `tabController` — external `TabController` for coordination with `TabBarView`

**Usage:**
```dart
MpSegmentedControl(
  initialSelectedItem: "test_3",
  items: [
    MpSegmentedControlItem.label(context, "Test 1", "test_1"),
    MpSegmentedControlItem.label(context, "Test 2", "test_2"),
    MpSegmentedControlItem.label(context, "Test 3", "test_3"),
  ],
)
```

**Figma:** https://www.figma.com/design/djepS92jOSLv9ayVBIcH4M/Mobile-Pixel-2.4?node-id=17382-15289

---

## MpSelect

A form field that opens a searchable selection bottom sheet. Generic over item type `T`.

**When to use:** Use for single or multi-select dropdowns in forms where options come from an async data source. For static small option lists, consider `MpSegmentedControl` or radio buttons instead.

**Key params:**
- `label` — field label
- `hint` — placeholder when nothing is selected
- `getItems` — async function returning `List<T>` based on query
- `getItemLabel` — function returning display string for each item
- `listItemBuilder` — function building the row widget for each item

**Usage:**
```dart
MpSelect<UserData>(
  label: "Select User",
  hint: "Tap to select",
  getItems: _loadData,
  getItemLabel: (item) => item.name,
  listItemBuilder: (item) => Text(item.name),
)
```

**Figma:** https://www.figma.com/design/djepS92jOSLv9ayVBIcH4M/Mobile-Pixel-2.4?node-id=17448-10982

---

## MpSlider

A range slider with title, caption, and value display.

**When to use:** Use for continuous numeric range inputs (e.g. salary range, distance filter, age range). For discrete step selection, consider `MpSegmentedControl`.

**Key params:**
- `title` — required label above slider
- `value` — current slider value
- `minValue` / `maxValue` — range bounds
- `onChangedCallback` — called continuously as user drags
- `caption` — optional secondary label

**Usage:**
```dart
MpSlider(
  title: 'Slider title',
  value: 0.0,
  minValue: 0.0,
  maxValue: 1.0,
  onChangedCallback: (value) {},
)
```

**Figma:** https://www.figma.com/design/djepS92jOSLv9ayVBIcH4M/Mobile-Pixel-2.4?node-id=18084-55630

---

## MpStories

An auto-advancing story view (Instagram-style) with progress bar and lifecycle callbacks.

**When to use:** Use for onboarding tours, product announcements, or media stories. Requires an `MpStoriesController` for programmatic control (start, pause, next, previous).

**Key params:**
- `controller` — required `MpStoriesController(count:)`
- `autoStart` — starts automatically; defaults to `true`
- `hideOnStop` — hides widget when stopped; defaults to `false`
- `onStart` / `onStop` / `onPause` / `onResume` / `onIndexChange` — lifecycle callbacks

**Usage:**
```dart
MpStories(
  controller: MpStoriesController(count: 4),
  onIndexChange: (index) => debugPrint('Page $index'),
)
```

---

## MpTabs

Horizontal scrollable tabs with optional icons, typically used for sub-navigation within a screen.

**When to use:** Use for switching between views within the same screen (e.g. "All / Pending / Approved"). Requires a `TabController` or wrapping in `DefaultTabController`.

**Key params:**
- `items` — list of `MpTabsItemData` (icon as String) or `MpTabsItemWidgetData` (icon as Widget)
- `currentIndex` — active tab

**Usage:**
```dart
MpTabs(
  items: [
    MpTabsItemData(label: 'Tab 1'),
    MpTabsItemData(label: 'Tab 2', icon: MpIcons.alert.done),
  ],
  currentIndex: 0,
)
```

---

## MpTextEditor

A rich text editor (built on `flutter_quill`) with toolbar, mentions, and attachment support.

**When to use:** Use for comment boxes, note inputs, or any field requiring formatted text (bold, italic, links). For plain text, use `MpTextField`.

**Key params:**
- `controller` — required `QuillController`
- `showToolbar` — shows formatting toolbar; defaults to `true`
- `toolbarPosition` — `bottom` (default) or `top`
- `mentions` — list of mentionable users/entities
- `showAttachment` — enables file attachment button; defaults to `true`

**Figma:** https://www.figma.com/design/djepS92jOSLv9ayVBIcH4M/Mobile-Pixel-2.4?node-id=18042-70193

---

## MpThumbnail

A file/image preview widget supporting images, PDFs, and other file types.

**When to use:** Use in upload flows and attachment displays to preview files before or after upload. Built into `MpUpload` and `MpTextEditor` attachment flows — use directly only for custom layouts.

**Key params:**
- `path` — file path or URL (auto-detects image vs PDF)
- `size` — defaults to full-width at 92px height
- `deleteIcon` / `deleteIconPadding` — for deletable attachments

**Figma:** https://www.figma.com/file/Lp6VSWJnP5wI4SdztB5H2f/Mobile-Kit-2.1?type=design&node-id=7048-60414

---

## MpTimePicker

Shows a time, time range, or duration picker inside a bottom sheet. Returns the selected value via Future.

**When to use:** Use `MpTimePicker.show()` when collecting time input. For a combined field+picker interaction, use `MpTimePickerField` instead.

**Key params:**
- `type` — `MpTimePickerType.time` | `timeRange` | `duration`
- `onTapButton` — callback with selected `DateTime` (for time/duration types)
- `onTapButtonRange` — callback for time range type
- `is12HourFormat` — 12-hour AM/PM mode
- `hoursInterval` / `minutesInterval` / `secondsInterval` — scroll increments

**Usage:**
```dart
MpTimePicker.show(
  context,
  type: MpTimePickerType.time,
  onTapButton: (value) => print(value.toIso8601String()),
)
```

---

## MpTimePickerField

A read-only text field that opens an `MpTimePicker` bottom sheet on tap.

**When to use:** Use in forms where users select a time value. Handles field display, formatting, and clear action automatically. Prefer over manually wiring `MpTextField(readOnly: true)` + `MpTimePicker`.

**Key params:**
- `type` — time picker type (time, timeRange, duration)
- `label` / `hint` / `helper` / `validator` — standard field props
- `withClearAction` — shows clear button; defaults to `true`
- `onChanged` — callback when selection changes

**Figma:** https://www.figma.com/design/djepS92jOSLv9ayVBIcH4M/Mobile-Pixel-2.4?node-id=17562-11823

---

## MpAccordionTimeline

A timeline entry with an expandable content section, used for approval flows and history lists.

**When to use:** Use in approval timelines, process history, or activity logs where each step has expandable detail. Chain multiple `MpAccordionTimeline` widgets vertically; set `isFirstItem`/`isLastItem` to control connector lines.

**Key params:**
- `label` — step label
- `caption` — step status
- `timelines` — list of `MpTimeline.*` items shown when expanded
- `isFirstItem` / `isLastItem` — controls leading/trailing connector lines

**Usage:**
```dart
MpAccordionTimeline(
  label: 'Approval stage 1',
  timelines: [
    MpTimeline.success(label: "Approved", username: "Christin", date: DateTime.now()),
  ],
)
```

**Figma:** https://www.figma.com/file/Lp6VSWJnP5wI4SdztB5H2f/Mobile-Kit-2.1?type=design&node-id=5343-46805

---

## MpToast

A temporary overlay notification shown at the top or bottom of the screen.

**When to use:** Use to give users brief feedback after an action (save success, copy, error) without interrupting flow. Use semantic variants — `done` for success, `error` for failures, `warning` for caution, `info` for neutral feedback. Do NOT use for errors that require user action (use `MpBanner` or `MpDialog`).

**Variants:**
- `MpToast.done(message)` — success (green border)
- `MpToast.error(message)` — error/failure (red border)
- `MpToast.info(message)` — neutral information (blue border)
- `MpToast.warning(message)` — caution (yellow border)
- `MpToast.greetings(message)` — celebratory with emoji support

**Key params:**
- `message` — required text
- `icon` — optional icon path
- `direction` — `MpToastDirection` controls anchor position
- `.show(context)` — call on the instance to display it

**Usage:**
```dart
MpToast.info('Lorem ipsum dolor').show(context)
```

**Figma:** https://www.figma.com/design/djepS92jOSLv9ayVBIcH4M/Mobile-Pixel-2.4?node-id=17611-13670

---

## MpTooltip

A tooltip that wraps any widget and shows explanatory text on tap or long press.

**When to use:** Use to explain icons, truncated labels, or non-obvious UI elements. Defaults to tap trigger mode (unlike Flutter's default long-press).

**Key params:**
- `message` — tooltip text (or use `richMessage` for styled content)
- `triggerMode` — defaults to `TooltipTriggerMode.tap` (not long press)
- `child` — the widget to wrap

**Usage:**
```dart
MpTooltip(
  message: "This is a tooltip",
  child: Text("A Text"),
)
```

---

## MpMultiUpload

A file/image multi-upload component with drag zone, thumbnail previews, and delete support.

**When to use:** Use in forms that require file attachments (documents, images). For single-file upload, use `MpUpload`. For rich text with inline attachments, use `MpTextEditor`.

**Key params:**
- `data` — current list of uploaded file paths
- `label` — section label
- `caption` — helper text
- `error` — error message
- `size` — thumbnail size; defaults to `160x160`
- `dropzoneLabel` — text shown in the upload zone
- `deleteIcon` — icon for delete action

**Figma:** https://www.figma.com/design/djepS92jOSLv9ayVBIcH4M/Mobile-Pixel-2.4?node-id=17752-25855

---

## MpVideoPlayer

An inline video player supporting file and network stream sources.

**When to use:** Use to play video files or streams inline in a screen. Handles play/pause controls and state management.

**Key params:**
- `file` — local `File` to play
- `videoUrl` — `Uri` for network stream
- `height` / `width` — player dimensions

---

# Pages

Pages are full-screen widgets that are pushed as routes. They include their own `Scaffold`.

## Pages — Overview

Pages are full-screen Pixel widgets pushed as named routes or via `Navigator`. Each page owns its `Scaffold`, app bar, and top-level layout — they are not embedded inside other pages.

**Examples:** calendar pickers, image viewers, permission request screens, scan screens — self-contained screens with their own navigation lifecycle.

**Constraints:** Pages handle their own scaffold and may own state, but should delegate data fetching and business logic to BLoC/domain layers. Do not nest a page inside another widget's build tree — they are route destinations, not layout components.

**Usage rule:** Use a page when the feature requires a full-screen takeover pushed via the router. For partial-screen overlays, use a component (e.g. `MpBottomSheet`) instead.

---

## MpCalendar

A full interactive calendar view with event markers, day selection, and week navigation.

**When to use:** Use when users need to browse and select dates on a calendar view within the app. For bottom-sheet date pickers, use `MpDatePicker` instead.

**Key params:**
- `data` — list of `MpCalendarData` with date, event type, and label
- `onDateSelected` — called when user taps a day
- `onFocusDateChanged` — called when month navigation changes focus
- `itemBuilder` — custom event item builder

**Usage:**
```dart
MpCalendar(
  onDateSelected: onDateSelected,
  data: [
    MpCalendarData(
      date: DateTime.now(),
      type: MpCalendarEventType.company,
      label: 'Mid-year celebration',
      onTap: onTapItem,
    ),
  ],
)
```

**Figma:** https://www.figma.com/design/djepS92jOSLv9ayVBIcH4M/Mobile-Pixel-2.4?node-id=18167-65383

---

## MpCamera

A full-screen camera capture page for photo and video.

**When to use:** Use when the app needs to capture photos or videos. Push as a route and handle the returned capture result in the calling screen.

**Key params:**
- `onCameraError` — handles `CameraException`
- Supports `CaptureMode.photo` and `CaptureMode.video`
- Supports `CaptureType.frontCamera` and `CaptureType.backCamera`

---

## MpCsatFeedback

A CSAT (Customer Satisfaction) feedback page with rating emoji options and assessment tags.

**When to use:** Use at the end of feature flows to collect user satisfaction feedback. Typically shown as a full-screen route or bottom sheet after a key action completes.

**Key params:**
- `appName` / `featureName` — identifies what is being rated
- `ratingOptions` — list of `MpFeedbackData` with rating icons (emoji)
- `assessmentOptions` — list of `MpFeedbackData` for qualitative tags
- `playStoreUrl` — link to app store for review deeplink

---

## MpForceUpdate

A full-screen update gate that blocks app usage until the user updates.

**When to use:** Show as a pushed route when the server returns a "force update" signal. Use `onLater` parameter to switch between forced (no dismiss) and recommended (dismissable) update modes.

**Key params:**
- `product` — `MpForceUpdateProduct.*` selects the product illustration
- `onUpdate` — "Update now" button callback; launch store URL here
- `onLater` — when provided, shows "Later" button (recommended update mode); when null, shows forced update only

**Usage:**
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => MpForceUpdate(
      product: MpForceUpdateProduct.talenta,
      onUpdate: () => launchUrl(storeUrl),
    ),
  ),
)
```

---

## MpLaunchScreen

An animated splash/launch screen with logo animation and progress indicator support.

**When to use:** Use as the initial route to show the app logo animation and transition to the home screen. The `nextRoute` builder is called after animation completes or `progress.value` reaches 1.0.

**Key params:**
- `nextRoute` — builder for the post-launch screen
- `builder` — custom logo animation builder (use with `MpLogoAnimation`)
- `onAnimationFinished` — called when animation completes

---

## MpServerFeedback

A standardized server error display for common failure states. Can be shown as a page or bottom sheet.

**When to use:** Use to replace blank/broken screens when API calls fail. Match the variant to the HTTP/network error type. Avoids hand-rolling error state screens.

**Variants:**
- `MpServerFeedback.timeout()` — request timeout
- `MpServerFeedback.sessionExpired()` — auth expired
- `MpServerFeedback.noAccess()` — 403 forbidden
- `MpServerFeedback.notFound()` — 404 not found
- `MpServerFeedback.serverError()` — 5xx errors
- `MpServerFeedback.maintenance()` — planned maintenance
- `MpServerFeedback.offline()` — no network connection
- `MpServerFeedback.custom()` — custom message and illustration

**Key params:**
- `onTapTryLater` — retry/dismiss callback (typically pop or reload)

**Usage:**
```dart
MpServerFeedback.maintenance(
  onTapTryLater: () => Navigator.of(context).pop(),
).showAsBottomSheet(context)
```

---

## MpSignOut

A sign-out confirmation dialog with "Stay signed in" and "Sign out" actions.

**When to use:** Use whenever the user taps a sign-out action to confirm intent before executing. Show as a dialog via `.showDialog()`.

**Key params:**
- `title` — dialog title
- `body` — confirmation message
- `onSignIn` — "Stay signed in" callback (typically pop)
- `onSignOut` — "Sign out" callback (clear session, navigate to login)

**Usage:**
```dart
await MpSignOut(
  title: 'Sign Out',
  body: 'Are you sure you want to sign out?',
  onSignIn: () => Navigator.pop(context),
  onSignOut: () => _performSignOut(),
).showDialog(context)
```

---

# Templates

Templates are high-level layout patterns and complex composite components.

## Templates — Overview

Templates are the highest-level reusable structures in Mekari Pixel. They define layout skeletons, interaction scaffolds, or complex composites that span multiple components and establish a repeating screen pattern.

**Examples:** accordions, steppers, multi-step flows, data table layouts, wizard scaffolds — structures that dictate the arrangement and sequencing of content rather than the content itself.

**Constraints:** Templates compose components and atoms but carry no domain-specific content. Parameters are slots (`Widget`, callbacks, config objects) — not raw data. Business logic belongs in the BLoC layer above the template, not inside it.

**Usage rule:** Reach for a template when the same structural pattern recurs across multiple features with different content. If only one feature uses the structure, build it inline with components; extract to a template only when the pattern proves reusable.

---

## MpAccordion

A collapsible section with a header (title, caption, optional leading) and expandable content.

**When to use:** Use to progressively disclose content and reduce visual complexity (FAQ, settings groups, optional details). For timeline-specific accordions, use `MpAccordionTimeline` (component).

**Key params:**
- `title` — required header label
- `caption` — secondary header text
- `leading` — optional leading widget (avatar, icon)
- `content` — the collapsible widget
- `initialExpand` — expanded on first render; defaults to `false`

**Usage:**
```dart
MpAccordion(
  title: "Label",
  caption: "This is caption",
  content: Text('Your content will be here'),
)
```

**Figma:** https://www.figma.com/design/djepS92jOSLv9ayVBIcH4M/Mobile-Pixel-2.4?node-id=17792-2289

---

## MpActionGroup

A container that groups related action buttons (typically `MpButton` widgets) with consistent spacing and layout.

**When to use:** Use at the bottom of forms, dialogs, and detail screens where two or more related actions need consistent spacing. Handles button layout automatically.

**Key params:**
- `actions` — list of action widgets; prefer `MpButton`
- `style` — layout and spacing overrides

**Usage:**
```dart
MpActionGroup(
  actions: [
    MpButton.primary(label: 'Submit'),
    MpButton.secondary(label: 'Cancel'),
  ],
)
```

**Figma:** https://www.figma.com/design/djepS92jOSLv9ayVBIcH4M/Mobile-Pixel-2.4?node-id=17503-19579

---

## MpAppLock

A security overlay that hides and locks the app when it goes to the background.

**When to use:** Wrap the root `MaterialApp` in `MpAppLock` for apps requiring session security (banking, HR data). Automatically hides app content in the system task switcher.

**Key params:**
- `lockBuilder` — builds the lock screen widget (PIN gate, biometric prompt)
- `autoLockOnPause` — locks when app goes to background
- `child` — the `MaterialApp` or root widget

**Usage:**
```dart
MpAppLock(
  autoLockOnPause: true,
  lockBuilder: (context) => ExampleAppLockGate(),
  child: MaterialApp(home: HomeScreen()),
)
```

---

## MpBottomSheet

Programmatic bottom sheet trigger with Pixel-styled container, handle, and radius.

**When to use:** Use `MpBottomSheet.show()` as the standard way to show bottom sheets app-wide — it applies consistent radius, handle, and animation. Pass `floating: true` for floating sheet style.

**Key params:**
- `builder` — returns the bottom sheet content widget; use `MpBottomSheetContent` for structure
- `isScrollControlled` — allows full-height sheet; defaults based on content

**Usage:**
```dart
MpBottomSheet.show(
  context,
  builder: (_) => MpBottomSheetContent(
    header: const MpBottomSheetHeader(title: Text('Sheet title')),
    body: const Text('Content here'),
  ),
)
```

---

## MpDialog

Programmatic modal dialog trigger with Pixel-styled container.

**When to use:** Use `MpDialog.show()` for confirmation dialogs, destructive action prompts, and important decision gates. For non-blocking messages, use `MpToast`. For page-level messages, use `MpBanner`.

**Key params:**
- `builder` — returns content widget; use `MpDialogContent` for structure
- `barrierDismissible` — defaults to `false` (user must take explicit action)

**Usage:**
```dart
MpDialog.show(
  context,
  builder: (_) => MpDialogContent(
    header: const MpDialogHeader(title: Text('Confirm delete?')),
    body: const Text('This cannot be undone.'),
  ),
)
```

**Figma:** https://www.figma.com/design/djepS92jOSLv9ayVBIcH4M/Mobile-Pixel-2.4?node-id=17406-4608

---

## MpGuideTour

A full-screen modal tour introducing a new feature, with illustration, content, and actions.

**When to use:** Use for first-time feature discovery after a major release. Show once per user (persist seen state). Prefer `MpWalkthrough` for multi-page onboarding.

**Key params:**
- `header` — `MpGuideTourHeader` with icon and label
- `content` — body widget (text, images)
- `illustration` — visual asset
- `actions` — list of `MpButton` widgets

**Usage:**
```dart
MpGuideTour.show(
  context,
  header: MpGuideTourHeader(icon: MpIcons.logo.mekariQontak.toIcon(), label: 'New Feature'),
  content: Text('Introducing Sales Target'),
  actions: [MpButton.primary(label: 'Explore now', onPressed: () => Navigator.pop(context))],
)
```

---

## MpHorizontalBanner

A tappable promotional banner with gradient background and a pop-out illustration.

**When to use:** Use on home screens and dashboard cards for feature promotions or announcements. The illustration overflows the banner container for visual depth.

**Key params:**
- `titleLabel` / `titleBoldLabel` — two-part title with mixed weight
- `titleWidget` — override with custom widget
- `imagePath` — illustration asset
- `gradient` — background gradient
- `onPressed` — tap callback

**Usage:**
```dart
MpHorizontalBanner(
  titleLabel: "How to run",
  titleBoldLabel: "360º Review",
  imagePath: "assets/illustrations/banner_1.png",
  gradient: LinearGradient(colors: [Color(0xFFEA7A72), Color(0xFFE2483D)]),
  onPressed: () => _showDialog(context),
)
```

---

## MpListTileX

A flexible list row supporting leading (avatar/icon), content area, trailing widget, and action icons.

**When to use:** Use as the standard list row for settings, menu items, entity lists, and any row-based content. Use content variants for consistent label/caption layout: `MpListTileX.single` (one line), `MpListTileX.double` (label + caption), `MpListTileX.triple` (label + two captions), `MpListTileX.overline` (overline + label).

**Key params:**
- `content` — the main content widget; prefer `MpListTileXContent` variants
- `leading` — left widget (avatar, icon, image)
- `trailing` — right widget (text, badge, action text)
- `actions` — list of right-side icon widgets
- `onTap` — makes the row tappable
- `expandedContent` — content fills available width; defaults to `true`

**Usage:**
```dart
MpListTileX(
  content: Text('Flex Benefit'),
  leading: MpAvatar.icon(icon: Icons.person),
  trailing: MpActionText(label: 'Edit'),
  onTap: () {},
)
```

**Figma:** https://www.figma.com/design/djepS92jOSLv9ayVBIcH4M/Mobile-Pixel-2.4?node-id=17360-10958

---

## MpMenuBadge

Positions a badge overlay on top of a menu icon or any child widget.

**When to use:** Use inside `MpBottomNavBar` items or tab icons to show notification counts. The badge is positioned absolutely over the top-end corner by default.

**Key params:**
- `badge` — badge widget; prefer `MpBadge.negativeMenu(text:)`
- `child` — the icon/widget to overlay
- `position` — defaults to `MpMenuBadgePosition.topEnd()`
- `showBadge` — toggle visibility without removing widget

**Usage:**
```dart
MpMenuBadge(
  badge: MpBadge.negativeMenu(text: '9+'),
  child: icon,
)
```

---

## MpProgressIndicator

A progress display with step count or percentage, used for multi-step flows.

**When to use:** Use in multi-step forms, onboarding flows, or task completion tracking to show progress. Use `step` variant when there are discrete named steps; `percentage` when showing a continuous 0-100% value.

**Variants:**
- `MpProgressIndicator.step(title:, value:, maxValue:)` — shows "Step N of M"
- `MpProgressIndicator.percentage(title:, value:)` — shows percentage bar

**Usage:**
```dart
MpProgressIndicator.step(
  title: "Employee Data",
  value: 2,
  maxValue: 4,
)
```

---

## MpPullToRefresh

A pull-to-refresh wrapper that adds swipe-down-to-reload behavior to any scrollable.

**When to use:** Use on any list or scroll view that displays remotely-fetched data that users may need to refresh manually.

**Key params:**
- `controller` — required `MpRefreshController`
- `onRefresh` — async callback; call `controller.refreshCompleted()` when done
- `child` — the scrollable widget

**Usage:**
```dart
MpPullToRefresh(
  controller: _refreshController,
  onRefresh: _onRefresh,
  child: ListView(children: items),
)
```

---

## MpStepper

A step indicator bar for multi-step forms and wizards.

**When to use:** Use at the top of multi-step flows to show which step the user is on and how many remain. Use `number` type for numbered steps, `dot` type for unnamed progress.

**Variants:**
- `MpStepper.number(controller:, children:)` — numbered steps
- `MpStepper.dot(controller:, children:)` — dot indicator

**Key params:**
- `controller` — `MpStepperController` for programmatic navigation
- `children` — list of `MpStepperItem`
- `showLabel` — shows step labels; defaults to `true`

---

## MpStickyButton

A button container that sticks to the bottom of the screen, above the system nav bar.

**When to use:** Use for the primary CTA on forms and detail screens where the button should remain accessible while scrolling. Wrap `MpButton.primary()` as the `button` param.

**Key params:**
- `button` — the button widget to pin

**Usage:**
```dart
MpStickyButton(
  button: MpButton.primary(
    label: 'Submit',
    onPressed: () {},
  ),
)
```

---

## MpToggleHeaderListTileX

A list tile with an integrated toggle switch; supports single-label and custom content layouts.

**When to use:** Use for settings rows where users can enable/disable a feature. Replaces pairing `MpListTileX` + `MpToggle` manually.

**Variants:**
- `MpToggleHeaderListTileX(content:, ...)` — custom content widget in tile body
- `MpToggleHeaderListTileX.single(label:, ...)` — simple single-label row

**Key params:**
- `value` — toggle current state
- `onChanged` — callback with new value; null disables toggle
- `leading` — optional leading widget (icon, avatar)

**Usage:**
```dart
MpToggleHeaderListTileX.single(
  value: _value,
  onChanged: (value) => setState(() => _value = value),
  label: 'Flex Benefit',
)
```

---

## MpWalkthrough

A multi-page onboarding carousel with progress bar, product logo, and swipeable pages.

**When to use:** Use for app onboarding shown at first launch or feature introduction that spans multiple screens. For single-page feature announcements, use `MpGuideTour`.

**Key params:**
- `productLogo` — asset path for product logo
- `productName` — app/product name
- `pages` — list of `WalkthroughPage` records with `id`, `title`, `illustration`
- `pageBuilder` — custom builder for each page content
- `onPageChanged` — called on page navigation

---

## MpCheckboxListTileX

A list tile with an integrated checkbox, for multi-select list rows.

**When to use:** Use in selection lists where each row can be independently selected. For a flat list of checkboxes without tile structure, use `MpCheckboxList` (component).

---

## MpRadioButtonListTileX

A list tile with an integrated radio button, for mutually exclusive list row selection.

**When to use:** Use in selection lists where exactly one row can be selected. Builds on `MpListTileX` with a radio button in the trailing position.
