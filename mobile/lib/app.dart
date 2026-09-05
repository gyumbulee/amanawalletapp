import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'constants/app_constants.dart';
import 'core/push/push_notification_service.dart';
import 'features/settings/presentation/theme_mode_provider.dart';
import 'providers/global_providers.dart';
import 'routing/app_router.dart';
import 'theme/app_theme.dart';

class AmanaWalletApp extends ConsumerWidget {
  const AmanaWalletApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeProvider);
    // Side-effect-only watch: fires PushNotificationService.initialize()
    // once and keeps it alive for the app's lifetime. The AsyncValue itself
    // is unused — permission prompts and registration failures are handled
    // (and logged) inside the service, not surfaced here.
    ref.watch(pushNotificationInitProvider);

    // Drops the native splash preserved in main.dart the moment the auth
    // check settles (success or failure) — pairs with the redirect logic
    // in app_router.dart, which is already waiting on this exact provider.
    ref.listen(isAuthenticatedProvider, (previous, next) {
      if (!next.isLoading) {
        FlutterNativeSplash.remove();
      }
    });

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      routerConfig: router,
    );
  }
}
