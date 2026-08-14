import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'providers/global_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
