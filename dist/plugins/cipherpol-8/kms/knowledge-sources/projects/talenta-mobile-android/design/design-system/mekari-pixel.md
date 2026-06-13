# Mekari Pixel — Android Design System Catalog

## Package Info
- **Platform:** Android (Views/Kotlin). Local module dependency.
- **Module:** `lib_core_mekari_pixel`
- **Package:** `co.talenta.lib_core_mekari_pixel`
- **Prefix:** `Mp` (e.g. `MpButton`, `MpTextField`, `MpToast`)
- **Resource prefix:** `mp_` (all res names prefixed)
- **Theme:** `MekariPixel` (extends `Theme.MaterialComponents.Light.NoActionBar.Bridge`)
- **Dependencies:**
  - AndroidX: Core KTX, AppCompat, ConstraintLayout
  - Material Design: Material Components, FlexBox
  - RxBinding 4 (with Material support)
  - Mekari Commons library
- **Source path:** `../talenta-mobile-android/lib_core_mekari_pixel/`

---

# Design Tokens

## Colors

### Core Palette
| Token Name | Hex Value | Usage |
|---|---|---|
| `transparent` | `#00000000` | Transparent states |
| `white` | `#FFFFFF` | Primary background |
| `dark` | `#232933` | Primary text, dark states |
| `background` | `#F2EFED` | Default app background |

### Gray Scale
| Token Name | Hex Value | Usage |
|---|---|---|
| `gray_25` | `#F8F9FB` | Lightest background |
| `gray_50` | `#EDF0F2` | Disabled state backgrounds |
| `gray_100` | `#D0D6DD` | Border/divider color |
| `gray_400` | `#8B95A5` | Secondary text |
| `gray_600` | `#626B79` | Tertiary text, inactive states |
| `neutral_subtle` | `#F0F1F3` | Neutral tap/hover state |
| `neutral_tap` | `#F7F8F9` | Neutral interactive state |

### Blue Palette (Primary Action)
| Token Name | Hex Value | Usage |
|---|---|---|
| `blue_50` | `#EAECFB` | Light blue backgrounds |
| `blue_100` | `#D5DEFF` | Blue tint backgrounds |
| `blue_400` | `#4B61DD` | Primary interactive color, tabs |
| `blue_500` | `#1C44D5` | Primary button hover, ripple |
| `blue_700` | `#0031BE` | Primary button default |
| `color_blue_sky` | `#005FBF` | Alternative blue accent |
| `link` | `#1357FF` | Hyperlink color |

### Red Palette (Danger/Error)
| Token Name | Hex Value | Usage |
|---|---|---|
| `red_50` | `#FDECEE` | Error background |
| `red_400` | `#DA473F` | Error text/icon |
| `red_500` | `#C83E39` | Error hover |
| `red_700` | `#AB3129` | Error default |
| `colorPrimary` | `#C02A34` | Legacy primary color |
| `redButton` | `#9d0001` | Legacy danger button |

### Green Palette (Success)
| Token Name | Hex Value | Usage |
|---|---|---|
| `green_50` | `#E8F5EB` | Success background |
| `green_400` | `#68BE79` | Success lighter |
| `green_500` | `#4FB262` | Success default |
| `green_700` | `#3C914D` | Success darker |
| `leaf_400` | `#22C55E` | Alternative success |

### Orange Palette (Warning)
| Token Name | Hex Value | Usage |
|---|---|---|
| `orange_50` | `#FBF3DD` | Warning background |
| `orange_400` | `#E0AB00` | Warning lighter |
| `orange_500` | `#DE9400` | Warning default |
| `orange_700` | `#DB8000` | Warning darker |

### Data Visualization
| Token Name | Hex Value | Usage |
|---|---|---|
| `sky_100` | `#60A5FA` | Chart color |
| `sky_400` | `#3B82F6` | Chart color |
| `teal_400` | `#14B8A6` | Chart color |
| `rose_400` | `#EF4444` | Badge color (99+ notification) |
| `violet_400` | `#8B5CF6` | Chart color |
| `apricot_400` | `#F97316` | Chart color |
| `amber_400` | `#F59E0B` | Chart color |

### Brand Colors (Mekari Products)
| Token Name | Hex Value | Usage |
|---|---|---|
| `mekari` | `#651FFF` | Mekari brand |
| `talenta` | `#F22929` | Talenta product brand |
| `capital` | `#2F5573` | Capital product |
| `esign` | `#00C853` | E-Sign product |
| `expense` | `#183883` | Expense product |
| `flex` | `#7C4DFF` | Flex product |
| `jurnal` | `#40C3FF` | Jurnal product |
| `klikpajak` | `#FF9100` | KlikPajak product |
| `qontak` | `#2979FF` | Qontak product |
| `university` | `#448AFF` | University product |

### State Colors
| Token Name | Hex Value | Usage |
|---|---|---|
| `overlay` | `#80232933` | Dark overlay (50% opacity) |
| `aqua_100` | `#22D3EE` | Aqua accent |
| `ice_50` | `#E0EEFF` | Ice background |
| `ice_100` | `#B4D3F2` | Ice tint |
| `ash_100` | `#E7EDF5` | Ash background |
| `brand` | `#EEF0FC` | Brand light background |

### Legacy/Deprecated
| Token Name | Hex Value | Usage |
|---|---|---|
| `textColorGray` | `#9D9D9D` | Legacy gray text |
| `greyDefault` | `#777777` | Legacy default gray |
| `slate` | `#777777` | Legacy slate |
| `stone_400` | `#71717A` | Legacy stone |
| `dc_red` | `#E74C3C` | Legacy error |
| `gray` | `#ff888888` | Legacy semi-transparent gray |
| `cloud` | `#F2F4F7` | Legacy cloud color |
| `dark_red` | `#BF000A` | Legacy dark red |
| `light_coral` | `#FB5B58` | Legacy light coral |
| `light_theme_chart_cat06_bold` | `#E2483D` | Legacy chart color |
| `light_theme_text_selected` | `#4B61DC` | Legacy selected text |

## Typography

### Styles (with font weight and line height)
| Style Name | Size | Line Height | Font Weight | Usage |
|---|---|---|---|---|
| `MpTextStyles.LargeTitle` | 24sp | 32sp | Semi-Bold | Page headers, large headlines |
| `MpTextStyles.SectionTitle` | 20sp | 28sp | Semi-Bold | Section headers, dialog titles |
| `MpTextStyles.Label` | 16sp | 24sp | Regular | Body text, button labels, form labels |
| `MpTextStyles.Label.SemiBold` | 16sp | 24sp | Semi-Bold | Emphasized labels, prominent text |
| `MpTextStyles.Body` | 14sp | 20sp | Regular | Standard paragraph text |
| `MpTextStyles.Body.SemiBold` | 14sp | 20sp | Semi-Bold | Emphasized body text |
| `MpTextStyles.Caption` | 12sp | 16sp | Regular | Small supporting text, hints |
| `MpTextStyles.Caption.SemiBold` | 12sp | 16sp | Semi-Bold | Small emphasized text |
| `MpTextStyles.Overline` | 10sp | 12sp | Regular | Tiny labels, metadata |
| `MpTextStyles.Overline.SemiBold` | 10sp | 12sp | Semi-Bold | Tiny emphasized labels |

### Font Families
- **Regular:** `inter_regular`
- **Semi-Bold:** `inter_semi_bold`

### Color Variants
Most text styles have color variants:
- `.Dark` — `#232933` (dark text)
- `.White` — `#FFFFFF` (white text)
- `.Gray400` — `#8B95A5` (secondary text)
- `.Gray600` — `#626B79` (tertiary text)
- `.Blue400` — `#4B61DD` (blue text)
- `.Green700` — `#3C914D` (green success text)
- `.Red400` / `.Red` — Red error text
- `.Primary` — `#C02A34` (primary brand color)
- `.Orange700` — `#DB8000` (orange warning text)
- `.Link` — `#1357FF` (hyperlink blue)

## Spacing & Sizing

### Icon Sizes
| Token | Size |
|---|---|
| `icon_size_20dp` | 20dp |
| `icon_size_21dp` | 21dp |
| `icon_size_24dp` | 24dp |
| `icon_size_25dp` | 25dp |
| `icon_size_30dp` | 30dp |
| `icon_size_32dp` | 32dp |
| `icon_size_47dp` | 47dp |
| `icon_size_60dp` | 60dp |
| `icon_size_75dp` | 75dp |
| `icon_size_90dp` | 90dp |

### Spacing Scale (0dp to 420dp)
Common values: 0, 1, 2, 3, 4, 5, 6, 7, 8, 10, 12, 14, 16, 18, 20, 24, 28, 32, 40, 48, 56, 64, 72, 80, 96, 112, 128, 140, 160, 180, 200, 240, 280, 300, 320, 350, 380, 420

Negative spacing: -2, -6, -8, -54 (for overlap/margin compensation)

### Component Heights & Padding
| Token | Size | Usage |
|---|---|---|
| `spacing_1.5dp` | 1.5dp | Component stroke width |
| `spacing_12dp` | 12dp | Button corner radius, padding |
| `spacing_16dp` | 16dp | Standard padding, margins |
| `spacing_24dp` | 24dp | Component spacing |
| `spacing_48dp` | 48dp | Button height |
| `spacing_56dp` | 56dp | Toolbar/AppBar height |
| `spacing_72dp` | 72dp | Thumbnail image height |

### Line Widths
| Token | Size |
|---|---|
| `line_half` | 0.5dp |
| `line_1` | 1dp |

---

# Components

## Button — `MpButton` (Base Abstract Class)

**Base Class:** `MaterialButton` (Material Components)

**Default Style:** `MpButton` (extends `Widget.MaterialComponents.Button.UnelevatedButton`)

### Properties
- **Layout:** `match_parent` width, `48dp` height
- **Corner radius:** `12dp`
- **Icon size:** `24dp`
- **Icon gravity:** `textStart`
- **Text case:** Disabled (uses actual case)
- **Insets:** All set to `0dp` (no padding around content)

### XML Attributes (from `attrs.xml`)
```xml
<declare-styleable name="MpButton">
    <attr name="isLoading" format="boolean"/>
    <attr name="loadingIcon" format="reference"/>
</declare-styleable>
```

### Key Public Methods
```kotlin
fun isLoading(): Boolean
fun setLoading(show: Boolean)
fun setLoadingIcon(drawable: Drawable?)
fun useIconColor(whenEnableState: Boolean, whenDisableState: Boolean = false)
```

### Loading State
- Prevents click listeners when loading
- Supports custom progress drawable or default circular progress
- Automatically restores button state after loading completes
- Temporarily stores button attributes (text, icon, dimensions) during loading

### Important Properties
- `enableOnClickWhenDisabled: Boolean` — Allow clicks even when button is disabled
- `isUseIconColorWhenDisabled: Boolean` — Control icon tint in disabled state
- `isUseIconColorWhenEnabled: Boolean` — Control icon tint in enabled state

### Button Variants (All extend `MpButton`)

#### `MpButtonPrimary`
- **Style attr:** `mpButtonPrimaryStyle`
- **Background:** `blue_400` (enabled) → `gray_50` (disabled)
- **Text color:** White → Gray (disabled)
- **Stroke:** None
- **Ripple:** `blue_500`
- **Usage:** Primary actions (Save, Submit, Create)

#### `MpButtonSecondary`
- **Style attr:** `mpButtonSecondaryStyle`
- **Background:** White (enabled) → `gray_50` (disabled)
- **Text color:** `blue_400` → Gray (disabled)
- **Stroke:** `1dp` `blue_400` → `gray_100` (disabled)
- **Ripple:** `blue_50`
- **Usage:** Secondary actions (Cancel, Back, Alternative)

#### `MpButtonGhost`
- **Style attr:** `mpButtonGhostStyle`
- **Background:** Transparent
- **Text color:** `blue_400` → Gray (disabled)
- **Stroke:** None
- **Ripple:** `gray_50`
- **Usage:** Tertiary actions (Dismiss, Skip, Optional)

#### `MpButtonDanger`
- **Style attr:** `mpButtonDangerStyle`
- **Background:** `red_700` (enabled) → `gray_50` (disabled)
- **Text color:** White → Gray (disabled)
- **Stroke:** None
- **Ripple:** `red_500`
- **Usage:** Destructive actions (Delete, Remove, Confirm Delete)

### Usage Example (XML)
```xml
<co.talenta.lib_core_mekari_pixel.component.button.MpButtonPrimary
    android:id="@+id/btnSave"
    android:layout_width="match_parent"
    android:layout_height="wrap_content"
    android:text="Save"
    app:icon="@drawable/mp_ic_done_fill"
    app:isLoading="false" />
```

### Usage Example (Kotlin)
```kotlin
val button = MpButtonPrimary(this)
button.text = "Submit"
button.setOnClickListener {
    button.setLoading(true)
    // Do work...
    button.setLoading(false)
}
```

---

## TextField — `MpTextField`

**Base Class:** `FrameLayout`

**Contains:** `MpTextInputLayout` + `MpTextInputEditText`

### XML Attributes
```xml
<declare-styleable name="MpTextField">
    <attr name="text" format="string"/>
    <attr name="inputLayoutHintText" format="string"/>
    <attr name="editTextHintText" format="string"/>
    <attr name="prefixText" format="string"/>
    <attr name="suffixText" format="string"/>
    <attr name="errorText" format="string"/>
    <attr name="helperText" format="string"/>
    <attr name="startIconDrawable" format="reference"/>
    <attr name="endIconDrawable" format="reference"/>
    <attr name="disabled" format="boolean"/>
    <attr name="readOnly" format="boolean"/>
    <attr name="hideUnfocusedUnderline" format="boolean"/>
    <attr name="thumbnailImage" format="reference"/>
    <attr name="thumbnailHeight" format="dimension"/>
    <attr name="showThumbnail" format="boolean"/>
    <attr name="endIconType" format="enum">
        <!-- custom | none | password_toggle | clear_text | dropdown_menu -->
    </attr>
    <attr name="inputType" format="flags">
        <!-- Standard Android InputType flags -->
    </attr>
</declare-styleable>
```

### Key Properties
| Property | Type | Default | Usage |
|---|---|---|---|
| `text` | CharSequence? | null | Field value |
| `inputLayout` | MpTextInputLayout | — | Container layout |
| `editText` | MpTextInputEditText | — | Input field |
| `inputLayoutHintText` | CharSequence? | null | Floating hint |
| `editTextHintText` | CharSequence? | null | Inline placeholder |
| `prefixText` | CharSequence? | null | Text prefix (e.g., "$") |
| `suffixText` | CharSequence? | null | Text suffix (e.g., "USD") |
| `errorText` | CharSequence? | null | Error message |
| `helperText` | CharSequence? | null | Helper text below field |
| `startIconDrawable` | Drawable? | null | Left icon |
| `endIconDrawable` | Drawable? | null | Right icon |
| `endIconType` | Int | `END_ICON_NONE` | Icon mode (clear, password toggle, dropdown) |
| `disabled` | Boolean | false | Disable entire field |
| `readOnly` | Boolean | false | Read-only mode (no edit) |
| `hideUnfocusedUnderline` | Boolean | false | Hide underline when unfocused |
| `inputType` | Int | `TYPE_CLASS_TEXT` | Input type (phone, email, number, etc.) |
| `thumbnailHeight` | Int | 72dp | Height of thumbnail image |
| `showThumbnail` | Boolean | false | Show/hide thumbnail |

### Thumbnail Image Methods
```kotlin
fun setThumbnailImage(bitmap: Bitmap?)
fun setThumbnailImage(uri: Uri?)
fun setThumbnailImage(resourceId: Int)
fun clearThumbnailImage()
fun setThumbnailClickListener(listener: OnClickListener?)
fun setRemoveThumbnailClickListener(listener: OnClickListener?)
```

### Thumbnail Behavior
- Fixed size: 72dp x 72dp (customizable via `thumbnailHeight`)
- Positioned left of input field
- Auto-hides remove button when thumbnail is gone
- Remove button automatically clears thumbnail, then fires custom listener
- EditText height auto-adjusts when thumbnail visible (thumbnail + 32dp)

### Usage Example (XML)
```xml
<co.talenta.lib_core_mekari_pixel.component.textfield.MpTextField
    android:id="@+id/tfEmail"
    android:layout_width="match_parent"
    android:layout_height="wrap_content"
    app:inputLayoutHintText="Email Address"
    app:startIconDrawable="@drawable/mp_ic_envelop_duotone"
    app:inputType="textEmailAddress"
    app:helperText="We'll never share your email" />
```

### Usage Example (Kotlin)
```kotlin
val textField = MpTextField(this)
textField.inputLayoutHintText = "Name"
textField.text = "John Doe"
textField.editText.doAfterTextChanged { text ->
    // Validate on text change
}
```

---

## TextInputLayout — `MpTextInputLayout`

**Base Class:** `TextInputLayout` (Material Components)

**Default Style:** `MpTextInputLayout` (extends `Widget.MaterialComponents.TextInputLayout.FilledBox`)

### XML Attributes
```xml
<declare-styleable name="MpTextInputLayout">
    <attr name="isRequired" format="boolean"/>
    <attr name="hideUnfocusedUnderline" format="boolean"/>
</declare-styleable>
```

### Key Properties
| Property | Type | Default | Usage |
|---|---|---|---|
| `isRequired` | Boolean | false | Auto-add red "*" asterisk to hint |
| `hideUnfocusedUnderline` | Boolean | false | Show underline only when focused |

### Features
- **Required indicator:** Automatically appends red asterisk ("*") to hint when `isRequired=true`
- **Dynamic hint:** When prefix/suffix set, shows "(prefix)" in unfocused state
- **Underline visibility:** Can hide stroke/underline when not focused
- **End icon modes:**
  - `END_ICON_CLEAR_TEXT` → Shows `mp_ic_reset` icon
  - `END_ICON_DROPDOWN_MENU` → Shows `mp_ic_chevrons_down` icon
  - `END_ICON_PASSWORD_TOGGLE` → Shows `mp_selector_password_toggle` icon
  - `END_ICON_CUSTOM` / `END_ICON_NONE` → Custom or no icon

### Usage Example
```kotlin
val layout = MpTextInputLayout(context)
layout.isRequired = true
layout.hint = "Password"
layout.endIconMode = TextInputLayout.END_ICON_PASSWORD_TOGGLE
```

---

## TextInputEditText — `MpTextInputEditText`

**Base Class:** `TextInputEditText` (Material Components)

**Default Style:** `MpTextInputEditText` (extends `Widget.MaterialComponents.TextInputEditText.FilledBox`)

### XML Attributes
```xml
<declare-styleable name="MpTextInputEditText">
    <attr name="excludeEmoji" format="boolean"/>
</declare-styleable>
```

### Properties
| Property | Type | Default | Usage |
|---|---|---|---|
| `excludeEmoji` | Boolean | false | Block emoji input |

### Features
- **Default font:** `inter_regular`
- **Emoji filter:** Optional input filter that blocks emoji and special symbols
- **Method:** `setExcludeEmoji(exclude: Boolean)` — Toggle emoji filtering

### Usage Example
```kotlin
val editText = MpTextInputEditText(context)
editText.setExcludeEmoji(true)
```

---

## Dialog — `MpDialog`

**Base Class:** `AlertDialog` (AndroidX AppCompat)

### Factory Methods
```kotlin
MpDialog.create(context: Context): MpDialog
MpDialog.createCloseDialog(context: Context): MpDialog  // ONE_BUTTON, DEFAULT style
MpDialog.createDeleteDialog(context: Context): MpDialog // TWO_BUTTON, DANGER_GHOST style
MpDialog.createSaveDialog(context: Context): MpDialog   // THREE_BUTTON, PRIMARY_SECONDARY style
MpDialog.createNoneDialog(context: Context): MpDialog   // No action group
```

### Key Methods
```kotlin
fun setTitle(title: CharSequence?)
fun setTitle(titleId: Int)
fun setMessage(message: CharSequence?)
fun setActionGroupButton(type: ActionGroupButtonType, style: ActionGroupButtonStyle)
fun setTitleMaxLines(maxLines: Int)
fun setPositiveButton(attribute: ButtonAttribute, action: (() -> Unit)? = null)
fun setNegativeButton(attribute: ButtonAttribute, action: (() -> Unit)? = null)
fun setOptionalButton(attribute: ButtonAttribute, action: (() -> Unit)? = null)
fun withoutActionGroup()
```

### ButtonAttribute Data Class
```kotlin
data class ButtonAttribute(
    val title: String,
    @GravityInt val titleGravity: Int = Gravity.CENTER,
    val icon: Drawable? = null,
    @MaterialButton.IconGravity val iconGravity: Int = MaterialButton.ICON_GRAVITY_START,
    val useIconColor: Boolean = false,
)
```

### Action Group Button Types
- `ONE_BUTTON` — Shows only positive button
- `TWO_BUTTON` — Shows positive + negative
- `THREE_BUTTON` — Shows positive + negative + optional

### Action Group Button Styles
- `DEFAULT` — Primary (positive) + Ghost (negative)
- `PRIMARY_SECONDARY` — Primary (positive) + Secondary (negative)
- `MAIN_SECONDARY` — Secondary (positive) + Ghost (negative)
- `DANGER_GHOST` — Danger (positive) + Ghost (negative)

### Usage Example
```kotlin
MpDialog.create(this).apply {
    setTitle("Confirm Delete")
    setMessage("Are you sure you want to delete this item?")
    setActionGroupButton(
        type = MpActionGroup.ActionGroupButtonType.TWO_BUTTON,
        style = MpActionGroup.ActionGroupButtonStyle.DANGER_GHOST
    )
    setPositiveButton(
        attribute = MpDialog.ButtonAttribute(
            title = "Delete",
            icon = getDrawable(R.drawable.mp_ic_delete_fill)
        ),
        action = { deleteItem() }
    )
    setNegativeButton(
        attribute = MpDialog.ButtonAttribute(title = "Cancel"),
        action = { dismiss() }
    )
    show()
}
```

---

## Toast — `MpToast`

**Base Class:** `BaseTransientBottomBar<MpToast>` (Material Components Snackbar)

**Contains:** `MpToastLayout` (custom view for styling)

### Factory Methods
```kotlin
fun make(view: View, message: String, durationInMillis: Int = DURATION_DEFAULT): MpToast
fun makeInfo(view: View, message: String, durationInMillis: Int = DURATION_DEFAULT): MpToast
fun makeError(view: View, message: String, durationInMillis: Int = DURATION_DEFAULT): MpToast
fun makeWarning(view: View, message: String, durationInMillis: Int = DURATION_DEFAULT): MpToast
fun makeSuccess(view: View, message: String, durationInMillis: Int = DURATION_DEFAULT): MpToast
```

### Key Methods
```kotlin
fun setMessage(message: String): MpToast
fun setTextColor(hexColor: String): MpToast
fun setTextColor(colorStateList: ColorStateList): MpToast
fun setTextColorResource(@ColorRes colorRes: Int): MpToast
fun setIconDrawable(drawable: Drawable?): MpToast
fun setIconDrawableResource(@DrawableRes drawableRes: Int): MpToast
fun setStrokeColor(hexColor: String): MpToast
fun setStrokeColorResource(@ColorRes colorRes: Int): MpToast
fun setBackgroundColor(hexColor: String): MpToast
fun setBackgroundColorResource(@ColorRes colorRes: Int): MpToast
fun setCornerRadius(radius: Float): MpToast
fun setCornerRadiusResource(@DimenRes dimenRes: Int): MpToast
fun setContentElevation(elevation: Float): MpToast
fun setContentElevationResource(@DimenRes dimenRes: Int): MpToast
fun setContentMargin(start: Int, top: Int, end: Int, bottom: Int): MpToast
fun setContentMarginResource(@DimenRes start: Int, @DimenRes top: Int, @DimenRes end: Int, @DimenRes bottom: Int): MpToast
fun setToastPosition(@ToastPosition position: Int): MpToast
fun setToastDuration(durationInMillis: Int): MpToast
fun setMaxLine(maxLine: Int): MpToast
fun setEllipsize(where: TextUtils.TruncateAt?): MpToast
fun show()
```

### Toast Positions
- `SHOW_ON_TOP` (Gravity.TOP)
- `SHOW_ON_CENTER` (Gravity.CENTER)
- `SHOW_ON_BOTTOM` (Gravity.BOTTOM) — Default

### Duration Constants
```kotlin
const val DURATION_DEFAULT = 3500        // 3.5 seconds
const val DURATION_INDEFINITE = LENGTH_INDEFINITE
```

### Predefined Types
| Method | Icon | Stroke Color | Usage |
|---|---|---|---|
| `makeInfo()` | `mp_ic_info_duo_tone` | `blue_500` | Information |
| `makeSuccess()` | `mp_ic_done_duo_tone` | `green_500` | Success |
| `makeError()` | `mp_ic_error_duo_tone` | `red_500` | Error |
| `makeWarning()` | `mp_ic_warning_triangle_duo_tone` | `orange_500` | Warning |

### Usage Example
```kotlin
MpToast.makeSuccess(
    view = binding.root,
    message = "Item saved successfully",
    durationInMillis = MpToast.DURATION_DEFAULT
).apply {
    setToastPosition(MpToast.SHOW_ON_TOP)
    setContentMargin(16, 16, 16, 16)
}.show()
```

---

## Search — `MpSearch`

**Base Class:** `FrameLayout`

### XML Attributes
```xml
<declare-styleable name="MpSearch">
    <attr name="searchIcon" format="reference"/>
    <attr name="resetIcon" format="reference"/>
    <attr name="showFilterButton" format="boolean"/>
    <attr name="showEndButton" format="boolean"/>
    <attr name="searchHint" format="string"/>
    <attr name="searchQuery" format="string"/>
    <attr name="searchBackgroundColor" format="color"/>
    <attr name="searchBackgroundColorHighlighted" format="color"/>
    <attr name="searchStrokeColor" format="color"/>
    <attr name="searchStrokeColorHighlighted" format="color"/>
    <attr name="filterText" format="string"/>
    <attr name="endButtonText" format="string"/>
</declare-styleable>
```

### Key Properties
| Property | Type | Default | Usage |
|---|---|---|---|
| `searchIcon` | @DrawableRes | `mp_ic_search_outline` | Search icon |
| `resetIcon` | @DrawableRes | `mp_ic_reset` | Clear/reset icon |
| `isShowFilterButton` | Boolean | false | Show filter button |
| `isShowEndButton` | Boolean | false | Show end button |
| `searchEditText` | TextInputEditText | — | Input field |

### Key Methods
```kotlin
fun setHint(charSequence: CharSequence)
fun getHint(): CharSequence?
fun setQuery(charSequence: CharSequence)
fun setFilterButtonText(charSequence: CharSequence)
fun setEndButtonText(charSequence: CharSequence)
fun setFilterButtonClickListener(listener: OnClickListener)
fun setEndButtonClickListener(listener: OnClickListener)
fun setSearchBackground(@ColorRes backgroundColor: Int, @ColorRes strokeColor: Int)
fun setSearchBackgroundHighlighted(@ColorRes backgroundColor: Int, @ColorRes strokeColor: Int)
```

### Default Styling
- **Unfocused:** White background + `gray_100` stroke
- **Focused:** White background + `blue_400` stroke (highlighted)
- **Corner radius:** Rounded (999dp = full radius)
- **Margins:** 16dp default, adjusted with buttons visible

### Usage Example
```kotlin
val search = MpSearch(this)
search.isShowFilterButton = true
search.setHint("Search employees...")
search.setFilterButtonText("Advanced")
search.setFilterButtonClickListener {
    openAdvancedFilters()
}
```

---

## Select — `MpSelect`

**Base Class:** `MpTextField`

### XML Attributes
```xml
<declare-styleable name="MpSelect">
    <attr name="mode" format="enum">
        <enum name="basic" value="0"/>        <!-- Chevron down icon -->
        <enum name="date" value="1"/>         <!-- Calendar icon -->
        <enum name="time" value="2"/>         <!-- Clock icon -->
        <enum name="redirect" value="3"/>     <!-- Chevron right icon -->
    </attr>
</declare-styleable>
```

### Properties
| Property | Type | Default | Icon | Usage |
|---|---|---|---|---|
| `mode` | Int | `MODE_BASIC` (0) | `mp_ic_chevrons_down` | Dropdown selector |
| | | `MODE_DATE` (1) | `mp_ic_calendar_outline` | Date picker |
| | | `MODE_TIME` (2) | `mp_ic_time_outline` | Time picker |
| | | `MODE_REDIRECT` (3) | `mp_ic_chevrons_right` | Redirect/navigation |

### Key Methods
```kotlin
var mode: Int  // Get/set select mode (0-3)
```

### Behavior
- Disables text editing (not focusable, not editable)
- Hides cursor
- Allows long-click and click
- End icon mode auto-set to CUSTOM based on mode
- Click listeners propagate to editText, startIcon, and endIcon

### Usage Example
```kotlin
val select = MpSelect(this).apply {
    mode = MpSelect.MODE_DATE
    editTextHintText = "Select date..."
    setOnClickListener {
        showDatePicker()
    }
}
```

---

## SelectTag — `MpSelectTag`

**Base Class:** `ConstraintLayout`

### XML Attributes
```xml
<declare-styleable name="MpSelectTagView">
    <attr name="hint" format="string"/>
</declare-styleable>
```

### Key Properties
```kotlin
var hint: CharSequence?  // Get/set hint text
var selectedOptions: List<String>  // Get/set selected items
```

### Key Views
| Property | Type | Access |
|---|---|---|
| `inputLayout` | MpTextInputLayout | Editable input state |
| `etSelect` | MpTextInputEditText | Input field |
| `clTags` | ConstraintLayout | Chip container (when items selected) |

### Behavior
- **Input state (empty):** Shows input field with hint
- **Chip state (selected):** Shows first 2 items as chips
- **Overflow:** Shows "+N others" label for remaining items
- **Chip styling:** Gray background + gray text, 4dp radius, 2dp margins

### Usage Example
```kotlin
val selectTag = MpSelectTag(this)
selectTag.hint = "Select employees..."
selectTag.selectedOptions = listOf("John Doe", "Jane Smith", "Bob Wilson")
selectTag.setOnClickListener {
    openMultiSelectDialog()
}
```

---

## AppBar — `MpAppBar` (Base Abstract)

**Base Class:** `MaterialToolbar`

**Default Style:** `MpAppBar`

### Variants (All extend `MpAppBar`)

#### `MpAppBar` (Base)
- **Background:** `background` (#F2EFED)
- **Title style:** `MpTextStyles.SectionTitle.Dark` (20sp, semi-bold)
- **Subtitle style:** `MpTextStyles.Label` (16sp, regular)
- **Title alignment:** Centered
- **Navigation icon:** None
- **Usage:** Standard app bar with title/subtitle

#### `MpAppBarText`
- **Style attr:** `mpAppBarTextStyle`
- **Navigation icon:** `mp_ic_arrow_left` (back button)
- **Usage:** Screen headers with back navigation

#### `MpAppBarProfile`
- **Title alignment:** Left-aligned (not centered)
- **Content insets:** 16dp start, 16dp end, 0dp start/end with navigation or actions
- **Usage:** Profile/detail screens

#### `MpAppBarLogo`
- **Content insets:** 0dp (full-width logo)
- **XML attr:** `logoCentered` (boolean) — Center logo horizontally
- **Usage:** App branding, full-width logos

#### `MpAppBarSearch`
- **Content insets:** 16dp start, 0dp end with actions
- **Usage:** Search screens

### Key Methods
```kotlin
fun getTitleTextView(): TextView?
fun getSubtitleTextView(): TextView?
```

### Usage Example (XML)
```xml
<co.talenta.lib_core_mekari_pixel.component.appbar.MpAppBarText
    android:id="@+id/appbar"
    android:layout_width="match_parent"
    android:layout_height="wrap_content"
    android:title="Screen Title"
    android:subtitle="Subtitle text" />
```

---

## ActionGroup — `MpActionGroup`

**Base Class:** `LinearLayoutCompat`

### XML Attributes
```xml
<declare-styleable name="MpActionGroup">
    <attr name="actionGroupButtonType" format="flags">
        <flag name="OneButton" value="1"/>
        <flag name="TwoButton" value="2"/>
        <flag name="ThreeButton" value="3"/>
    </attr>
    <attr name="actionGroupButtonStyle" format="flags">
        <flag name="Default" value="1"/>              <!-- Primary + Ghost -->
        <flag name="PrimarySecondary" value="2"/>     <!-- Primary + Secondary -->
        <flag name="MainSecondary" value="3"/>        <!-- Secondary + Ghost -->
        <flag name="DangerGhost" value="4"/>          <!-- Danger + Ghost -->
    </attr>
    <attr name="actionGroupReverseButton" format="boolean"/>
    <attr name="positiveButtonId" format="reference"/>
    <attr name="positiveButtonText" format="string"/>
    <attr name="positiveButtonIcon" format="reference"/>
    <attr name="positiveButtonIconGravity" format="flags"/>
    <attr name="negativeButtonId" format="reference"/>
    <attr name="negativeButtonText" format="string"/>
    <attr name="negativeButtonIcon" format="reference"/>
    <attr name="negativeButtonIconGravity" format="flags"/>
    <attr name="optionalButtonId" format="reference"/>
    <attr name="optionalButtonText" format="string"/>
    <attr name="optionalButtonIcon" format="reference"/>
    <attr name="optionalButtonIconGravity" format="flags"/>
</declare-styleable>
```

### Key Properties
```kotlin
var positiveButton: MpButton
var negativeButton: MpButton
var optionalButton: MpButton
var isReversed: Boolean
```

### Enums
```kotlin
enum class ActionGroupButtonType(val attrValue: Int) {
    ONE_BUTTON(1),
    TWO_BUTTON(2),
    THREE_BUTTON(3)
}

enum class ActionGroupButtonStyle(val attrValue: Int) {
    DEFAULT(1),              // MpButtonPrimary + MpButtonGhost
    PRIMARY_SECONDARY(2),    // MpButtonPrimary + MpButtonSecondary
    MAIN_SECONDARY(3),       // MpButtonSecondary + MpButtonGhost
    DANGER_GHOST(4),         // MpButtonDanger + MpButtonGhost
}

enum class IconGravity(val attrValue: Int, val gravityValue: Int) {
    START(1, ICON_GRAVITY_START),
    TEXT_START(2, ICON_GRAVITY_TEXT_START),
    END(3, ICON_GRAVITY_END),
    TEXT_END(4, ICON_GRAVITY_TEXT_END),
    TOP(5, ICON_GRAVITY_TOP),
    TEXT_TOP(6, ICON_GRAVITY_TEXT_TOP),
}
```

### Key Methods
```kotlin
fun setActionGroup(type: ActionGroupButtonType, style: ActionGroupButtonStyle)
fun setActionGroupButtonId(positiveButtonId: Int, negativeButtonId: Int, optionalButtonId: Int)
fun reverseButton(reverse: Boolean)
```

### Layout Behavior
- **Horizontal:** Buttons distributed with `weight=1` (equal width)
- **Vertical:** Buttons stacked with wrap_content height
- **Margins:** 12dp padding start/end, 16dp top/bottom (from style)

### Usage Example
```kotlin
val actionGroup = MpActionGroup(this)
actionGroup.setActionGroup(
    type = MpActionGroup.ActionGroupButtonType.TWO_BUTTON,
    style = MpActionGroup.ActionGroupButtonStyle.PRIMARY_SECONDARY
)
actionGroup.positiveButton.text = "Save"
actionGroup.positiveButton.setOnClickListener { save() }
actionGroup.negativeButton.text = "Cancel"
actionGroup.negativeButton.setOnClickListener { cancel() }
```

---

## TabLayout — `MpTabLayout`

**Base Class:** `TabLayout` (Material Components)

**Default Style:** `MpTabLayoutStyle`

### XML Attributes
```xml
<declare-styleable name="MpTabLayout">
    <attr name="attachedViewPager" format="reference"/>
    <attr name="labelTextSize" format="reference"/>
</declare-styleable>
```

### Key Properties
```kotlin
var viewPagerAdapter: BasePageAdapter?
```

### Key Methods
```kotlin
fun setupWithViewPager(viewPager: ViewPager?)
fun updateListFragment(fragmentViewList: List<FragmentViewModel>)
fun updateBadgeCount(position: Int, number: Int)
```

### Tab Styling
- **Indicator color:** `blue_400`
- **Indicator height:** 3dp
- **Selected text style:** Bold, `blue_400` color, 16sp (auto-sized if not fixed)
- **Unselected text style:** Regular, `gray_600` color, 16sp
- **Background:** White
- **Icon + Text:** Icons display with text below
- **Badge:** Red badge with white text (only for selected tabs with count > 0)

### Badge Behavior
- Shows numeric count (up to 99) or "99+" for larger counts
- Auto-displays on selected tab when `updateBadgeCount()` called
- Updates when tab selection changes

### Dynamic Height
Supports auto-height adjustment via `remeasureCurrentPage()` method when tab selected (for WrapContentViewPager).

### Usage Example
```kotlin
val tabLayout = MpTabLayout(this)
tabLayout.viewPagerAdapter = myPageAdapter
tabLayout.setupWithViewPager(viewPager)
tabLayout.updateBadgeCount(0, 5)  // Show "5" badge on first tab
```

---

## BottomNavigationBar — `MpBottomNavBar`

**Base Class:** `BottomNavigationView` (Material Components)

**Default Style:** `MpBottomNavigationBar`

### Styling
- **Label visibility:** Labeled (always show labels)
- **Active text style:** `MpTextStyles.Overline.SemiBold` (10sp)
- **Inactive text style:** `MpTextStyles.Overline` (10sp)
- **Text color:** `mp_selector_bottom_navigation_default` (dark when active, gray_600 when inactive)
- **Icon tint:** `mp_selector_bottom_navigation_default`
- **Ripple color:** `blue_50`
- **Background:** White
- **Divider:** 1dp stroke (from parent styling)

### Key Methods
```kotlin
fun addOrUpdateBadgeView(menuItemId: Int, count: Int)
fun removeBadgeView(menuItemId: Int)
fun setMenuVisibility(menuItemId: Int, isVisible: Boolean)
fun setBackgroundColor(hexColor: String)
```

### Badge Behavior
- **Custom implementation** (not Material's native badge)
- **Display:** Red circle for 1-digit, rounded rectangle for 2+ digits
- **Max shown:** 99, displays "99+" for higher counts
- **Stroke:** White 1.5dp border around badge
- **Auto-restore:** Badges persist even when menu item visibility changes

### Usage Example
```kotlin
val bottomNav = MpBottomNavBar(this)
bottomNav.menu.clear()
bottomNav.inflateMenu(R.menu.menu_bottom_nav)
bottomNav.addOrUpdateBadgeView(R.id.nav_inbox, 5)
bottomNav.setOnNavigationItemSelectedListener { item ->
    when (item.itemId) {
        R.id.nav_home -> showHome()
        R.id.nav_inbox -> showInbox()
    }
    true
}
```

---

## ProgressIndicator — `MpProgressIndicator`

**Base Class:** `ProgressBar`

**Default Style:** `MpProgressIndicator`

### Properties
| Property | Value |
|---|---|
| Layout width | match_parent |
| Layout height | wrap_content |
| Max progress | 8 |
| Default progress | 4 (50%) |
| Drawable | `mp_bg_progress_indicator` |

### Usage
Generally used for multi-step progress display (e.g., 4/8 steps completed).

### Usage Example
```kotlin
val progress = MpProgressIndicator(this)
progress.max = 8
progress.progress = 3  // 3/8 steps
```

---

## ImageView — `MpZoomableImageView`

**Base Class:** `AppCompatImageView`

### Features
- **Pinch zoom:** Scale factor between 1x and 4x
- **Pan/drag:** Move image around when zoomed
- **Fit-to-screen:** Auto-fit image on load
- **Double-finger zoom:** ScaleGestureDetector support

### Scale Limits
- **Minimum:** 1.0x (fit to screen)
- **Maximum:** 4.0x (8x pixel area)

### Touch Gestures
- **Single finger drag:** Pan when zoomed
- **Two finger pinch:** Zoom in/out
- **Boundary constraints:** Prevents over-panning beyond image bounds

### Usage Example
```kotlin
val imageView = MpZoomableImageView(this, null)
imageView.setImageResource(R.drawable.sample_image)
// User can pinch-zoom and drag
```

---

# Assets

## Icons (427 total drawable resources)

Icons are named with prefix `mp_ic_` and follow Material Design conventions.

### Common Icon Categories

#### Navigation & Direction
- `arrow_left`, `arrow_right`, `arrow_up`, `arrow_down`
- `chevrons_left`, `chevrons_right`, `chevrons_up`, `chevrons_down`
- `caret_up`, `caret_down`, `caret_right`
- `expand_arrow`, `collapse_arrow`
- `jump_forward`, `jump_previous`
- `link_external`, `link_internal`
- `expand_default`, `collapse_default`
- `expand_arrow`

#### Actions & Status
- `done`, `check` (Success/checkmark)
- `close` (Close/dismiss)
- `delete` (Delete/remove)
- `edit` (Edit/modify)
- `refresh`, `redo`, `undo`
- `download`, `upload`
- `copy`
- `search`

#### Media & Files
- `file_image`, `file_video`, `file_audio`, `file_code`, `file_music`
- `doc` (Document)
- `pdf`
- `folder_open`, `folder_close`
- `attachment`
- `image` / `img`
- `camera`, `flip_camera`
- `video`

#### Communication
- `chat`, `comment`
- `notification`
- `sent`, `reply`, `forward`
- `envelop` (Email)
- `phone`

#### UI & Input
- `check_box_*` (default, selected, disabled, disabled_selected)
- `radio_button_*` (default, selected, disabled)
- `switch_*` (default, selected, disabled)
- `toggle_*` (various states)

#### System & Settings
- `settings`
- `help_*` (help, help_centre)
- `info`, `info_fill`, `error`
- `warning_*` (warning_triangle, warning_circular)
- `security`
- `protection`
- `language`
- `password`
- `fingerprint`, `face_id`

#### User & Profile
- `profile`, `people`, `contact`, `team`
- `user`
- `id_card`

#### Business & Finance
- `briefcase`
- `money` / `payment`
- `payslip`
- `invoice`
- `receipt`
- `chart_of_account`

#### Time & Scheduling
- `calendar`, `time`, `schedule`, `clock`
- `history`
- `timeout`

#### Filters & Views
- `filter`
- `sort_*` (sort_default, sort_ascending, sort_descending)
- `sliders`
- `table_view_*` (column, field, filter, sort, list, list_fill_v2)

#### Mekari Products
- `logo_mekari*` (Mekari, Account, Flex, Jurnal, KlikPajak, Talenta)

#### Form & Interaction
- `add`, `minus`
- `add_circular_*` (add_circular_outline, add_circular_fill, add_circular_duo_tone)
- `drag`

### Icon Variants

Icons typically available in three styles:

1. **Outline** (`_outline`) — Stroke only (recommended for default states)
2. **Fill** (`_fill`) — Solid fill (recommended for selected/active states)
3. **Duotone** (`_duo_tone`) — Two-color (recommended for emphasis)

### Example Icon Set
For a feature like "Employees", you might find:
- `mp_ic_employee_outline.xml` (Stroke)
- `mp_ic_people_outline.xml` (Stroke, plural)
- `mp_ic_people_fill.xml` (Fill, plural)
- `mp_ic_people_duotone.xml` (Two-color, plural)

---

# Setup & Integration

## Gradle Dependency

In your app module's `build.gradle`:

```gradle
dependencies {
    implementation project(':lib_core_mekari_pixel')
}
```

The module itself depends on:
```gradle
implementation commonDependencies.androidxCoreKtx
implementation commonDependencies.androidxAppCompat
implementation commonDependencies.constraintLayout
implementation commonDependencies.androidMaterial
implementation commonDependencies.flexBox
implementation commonDependencies.mekariCommons
implementation commonDependencies.rxBinding4
implementation commonDependencies.rxBinding4Material
```

## Theme Application

In your app's `AndroidManifest.xml`:

```xml
<application
    android:theme="@style/MekariPixel"
    ... >
    <!-- Activities inherit this theme -->
</application>
```

Or in individual Activity:

```xml
<activity
    android:name=".MainActivity"
    android:theme="@style/MekariPixel"
    ... />
```

## XML Namespace

In your layout files, declare the namespace:

```xml
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:orientation="vertical">

    <!-- Use app:* attributes for custom properties -->

</LinearLayout>
```

## Common Kotlin Imports

```kotlin
import co.talenta.lib_core_mekari_pixel.component.button.*
import co.talenta.lib_core_mekari_pixel.component.textfield.*
import co.talenta.lib_core_mekari_pixel.component.dialog.MpDialog
import co.talenta.lib_core_mekari_pixel.component.toast.MpToast
import co.talenta.lib_core_mekari_pixel.component.search.MpSearch
import co.talenta.lib_core_mekari_pixel.component.select.*
import co.talenta.lib_core_mekari_pixel.component.appbar.*
import co.talenta.lib_core_mekari_pixel.component.actiongroup.MpActionGroup
import co.talenta.lib_core_mekari_pixel.component.tabs.MpTabLayout
import co.talenta.lib_core_mekari_pixel.component.bottomnavigationbar.MpBottomNavBar
import co.talenta.lib_core_mekari_pixel.component.progressindicator.MpProgressIndicator
```

## Resource Prefix Enforcement

The build.gradle defines:
```gradle
android {
    android {
        resourcePrefix 'mp_'
    }
}
```

All resource names must use the `mp_` prefix to avoid conflicts with other libraries and comply with Mekari Pixel conventions.

---

# Additional Reference

## Color State Lists

Button and interactive components use color state lists (in `/res/color/`) to automatically handle enabled/disabled states:

- `mp_selector_button_primary_background` — Blue→Gray50 based on enabled state
- `mp_selector_button_secondary_background` — White→Gray50 based on enabled state
- `mp_selector_button_secondary_stroke` — Blue→Gray100 based on enabled state
- `mp_selector_button_danger_background` — Red→Gray50 based on enabled state
- `mp_selector_button_*_text` — Text colors per button variant
- `mp_selector_button_ghost_text` — Ghost button text color selector
- `mp_selector_text_input_layout_*` — TextInput state colors
- `mp_selector_bottom_navigation_default` — BottomNav active/inactive colors
- `mp_selector_tab_text` — Tab selected/unselected text colors

## Custom Drawable Resources

- `mp_bg_circle_gray_50` — Gray circular background (for avatars)
- `mp_bg_box_rounded_white_16_inset_16` — Rounded white box (for dialogs)
- `mp_bg_progress_indicator` — Progress bar drawable
- `mp_divider_action_group` — Divider between action group buttons
- `mp_ripple_bottom_navigation_default` — Ripple effect for bottom nav
- `mp_selector_radio_button_option` — Radio button drawable
- `mp_selector_check_box_option` — Checkbox drawable
- `mp_selector_switch_option` — Switch drawable
- `mp_selector_password_toggle` — Password visibility toggle icon

---

# Version & Conventions

- **Kotlin version:** 1.x (with Android extensions and viewBinding)
- **Minimum API level:** Typically API 21+ (check parent project)
- **Namespace:** `co.talenta.lib_core_mekari_pixel`
- **Build type:** Android Library (AAR)
