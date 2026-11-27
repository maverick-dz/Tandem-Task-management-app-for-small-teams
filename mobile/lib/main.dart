import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tandem/app.dart';
import 'package:tandem/core/notifications/push_registration.dart';
import 'package:tandem/core/storage/settings_store.dart';
import 'package:tandem/core/storage/storage_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Push needs google-services.json: build with --dart-define=PUSH_ENABLED=true.
  if (pushEnabled) await Firebase.initializeApp();
  // The settings are read before the first frame, so the language is right at once.
  final settings = await SharedPreferencesSettingsStore().load();
  runApp(
    ProviderScope(
      overrides: [initialSettingsProvider.overrideWithValue(settings)],
      child: const TandemApp(),
    ),
  );
}
