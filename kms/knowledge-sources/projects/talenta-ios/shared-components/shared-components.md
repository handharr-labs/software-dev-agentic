---
scope: project/talenta-ios
platform: ios
discipline: engineering
artifact: shared-components
---
# Shared Components

## BaseViewController

- path: Talenta/Shared/Presentation/Base/BaseViewController.swift
- type: UIViewController subclass
- params: toggleVM: ToggleViewModel?, userVM: UserViewModel?
- note: Conforms to CustomNavigationBar; base for legacy controller layer

## TalentaBaseViewController

- path: Talenta/Shared/Presentation/Base/TalentaBaseViewController.swift
- type: UIViewController subclass
- note: Base for Clean Architecture module view controllers

## DraggableBottomSheetViewController

- path: Talenta/Shared/Presentation/Base/DraggableBottomSheetViewController.swift
- type: TalentaBaseViewController subclass
- note: Draggable bottom sheet; subclass and override setupContentView() to add content

## ShimmerBarView

- path: Talenta/Shared/Presentation/ShimmerView/ShimmerBarView.swift
- type: UIView subclass
- note: Skeleton/shimmer loading placeholder bar

## CustomTableView

- path: Talenta/Shared/Presentation/CustomTableView/CustomTableView.swift
- type: UITableView subclass
- note: Shared table view with custom configuration

## TourOverlayViewController

- path: Talenta/Shared/Presentation/View/Tour/TourOverlayViewController.swift
- type: UIViewController
- note: Overlay for onboarding tour steps

## TourPopupView

- path: Talenta/Shared/Presentation/View/Tour/TourPopupView.swift
- type: UIView
- note: Popup bubble used in onboarding tour flow

## TalentaPrimaryButton

- path: Talenta/Views/Button/TalentaPrimaryButton.swift
- type: UIButton subclass
- note: Primary action button with Talenta styling

## TalentaSecondaryButton

- path: Talenta/Views/Button/TalentaSecondaryButton.swift
- type: TalentaPrimaryButton subclass
- note: Secondary action button, inherits primary styling

## NoticeEnablePermissionView

- path: Talenta/Views/Notice/NoticeEnablePermissionView.swift
- type: UIView subclass
- note: Notice banner prompting user to enable device permissions

## CommonHeaderView

- path: Talenta/Views/Common/CommonHeaderView.swift
- type: UIView subclass
- note: General-purpose section header view

## CommonHeaderViewWithCloseButton

- path: Talenta/Views/Common/CommonHeaderViewWithCloseButton.swift
- type: UIView subclass
- note: Header view with an embedded close/dismiss button

## CommonHeaderTimesheet

- path: Talenta/Views/Common/CommonHeaderTimesheet.swift
- type: UIView subclass
- note: Header view specific to Timesheet screens

## CommonLoadingView

- path: Talenta/Views/Common/CommonLoadingView.swift
- type: UIView subclass
- note: Full-screen loading indicator overlay

## CommonLoadingWithTextView

- path: Talenta/Views/Common/CommonLoadingWithTextView.swift
- type: UIView subclass
- note: Loading indicator with descriptive text label

## CommonMyInfoHeaderView

- path: Talenta/Views/Common/CommonMyInfoHeaderView.swift
- type: UIView subclass
- note: Header for My Info profile sections

## CommonMyInfoHeaderViewNew

- path: Talenta/Views/Common/CommonMyInfoHeaderViewNew.swift
- type: UIView subclass
- note: Redesigned header for My Info sections

## CommonUserHeaderView

- path: Talenta/Views/Common/CommonUserHeaderView.swift
- type: UIView subclass
- note: Header showing user identity (avatar, name)

## CommonUserInfoHeaderView

- path: Talenta/Views/Common/CommonUserInfoHeaderView.swift
- type: UIView subclass
- note: Extended user info header with additional fields

## ErrorConnectionNetworkView

- path: Talenta/Views/Common/ErrorConnectionNetworkView.swift
- type: UIView subclass
- note: Empty state view for network connectivity errors

## DefaultFailedLoadPageView

- path: Talenta/Views/Common/DefaultFailedLoadPageView.swift
- type: UIView subclass
- note: Generic failed-to-load page state view

## HeaderTitleView

- path: Talenta/Views/Common/HeaderTitleView.swift
- type: UIView subclass (final)
- note: Simple title-only navigation header

## HistoryCommonHeaderView

- path: Talenta/Views/Common/HistoryCommonHeaderView.swift
- type: UIView subclass
- note: Header for history list screens

## HeaderViewWithRequestChangeDataView

- path: Talenta/Views/Common/HeaderViewWithRequestChangeDataView.swift
- type: UIView subclass
- note: Header with embedded request-change-data action

## HistoricalTableViewCell

- path: Talenta/Views/Common/HistoricalTableViewCell.swift
- type: UITableViewCell subclass
- note: Reusable cell for historical request list rows

## CommonDropdownTableViewCell

- path: Talenta/Views/Common/CommonDropdownTableViewCell.swift
- type: UITableViewCell subclass
- note: Table cell with embedded dropdown selector

## EmptyTableViewCell

- path: Talenta/Views/Common/EmptyTableViewCell.swift
- type: UITableViewCell subclass
- note: Placeholder cell for empty table state

## PhotoTableViewCell

- path: Talenta/Views/Common/PhotoTableViewCell.swift
- type: UITableViewCell subclass
- note: Table cell displaying a photo attachment

## PhotoCollectionViewCell

- path: Talenta/Views/Common/PhotoCollectionViewCell.swift
- type: UICollectionViewCell subclass
- note: Collection cell for photo grid display

## AddPhotoCollectionViewCell

- path: Talenta/Views/Common/AddPhotoCollectionViewCell.swift
- type: UICollectionViewCell subclass
- note: Collection cell with add-photo action

## PhotoViewerController

- path: Talenta/Views/Common/PhotoViewerController.swift
- type: DTPhotoViewerController subclass
- note: Full-screen photo viewer using DTPhotoViewerController (third-party)

## DatePickerView

- path: Talenta/Views/Common/DatePickerView.swift
- type: UIView subclass
- note: Inline date picker component

## MonthYearPickerView

- path: Talenta/Views/Common/MonthYearPickerView.swift
- type: UIPickerView subclass
- note: Month and year selection picker

## YearPickerView

- path: Talenta/Views/Common/YearPickerView.swift
- type: UIPickerView subclass
- note: Year-only selection picker

## TimesheetTrackerView

- path: Talenta/Views/Common/TimesheetTrackerView.swift
- type: UIView subclass
- note: Visual time tracker display for Timesheet

## SlideToStartControl

- path: Talenta/Views/Common/SlideToStartControl.swift
- type: UIControl subclass
- note: Slide-to-start gesture control (used in attendance check-in)

## SlideToEndControl

- path: Talenta/Views/Common/SlideToEndControl.swift
- type: UIControl subclass
- note: Slide-to-end gesture control (used in attendance check-out)

## TagUILabel

- path: Talenta/Views/Common/TagUILabel.swift
- type: UILabel subclass
- note: Styled label for status/category tags

## SnapingCollectionViewFlowLayout

- path: Talenta/Views/Common/SnapingCollectionViewFlowLayout.swift
- type: UICollectionViewFlowLayout subclass
- note: Snapping scroll behavior for collection views

## CustomFloatingPanelLayout

- path: Talenta/Views/Common/CustomFloatingPanelLayout.swift
- type: FloatingPanelLayout implementation
- note: Custom layout for FloatingPanel library panels

## FlexiblePageControl

- path: Talenta/Views/PageControl/FlexiblePageControl.swift
- type: UIView subclass
- note: Flexible/animated page control indicator

## CustomBarItemNotificationCell

- path: Talenta/Views/PagerTab/CustomBarItemNotificationCell.swift
- type: UICollectionViewCell subclass
- note: Tab bar item cell with notification badge

## InvalidFakeLocationView

- path: Talenta/Views/Common/FakeLocation/InvalidFakeLocationView.swift
- type: UIView subclass
- note: Warning view shown when fake/mock GPS location is detected
