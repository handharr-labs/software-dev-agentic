# Shared Components — flutter-mobile-talenta

All live under `talenta/lib/src/shared/core/presentation/widgets/`.

## Generic UI

| Component | File | Purpose |
|---|---|---|
| `ActionButtonWidget` | `generic/action_button_widget.dart` | CTA button |
| `AppBarDateFilter` | `generic/app_bar_date_filter.dart` | Date filter in app bar |
| `BannerInfoWidget` | `generic/banner_info_widget.dart` | Informational banner |
| `BaseBottomSheet` | `generic/base_bottom_sheet.dart` | Base bottom sheet scaffold |
| `ColoredHeaderCardWidget` | `generic/colored_header_card_widget.dart` | Card with colored header |
| `FilterIconWidget` / `FilterSectionWidget` | `generic/filter_*.dart` | Filter controls |
| `ListPaginationWidget` | `generic/list_pagination_widget.dart` | Paginated list |
| `SectionedListPaginationWidget` | `generic/sectioned_list_pagination_widget.dart` | Sectioned paginated list |
| `SectionWidget` | `generic/section_widget.dart` | Content section |
| `StatusFilterBottomSheet` | `generic/status_filter_bottom_sheet.dart` | Status-based filter sheet |
| `LoadingFromHostContainer` | `generic/loading_from_host_container.dart` | Host-injected loading state |
| `TopBottomCurveContainer` / `Clipper` | `generic/top_bottom_curve_*.dart` | Curved decorative containers |
| `MpYearPickerAppBar` | `generic/mp_year_picker_app_bar.dart` | Year picker in app bar |
| `LoadmoreListTileWidget` | `load_more/loadmore_list_tile_widget.dart` | Load-more list tile |

## Attachment / Media

| Component | File | Purpose |
|---|---|---|
| `AttachmentInput` | `attachment_input/attachment_input.dart` | File/image attachment picker |
| `AttachmentThumbnail` | `attachment_input/attachment_thumbnail.dart` | Attachment preview thumbnail |
| `AvatarField` | `attachment_input/avatar_field.dart` | Avatar upload field |
| `FileSourceBottomSheet` | `attachment_input/file_source_bottom_sheet.dart` | Camera/gallery/file picker sheet |
| `MediaViewer` | `pixel_viewer_component/media_viewer/media_viewer.dart` | Full-screen media viewer (image/video/PDF) |
| `TalentaWebView` / `TalentaWebViewScreen` | `webview/talenta_webview.dart` | Shared WebView with JS channel support |
| `GenericWebViewScreen` | `webview/generic_webview_screen.dart` | Generic WebView wrapper |

## Sections / Approval

| Component | File | Purpose |
|---|---|---|
| `ApprovalLineView` | `section/approval_line_view.dart` | Approval chain visualization |
| `ApprovalStatusBottomSheet` | `section/approval_status_bottom_sheet.dart` | Approval status display |
| `ApprovalStatusCard` | `section/approval_status_card.dart` | Status card |
| `ItemSectionView` | `section/item_section_view.dart` | Key-value section row |
| `AccordionSectionView` | `section/accordion_section_view.dart` | Collapsible section |
| `AttachmentSection` | `section/attachment_section.dart` | Attachments display section |
| `UserHeader` | `section/user_header.dart` | Employee header card |

## Bottom Sheets / Dialogs

| Component | File | Purpose |
|---|---|---|
| `CancelRequestConfirmationBottomSheet` | `bottom_sheet/cancel_request_confirmation_bottomsheet.dart` | Cancel request confirmation |
| `EmployeeInfoBottomSheet` | `bottom_sheet/employee_info_bottom_sheet.dart` | Employee info sheet |
| `OtpRequestErrorBottomSheet` | `bottom_sheet/otp_request_error_bottom_sheet.dart` | OTP error feedback |
| `RadioButtonBottomSheet` | `bottom_sheet/radio_button_bottom_sheet.dart` | Radio selection sheet |

## Utilities

| Component | File | Purpose |
|---|---|---|
| `NetworkAwareWidget` | `network_aware_widget.dart` | Network status gating |
| `HtmlContentView` | `html_content/html_content_view.dart` | HTML rendering via flutter_widget_from_html |
| `MapPictureWidget` | `map/map_picture_widget.dart` | Static map thumbnail |
| `SelectList` | `select/select_list.dart` | Generic selectable list |
| `OverviewItemCard` | `overview_item_card/overview_item_card.dart` | Summary card for overview data |
| `RequestListTileWidget` | `list_tile/request_list_tile_widget.dart` | Request list row tile |
| `TimeWithTimezoneWidget` | `time_with_timezone_widget.dart` | Time display with timezone label |
