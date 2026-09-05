import 'dart:developer' as developer;

import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../constants/api_endpoints.dart';
import '../../features/notifications/presentation/providers/notification_list_provider.dart';
import '../../features/notifications/presentation/providers/unread_count_provider.dart';
import '../../providers/global_providers.dart';
import '../../routing/app_router.dart';

/// Must be a top-level function, not a class method — the platform spawns a
/// separate isolate to run this when a push arrives while the app is fully
/// terminated or backgrounded, so it can't close over any Flutter/app
/// state. Kept intentionally minimal: just make sure Firebase is
/// initialized so the plugin doesn't crash. Anything more (navigation,
/// Riverpod state, updating the unread badge) has to happen in the
/// foreground/tap handlers below instead, since this isolate has no widget
/// tree and no access to the app's ProviderContainer.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

/// Owns the whole push-notification lifecycle: requesting permission,
/// fetching/refreshing the FCM token, registering it with the backend, and
/// routing a tapped notification to the right screen.
///
/// Registration/unregistration is deliberately best-effort — a failure here
/// should never block login/logout, so every network call is wrapped and
/// swallowed (with a debug log) rather than surfaced to the user.
///
/// Web is intentionally skipped for now: browser push needs its own
/// service-worker file (web/firebase-messaging-sw.js) and a VAPID key from
/// the Firebase console, which is enough extra setup to warrant its own
/// pass rather than bolting it on half-configured here.
class PushNotificationService {
  PushNotificationService(this._ref);

  final Ref _ref;

  String? _registeredToken;

  Future<void> initialize() async {
    if (kIsWeb) return;

    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    final messaging = FirebaseMessaging.instance;

    // Covers both the iOS permission prompt and Android 13+'s runtime
    // POST_NOTIFICATIONS permission — the plugin handles the platform
    // split internally. If the user declines, we still proceed (no push,
    // the in-app notification list is unaffected).
    await messaging.requestPermission(alert: true, badge: true, sound: true);

    final token = await messaging.getToken();
    if (token != null) {
      await _registerToken(token);
    }

    messaging.onTokenRefresh.listen(_registerToken);

    // Foreground: the OS doesn't show a heads-up banner for a push that
    // arrives while the app is already open, so at minimum keep the in-app
    // notification bell/list in sync with what just landed rather than
    // requiring a manual pull-to-refresh to discover it.
    FirebaseMessaging.onMessage.listen((message) {
      _ref.invalidate(unreadNotificationCountProvider);
      _ref.invalidate(notificationListProvider);
    });

    // Tapped while the app was backgrounded (not terminated).
    FirebaseMessaging.onMessageOpenedApp.listen(_handleTap);

    // Cold start: app was fully terminated and opened via a notification tap.
    final initialMessage = await messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleTap(initialMessage);
    }
  }

  Future<void> _registerToken(String token) async {
    if (_registeredToken == token) return;

    final authToken = await _ref.read(secureStorageProvider).getAuthToken();
    if (authToken == null || authToken.isEmpty) return; // not logged in yet

    try {
      await _ref.read(dioProvider).post(
        ApiEndpoints.deviceToken,
        data: {'token': token, 'platform': _platformName},
      );
      _registeredToken = token;
    } on DioException catch (e) {
      developer.log('Push token registration failed', error: e, name: 'PushNotificationService');
    }
  }

  /// Call right after a successful login. The FCM token is often fetched
  /// before the user is authenticated (e.g. cold start lands on the login
  /// screen), so [_registerToken] would have skipped it for lack of a
  /// bearer token — this re-attempts now that one exists.
  Future<void> registerAfterLogin() async {
    if (kIsWeb) return;
    final token = await FirebaseMessaging.instance.getToken();
    if (token != null) await _registerToken(token);
  }

  /// Call before clearing the session on logout, so a shared/former device
  /// stops receiving push notifications for this account.
  Future<void> unregisterBeforeLogout() async {
    if (kIsWeb) return;

    final token = _registeredToken ?? await FirebaseMessaging.instance.getToken();
    if (token == null) return;

    try {
      await _ref.read(dioProvider).delete(ApiEndpoints.deviceToken, data: {'token': token});
    } on DioException catch (e) {
      developer.log('Push token unregistration failed', error: e, name: 'PushNotificationService');
    } finally {
      _registeredToken = null;
    }
  }

  /// Mirrors the `data.type` values set in the backend's toFcm() payloads
  /// (TransactionStatusNotification, ReferralBonusEarnedNotification,
  /// SupportTicketReplyNotification) — keep both sides in sync if a new
  /// pushable notification type is added.
  void _handleTap(RemoteMessage message) {
    final router = _ref.read(appRouterProvider);

    switch (message.data['type']) {
      case 'transaction_status':
        final id = message.data['transaction_id'];
        if (id != null) router.push(AppRoutes.transactionDetail(id));
      case 'referral_bonus':
        router.push(AppRoutes.referral);
      case 'support_ticket_reply':
        final ticketId = message.data['ticket_id'];
        if (ticketId != null) router.push(AppRoutes.supportTicketDetailPath(ticketId));
      default:
        router.push(AppRoutes.notifications);
    }
  }

  String get _platformName {
    return defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android';
  }
}

final pushNotificationServiceProvider = Provider<PushNotificationService>((ref) {
  return PushNotificationService(ref);
});

/// Watched once at the app root purely for its side effect (kicks off
/// [PushNotificationService.initialize]) — see app.dart.
final pushNotificationInitProvider = FutureProvider<void>((ref) {
  return ref.read(pushNotificationServiceProvider).initialize();
});
