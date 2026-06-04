# Feature Inventory — flex-mobile (Flutter)

Scanned: 2026-06-04
Source: https://github.com/mekari/flex-mobile
Local path: /Users/puras.handharmahuamekari.com/Workspace/flex-mobile

## App Overview

flex-mobile is a Flutter fintech app by Mekari for earned-wage access (EWA), PPOB bill payments, savings, and related financial services for employees. Architecture: Clean Architecture + BLoC. Monorepo with three internal packages: `flex_core`, `cashout`, `saving`.

---

## Features (lib/features/)

### 1. account
- Profile/menu screen for the user's account
- Sub-sections: info menu, benefits, referral, settings, signout dialog, support dialog
- Presentation-only feature (no data layer in this directory — data lives in flex_core)

### 2. app_settings
- Fetches mobile app version settings (min/force-update enforcement)
- BLoC: MobileVersionBloc
- Use case: GetMobileVersionSettings
- Endpoint: GET `mobile_versions`

### 3. auto_debit
- Bank auto-debit linkage feature for automatic salary deduction
- Screens: landing, activation slider, bank selection, FAQ, linkage, TnC
- BLoC: AutoDebitBloc
- Entities: AutoDebitBankInfo, AutoDebitSettings, AutoDebitLinkage
- Use cases: GetBankInfo, GetAutoDebitSettings, GetAutoDebitLinkage, GetActivationUrl
- Endpoints: GET `auto_debits/banks`, GET `auto_debits/setting`, GET `auto_debits/linkages/info`, POST `auto_debits/linkages`

### 4. balance (lib/features/balance + flex_core/features/balance)
- Shows EWA/credit balance detail with recent transaction history
- Entities: Balance, BalanceDetail, BalanceCategory
- Endpoint: via flex_core BalanceRemoteSource

### 5. campaigns
- Displays promotional campaigns on the home screen
- Screens: CampaignDetailScreen
- BLoCs: CampaignsBloc, CampaignDetailBloc
- Entities: Campaign, CampaignDetail
- Use cases: GetCampaignsUsecase, GetCampaignDetailUsecase
- Endpoint: GET `mobile/campaigns`, GET `mobile/campaigns/{id}`

### 6. cashout (modules/cashout)
- Dedicated module for Earned Wage Access cash withdrawal flow
- Sub-features: fee calculation, payment methods, promo codes, B2C partner payment
- Screens: payment selection, confirmation, success, partner agreement webview
- BLoCs: FeeCalculationsBloc, PaymentMethodsBloc, PaymentsBloc, PartnerPaymentBloc
- Entities: FeeCalculations, FeeSettings, Payment, PaymentData, PaymentMethods, Promo, CreditPartner
- Use cases: CreatePayment, GetCompanyFeeSettings, GetFeeCalculations, GetPartnerPayment, GetPaymentMethods, GetPromoDetail, GetPromos, RequestPartnerPayment
- Endpoints: GET `company_fee_settings`, GET `fee_calculations`, GET `payment_methods`, POST `credit/transactions/cashout`, POST `credit/credit_partner_transactions`, GET `credit/credit_partner_transactions/{id}`, GET `promo_codes`, GET `promo_codes/{id}`

### 7. ckyc (Credit KYC)
- Full KYC/identity verification flow for credit upgrade
- Steps: NIK validation, KTP photo capture, OCR, liveness check, form submission, payslip upload, emergency contact, spouse data, TnC
- BLoCs: CkycBloc, CkycMasterDataBloc, CkycProcessBloc, CkycTncBloc, TakeKtpBloc, CkycLivenessBloc, CkycEmergencyBloc, UploadPayslipBloc
- Entities: CkycMasterData, CkycOcrData, CkycStepDetails
- Use cases: ValidateNik, GetStepDetails, GetOcrData, GetUploadKTPUrl, UploadKTP, FinishUploadKTP, UploadPayslip, SubmitForm, SubmitEmergencyContact, SubmitSpouseData, CheckLiveness, UpdateLivenessStep, GetTermOfService, InitKyc
- Endpoints: POST `ckyc/kyc/availability`, GET/POST `ckyc/kyc`, GET `ckyc/ocr`, POST `ckyc/ktps`, PATCH `ckyc/ktps`, POST `ckyc/kyc/upload_payslip`, POST `ckyc/ocr` (form), POST `ckyc/kyc/emergency_contact`, POST `ckyc/kyc/spouse_data`, POST `ckyc/liveness`, PATCH `ckyc/liveness`, POST `ckyc/kyc/init`, GET `ckyc/kyc/terms_of_service`

### 8. electricity (PPOB)
- Prepaid and postpaid PLN electricity bill payment
- Screens: ElectricityPrepaidScreen, ElectricityPostpaidScreen, ElectricityBillingScreen
- BLoC: ElectricityBloc
- Use cases: GetPrepaidElectricityProducts, InquiryPrepaidElectricity, InquiryPostpaidElectricity
- Endpoints: POST `credit/transactions/electricity_prepaids/inquire`, POST `credit/transactions/electricity_postpaids/inquire`, GET `sepulsa_product/...`

### 9. fee_calculations
- Generic fee calculation feature for transactions
- Endpoint: via shared FeeCalculationsDataSource

### 10. flex_point
- Flex Points loyalty/reward balance and transaction history
- Screens: FlexPointScreen, FlexPointHistoryScreen
- BLoCs: FlexPointBloc, FlexPointBalanceBloc
- Entities: FlexPointBalance, FlexPointTransaction
- Use cases: GetFlexPointBalance, GetFlexPointTransaction
- Endpoints: GET `flex_points/balance`, GET `flex_point_transactions`

### 11. home
- Main dashboard screen; aggregates balance, campaigns, awareness articles, benefits, PPOB shortcuts, recent transactions, active vouchers
- Widgets: HomeBalanceSection, HomeCampaignSection, HomeAwarenessSection, HomePpobSection, HomeRecentTransactionSection, HomeActiveVoucherSection, HomeHighlightedProductSection, HomeBenefitsSection, HomeAppBar, HomeTabBar, HomeTabContent
- NPS subscription via Firebase Realtime DB
- Coachmark/onboarding overlay

### 12. inbox (local)
- Local notification inbox backed by Hive (no remote fetch)
- Used for MoEngage inbox messages

### 13. individual_access
- Mekari Saving individual access eligibility check and TnC acceptance
- Screens: IndividualAccessLandingScreen, IndividualAccessScreen
- BLoC: IndividualAccessBloc
- Use cases: CheckEligibility, AcceptIndividualAccess
- Endpoints: GET `mekari_saving/users/access_status`, POST `mekari_saving/users/accept_tnc`

### 14. installment
- Installment/lending feature (referenced in DI but screens not fully explored)

### 15. mobile (PPOB)
- Prepaid mobile top-up (pulsa + data plan) and postpaid phone bill payment
- Screens: MobilePlanScreen, DataPlanScreen, MobilePostpaidScreen, MobilePostpaidBillingScreen
- BLoCs: PrepaidProductsBloc, PrepaidFilteredProductsBloc, PostpaidProductsBloc, PostpaidInquiryBloc, RecentTransactionBloc
- Use cases: FindAllPrepaidMobileProduct, FindAllPrepaidDataPlanProduct, FindAllPostpaidMobileProduct, GetPostpaidMobileInquiry, GetRecentMobilePlanTransactions, GetRecentDataPlanTransactions, GetRecentPostpaidMobileTransactions
- Endpoints: GET `sepulsa_product/mobile_prepaid`, GET `sepulsa_product/mobile_postpaid`, POST `credit/transactions/mobile_postpaids/inquire`

### 16. payment (shared payment flow)
- Generic PPOB transaction payment submission; handles credit and flex balance paths
- Covers: mobile prepaid/postpaid, electricity prepaid/postpaid, e-wallets (GoPay, OVO, ShopeePay, DANA), voucher, cashout, PDAM
- Two data sources: CreditPaymentDataSource (`credit/transactions/*`) and FlexPaymentDataSource (`flex/transactions/*`)
- BLoCs: PaymentDataBloc, PaymentFeeBloc, PaymentMethodBloc, PaymentVerificationBloc
- Screens: PaymentConfirmationScreen, PaymentVerificationScreen

### 17. pdam (PPOB)
- PDAM water utility bill inquiry and payment
- Screens: PdamInputScreen, PdamBillingScreen
- BLoCs: PdamOperatorBloc, PdamInquiryBloc, RecentPdamTransactionBloc
- Use cases: GetPdamOperators, InquirePdam, GetRecentPdamTransactions
- Endpoints: GET `credit/transactions/pdams/operators`, POST `credit/transactions/pdams/inquire`

### 18. promo
- Generic promo codes listing (distinct from cashout promos — benefit-level promos)
- Screens: PromoListScreen, PromoDetailScreen
- BLoCs: PromoListBloc, PromoDetailBloc
- Entities: Promo
- Endpoints: GET `promo_codes`, GET `promo_codes/{id}`

### 19. product (generic PPOB product)
- Cached product catalog (backed by Hive + remote)

### 20. referral
- Referral program: share referral code, submit received code, view settings
- Screens: ReferralScreen, ReferralTncScreen, referral sheets (input, exist, not-eligible)
- BLoC: ReferralBloc
- Entities: ReferralGlobalSettings, ReferralUserSettings
- Use cases: GetReferralGlobalSettings, GetReferralUserSettings, SubmitReferralCode, GetIsFirstTimeReferralAccess, SetFirstTimeReferralAccess
- Endpoints: GET `referral_settings`, GET `user_referral_settings`, PATCH `user_referral_settings/{code}`

### 21. reimbursement
- Employee expense reimbursement submission and detail view
- Screens: ReimbursementRequestScreen, ReimbursementDetailScreen
- BLoCs: ReimbursementRequestBloc, ReimbursementDetailBloc
- Entities: Reimbursement
- Use cases: RequestReimbursement, GetReimbursementDetail, CancelReimbursement
- Endpoints: POST `reimbursements`, GET `reimbursements/{id}`, DELETE `reimbursements/{id}`

### 22. savings (lib/features/savings — bridge to saving module)
- Registers user into Mekari Saving service
- Use case: RegisterUserUsecase
- Endpoint: POST `mekari_saving/users`

### 23. saving (modules/saving)
- Full Mekari Savings module (separate Dart package)
- Sub-features: authentication (linkage to savings account, token management), balance, transactions, settings, KYC
- Multi-BLoC architecture; uses separate savings API base URL

### 24. voucher
- User voucher list (active + past) with redeem flow
- Screens: VoucherScreen
- BLoC: VoucherBloc
- Entities: Voucher, VoucherDetail, VoucherRedeem
- Use cases: GetVoucherList, GetVoucherDetail, RedeemVoucher
- Endpoints: GET `user_vouchers`, GET `user_vouchers/{id}`, PUT `user_vouchers/{id}/redeem`

### 25. flex_core/auth
- SSO login/logout, company app info sync
- Endpoints: POST sync SSO, GET company app info

### 26. flex_core/awareness
- Awareness articles and product feedback screen

### 27. flex_core/balance
- Core balance fetch (credit/flex balance)

---

## Feature Count: 27 features
