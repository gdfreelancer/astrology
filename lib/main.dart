import 'package:flutter/material.dart';

import 'app.dart';
import 'l10n/app_locale.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppLocale.initialize();
  runApp(const AstrologyApp());
}
