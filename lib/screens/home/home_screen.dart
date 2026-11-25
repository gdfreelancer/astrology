import 'package:flutter/material.dart';

import '../../l10n/app_locale.dart';
import '../../theme/app_theme.dart';
import '../baby_name/baby_birth_details_screen.dart';
import '../kundali/create_kundali_screen.dart';
import '../rashi/rashi_list_screen.dart';
import '../horoscope/daily_horoscope_screen.dart';
import '../muhurat/muhurat_screen.dart';
import '../panchang/panchang_screen.dart';
import '../matching/matching_home_screen.dart';
import '../settings/settings_screen.dart';
import '../../widgets/feature_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(22, 18, 22, 30),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(context.tr('namaste'), style: const TextStyle(fontSize: 10, letterSpacing: 1.7, fontWeight: FontWeight.w800, color: AppTheme.saffron)),
                            const SizedBox(height: 5),
                            Text(context.tr('home_tagline'), style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w800, color: AppTheme.ink)),
                          ],
                        ),
                      ),
                      Material(
                        color: const Color(0xFFF1E9FA),
                        borderRadius: BorderRadius.circular(16),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const SettingsScreen())),
                          child: const SizedBox(width: 46, height: 46, child: Icon(Icons.settings_rounded, color: AppTheme.plum, size: 22)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _KundaliBanner(onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const CreateKundaliScreen()))),
                  const SizedBox(height: 29),
                  Row(
                    children: [
                      Expanded(child: Text(context.tr('explore_astrology'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.ink))),
                      Text(context.tr('discover_more'), style: const TextStyle(fontSize: 11, color: AppTheme.plum, fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: 14),
                  GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.04,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      FeatureCard(emoji: '👶', title: context.tr('baby_name_rashi'), description: context.tr('baby_name_desc'), tint: const Color(0xFFFFF0E2), onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const BabyBirthDetailsScreen()))),
                      FeatureCard(emoji: '♈', title: context.tr('all_rashis'), description: context.tr('all_rashis_desc'), tint: const Color(0xFFF0EAFE), onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const RashiListScreen()))),
                      FeatureCard(emoji: '📅', title: context.tr('panchang'), description: context.tr('panchang_desc'), tint: const Color(0xFFE9F5EE), onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const PanchangScreen()))),
                      FeatureCard(emoji: '💞', title: context.tr('kundali_matching'), description: context.tr('matching_desc'), tint: const Color(0xFFFFEDEF), onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const MatchingHomeScreen()))),
                      FeatureCard(emoji: '✨', title: context.tr('daily_horoscope'), description: context.tr('horoscope_desc'), tint: const Color(0xFFFFF5D9), onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const DailyHoroscopeScreen()))),
                      FeatureCard(emoji: '🕉️', title: context.tr('muhurat'), description: context.tr('muhurat_desc'), tint: const Color(0xFFE8F3FA), onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const MuhuratScreen()))),
                    ],
                  ),
                  const SizedBox(height: 22),
                  Container(
                    padding: const EdgeInsets.all(17),
                    decoration: BoxDecoration(color: const Color(0xFFFFF6E8), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFF4E5CC))),
                    child: Row(
                      children: [
                        const Text('🌟', style: TextStyle(fontSize: 27)),
                        const SizedBox(width: 13),
                        Expanded(child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(context.tr('universe_rhythm'), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.ink)),
                            const SizedBox(height: 4),
                            Text(context.tr('universe_subtitle'), style: const TextStyle(fontSize: 11, color: AppTheme.muted)),
                          ],
                        )),
                      ],
                    ),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _KundaliBanner extends StatelessWidget {
  const _KundaliBanner({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.plum,
      borderRadius: BorderRadius.circular(26),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(26),
        child: Container(
          height: 178,
          padding: const EdgeInsets.fromLTRB(21, 20, 16, 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            gradient: const LinearGradient(colors: [Color(0xFF8062B5), Color(0xFF60468F)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          ),
          child: Stack(
            children: [
              const Positioned(right: 3, top: 0, child: Text('✧', style: TextStyle(fontSize: 30, color: Color(0x99FFFFFF)))),
              const Positioned(right: 62, bottom: 1, child: Text('☼', style: TextStyle(fontSize: 75, color: Color(0x22FFFFFF)))),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.16), borderRadius: BorderRadius.circular(30)),
                    child: Text(context.tr('your_birth_chart'), style: const TextStyle(fontSize: 9, letterSpacing: 1.4, fontWeight: FontWeight.w800, color: Colors.white)),
                  ),
                  const Spacer(),
                  Text(context.tr('discover_kundali'), style: const TextStyle(fontSize: 23, height: 1.15, fontWeight: FontWeight.w800, color: Colors.white)),
                  const SizedBox(height: 7),
                  Text(context.tr('birth_chart_subtitle'), style: const TextStyle(fontSize: 10, color: Color(0xFFE9DFF8))),
                  const Spacer(),
                  Row(children: [
                    Text(context.tr('create_kundali'), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFFFFE3A8))),
                    const SizedBox(width: 7),
                    Container(width: 22, height: 22, decoration: const BoxDecoration(color: Color(0xFFFFE3A8), shape: BoxShape.circle), child: const Center(child: Text('→', style: TextStyle(fontSize: 14, height: 1, color: AppTheme.plum, fontWeight: FontWeight.w800)))),
                  ]),
                ],
              ),
              const Positioned(right: 18, top: 48, child: Text('🔮', style: TextStyle(fontSize: 58))),
            ],
          ),
        ),
      ),
    );
  }
}
