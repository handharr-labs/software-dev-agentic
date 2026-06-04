# API Endpoints — flex-mobile (Flutter)

Scanned: 2026-06-04

All paths are relative to the base URL configured per environment via envied (`BASE_URL`, `BENEFIT_CMS_URL`, `LENDING_URL`, `SAVING_URL`). Most endpoints use `FlexNetworkClient` (credit/benefit network). Pin-protected endpoints send PIN in request header `pin: <value>`. JSONAPI responses use `japx` for decoding.

---

## Environments

| Name       | Env file           |
|------------|--------------------|
| production | `.env.production`  |
| staging    | `.env.staging`     |
| sandbox    | `.env.sandbox`     |

Base URL keys: `BASE_URL` (credit), `BENEFIT_CMS_URL` (benefit/lending CMS), `LENDING_URL`, `SAVING_URL`

---

## App Settings

| Method | Path              | Feature       | Notes              |
|--------|-------------------|---------------|--------------------|
| GET    | `mobile_versions` | app_settings  | Force-update check |

---

## Auto Debit

| Method | Path                       | Feature    | Notes                    |
|--------|----------------------------|------------|--------------------------|
| GET    | `auto_debits/banks`        | auto_debit | List supported banks     |
| GET    | `auto_debits/setting`      | auto_debit | Auto-debit settings      |
| GET    | `auto_debits/linkages/info`| auto_debit | Current linkage status   |
| POST   | `auto_debits/linkages`     | auto_debit | Request activation URL   |

---

## Cashout (EWA withdrawal — modules/cashout)

| Method | Path                                              | Feature | Notes                                 |
|--------|---------------------------------------------------|---------|---------------------------------------|
| GET    | `company_fee_settings`                            | cashout | Company cashout fee config            |
| GET    | `fee_calculations`                                | cashout | Calculate transaction fee             |
| GET    | `payment_methods`                                 | cashout | Available payment methods             |
| POST   | `credit/transactions/cashout`                     | cashout | Create cashout transaction (PIN req)  |
| POST   | `credit/credit_partner_transactions`              | cashout | Request B2C partner payment           |
| POST   | `credit/credit_partner_transactions/{id}/cashout` | cashout | Complete partner cashout              |
| GET    | `credit/credit_partner_transactions/{id}`         | cashout | Get partner payment status            |
| GET    | `promo_codes`                                     | cashout | List available promos                 |
| GET    | `promo_codes/{id}`                                | cashout | Promo detail                          |

---

## CKYC (Credit KYC)

| Method | Path                             | Feature | Notes                            |
|--------|----------------------------------|---------|----------------------------------|
| POST   | `ckyc/kyc/availability`          | ckyc    | Validate NIK                     |
| POST   | `ckyc/kyc/init`                  | ckyc    | Init KYC process                 |
| GET    | `ckyc/kyc`                       | ckyc    | Get KYC step details             |
| GET    | `ckyc/ocr`                       | ckyc    | Get OCR data from KTP            |
| POST   | `ckyc/ktps`                      | ckyc    | Get presigned S3 URL for KTP     |
| PATCH  | `ckyc/ktps`                      | ckyc    | Finish KTP upload                |
| POST   | `ckyc/kyc/upload_payslip`        | ckyc    | Upload payslip (multipart)       |
| POST   | `ckyc/ocr`                       | ckyc    | Submit OCR form data             |
| POST   | `ckyc/kyc/emergency_contact`     | ckyc    | Submit emergency contact         |
| POST   | `ckyc/kyc/spouse_data`           | ckyc    | Submit spouse data               |
| POST   | `ckyc/liveness`                  | ckyc    | Start liveness check             |
| PATCH  | `ckyc/liveness`                  | ckyc    | Update liveness step             |
| GET    | `ckyc/kyc/terms_of_service`      | ckyc    | Fetch TnC URL (cached 5 min)     |

---

## Electricity (PPOB)

| Method | Path                                               | Feature     | Notes                    |
|--------|----------------------------------------------------|-------------|--------------------------|
| POST   | `credit/transactions/electricity_prepaids/inquire` | electricity | PLN prepaid inquiry      |
| POST   | `credit/transactions/electricity_postpaids/inquire`| electricity | PLN postpaid inquiry     |
| GET    | `sepulsa_product/electricity_prepaid` (inferred)   | electricity | Prepaid token products   |

---

## Flex Points

| Method | Path                      | Feature    | Notes                         |
|--------|---------------------------|------------|-------------------------------|
| GET    | `flex_points/balance`     | flex_point | Flex Points balance           |
| GET    | `flex_point_transactions` | flex_point | Paginated transaction history |

---

## Individual Access (Mekari Saving)

| Method | Path                               | Feature           | Notes                        |
|--------|------------------------------------|-------------------|------------------------------|
| GET    | `mekari_saving/users/access_status`| individual_access | Eligibility check            |
| POST   | `mekari_saving/users/accept_tnc`   | individual_access | Accept individual access TnC |

---

## Mobile PPOB

| Method | Path                                          | Feature | Notes                      |
|--------|-----------------------------------------------|---------|----------------------------|
| GET    | `sepulsa_product/mobile_prepaid`              | mobile  | Prepaid/data plan products |
| GET    | `sepulsa_product/mobile_postpaid`             | mobile  | Postpaid mobile products   |
| POST   | `credit/transactions/mobile_postpaids/inquire`| mobile  | Postpaid bill inquiry      |

---

## Payment (PPOB Transactions)

Two parallel sets: `CreditPaymentDataSource` (credit balance) and `FlexPaymentDataSource` (flex balance).

| Method | Path (credit)                                     | Path (flex)                        | Notes      |
|--------|---------------------------------------------------|------------------------------------|------------|
| POST   | `credit/transactions/mobile_prepaids`             | `flex/transactions/mobile_prepaids`| PIN header |
| POST   | `credit/transactions/mobile_postpaids`            | `flex/transactions/mobile_postpaids`| PIN header |
| POST   | `credit/transactions/electricity_prepaids`        | `flex/transactions/electricity_prepaids`| PIN header |
| POST   | `credit/transactions/electricity_postpaids`       | `flex/transactions/electricity_postpaids`| PIN header |
| POST   | `credit/transactions/gopay`                       | `flex/transactions/gopay`          | PIN header |
| POST   | `credit/transactions/ovo`                         | `flex/transactions/ovo`            | PIN header |
| POST   | `credit/transactions/shopee_pay`                  | `flex/transactions/shopee_pay`     | PIN header |
| POST   | `credit/transactions/dana`                        | `flex/transactions/dana`           | PIN header |
| POST   | `credit/transactions/voucher`                     | flex voucher path                  | PIN header |
| POST   | `credit/transactions/cashout`                     | —                                  | PIN header |
| POST   | `credit/transactions/pdams`                       | `flex/transactions/pdams`          | PIN header |
| POST   | `credit/credit_partner_transactions/{id}/cashout` | —                                  | Finfra path|

---

## PDAM (PPOB)

| Method | Path                                  | Feature | Notes                   |
|--------|---------------------------------------|---------|-------------------------|
| GET    | `credit/transactions/pdams/operators` | pdam    | List PDAM operators     |
| POST   | `credit/transactions/pdams/inquire`   | pdam    | PDAM bill inquiry       |

---

## Promo Codes (benefit-level)

| Method | Path               | Feature | Notes         |
|--------|--------------------|---------|---------------|
| GET    | `promo_codes`      | promo   | List promos   |
| GET    | `promo_codes/{id}` | promo   | Promo detail  |

---

## Referral

| Method | Path                            | Feature  | Notes                      |
|--------|---------------------------------|----------|----------------------------|
| GET    | `referral_settings`             | referral | Global referral config     |
| GET    | `user_referral_settings`        | referral | User's referral settings   |
| PATCH  | `user_referral_settings/{code}` | referral | Submit received code       |

---

## Reimbursement

| Method | Path                  | Feature       | Notes                     |
|--------|-----------------------|---------------|---------------------------|
| POST   | `reimbursements`      | reimbursement | Create reimbursement      |
| GET    | `reimbursements/{id}` | reimbursement | Detail                    |
| DELETE | `reimbursements/{id}` | reimbursement | Cancel                    |

---

## Savings (Mekari Saving user registration)

| Method | Path                  | Feature | Notes          |
|--------|-----------------------|---------|----------------|
| POST   | `mekari_saving/users` | savings | Register user  |

---

## Vouchers

| Method | Path                        | Feature | Notes                         |
|--------|-----------------------------|---------|-------------------------------|
| GET    | `user_vouchers`             | voucher | Paginated list (active/past)  |
| GET    | `user_vouchers/{id}`        | voucher | Voucher detail                |
| PUT    | `user_vouchers/{id}/redeem` | voucher | Redeem voucher                |

---

## Campaigns

| Method | Path                    | Feature   | Notes                    |
|--------|-------------------------|-----------|--------------------------|
| GET    | `mobile/campaigns`      | campaigns | List campaigns (cached)  |
| GET    | `mobile/campaigns/{id}` | campaigns | Campaign detail          |

---

## Total endpoints: ~60
