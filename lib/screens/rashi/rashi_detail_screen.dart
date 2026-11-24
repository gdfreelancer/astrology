import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../widgets/rashi_artwork.dart';
import 'rashi_info.dart';

class RashiDetailScreen extends StatelessWidget {
  const RashiDetailScreen({super.key, required this.rashi});
  final RashiInfo rashi;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: CustomScrollView(slivers: [
      SliverAppBar(
        pinned: true,
        expandedHeight: 300,
        backgroundColor: const Color(0xFF35264F),
        foregroundColor: Colors.white,
        title: Text(rashi.sanskrit, style: const TextStyle(fontWeight: FontWeight.w800)),
        flexibleSpace: FlexibleSpaceBar(background: Stack(fit: StackFit.expand, children: [
          RashiArtwork(rashi: rashi, borderRadius: BorderRadius.zero),
          Positioned(left: 22, right: 22, bottom: 22, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(rashi.gujarati, style: const TextStyle(color: Color(0xFFFFDCA0), fontSize: 15, fontWeight: FontWeight.w800)),
            const SizedBox(height: 3),
            Text(rashi.english, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800)),
            Text('Rashi ${rashi.number}  •  ${rashi.symbol}', style: const TextStyle(color: Color(0xFFE8DFF3), fontSize: 11)),
          ])),
        ])),
      ),
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 36),
        sliver: SliverList(delegate: SliverChildListDelegate([
          Text(rashi.summary, style: const TextStyle(fontSize: 14, height: 1.55, color: AppTheme.ink, fontWeight: FontWeight.w600)),
          const SizedBox(height: 20),
          _sectionTitle('Traditional Rashi details', 'Core attributes in Vedic astrology'),
          const SizedBox(height: 11),
          _attributeGrid(),
          const SizedBox(height: 24),
          _sectionTitle('Personality & nature', 'Traditional interpretations'),
          const SizedBox(height: 10),
          _infoCard(rashi.personality),
          const SizedBox(height: 12),
          _bulletCard('Strengths', rashi.strengths, const Color(0xFFEAF4EC)),
          const SizedBox(height: 10),
          _bulletCard('Growth areas', rashi.challenges, const Color(0xFFFFF2E5)),
          const SizedBox(height: 24),
          _sectionTitle('Life themes', 'General traditional associations, not predictions'),
          const SizedBox(height: 11),
          _lifeCard('♡', 'Love & relationships', rashi.love),
          _lifeCard('✧', 'Career & work', rashi.career),
          _lifeCard('₹', 'Money & resources', rashi.finance),
          _lifeCard('⌂', 'Family & home', rashi.family),
          _lifeCard('✺', 'Body symbolism', rashi.wellbeing),
          const SizedBox(height: 24),
          _sectionTitle('Nakshatras in this Rashi', 'Nakshatra portions and their Pada coverage'),
          const SizedBox(height: 9),
          _infoCard('These are the Nakshatra portions that fall within ${rashi.sanskrit}. A Nakshatra can extend across two adjacent Rashis.'),
          const SizedBox(height: 10),
          ...rashi.nakshatras.map((item) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFECE6F0))),
            child: Row(children: [
              const Text('✦', style: TextStyle(color: AppTheme.saffron, fontSize: 17)),
              const SizedBox(width: 10),
              Expanded(child: Text(item, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.ink))),
            ]),
          )),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: const Color(0xFFFFF6E8), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFF2E5D0))),
            child: const Text('Astrology content is presented for cultural and educational interest. Individual birth-chart results depend on exact planetary positions, birth time, location and the tradition used. Health, financial and relationship decisions should not be based on Rashi descriptions alone.', style: TextStyle(fontSize: 10, height: 1.5, color: AppTheme.muted)),
          ),
        ])),
      ),
    ]),
  );

  Widget _attributeGrid() {
    final items = [
      ('Ruling planet', rashi.ruler, '☼'),
      ('Element / Tatva', rashi.element, '✧'),
      ('Nature', rashi.nature, '◈'),
      ('Gender', rashi.gender, '◇'),
      ('Direction', rashi.direction, '➤'),
      ('Body association', rashi.bodyPart, '◎'),
    ];
    return GridView.builder(
      itemCount: items.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 9, mainAxisSpacing: 9, childAspectRatio: 2.2),
      itemBuilder: (context, index) {
        final item = items[index];
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFECE6F0))),
          child: Row(children: [
            Text(item.$3, style: const TextStyle(fontSize: 19, color: AppTheme.plum)),
            const SizedBox(width: 7),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(item.$1, style: const TextStyle(fontSize: 9, color: AppTheme.muted)),
              const SizedBox(height: 2),
              Text(item.$2, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppTheme.ink)),
            ])),
          ]),
        );
      },
    );
  }

  Widget _sectionTitle(String title, String subtitle) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppTheme.ink)),
    const SizedBox(height: 3),
    Text(subtitle, style: const TextStyle(fontSize: 10, color: AppTheme.muted)),
  ]);

  Widget _infoCard(String text) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFECE6F0))),
    child: Text(text, style: const TextStyle(fontSize: 12, height: 1.55, color: AppTheme.ink)),
  );

  Widget _bulletCard(String title, List<String> values, Color color) => Container(
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(16)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.ink)),
      const SizedBox(height: 8),
      ...values.map((value) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('•  ', style: TextStyle(fontSize: 12, color: AppTheme.plum)),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 11, height: 1.4, color: AppTheme.ink))),
        ]),
      )),
    ]),
  );

  Widget _lifeCard(String icon, String title, String body) => Container(
    margin: const EdgeInsets.only(bottom: 9),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: const Color(0xFFECE6F0))),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(width: 32, height: 32, alignment: Alignment.center, decoration: BoxDecoration(color: const Color(0xFFF1EAFE), borderRadius: BorderRadius.circular(11)), child: Text(icon, style: const TextStyle(fontSize: 17, color: AppTheme.plum))),
      const SizedBox(width: 11),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.ink)),
        const SizedBox(height: 4),
        Text(body, style: const TextStyle(fontSize: 11, height: 1.5, color: AppTheme.muted)),
      ])),
    ]),
  );
}
