# Shared Components — talenta-mobile-android

## BaseVbActivity

- path: base/src/main/java/co/talenta/base/view/BaseVbActivity.kt
- params: VB : ViewBinding

## BaseVbFragment

- path: base/src/main/java/co/talenta/base/view/BaseVbFragment.kt
- params: VB : ViewBinding

## BaseInjectionVbActivity

- path: base/src/main/java/co/talenta/base/view/BaseInjectionVbActivity.kt
- params: VB : ViewBinding

## BaseMvpVbActivity

- path: base/src/main/java/co/talenta/base/view/BaseMvpVbActivity.kt
- params: P : MvpPresenter<V>, V : MvpView, VB : ViewBinding

## BaseMvpVbFragment

- path: base/src/main/java/co/talenta/base/view/BaseMvpVbFragment.kt
- params: P : MvpPresenter<V>, V : MvpView, VB : ViewBinding

## BaseVbDialog

- path: base/src/main/java/co/talenta/base/view/BaseVbDialog.kt
- params: VB : ViewBinding

## BaseMvpVbDialog

- path: base/src/main/java/co/talenta/base/view/BaseMvpVbDialog.kt
- params: P : MvpPresenter<V>, V : MvpView, VB : ViewBinding

## WebViewActivity

- path: base/src/main/java/co/talenta/base/view/WebViewActivity.kt
- params: none (configured via intent extras)

## EmptyStateView

- path: base/src/main/java/co/talenta/base/widget/EmptyStateView.kt
- params: context, attrs (View subclass)

## InfoView

- path: base/src/main/java/co/talenta/base/widget/InfoView.kt
- params: context, attrs (View subclass)

## TimezoneTextView

- path: base/src/main/java/co/talenta/base/widget/TimezoneTextView.kt
- params: context, attrs (TextView subclass)

## ExpandableTextView

- path: base/src/main/java/co/talenta/base/widget/ExpandableTextView.kt
- params: context, attrs (TextView subclass)

## MonthYearPickerView

- path: base/src/main/java/co/talenta/base/widget/MonthYearPickerView.kt
- params: context, attrs (View subclass)

## NonInterceptingRecyclerView

- path: base/src/main/java/co/talenta/base/widget/NonInterceptingRecyclerView.kt
- params: context, attrs (RecyclerView subclass)

## EmojiExcludeEditText

- path: base/src/main/java/co/talenta/base/widget/EmojiExcludeEditText.kt
- params: context, attrs (EditText subclass)

## MagnifyingPageIndicator

- path: base/src/main/java/co/talenta/base/widget/MagnifyingPageIndicator.kt
- params: context, attrs (View subclass)

## SingleClickListener

- path: base/src/main/java/co/talenta/base/widget/SingleClickListener.kt
- params: none (abstract View.OnClickListener)

## TalentaWebView

- path: base/src/main/java/co/talenta/base/widget/webview/TalentaWebView.kt
- params: context, attrs (WebView subclass)

## CustomWebView

- path: base/src/main/java/co/talenta/base/widget/webview/CustomWebView.kt
- params: context, attrs (WebView subclass)

## ErrorPageView

- path: base/src/main/java/co/talenta/base/widget/webview/ErrorPageView.kt
- params: context, attrs (View subclass)

## SuccessSnackBarView

- path: base/src/main/java/co/talenta/base/widget/snackbar/SuccessSnackBarView.kt
- params: context, attrs (View subclass)

## DateTimePickerDialog

- path: base/src/main/java/co/talenta/base/widget/dialog/DateTimePickerDialog.kt
- params: none (injected via Dagger)

## FilterDialog

- path: base/src/main/java/co/talenta/base/widget/dialog/FilterDialog.kt
- params: none

## FeatureIntroductionDialog

- path: base/src/main/java/co/talenta/base/widget/dialog/FeatureIntroductionDialog.kt
- params: DialogIntroStyle (data class)

## PreviewImageDialog

- path: base/src/main/java/co/talenta/base/widget/dialog/previewimage/PreviewImageDialog.kt
- params: none (injected via Dagger)

## YearPickerDialog

- path: base/src/main/java/co/talenta/base/widget/dialog/yearpickerdialog/YearPickerDialog.kt
- params: none

## SelectOptionBottomSheet

- path: base/src/main/java/co/talenta/base/widget/dialog/select_option/SelectOptionBottomSheet.kt
- params: none

## SelectShiftDialog

- path: base/src/main/java/co/talenta/base/widget/dialog/select_shift/SelectShiftDialog.kt
- params: none

## MpBaseBottomSheet

- path: base/src/main/java/co/talenta/base/widget/bottomsheet/MpBaseBottomSheet.kt
- params: ContentVB : ViewBinding (abstract)

## MpBaseInjectionBottomSheet

- path: base/src/main/java/co/talenta/base/widget/bottomsheet/MpBaseInjectionBottomSheet.kt
- params: ContentVB : ViewBinding (abstract)

## MpBaseMvpBottomSheet

- path: base/src/main/java/co/talenta/base/widget/bottomsheet/MpBaseMvpBottomSheet.kt
- params: P : MvpPresenter<V>, V : MvpView, ContentVB : ViewBinding (abstract)

## InfoBottomSheet

- path: base/src/main/java/co/talenta/base/widget/bottomsheet/InfoBottomSheet.kt
- params: MpInfoBottomSheetConfig

## MpInfoBottomSheet

- path: base/src/main/java/co/talenta/base/widget/bottomsheet/MpInfoBottomSheet.kt
- params: none

## MpApprovalListBottomSheet

- path: base/src/main/java/co/talenta/base/widget/bottomsheet/MpApprovalListBottomSheet.kt
- params: none (private constructor, use factory)

## MpTimePickerBottomSheet

- path: base/src/main/java/co/talenta/base/widget/bottomsheet/MpTimePickerBottomSheet.kt
- params: mpTimePickerListener: MpTimePickerListener?

## MpOptionBottomSheet

- path: base/src/main/java/co/talenta/base/widget/bottomsheet/option/MpOptionBottomSheet.kt
- params: none

## MpDatePickerBottomSheet

- path: base/src/main/java/co/talenta/base/widget/bottomsheet/datepicker/MpDatePickerBottomSheet.kt
- params: none (private constructor, use factory)

## MpNumberPickerView

- path: base/src/main/java/co/talenta/base/widget/bottomsheet/datepicker/MpNumberPickerView.kt
- params: context, attrs (View subclass)

## RangeMonthYearPicker

- path: base/src/main/java/co/talenta/base/widget/rangemonthyearpicker/RangeMonthYearPicker.kt
- params: context, attrs (View subclass)

## KeyAwareEditText

- path: base/src/main/java/co/talenta/base/widget/edittext/KeyAwareEditText.kt
- params: context, attrs (EditText subclass)

## PermissionRationaleDialogBottomSheet

- path: base/src/main/java/co/talenta/base/widget/dialog/PermissionRationaleDialogBottomSheet.kt
- params: none

## MpBaseDialog

- path: base/src/main/java/co/talenta/base/widget/dialog/mpdialog/MpBaseDialog.kt
- params: ContentVB : ViewBinding (abstract)

## SettingBottomSheet

- path: base/src/main/java/co/talenta/base/widget/dialog/settingbottomsheet/SettingBottomSheet.kt
- params: none

## TimeDurationPickerDialog

- path: base/src/main/java/co/talenta/base/widget/dialog/TimeDurationPickerDialog.kt
- params: none (injected via Dagger)
