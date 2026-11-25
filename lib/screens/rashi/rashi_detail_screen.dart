import 'package:flutter/material.dart';

import '../../l10n/app_locale.dart';

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
        title: Text(_localizedRashiName(context, rashi), style: const TextStyle(fontWeight: FontWeight.w800)),
        flexibleSpace: FlexibleSpaceBar(background: Stack(fit: StackFit.expand, children: [
          RashiArtwork(rashi: rashi, borderRadius: BorderRadius.zero),
          Positioned(left: 22, right: 22, bottom: 22, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(_localizedRashiName(context, rashi), style: const TextStyle(color: Color(0xFFFFDCA0), fontSize: 15, fontWeight: FontWeight.w800)),
            const SizedBox(height: 3),
            Text(rashi.english, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800)),
            Text(' ${context.tr('rashi_number')} ${rashi.number}  •  ${rashi.symbol}', style: const TextStyle(color: Color(0xFFE8DFF3), fontSize: 11)),
          ])),
        ])),
      ),
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 36),
        sliver: SliverList(delegate: SliverChildListDelegate([
          Text(_rashiText('summary', rashi.summary), style: const TextStyle(fontSize: 14, height: 1.55, color: AppTheme.ink, fontWeight: FontWeight.w600)),
          const SizedBox(height: 20),
          _sectionTitle(context.tr('traditional_rashi_details'), context.tr('core_vedic_attributes')),
          const SizedBox(height: 11),
          _attributeGrid(context),
          const SizedBox(height: 24),
          _sectionTitle(context.tr('personality_nature'), context.tr('traditional_interpretations')),
          const SizedBox(height: 10),
          _infoCard(_rashiText('personality', rashi.personality)),
          const SizedBox(height: 12),
          _bulletCard(context.tr('strengths'), rashi.strengths, const Color(0xFFEAF4EC)),
          const SizedBox(height: 10),
          _bulletCard(context.tr('growth_areas'), rashi.challenges, const Color(0xFFFFF2E5)),
          const SizedBox(height: 24),
          _sectionTitle(context.tr('life_themes'), context.tr('general_associations')),
          const SizedBox(height: 11),
          _lifeCard('♡', context.tr('love_relationships'), _rashiText('love', rashi.love)),
          _lifeCard('✧', context.tr('career_work'), _rashiText('career', rashi.career)),
          _lifeCard('₹', context.tr('money_resources'), _rashiText('finance', rashi.finance)),
          _lifeCard('⌂', context.tr('family_home'), _rashiText('family', rashi.family)),
          _lifeCard('✺', context.tr('body_symbolism'), _rashiText('wellbeing', rashi.wellbeing)),
          const SizedBox(height: 24),
          _sectionTitle(context.tr('nakshatras_in_rashi'), context.tr('nakshatra_pada_coverage')),
          const SizedBox(height: 9),
          _infoCard('${context.tr('nakshatra_portions')}'),
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
            child: Text(context.tr('astrology_education_disclaimer'), style: TextStyle(fontSize: 10, height: 1.5, color: AppTheme.muted)),
          ),
        ])),
      ),
    ]),
  );

  String _rashiText(String field, String fallback) {
    final key = 'rashi_${rashi.number}_$field';
    final translated = AppLocale.text(key);
    return translated == key ? fallback : translated;
  }

  String _localizedAttribute(String value) {
    const keys = {
      'Mars (Mangal)':'attr_mars','Venus (Shukra)':'attr_venus','Mercury (Budha)':'attr_mercury',
      'Moon (Chandra)':'attr_moon','Sun (Surya)':'attr_sun','Jupiter (Guru)':'attr_jupiter','Saturn (Shani)':'attr_saturn',
      'Fire (Agni)':'attr_fire','Earth (Prithvi)':'attr_earth','Air (Vayu)':'attr_air','Water (Jala)':'attr_water',
      'Movable (Chara)':'attr_movable','Fixed (Sthira)':'attr_fixed','Dual (Dwiswabhava)':'attr_dual',
      'Masculine':'attr_masculine','Feminine':'attr_feminine','East':'attr_east','South':'attr_south','West':'attr_west','North':'attr_north',
      'Head':'attr_head','Face and neck':'attr_face_neck','Arms and shoulders':'attr_arms_shoulders','Chest':'attr_chest',
      'Stomach and upper abdomen':'attr_stomach','Waist and lower abdomen':'attr_waist_abdomen','Lower abdomen and pelvis':'attr_lower_abdomen_pelvis',
      'Reproductive organs':'attr_reproductive_organs','Thighs':'attr_thighs','Knees':'attr_knees','Calves and ankles':'attr_calves_ankles','Feet':'attr_feet'
    };
    final key = keys[value];
    return key == null ? value : AppLocale.text(key);
  }

  String _localizedRashiName(BuildContext context, RashiInfo value) => switch (AppLocale.locale.value.languageCode) { 'hi' => value.hindi, 'gu' => value.gujarati, _ => value.english };

  Widget _attributeGrid(BuildContext context) {
    final items = [
      (context.tr('ruling_planet'), _localizedAttribute(rashi.ruler), '☼'),
      (context.tr('element_tatva'), _localizedAttribute(rashi.element), '✧'),
      (context.tr('nature'), _localizedAttribute(rashi.nature), '◈'),
      (context.tr('gender'), _localizedAttribute(rashi.gender), '◇'),
      (context.tr('direction'), _localizedAttribute(rashi.direction), '➤'),
      (context.tr('body_association'), _localizedAttribute(rashi.bodyPart), '◎'),
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
