---
scope: project/flex-mobile
platform: flutter
discipline: engineering
artifact: feature-inventory
---
# Feature Inventory

Platform: Flutter (Melos monorepo)
Packages: `flex_mobile` (root app), `modules/flex_core`, `modules/saving`, `modules/cashout`
Last scanned: 2026-06-04

---

## Authentication

- **SSO Login** — Mekari SSO via `auth_module` (git package). Syncs user via `auth/sync_user_via_sso`. Stores auth tokens in `FlutterSecureStorage`.
- **PIN Management** — Setup, change, forgot, and validation endpoints under `pins/`. PIN is sent as an HTTP header on payment requests.
- **OTP Verification** — Device verification via `device_verification/send_otp` and `device_verification/validate_otp`. Multi-channel: SMS, WhatsApp, email.
- **Biometric Auth** — `local_auth` package for fingerprint/face unlock.

---

## Session Management

- `SessionBloc` in `lib/shared/presentation/blocs/session/` manages the active user session lifecycle.

---

## Balance

- **Balance Overview** — Fetches credit and flex balances via `user_balance` and `user_balance/details` (flex_core `BalanceRemoteSource`).

---

## Transactions

- **Credit Transactions** — Paginated list and detail via `credit/transactions` (flex_core `CreditTransactionRemoteSource`).
- **Flex Transactions** — Paginated list and detail via `flex_transactions` (flex_core `FlexTransactionRemoteSource`).
- **Transaction Approval** — Multi-step approval workflow for company admins. Pending approvals, history, single and bulk approve/reject via `credit/transaction_approvals`.
- **Recent Transactions** — Locally cached PPOB transaction history via `HiveProductHelper`.

---

## Cashout (Early Salary Withdrawal)

Module: `modules/cashout` (Brick-Way micro-frontend).
- **Cashout Flow** — Amount input, fee simulation, payment confirmation, PIN authorization. Supports credit and Finfra (B2C partner) cashout paths.
- **Payment Methods** — `payment_methods?transaction_kind=cashout` shows credit, Flex Points, and cashout limit.
- **Fee Calculation** — `fee_calculations` and `company_fee_settings` for admin fee and Flex Point deduction preview.
- **Promo / Discount** — Promo list and detail fetched from a dedicated promo source; applied at cashout confirmation.
- **Partner Payment (Finfra B2C)** — Creates partner transaction at `credit/credit_partner_transactions`, then executes cashout at `credit/credit_partner_transactions/{id}/cashout`.

---

## Installment (Flex Lending)

Feature: `lib/features/installment/`
- **Loan Agreement (ToS)** — Fetches term-of-service via `lending/term_of_service`.
- **Loan Simulation** — `lending/user_loans/simulation_details` returns repayment schedule for requested amount.
- **Tenure Options** — `lending/user_loans/available_tenure` returns available repayment periods.
- **Loan Request** — POST `lending/user_loans` to submit a loan application.
- **OTP Verification** — Verifies and resends loan OTP via `lending/otps/verify` and `lending/otps/resend`.
- **Loan History** — Paginated history via GET `lending/user_loans`.
- **Upgrade Facility** — `PATCH /lending/users/update_limit_upgrade_status` to accept/reject a credit limit upgrade offer.
- **KYC for Lending** — `KycLendingBloc` drives the KYC steps required before loan disbursement.

---

## CKYC (Customer KYC)

Feature: `lib/features/ckyc/`
- **NIK Validation** — `ckyc/kyc/availability` checks ID card availability.
- **KYC Init & Steps** — `ckyc/kyc/init` initialises, `ckyc/kyc` fetches current step details.
- **KTP Upload** — Presigned URL flow: POST `ckyc/ktps` → PUT to presigned URL → PATCH `ckyc/ktps` to finalise.
- **Payslip Upload** — Multipart POST to `ckyc/kyc/upload_payslip`.
- **OCR Data** — GET and POST `ckyc/ocr`.
- **Liveness Check** — POST `ckyc/liveness` returns a liveness URL; PATCH `ckyc/liveness` updates step.
- **Emergency Contact** — POST `ckyc/kyc/emergency_contact`.
- **Spouse Data** — POST `ckyc/kyc/spouse_data`.
- **ToS** — GET `ckyc/kyc/terms_of_service` (cached 5 minutes).

---

## PPOB — Mobile Prepaid

Feature: `lib/features/mobile/`
- **Products** — GET `sepulsa_product/mobile_prepaid?paket_data=<bool>` for pulsa and data packages.
- **Payment** — POST `credit/transactions/mobile_prepaids` (via `CreditPaymentDataSource`) or `flex/transactions/mobile_prepaids` (via `FlexPaymentDataSource`).

---

## PPOB — Mobile Postpaid

Feature: `lib/features/mobile/`
- **Products** — GET `sepulsa_product/mobile_postpaid`.
- **Inquiry** — POST `credit/transactions/mobile_postpaids/inquire`.
- **Payment** — POST `credit/transactions/mobile_postpaids` (via `CreditPaymentDataSource`) or `flex/transactions/mobile_postpaids` (via `FlexPaymentDataSource`).

---

## PPOB — Electricity

Feature: `lib/features/electricity/`
- **Prepaid Products** — GET `sepulsa_product/electricity_prepaid`.
- **Prepaid Inquiry** — POST `credit/transactions/electricity_prepaids/inquire`.
- **Postpaid Inquiry** — POST `credit/transactions/electricity_postpaids/inquire`.
- **Payment** — POST `credit/transactions/electricity_prepaids` or `credit/transactions/electricity_postpaids`.

---

## PPOB — PDAM (Water Utility)

Feature: `lib/features/pdam/`
- **Operators** — GET `credit/transactions/pdams/operators`.
- **Inquiry** — POST `credit/transactions/pdams/inquire`.
- **Payment** — POST `credit/transactions/pdams`.
- **Recent Transactions** — Hive-cached, surfaced in `RecentPDAMTransactionBloc`.

---

## E-Wallet Top-up

Feature: `lib/features/ewallet/`
- **GoPay, OVO, ShopeePay, DANA** — Each dispatched via corresponding `CreditPaymentDataSource` paths (e.g. `credit/transactions/gopay`).

---

## Vouchers

Feature: `lib/features/voucher/`
- **Voucher List** — Paginated GET `user_vouchers` (active and past).
- **Voucher Detail** — GET `user_vouchers/{id}?for=<balanceSource>`.
- **Redeem Voucher** — PUT `user_vouchers/{id}/redeem`.

---

## Promo

Feature: `lib/features/promo/`
- **Promo List** — GET `promo_codes`.
- **Promo Detail** — GET `promo_codes/{id}`.

---

## Campaigns

Feature: `lib/features/campaigns/`
- **Campaign List** — GET `mobile/campaigns` with query parameters; response cached via `NetworkCachePolicy`.
- **Campaign Detail** — GET `mobile/campaigns/{id}`.

---

## Products / Marketplace

Feature: `lib/features/product/`
- **Product List** — Paginated GET `mobile/products` with optional category filter; result cached in Hive.
- **Product Detail** — GET `mobile/products/{id}`.

---

## Flex Points

Feature: `lib/features/flex_point/`
- **Balance** — GET `flex_points/balance`.
- **Transaction History** — Paginated GET `flex_point_transactions` (year filter supported).

---

## Referral

Feature: `lib/features/referral/`
- **Global Settings** — GET `referral_settings`.
- **User Settings** — GET `user_referral_settings`.
- **Submit Code** — PATCH `user_referral_settings/{code}`.

---

## Reimbursement

Feature: `lib/features/reimbursement/`
- **Detail** — GET `reimbursements/{id}`.
- **Create** — POST `reimbursements`.
- **Cancel** — DELETE `reimbursements/{id}`.

---

## Individual Access (B2C / Mekari Saving Registration)

Feature: `lib/features/individual_access/`
- **Eligibility Check** — GET `mekari_saving/users/access_status`.
- **Accept TnC** — POST `mekari_saving/users/accept_tnc`.

---

## Savings (Mekari Saving Module)

Module: `modules/saving/`
- **User Registration** — POST `mekari_saving/users` (root app `SavingsRemoteSource`).
- **Auth / Token** — POST `auth/access-token`, POST `auth/refresh-token`, GET `auth/check-linkage-status` (SavingsNetworkClient to separate `SAVING_URL`).
- **Onboarding TnC** — GET `onboarding/tnc`, POST `onboarding/tnc/agree`, GET `onboarding/status`.
- **Balance Inquiry** — POST `transactions/balance-inquiry`.
- **Transaction List** — GET `transactions` with filters.
- **Transaction Detail** — GET `transactions/{id}/detail`.
- **Transfer Intrabank** — Inquiry, confirmation, and execution via dedicated paths under `transactions/`.
- **Transfer Interbank** — Same pattern as intrabank.
- **Bank List** — GET `transactions/bank-list`.
- **Profile Management** — GET/update profile, two-factor management (feature-flagged).

---

## App Settings

Feature: `lib/features/app_settings/`
- **Mobile Version Control** — GET `mobile_versions` returns min/force-update version per platform.

---

## Auto-Debit

Feature: `lib/features/auto_debit/`
- **Bank Info** — GET `auto_debits/banks`.
- **Settings** — GET `auto_debits/setting`.
- **Linkage Info** — GET `auto_debits/linkages/info`.
- **Activate Linkage** — POST `auto_debits/linkages`.

---

## Fee Calculations

Feature: `lib/features/fee_calculations/`
- **Company Fee Settings** — GET `company_fee_settings?transaction_kind=<kind>`.
- **Fee Calculation** — GET `fee_calculations` (also used in cashout module).

---

## Payment Methods

Feature: `lib/features/payment/`
- **Payment Methods** — GET `payment_methods?transaction_kind=<kind>` returns available payment sources (credit, flex points, cashout limit).
- **Payment Fee** — GET `fee_calculations` (via `PaymentFeeRemoteDataSource`).

---

## Home

Feature: `lib/features/home/`
- Presentation-only feature; aggregates balance, campaigns, and promo data from other features.

---

## Account

Feature: `lib/features/account/`
- Presentation-only; shows user profile info sourced from flex_core `UserRemoteDataSource`.

---

## Inbox (MoEngage)

Feature: `lib/features/inbox/`
- In-app inbox powered by `moengage_inbox`. Messages are fetched locally from MoEngage SDK; no custom REST endpoint.

---

## Balance (Presentation)

Feature: `lib/features/balance/`
- Presentation layer only; wraps balance data from flex_core.

---

## Walkthrough

`lib/shared/presentation/screens/walkthrough/`
- First-run onboarding flow with illustration screens.

---

## B2C (Business-to-Consumer)

Feature: `lib/features/b2c/`
- Presentation layer for B2C user experience; credit partner transaction flow.

---

## Insurance (Presentation Shell)

Feature: `lib/features/insurance/`
- Presentation-only shell; content delivered via WebView.

---

## Feedback (NPS / CSAT)

flex_core `FeedbackRemoteSource`
- Submits NPS and CSAT responses to Firebase Realtime Database at `user_feedback/nps/{companyId}/{userId}` and `user_feedback/csat/{companyId}/{userId}`.

---

## Feature Flags

Managed via `mekari_flag` (Firebase Remote Config wrapper).
Flags: `flag_mekari_network`, `flag_mekari_log`, `flag_mekari_savings`, `flag_savings_render_webview`, `flag_savings_cashin_cashout`, `flag_savings_profile_management`, `flag_savings_linkage_phone_prefilled`, `flag_savings_title_migration`, `flag_finfra_installment`, `flag_sso_phone_verification`, `flag_ewallet_dana`, `flag_pdam_feature`, `flag_use_objectbox`.
