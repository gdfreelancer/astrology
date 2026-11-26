import 'package:flutter/material.dart';

import '../../l10n/app_locale.dart';
import '../../models/muhurat_activity.dart';
import '../../screens/muhurat/muhurat_listing_screen.dart';
import '../../theme/app_theme.dart';

class MuhuratScreen extends StatelessWidget {
  const MuhuratScreen({super.key});

  void _openListing(BuildContext context, MuhuratActivity activity) {
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => MuhuratListingScreen(activity: activity),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('muhurat'),
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          children: [
            _hero(context),
            const SizedBox(height: 22),
            Text(context.tr('muhurat_question'),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.ink)),
            const SizedBox(height: 4),
            Text(context.tr('choose_activity_help'),
              style: const TextStyle(fontSize: 10, color: AppTheme.muted)),
            const SizedBox(height: 13),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: MuhuratActivity.all.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 11,
                mainAxisSpacing: 11,
                childAspectRatio: 1.42,
              ),
              itemBuilder: (context, index) {
                final activity = MuhuratActivity.all[index];
                return Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(17),
                  child: InkWell(
                    onTap: () => _openListing(context, activity),
                    borderRadius: BorderRadius.circular(17),
                    child: Container(
                      padding: const EdgeInsets.all(13),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(17),
                        border: Border.all(color: const Color(0xFFEDE7E1)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(children: [
                            Text(activity.emoji, style: const TextStyle(fontSize: 23)),
                            const Spacer(),
                            const Icon(Icons.arrow_forward_rounded, color: AppTheme.plum, size: 17),
                          ]),
                          const SizedBox(height: 8),
                          Text(context.tr(activity.titleKey),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.ink)),
                          const SizedBox(height: 3),
                          Text(context.tr(activity.descriptionKey),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 9, height: 1.35, color: AppTheme.muted)),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _hero(BuildContext context) => Container(
    padding: const EdgeInsets.all(19),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFF526F8E), Color(0xFF344C6A)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(23),
    ),
    child: Row(children: [
      Expanded(child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.tr('auspicious_moments'),
            style: const TextStyle(color: Color(0xFFDCE8F5), fontSize: 9, letterSpacing: 1.3, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text(context.tr('muhurat_annual_title'),
            style: const TextStyle(color: Colors.white, fontSize: 20, height: 1.2, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text(context.tr('muhurat_annual_subtitle'),
            style: const TextStyle(color: Color(0xFFDCE8F5), fontSize: 10)),
        ],
      )),
      const SizedBox(width: 12),
      const Text('🕉️', style: TextStyle(fontSize: 48)),
    ]),
  );
}
