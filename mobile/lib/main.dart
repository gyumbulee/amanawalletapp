import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'providers/global_providers.dart';

Future<void> main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  // Keeps the native splash (flutter_native_splash) on screen past first
  // frame — removed in app.dart once isAuthenticatedProvider resolves, so
  // returning users go straight to the dashboard instead of flashing the
  // login screen first while secure storage is still being read.
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Must resolve before runApp so sharedPreferencesProvider can be
  // overridden synchronously — everything downstream (local storage,
  // theme mode) depends on it being ready at first frame.
  final sharedPreferences = await SharedPreferences.getInstance();

  // Hive is used for non-sensitive caching only (provider lists, recent
  // transaction cache) — never tokens or PII. Works via IndexedDB on Web.
  await Hive.initFlutter();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const AmanaWalletApp(),
    ),
  );
}
