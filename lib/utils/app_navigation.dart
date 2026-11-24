import 'package:flutter/material.dart';

import '../screens/placeholder/feature_placeholder_screen.dart';

class AppNavigation {
  static void openFeature(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String emoji,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => FeaturePlaceholderScreen(
          title: title,
          subtitle: subtitle,
          emoji: emoji,
        ),
      ),
    );
  }
}
