---
scope: project/flex-mobile
platform: flutter
discipline: engineering
artifact: api-endpoints
---
# API Endpoints

Platform: Flutter (Melos monorepo)
Last scanned: 2026-06-04

The app uses four distinct base URL environments, all configured via `envied`-obfuscated `.env.*` files:

| Client | Env Var | Used By |
|---|---|---|
| `FlexNetworkClient` (credit) | `BASE_URL` | Most features |
| `BenefitNetworkClient` | `BENEFIT_CMS_URL` | Campaigns, products, benefit CMS |
| `LendingNetworkClient` | `LENDING_URL` | Installment / lending |
| `SavingsNetworkClient` | `SAVING_URL` | Mekari Saving module |

All clients use `mekari_network` (`MKRNetwork`) under the hood with `FlexNetworkAuthInterceptor` injecting Bearer tokens.

---

## Authentication (flex_core — credit base URL)

| Method | Path | Description |
|---|---|---|
| DELETE | `auth/logout` | Log out current session |
| POST | `auth/sync_user_via_sso` | Sync user after SSO login |

---

## Users (flex_core — credit base URL)

| Method | Path | Description |
|---|---|---|
| GET | `users/profile` | Fetch current user profile |
| GET | `users/employment_information` | Fetch employment info |
| POST | `users/change_settings` | Update user settings (language, etc.) |
| GET | `users/change_password` | Get change-password redirect URL |
| POST | `users/resend_agreement` | Resend sign agreement email |

---

## Balance (flex_core — credit base URL)

| Method | Path | Description |
|---|---|---|
| GET | `user_balance` | Fetch credit + flex balance |
| GET | `user_balance/details` | Fetch balance breakdown details |

---

## PIN (flex_core — credit base URL)

| Method | Path | Description |
|---|---|---|
| POST | `pins/pin_setup` | Set up new PIN |
| PUT | `pins/update_pin` | Change existing PIN |
| POST | `forgot_pin` | Initiate forgot-PIN flow |
| POST | `pins/pin_validation` | Validate PIN (pin passed as header) |

---

## Device Verification (flex_core — credit base URL)

| Method | Path | Description |
|---|---|---|
| POST | `device_verification/send_otp` | Send OTP via SMS/WhatsApp/email |
| POST | `device_verification/validate_otp` | Validate submitted OTP |

---

## Transactions (flex_core — credit base URL)

| Method | Path | Description |
|---|---|---|
| GET | `credit/transactions` | Paginated credit transaction list |
| GET | `credit/transactions/{id}` | Credit transaction detail |
| GET | `flex_transactions` | Paginated flex transaction list |
| GET | `flex_transactions/{id}` | Flex transaction detail |

---

## Transaction Approval (flex_core — credit base URL)

| Method | Path | Description |
|---|---|---|
| GET | `credit/transaction_approvals/{id}` | Approval detail |
| GET | `credit/transactions/{id}/approval_history` | Approval history for a transaction |
| PATCH | `credit/transaction_approvals/{id}` | Update approval status |
| POST | `credit/transaction_approvals/process_bulk` | Bulk approve/reject |
| GET | `credit/transaction_approvals/check_pending_approvals` | Check if pending approvals exist |
| GET | `credit/transaction_approvals/pending_approvals` | Paginated pending approvals |
| GET | `credit/transaction_approvals/my_approvals` | Paginated approval history |

---

## Payment Methods (credit base URL)

| Method | Path | Description |
|---|---|---|
| GET | `payment_methods` | Available payment sources; requires `transaction_kind` query param |

---

## Fee Calculations (credit base URL)

| Method | Path | Description |
|---|---|---|
| GET | `fee_calculations` | Calculate transaction fee |
| GET | `company_fee_settings` | Fetch company-level fee settings; requires `transaction_kind` |

---

## Cashout (credit base URL)

| Method | Path | Description |
|---|---|---|
| POST | `credit/transactions/cashout` | Execute standard cashout |
| POST | `credit/credit_partner_transactions` | Create Finfra B2C partner transaction |
| GET | `credit/credit_partner_transactions/{id}` | Get partner transaction status |
| POST | `credit/credit_partner_transactions/{id}/cashout` | Execute cashout on partner transaction |

---

## Lending (LendingNetworkClient — LENDING_URL)

| Method | Path | Description |
|---|---|---|
| GET | `lending/term_of_service` | Fetch loan agreement ToS |
| GET | `lending/user_loans/simulation_details` | Loan repayment simulation |
| GET | `lending/user_loans/available_tenure` | Available repayment tenure options |
| POST | `lending/user_loans` | Submit loan request |
| GET | `lending/user_loans/{id}` | Fetch loan detail |
| GET | `lending/user_loans` | Paginated loan history |
| POST | `lending/otps/verify` | Verify loan OTP |
| POST | `lending/otps/resend` | Resend loan OTP |
| PATCH | `/lending/users/update_limit_upgrade_status` | Accept/reject credit limit upgrade |

---

## CKYC (credit base URL)

| Method | Path | Description |
|---|---|---|
| POST | `ckyc/kyc/availability` | Validate NIK |
| GET | `ckyc/kyc` | Get KYC step details |
| POST | `ckyc/kyc/init` | Initialise KYC process |
| GET | `ckyc/ocr` | Get OCR data |
| POST | `ckyc/ocr` | Submit OCR form data |
| POST | `ckyc/ktps` | Get presigned URL for KTP upload |
| PUT | `<presigned_url>` | Upload KTP file directly to S3 |
| PATCH | `ckyc/ktps` | Finalise KTP upload |
| POST | `ckyc/kyc/upload_payslip` | Upload payslip (multipart) |
| POST | `ckyc/kyc/emergency_contact` | Submit emergency contact |
| POST | `ckyc/kyc/spouse_data` | Submit spouse data |
| POST | `ckyc/liveness` | Initiate liveness check, returns URL |
| PATCH | `ckyc/liveness` | Update liveness step status |
| GET | `ckyc/kyc/terms_of_service` | Get KYC ToS URL (5-minute cache) |

---

## Mobile PPOB (credit base URL)

| Method | Path | Description |
|---|---|---|
| GET | `sepulsa_product/mobile_prepaid` | Prepaid mobile products |
| GET | `sepulsa_product/mobile_postpaid` | Postpaid mobile products |
| POST | `credit/transactions/mobile_postpaids/inquire` | Postpaid bill inquiry |
| POST | `credit/transactions/mobile_prepaids` | Pay prepaid mobile (credit) |
| POST | `credit/transactions/mobile_postpaids` | Pay postpaid mobile (credit) |
| POST | `flex/transactions/mobile_prepaids` | Pay prepaid mobile (flex) |
| POST | `flex/transactions/mobile_postpaids` | Pay postpaid mobile (flex) |

---

## Electricity PPOB (credit base URL)

| Method | Path | Description |
|---|---|---|
| GET | `sepulsa_product/electricity_prepaid` | Prepaid electricity token products |
| POST | `credit/transactions/electricity_prepaids/inquire` | Prepaid meter inquiry |
| POST | `credit/transactions/electricity_postpaids/inquire` | Postpaid bill inquiry |
| POST | `credit/transactions/electricity_prepaids` | Pay prepaid electricity (credit) |
| POST | `credit/transactions/electricity_postpaids` | Pay postpaid electricity (credit) |
| POST | `flex/transactions/electricity_prepaids` | Pay prepaid electricity (flex) |
| POST | `flex/transactions/electricity_postpaids` | Pay postpaid electricity (flex) |

---

## PDAM (credit base URL)

| Method | Path | Description |
|---|---|---|
| GET | `credit/transactions/pdams/operators` | List PDAM water operators |
| POST | `credit/transactions/pdams/inquire` | PDAM bill inquiry |
| POST | `credit/transactions/pdams` | Pay PDAM bill (credit) |
| POST | `flex/transactions/pdams` | Pay PDAM bill (flex) |

---

## E-Wallet (credit base URL)

| Method | Path | Description |
|---|---|---|
| POST | `credit/transactions/gopay` | Top up GoPay |
| POST | `credit/transactions/ovo` | Top up OVO |
| POST | `credit/transactions/shopee_pay` | Top up ShopeePay |
| POST | `credit/transactions/dana` | Top up DANA |
| POST | `flex/transactions/gopay` | Top up GoPay (flex balance) |
| POST | `flex/transactions/ovo` | Top up OVO (flex balance) |
| POST | `flex/transactions/shopee_pay` | Top up ShopeePay (flex balance) |
| POST | `flex/transactions/dana` | Top up DANA (flex balance) |

---

## Vouchers (credit base URL)

| Method | Path | Description |
|---|---|---|
| GET | `user_vouchers` | Paginated voucher list (`past` param) |
| GET | `user_vouchers/{id}` | Voucher detail |
| PUT | `user_vouchers/{id}/redeem` | Redeem voucher |
| POST | `flex_transactions` | Pay with voucher (flex) |
| POST | `credit/transactions/voucher` | Pay with voucher (credit) |

---

## Promo Codes (credit base URL)

| Method | Path | Description |
|---|---|---|
| GET | `promo_codes` | List promos |
| GET | `promo_codes/{id}` | Promo detail |

---

## Campaigns (BenefitNetworkClient — BENEFIT_CMS_URL)

| Method | Path | Description |
|---|---|---|
| GET | `mobile/campaigns` | Campaign list (cacheable) |
| GET | `mobile/campaigns/{id}` | Campaign detail |

---

## Products (BenefitNetworkClient — BENEFIT_CMS_URL)

| Method | Path | Description |
|---|---|---|
| GET | `mobile/products` | Paginated product list |
| GET | `mobile/products/{id}` | Product detail |

---

## Flex Points (credit base URL)

| Method | Path | Description |
|---|---|---|
| GET | `flex_points/balance` | Flex Point balance |
| GET | `flex_point_transactions` | Paginated Flex Point transaction history |

---

## Referral (credit base URL)

| Method | Path | Description |
|---|---|---|
| GET | `referral_settings` | Global referral settings |
| GET | `user_referral_settings` | User referral settings |
| PATCH | `user_referral_settings/{code}` | Submit referral code |

---

## Reimbursement (credit base URL)

| Method | Path | Description |
|---|---|---|
| GET | `reimbursements/{id}` | Reimbursement detail |
| POST | `reimbursements` | Create reimbursement |
| DELETE | `reimbursements/{id}` | Cancel reimbursement |

---

## Auto-Debit (credit base URL)

| Method | Path | Description |
|---|---|---|
| GET | `auto_debits/banks` | Supported banks for auto-debit |
| GET | `auto_debits/setting` | Auto-debit settings |
| GET | `auto_debits/linkages/info` | Current linkage info |
| POST | `auto_debits/linkages` | Create linkage (returns activation URL) |

---

## App Settings (credit base URL)

| Method | Path | Description |
|---|---|---|
| GET | `mobile_versions` | Min/force-update version per platform |

---

## Individual Access (credit base URL)

| Method | Path | Description |
|---|---|---|
| GET | `mekari_saving/users/access_status` | Check B2C eligibility |
| POST | `mekari_saving/users/accept_tnc` | Accept individual access TnC |

---

## Mekari Saving Registration (credit base URL)

| Method | Path | Description |
|---|---|---|
| POST | `mekari_saving/users` | Register user for Mekari Saving |

---

## Mekari Saving (SavingsNetworkClient — SAVING_URL)

| Method | Path | Description |
|---|---|---|
| POST | `auth/access-token` | Obtain savings auth token |
| POST | `auth/refresh-token` | Refresh savings auth token |
| GET | `auth/check-linkage-status` | Check savings account linkage |
| GET | `onboarding/tnc` | Savings onboarding TnC |
| POST | `onboarding/tnc/agree` | Agree to savings TnC |
| GET | `onboarding/status` | Savings onboarding status |
| POST | `transactions/balance-inquiry` | Savings account balance |
| GET | `transactions` | Savings transaction list |
| GET | `transactions/{id}/detail` | Savings transaction detail |
| GET | `transactions/bank-list` | Bank list for transfers |
| POST | `transactions/internal-account-inquiry` | Intrabank transfer inquiry |
| POST | `transactions/external-account-inquiry` | Interbank transfer inquiry |
| POST | `transactions/transfer-intrabank` | Execute intrabank transfer |
| POST | `transactions/transfer-interbank` | Execute interbank transfer |
| POST | `transactions/transfer-intrabank-confirmation` | Intrabank transfer confirmation |
| POST | `transactions/transfer-interbank-confirmation` | Interbank transfer confirmation |

---

## Feedback (Firebase Realtime Database)

| Operation | Path | Description |
|---|---|---|
| SET | `user_feedback/csat/{companyId}/{userId}` | Submit CSAT rating |
| SET | `user_feedback/nps/{companyId}/{userId}` | Submit NPS rating |

---

## QA / Dev Tools (ENABLE_DEV_TOOLS only)

| Method | Path | Base |
|---|---|---|
| POST | `/v2/transaction/sendpush` | `https://api-01.moengage.com` — push notification trigger |
