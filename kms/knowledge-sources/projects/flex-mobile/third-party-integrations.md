# Third-Party Integrations — flex-mobile (Flutter)

Scanned: 2026-06-04

---

## Analytics & Monitoring

| Integration              | Package                    | Version   | Purpose                                          |
|--------------------------|----------------------------|-----------|--------------------------------------------------|
| Firebase Analytics       | `firebase_analytics`       | 11.3.6    | User event tracking, screen analytics            |
| Firebase Crashlytics     | `firebase_crashlytics`     | 4.2.0     | Crash reporting and error monitoring             |
| Firebase Performance     | `firebase_performance`     | 0.10.0+11 | HTTP and custom trace performance monitoring     |
| Firebase Realtime DB     | `firebase_database`        | 11.3.5    | NPS/CSAT survey triggers                         |
| Firebase Remote Config   | `firebase_remote_config`   | 5.2.0     | Feature flags, remote configuration              |
| MoEngage                 | `moengage_flutter`         | 9.2.1     | Push notifications, in-app messaging, event tracking |
| MoEngage Inbox           | `moengage_inbox`           | 8.2.1     | In-app notification inbox                        |
| Mekari Log (`mekari_log`)| git (Bitbucket)            | log-1.38.2| Internal HTTP request/response logging           |

---

## Authentication

| Integration  | Package                  | Version                        | Purpose                                   |
|--------------|--------------------------|--------------------------------|-------------------------------------------|
| Mekari SSO   | `auth_module`            | git auth_module-1.41.0         | SSO login/logout with ssoClientId/ssoEnvironment |
| Biometric Auth| `local_auth`            | 2.3.0                          | Fingerprint/Face ID for PIN confirmation  |
| Secure Storage| `flutter_secure_storage`| 9.2.4                          | Encrypted token/session storage           |

---

## Networking

| Integration    | Package          | Version        | Purpose                              |
|----------------|------------------|----------------|--------------------------------------|
| Dio            | `dio`            | 5.8.0+1        | HTTP client (wrapped by FlexNetworkClient) |
| Mekari Network | `mekari_network` | git network-1.6.1 | Internal network client base with interceptors |

---

## PPOB / Payments

| Integration          | Notes                                              |
|----------------------|----------------------------------------------------|
| Sepulsa              | Mobile prepaid/postpaid and electricity products via `sepulsa_product/*` endpoints |
| GoPay                | e-wallet payment via `credit/transactions/gopay`   |
| OVO                  | e-wallet payment via `credit/transactions/ovo`     |
| ShopeePay            | e-wallet payment via `credit/transactions/shopee_pay` |
| DANA                 | e-wallet payment via `credit/transactions/dana`    |
| Finfra (B2C partner) | `credit/credit_partner_transactions` — B2C lending partner |

---

## Local Storage

| Integration | Package                              | Version | Purpose                                     |
|-------------|--------------------------------------|---------|---------------------------------------------|
| Hive        | `hive` + `hive_flutter`              | 2.2.3   | Lightweight key-value store (session, settings, product cache) |
| ObjectBox   | `objectbox` + `objectbox_flutter_libs`| 4.1.0  | High-performance local DB for inbox/transactions |

---

## UI / Design

| Integration               | Package                     | Version                 | Purpose                              |
|---------------------------|-----------------------------|-------------------------|--------------------------------------|
| Mekari Pixel              | `mekari_pixel`              | git v2.22.0             | Internal design system (fonts, colors, components) |
| Mekari Pixel Illustrations| `mekari_pixel_illustrations`| git illustrations-1.4.0 | Illustration assets                  |
| Flutter SVG               | `flutter_svg`               | 2.0.10+1                | SVG asset rendering                  |
| Pie Chart                 | `pie_chart`                 | 5.4.0                   | Balance breakdown charts             |
| Sliver Tools              | `sliver_tools`              | 0.2.12                  | Sliver scroll extensions             |

---

## Media / Files

| Integration  | Package          | Version  | Purpose                           |
|--------------|------------------|----------|-----------------------------------|
| Camera       | `camera`         | 0.11.0+2 | KYC KTP photo capture             |
| Image Picker | `image_picker`   | 1.1.2    | Payslip/attachment upload         |
| File Picker  | `file_picker`    | 5.5.0    | Document upload                   |
| PDF Viewer   | `pdfx`           | 2.8.0    | In-app PDF rendering (TnC, statements) |
| Barcode/QR   | `barcode`        | 2.2.9    | QR code generation (referral)     |
| Share        | `share_plus`     | 7.2.2    | Share referral codes / documents  |

---

## Notifications / Communication

| Integration          | Package                      | Version | Purpose                              |
|----------------------|------------------------------|---------|--------------------------------------|
| Local Notifications  | `flutter_local_notifications`| 17.2.4  | Local push notification scheduling   |
| Ringtone Player      | `flutter_ringtone_player`    | 4.0.0+4 | Sound on payment success             |
| Sound Mode           | `sound_mode`                 | 3.1.1   | Detect device sound mode             |
| Vibration            | `vibration`                  | 3.1.4   | Haptic feedback                      |

---

## Deep Linking / Navigation

| Integration  | Package          | Version     | Purpose                              |
|--------------|------------------|-------------|--------------------------------------|
| App Links    | `app_links`      | 3.5.1       | Deep link / universal link handling  |
| URL Launcher | `url_launcher`   | 6.3.1       | Open external URLs, tel, mailto      |
| WebView      | `webview_flutter`| 4.8.0       | In-app web views (TnC, partner agreement webview) |
| Brick Way    | `brick_way`      | git v1.21.3 | Internal deep-link/module routing framework |

---

## Contacts / Device

| Integration    | Package                | Version | Purpose                          |
|----------------|------------------------|---------|----------------------------------|
| Contact Picker | `fluttercontactpicker` | 5.0.0   | Pick contacts (emergency contact in KYC) |
| Advertising ID | `advertising_id`       | 2.7.1   | Device ad identifier             |
| Android ID     | `android_id`           | 0.4.0   | Android device identifier        |
| Package Info   | `package_info_plus`    | 8.2.0   | App version info                 |

---

## Internal Mekari Packages (git dependencies, Bitbucket)

| Package                     | Ref                    | Purpose                          |
|-----------------------------|------------------------|----------------------------------|
| `auth_module`               | auth_module-1.41.0     | SSO authentication               |
| `mekari_flag`               | flag-1.7.0             | Feature flag client              |
| `mekari_log`                | log-1.38.2             | Structured request logging       |
| `mekari_network`            | network-1.6.1          | Network client base              |
| `mekari_pixel`              | v2.22.0                | Design system                    |
| `mekari_pixel_illustrations`| illustrations-1.4.0    | Illustration assets              |
| `mekari_qa_tools`           | qa_tools-1.0.4         | QA/testing tools (mock server, device preview) |
| `brick_way`                 | v1.21.3                | Module routing framework         |
| `network_inspector`         | network_inspector-1.4.1| Network debug inspector (QA)     |

---

## Integration Count: 42 integrations (packages + services)
