# Push Notifications Setup

All the code is done (backend FCM sending + mobile receiving/registering).
What's left are steps only you can do, since they require your own Firebase
account and Apple Developer account.

## 1. Create the Firebase project

1. Go to https://console.firebase.google.com and create a project (or use
   an existing one) — e.g. "Amana Wallet".
2. Add an Android app to it:
   - Package name: `com.amanawallet.mobile` (must match exactly —
     this is `applicationId` in `android/app/build.gradle.kts`)
   - Download the generated `google-services.json`
   - Place it at `android/app/google-services.json` in this repo
     (already gitignored — never commit it)
3. Add an iOS app to it:
   - Bundle ID: whatever `PRODUCT_BUNDLE_IDENTIFIER` is set to in Xcode
     (Runner target -> General -> Bundle Identifier)
   - Download the generated `GoogleService-Info.plist`
   - Place it at `ios/Runner/GoogleService-Info.plist`
   - **In Xcode**, right-click the `Runner` folder -> "Add Files to
     Runner..." -> select the plist -> make sure "Copy items if needed"
     and the Runner target are checked. Just dropping the file in the
     folder on disk isn't enough; Xcode needs it added to the project.

Without step 2/3, the app builds fine (both build.gradle.kts and the push
service check for the file first) but push notifications silently do
nothing on that platform.

## 2. iOS: enable Push Notifications + upload an APNs key

Firebase can't deliver to iOS without an APNs key from your Apple Developer
account:

1. In Xcode: select the `Runner` target -> **Signing & Capabilities** ->
   `+ Capability` -> add **Push Notifications** and **Background Modes**
   (check "Remote notifications" under Background Modes — this repo's
   `Info.plist` already declares `UIBackgroundModes: remote-notification`,
   but Xcode's capability toggle needs to be on too so it's reflected in
   the entitlements file).
2. In your Apple Developer account (https://developer.apple.com/account) ->
   Certificates, IDs & Profiles -> Keys -> create a new key with the "Apple
   Push Notifications service (APNs)" capability enabled. Download the
   `.p8` file (you only get one chance to download it).
3. In Firebase Console -> Project Settings -> Cloud Messaging -> Apple app
   configuration -> upload that `.p8` file along with your Key ID and Team
   ID (both shown on the key's page in the Apple Developer portal).

## 3. Backend: generate a service account for sending pushes

1. Firebase Console -> Project Settings -> Service Accounts -> "Generate
   new private key". This downloads a JSON file.
2. Store it somewhere on the server **outside the repo** (e.g.
   `/home/forge/secrets/firebase.json`), or locally outside the project
   folder for dev.
3. Set in `.env`:
   ```
   FCM_PROJECT_ID=<your-firebase-project-id>
   FCM_CREDENTIALS_PATH=/absolute/path/to/that-file.json
   ```

## 4. Run the migration

```
php artisan migrate
```

This creates the `device_tokens` table the backend uses to know which
devices to push to.

## 5. Test it

- Install the app on a real device (push doesn't work reliably on
  simulators/emulators for iOS, and Android emulators need Google Play
  services installed).
- Log in — this registers the device's FCM token with the backend
  automatically (`POST /notifications/device-token`).
- Trigger any of the three pushable events: a successful/failed purchase,
  a referral bonus, or a support ticket reply. You should get a push
  within a few seconds, and tapping it should open the right screen.

## What's NOT covered yet

- **Web push** is intentionally skipped (`PushNotificationService`
  short-circuits on `kIsWeb`). It needs its own service worker file
  (`web/firebase-messaging-sw.js`) and a VAPID key from the Firebase
  console — different enough from mobile setup to warrant its own pass
  later rather than a half-configured bolt-on now.
- **Reversed transactions** don't currently trigger any notification
  (mail, database, or push) — `TransactionService::markReversed()` doesn't
  dispatch an event the way `markSuccessful()`/`markFailed()` do. Small
  gap, separate from this push notification work.
