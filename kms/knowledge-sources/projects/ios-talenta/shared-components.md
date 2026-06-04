# Shared Components — ios-talenta

Platform: iOS (Swift/UIKit)
Scanned: 2026-06-04

## Base Classes

| Component | File | Description |
|-----------|------|-------------|
| `BaseViewController` | `Shared/Presentation/Base/BaseViewController.swift` | Root UIViewController; applies navigation bar visibility, status bar style |
| `TalentaBaseViewController` | `Shared/Presentation/Base/TalentaBaseViewController.swift` | Newer base VC with `DisposeBag`, interactive pop gesture observable, left bar button observable |
| `BaseCoordinator<T>` | `Base/BaseCoordinator.swift` | Generic coordinator base; manages child coordinators, navigation push/pop/dismiss, bottom sheet presentation, FloatingPanel delegate |
| `BaseViewModelV2` | `Shared/Domain/Base/BaseViewModelV2.swift` | Base ViewModel with `ViewModelAction / ViewModelState / ViewModelEvent` pattern |
| `IOViewModelType` | `Base/IOViewModelType.swift` | Input/Output ViewModel protocol |
| `BaseSubViewModel` | `Base/BaseSubViewModel.swift` | Sub-ViewModel base |

## UI Components (MekariPixel — internal design system)

| Component | File | Description |
|-----------|------|-------------|
| `MPButton` | `MekariPixel/…/Button/MPButton.swift` | Styled button |
| `MPTextField` | `MekariPixel/…/TextField/MPTextField.swift` | Styled text field |
| `MPBottomSheet` / `MPBottomSheetCustomViewController` | `MekariPixel/…/Bottom Sheet/` | Bottom sheet with title, action buttons, custom content |
| `MPAppBar` variants | `MekariPixel/…/App Bar/` | `MPTextAppBar`, `MPLogoAppBar`, `MPProfileAppBar`, `MPSearchAppBar`, `MPEmptyAppBar` |
| `MPToast` | `MekariPixel/…/Toast/MPToast.swift` | In-app toast messages |
| `MPDialog` | `MekariPixel/…/Dialog/MpDialog.swift` | Alert/dialog component |
| `MPTabBarPager` | `MekariPixel/…/Tab Bar/` | Segmented pager tab bar with content paging |
| `MPSelect` / `MPSelectTag` | `MekariPixel/…/MPSelect/` | Multi-select tag picker |
| `MPSearch` | `MekariPixel/…/Search/MPSearch.swift` | Search bar component |
| `MPDatePickerView` | `MekariPixel/…/DatePicker/` | Date picker with table view |
| `MpDefaultBanner` | `MekariPixel/…/Banner/MpDefaultBanner.swift` | Banner/alert strip |
| `MpActionGroup` | `MekariPixel/…/Action Group/MpActionGroup.swift` | Action button group |
| `MPColor` | `MekariPixel/…/Styles/Colors/MPColor.swift` | Design system color tokens |
| `MPTextStyle` | `MekariPixel/…/Styles/Typography/MPTextStyle.swift` | Typography tokens |

## Shared UI / Utilities

| Component | File | Description |
|-----------|------|-------------|
| `DraggableBottomSheetViewController` | `Shared/Presentation/Base/DraggableBottomSheetViewController.swift` | Draggable sheet base controller |
| `ShimmerBarView` | `Shared/Presentation/ShimmerView/ShimmerBarView.swift` | Skeleton loading shimmer |
| `CustomTableView` | `Shared/Presentation/CustomTableView/CustomTableView.swift` | Table view with built-in empty/loading state |
| `TourOverlayViewController` / `TourPopupView` | `Shared/Presentation/View/Tour/` | Onboarding tour overlay and popup |

## Attachment Module (MekariAttachment — internal pod)

| Component | File | Description |
|-----------|------|-------------|
| `MekariAttachment` | `MekariAttachment/…/Views/MekariAttachment.swift` | Entry point view for attach/display/remove files |
| `ViewerController` | `MekariAttachment/…/Controllers/ViewerController/` | File viewer (PDF, image, office files) |
| `AddAttachmentCollectionViewCell` | `MekariAttachment/…/Cells/AddAttachment/` | Cell for adding attachment |
| `ShowAttachmentCollectionViewCell` | `MekariAttachment/…/Cells/ShowAttachment/` | Cell for displaying attachment thumbnail |

## Services / Infrastructure

| Component | File | Description |
|-----------|------|-------------|
| `NetworkMiddleware<N>` | `Middleware/Network/Middleware+Network.swift` | Generic network middleware wrapper; calls `CoreNetwork` typed network class |
| `TalentaLocationManager` | `Shared/Infrastructure/Location/TalentaLocationManager.swift` | CLLocationManager wrapper for GPS-gated attendance |
| `AuthService` | `Services/UserService/AuthService.swift` | Keychain + OAuth2 PKCE session management |
| `FeatureFlagManager` | `Shared/Infrastructure/FeatureFlag/FeatureFlagManager.swift` | Firebase Remote Config-backed feature flags (v2, not yet active) |
| `MekariFlagCustomProvider` | `Utils/MekariFlag/MekariFlagCustomProvider.swift` | Active feature flag provider via `MekariFlag` pod |
| `ResponseCacher` | `Shared/Cache/ResponseCacher.swift` | TTL-based response cache |
| `ClarityManager` / `MekariLogManager` | `Shared/Infrastructure/Analytics/` | Microsoft Clarity session recording + Mekari log integration |
| `DeviceFingerprintService` | `Shared/Utils/Service/DeviceFingerprintService.swift` | Device fingerprint for security |
