# Amana Wallet — Flutter Frontend

**Completed so far:**
1. **Scaffold** — theme, router shell, Dio client, storage wrappers, shared widgets
2. **Auth** — register, login, OTP verify, forgot/reset password (screens + Riverpod controllers + repository, wired to `/api/v1/auth/*`)

All other feature screens are still stubbed with a `ComingSoonScreen`
placeholder and will be filled in phase by phase (Wallet + Virtual Account
next).

## Why this needs one setup step on your machine

This was generated in a sandbox without Flutter SDK / pub.dev access, so the
platform folders (`android/`, `ios/`, `web/`) and the `.dart_tool` /
`pubspec.lock` files don't exist yet. That's a one-time, 2-minute fix:

```bash
# 1. From the parent folder containing this amanawalletapp/ directory,
#    generate the missing platform folders into THIS existing project:
flutter create --platforms=android,ios,web --org com.amanawallet .

# 2. Install dependencies
flutter pub get

# 3. Run it (pick a device/target)
flutter run -d chrome        # Web
flutter run -d android       # Android emulator
flutter run -d ios           # iOS simulator (macOS only)
```

`flutter create .` will not overwrite `lib/`, `pubspec.yaml`, or this
README — it only fills in the platform scaffolding those files are missing.

## A note on dependencies

This scaffold is **hand-written, no code generation** — no `@riverpod`,
`@freezed`, or `@HiveType` annotations anywhere, so `build_runner`,
`freezed`, `json_serializable`, `riverpod_generator`, and `hive_generator`
were deliberately left out of `pubspec.yaml`. Those packages pin
conflicting `analyzer` versions against each other (a well-known Flutter
pub conflict, especially `hive_generator` vs `riverpod_generator`/
`freezed`), and since nothing here actually needs them, leaving them out
avoids that resolution failure entirely. Hive itself stays in as a runtime
dependency for later use as a non-sensitive cache — just without the
generator, since we're not using generated type adapters.

If a later phase genuinely needs code generation, add the matching
generator back in one at a time and re-run `flutter pub get` — that keeps
any future conflict isolated to a single package instead of three
interacting at once.

## Pointing the app at your Laravel backend

Edit `lib/core/config/env_config.dart`, or pass the URL at run time without
touching code:

```bash
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8000/api/v1
```

Dev defaults already set:
- Android emulator → `http://10.0.2.2:8000/api/v1` (10.0.2.2 = host machine from inside the emulator)
- iOS simulator / Web → use `http://localhost:8000/api/v1` or your machine's LAN IP if testing on a physical device

## What's included in this scaffold

- `core/` — env config, Dio client + auth interceptor (Sanctum bearer token, 401 handling), error mapper (Laravel validation/error shapes → typed `Failure`), secure storage (token/PIN) + local storage (prefs/theme) wrappers
- `theme/` — full brand palette, Poppins typography, light/dark `ThemeData`, radii (12/16/20px)
- `routing/` — GoRouter with named routes for all 12 features + auth flow, redirect guard based on token presence, auto re-evaluates on login/logout/401
- `shared/widgets/` — primary/secondary/danger buttons, text field, PIN input, OTP input, base card, wallet card, skeleton loaders, spinner, empty state, responsive scaffold (caps content width on Web so it doesn't stretch full browser width)
- `providers/global_providers.dart` — Riverpod wiring for SharedPreferences, secure storage, Dio, and auth status
- `features/*/` — `data/domain/presentation` folders created for all 12 customer-facing modules, ready for each phase (Auth first)

## Auth module details

- `features/auth/domain/` — `AuthUser` entity, `AuthRepository` interface, `AuthResult` (token nullable — null means the account still needs OTP verification)
- `features/auth/data/` — `AuthApiService` (raw Dio calls), `AuthRepositoryImpl` (maps responses, persists token via secure storage, maps errors through `ErrorMapper`)
- `features/auth/presentation/providers/` — one `AsyncNotifier` controller per flow (register, login, OTP verify + resend, forgot password, reset password, logout), plus `authSessionProvider` holding the current `AuthUser`
- `features/auth/presentation/screens/` — Login, Register, Verify OTP, Forgot Password, Reset Password — all built on `ResponsiveScaffold`, using the shared `AppTextField`/`OtpInput`/`PrimaryButton` widgets and surfacing Laravel 422 field errors inline via `ValidationFailureFieldError`

**Assumed API response shape** (adjust `AuthUserModel`/`AuthRepositoryImpl` if yours differs):
```json
{ "message": "...", "user": { "id": 1, "name": "...", "email": "...", "phone": "...", "referral_code": "...", "email_verified_at": null }, "token": "..." }
```
`token` is expected to be **omitted** on `/auth/register` (until OTP is verified) and **present** on `/auth/login` and `/auth/verify-otp`. If your backend issues a token immediately on register too, just drop the `requiresOtpVerification` branch in `register_screen.dart`.

**BVN is required at registration** (not deferred to a later profile step) — the register form sends `bvn` (validated client-side as exactly 11 digits) alongside name/email/phone/password, matching the backend built for this project.

**Email flow between screens**: OTP verify and reset-password screens receive the target email via GoRouter's `extra` param (`context.push(AppRoutes.verifyOtp, extra: email)`) — no global state needed for that handoff.

## Wallet + Virtual Account + Dashboard module details

- `features/wallet/` — `WalletBalance` + `WalletLedgerEntry` entities, repository wired to `/wallet/balance` and `/wallet/ledger`. `walletBalanceProvider` is an `AsyncNotifier` with `.refresh()` (call after a bill payment or on pull-to-refresh); `walletLedgerProvider` is paginated with infinite scroll via `.loadMore()`.
- `features/virtual_account/` — `VirtualAccount` entity, repository wired to `/virtual-account`, cached in a `FutureProvider` (invalidate to re-fetch, e.g. after BVN verification activates the account).
- `features/dashboard/` — home screen: greeting, wallet card (balance + virtual account + copy), 8-item quick actions grid routing into every bill-payment feature, recent transactions placeholder (real data lands with the Transactions phase next).
- **Wallet screen** (`/wallet`) — balance card, "Fund Wallet" button, full ledger history with pull-to-refresh + infinite scroll.
- **Fund Wallet screen** (`/virtual-account`) — shows the dedicated account (bank name, number, copy button) with a note that transfers auto-credit via the Flutterwave webhook. No in-app checkout screen was built here since the spec has funding happen via bank transfer only — flag it if you actually want a card/checkout funding path added too.

**Assumed API response shapes** (adjust the `*_model.dart` files if yours differ):
```json
// GET /wallet/balance
{ "balance": 150000, "currency": "NGN" }   // balance in kobo

// GET /wallet/ledger  (Laravel paginator)
{ "data": [ { "id": "...", "type": "credit", "amount": 50000, "balance_after": 150000, "description": "...", "reference": "...", "created_at": "..." } ],
  "meta": { "current_page": 1, "last_page": 3 } }

// GET /virtual-account
{ "account_number": "...", "account_name": "...", "bank_name": "...", "is_active": true }
```
All three repositories also accept the same payload nested one level under `"data"`, so a wrapped response won't break anything.

## Next phase

Transactions — history list, detail view, filters/search, wired to
`/transactions`, replacing the dashboard's "Recent Transactions" placeholder
with real data.
