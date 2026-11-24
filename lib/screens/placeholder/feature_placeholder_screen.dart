import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

class FeaturePlaceholderScreen extends StatelessWidget {
  const FeaturePlaceholderScreen({
    super.key,
    required this.title,
    required this.subtitle,
    required this.emoji,
  });

  final String title;
  final String subtitle;
  final String emoji;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('‹', style: TextStyle(fontSize: 32, height: 1, color: AppTheme.plum)),
        ),
        title: Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 104,
                height: 104,
                decoration: BoxDecoration(color: const Color(0xFFF1EAFE), borderRadius: BorderRadius.circular(30)),
                alignment: Alignment.center,
                child: Text(emoji, style: const TextStyle(fontSize: 52)),
              ),
              const SizedBox(height: 24),
              Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.ink)),
              const SizedBox(height: 9),
              Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, height: 1.6, color: AppTheme.muted)),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                decoration: BoxDecoration(color: const Color(0xFFFFF3DE), borderRadius: BorderRadius.circular(30)),
                child: const Text('Coming soon', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFFAD7831))),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
