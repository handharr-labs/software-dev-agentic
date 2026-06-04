# Architecture Deviations — flex-mobile (Flutter)

Scanned: 2026-06-04

## Summary

flex-mobile largely follows Clean Architecture + BLoC consistently. The deviations below are real observations from the codebase scan.

---

## DEV-001: Inconsistent use_cases directory naming

**Location:** Various features  
**Expected:** Uniform `use_cases/` directory name  
**Actual:** Some features use `use_cases/` (app_settings, auto_debit, voucher, promo), others use `usecases/` without underscore (ckyc, auto_debit domain, mobile, pdam, campaigns)  
**Impact:** Low — naming only, no functional consequence

---

## DEV-002: Domain entities with `.g.dart` files (json_serializable on domain layer)

**Location:** `lib/features/referral/domain/entities/referral_global_settings.g.dart`, `lib/features/referral/domain/entities/referral_user_settings.g.dart`, `saving` module entities  
**Expected:** Domain entities are pure Dart; serialization belongs in data layer  
**Actual:** Some domain entities generate `fromJson`/`toJson` directly via `json_annotation`  
**Impact:** Medium — couples domain to JSON serialization concern, violates layer purity

---

## DEV-003: Dual payment data source classes in a single file

**Location:** `lib/features/payment/data/data_sources/payment_remote_data_source.dart`  
**Actual:** Two concrete classes (`CreditPaymentDataSource`, `FlexPaymentDataSource`) in one file, both extending abstract `PaymentDataSource`. The abstract class holds the `FlexNetworkClient` reference — making it concrete, not abstract.  
**Impact:** Low-medium — harder to extend independently, but functional

---

## DEV-004: Account feature has no data/domain layers

**Location:** `lib/features/account/`  
**Expected:** Full Clean Architecture stack  
**Actual:** Only presentation layer exists. All account-related data is pulled from other features (auth from flex_core, balance, etc.)  
**Impact:** Low — intentional composition, but inconsistent with other feature structures

---

## DEV-005: Two separate `promo` feature implementations

**Location:** `lib/features/promo/` (benefit-level promos) and `modules/cashout/lib/src/data/sources/promo_remote_source.dart` (cashout promos)  
**Actual:** Both hit the same `promo_codes` API path but are completely separate feature implementations with no shared code  
**Impact:** Medium — duplication; risk of behavior divergence

---

## DEV-006: Network client as constructor parameter in abstract class

**Location:** `lib/features/payment/data/data_sources/payment_remote_data_source.dart`  
**Actual:** `PaymentDataSource` is declared abstract but takes `FlexNetworkClient` in its constructor, making it effectively a concrete base class  
**Impact:** Low — design smell, but works

---

## DEV-007: `flex_core` module contains presentation layer features

**Location:** `modules/flex_core/lib/features/auth/presentation/`, `modules/flex_core/lib/features/awareness/presentation/`, etc.  
**Expected:** Shared modules typically contain domain/data only  
**Actual:** flex_core ships complete feature stacks including screens and BLoCs, which the host app directly uses  
**Impact:** Low — intentional design for cross-product sharing, but couples UI to the core module

---

## DEV-008: `device_preview` and `mekari_qa_tools` in production dependencies

**Location:** `pubspec.yaml` dependencies block (not dev_dependencies)  
**Actual:** `device_preview: 1.2.0` and `mekari_qa_tools` are listed under `dependencies`, not `dev_dependencies`. Tree-shaken only if ENABLE_DEV_TOOLS flag is false.  
**Impact:** Medium — increases app binary size; should be under dev_dependencies or conditionally excluded

---

## DEV-009: Hardcoded `MOENGAGE_APP_ID` constant reference in service locator

**Location:** `lib/configs/di/service_locator.dart`  
**Actual:** App ID constant is directly referenced without env abstraction  
**Impact:** Low — common pattern for MoEngage integration

---

## Deviation Count: 9
