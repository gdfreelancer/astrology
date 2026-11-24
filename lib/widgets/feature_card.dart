import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class FeatureCard extends StatelessWidget {
  const FeatureCard({
    super.key,
    required this.emoji,
    required this.title,
    required this.description,
    required this.tint,
    required this.onTap,
  });

  final String emoji;
  final String title;
  final String description;
  final Color tint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFF0EBE5)),
            boxShadow: const [BoxShadow(color: Color(0x08000000), blurRadius: 16, offset: Offset(0, 6))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(color: tint, borderRadius: BorderRadius.circular(15)),
                alignment: Alignment.center,
                child: Text(emoji, style: const TextStyle(fontSize: 25)),
              ),
              const Spacer(),
              Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.ink)),
              const SizedBox(height: 5),
              Text(description, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, height: 1.4, color: AppTheme.muted)),
              const SizedBox(height: 10),
              const Align(
                alignment: Alignment.centerRight,
                child: Icon(Icons.arrow_forward_rounded, size: 17, color: AppTheme.plum),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
