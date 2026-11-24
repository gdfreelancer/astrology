import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../baby_name/baby_birth_details_screen.dart';
import '../../utils/app_navigation.dart';
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
                          children: const [
                            Text('NAMASTE  ✨', style: TextStyle(fontSize: 10, letterSpacing: 1.7, fontWeight: FontWeight.w800, color: AppTheme.saffron)),
                            SizedBox(height: 5),
                            Text('Your cosmic guide', style: TextStyle(fontSize: 23, fontWeight: FontWeight.w800, color: AppTheme.ink)),
                          ],
                        ),
                      ),
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(color: const Color(0xFFF1E9FA), borderRadius: BorderRadius.circular(16)),
                        alignment: Alignment.center,
                        child: const Text('🌙', style: TextStyle(fontSize: 24)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _KundaliBanner(
                    onTap: () => AppNavigation.openFeature(
                      context,
                      title: 'Create Kundali',
                      subtitle: 'Your birth chart and planetary positions will be available here.',
                      emoji: '🪷',
                    ),
                  ),
                  const SizedBox(height: 29),
                  Row(
                    children: const [
                      Expanded(child: Text('Explore astrology', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.ink))),
                      Text('Discover more', style: TextStyle(fontSize: 11, color: AppTheme.plum, fontWeight: FontWeight.w700)),
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
                      FeatureCard(emoji: '👶', title: 'Baby Name & Rashi', description: 'Find a name by birth details', tint: const Color(0xFFFFF0E2), onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const BabyBirthDetailsScreen()))),
                      FeatureCard(emoji: '♈', title: 'All 12 Rashis', description: 'Traits, symbols and details', tint: const Color(0xFFF0EAFE), onTap: () => _open(context, 'All 12 Rashis', 'Explore all zodiac signs, their traits and characteristics.', '♈')),
                      FeatureCard(emoji: '📅', title: 'Panchang', description: 'Tithi, nakshatra and yoga', tint: const Color(0xFFE9F5EE), onTap: () => _open(context, 'Panchang', 'Daily Hindu calendar details and auspicious timings.', '📅')),
                      FeatureCard(emoji: '💞', title: 'Kundali Matching', description: 'Compatibility and guna milan', tint: const Color(0xFFFFEDEF), onTap: () => _open(context, 'Kundali Matching', 'Check compatibility using two birth charts.', '💞')),
                      FeatureCard(emoji: '✨', title: 'Daily Horoscope', description: 'A daily look at your rashi', tint: const Color(0xFFFFF5D9), onTap: () => _open(context, 'Daily Horoscope', 'Read daily insights for your zodiac sign.', '✨')),
                      FeatureCard(emoji: '🕉️', title: 'Muhurat', description: 'Auspicious dates and timings', tint: const Color(0xFFE8F3FA), onTap: () => _open(context, 'Muhurat', 'Find auspicious dates and time windows.', '🕉️')),
                    ],
                  ),
                  const SizedBox(height: 22),
                  Container(
                    padding: const EdgeInsets.all(17),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF6E8),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFF4E5CC)),
                    ),
                    child: const Row(
                      children: [
                        Text('🌟', style: TextStyle(fontSize: 27)),
                        SizedBox(width: 13),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('The universe has a rhythm', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.ink)),
                              SizedBox(height: 4),
                              Text('Explore your cosmic story, one step at a time.', style: TextStyle(fontSize: 11, color: AppTheme.muted)),
                            ],
                          ),
                        ),
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

  static void _open(BuildContext context, String title, String subtitle, String emoji) {
    AppNavigation.openFeature(context, title: title, subtitle: subtitle, emoji: emoji);
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
            gradient: const LinearGradient(
              colors: [Color(0xFF8062B5), Color(0xFF60468F)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
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
                    child: const Text('YOUR BIRTH CHART', style: TextStyle(fontSize: 9, letterSpacing: 1.4, fontWeight: FontWeight.w800, color: Colors.white)),
                  ),
                  const Spacer(),
                  const Text('Discover your\nKundali', style: TextStyle(fontSize: 23, height: 1.15, fontWeight: FontWeight.w800, color: Colors.white)),
                  const SizedBox(height: 7),
                  const Text('Explore the map written in your stars', style: TextStyle(fontSize: 10, color: Color(0xFFE9DFF8))),
                  const Spacer(),
                  Row(
                    children: [
                      const Text('Create Kundali', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFFFFE3A8))),
                      const SizedBox(width: 7),
                      Container(
                        width: 22,
                        height: 22,
                        decoration: const BoxDecoration(color: Color(0xFFFFE3A8), shape: BoxShape.circle),
                        child: const Center(child: Text('→', style: TextStyle(fontSize: 14, height: 1, color: AppTheme.plum, fontWeight: FontWeight.w800))),
                      ),
                    ],
                  ),
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
