import 'package:flutter/material.dart';

import 'app.dart';
import 'l10n/app_locale.dart';
import 'services/settings/app_preferences_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppLocale.initialize();
  await AppPreferencesService.initialize();
  runApp(const AstrologyApp());
}
