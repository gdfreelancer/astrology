import 'package:flutter/material.dart';

import '../../l10n/app_locale.dart';
import '../../theme/app_theme.dart';
import 'graha_data.dart';
import 'graha_extended_data.dart';
import '../remedies/remedy_library_screen.dart';
import '../remedies/remedy_data.dart';

class GrahaDetailScreen extends StatelessWidget {
  const GrahaDetailScreen({super.key, required this.graha});

  final GrahaInfo graha;

  @override
  Widget build(BuildContext context) {
    final language = AppLocale.locale.value.languageCode;
    final name = grahaDisplayName(graha, language);
    final extended = grahaExtendedInfo[graha.id]!;

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 245,
            backgroundColor: const Color(0xFF35264F),
            foregroundColor: Colors.white,
            title: Text(name,
                style: const TextStyle(fontWeight: FontWeight.w800)),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF302544), Color(0xFF7656A7)],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: 22,
                      top: 50,
                      child: Text(graha.symbol, style: TextStyle(
                        fontSize: 112,
                        color: graha.color.withValues(alpha: .82),
                      )),
                    ),
                    Positioned(
                      left: 22,
                      right: 22,
                      bottom: 23,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(graha.sanskrit,
                              style: const TextStyle(
                                color: Color(0xFFFFDCA0),
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                              )),
                          const SizedBox(height: 4),
                          Text(name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 30,
                                fontWeight: FontWeight.w800,
                              )),
                          Text(context.tr('navagraha_member'),
                              style: const TextStyle(
                                color: Color(0xFFE8DFF3),
                                fontSize: 11,
                              )),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 36),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Text(context.tr(graha.summaryKey),
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.55,
                      color: AppTheme.ink,
                      fontWeight: FontWeight.w600,
                    )),
                const SizedBox(height: 22),
                _sectionTitle(context.tr('graha_core_nature'),
                    context.tr('traditional_interpretations')),
                const SizedBox(height: 10),
                _infoCard(context.tr(graha.natureKey)),
                const SizedBox(height: 20),
                _sectionTitle(context.tr('graha_karakatvas'),
                    context.tr('graha_karakatvas_subtitle')),
                const SizedBox(height: 10),
                _infoCard(context.tr(graha.karakaKey)),
                const SizedBox(height: 20),
                _sectionTitle(context.tr('graha_positive_expression'),
                    context.tr('graha_positive_expression_subtitle')),
                const SizedBox(height: 10),
                _infoCard(context.tr(graha.qualitiesKey)),
                const SizedBox(height: 20),
                _sectionTitle(context.tr('graha_body_associations'),
                    context.tr('graha_body_associations_subtitle')),
                const SizedBox(height: 10),
                _infoCard(context.tr(graha.bodyKey)),
                const SizedBox(height: 22),
                _sectionTitle(context.tr('graha_sign_dignity'),
                    context.tr('graha_sign_dignity_subtitle')),
                const SizedBox(height: 10),
                _attributeGrid(context, [
                  (context.tr('graha_own_signs'), graha.ownSigns, '⌂'),
                  (context.tr('graha_exaltation'), graha.exaltation, '↑'),
                  (context.tr('graha_debilitation'), graha.debilitation, '↓'),
                ]),
                const SizedBox(height: 22),
                _sectionTitle(context.tr('graha_traditional_associations'),
                    context.tr('graha_traditional_associations_subtitle')),
                const SizedBox(height: 10),
                _attributeGrid(context, [
                  (context.tr('graha_weekday'), graha.weekday, '◷'),
                  (context.tr('graha_colour'), graha.colour, '◉'),
                  (context.tr('graha_gemstone'), graha.gemstone, '◇'),
                  (context.tr('graha_element'), graha.element, '✧'),
                  (context.tr('graha_guna'), graha.guna, '◈'),
                  (context.tr('graha_deity'), graha.deity, 'ॐ'),
                  (context.tr('graha_dasha_period'), '${graha.dashaYears} ${context.tr('graha_years')}', '◷'),
                ]),
                const SizedBox(height: 22),
                _sectionTitle(context.tr('graha_phala'),
                    context.tr('graha_phala_subtitle')),
                const SizedBox(height: 10),
                _infoCard(extended.generalResults),
                const SizedBox(height: 20),
                _sectionTitle(context.tr('graha_rashi_phala'),
                    context.tr('graha_rashi_phala_subtitle')),
                const SizedBox(height: 8),
                ...List.generate(12, (index) => Container(
                  margin: const EdgeInsets.only(bottom: 7),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(color: const Color(0xFFECE6F0)),
                  ),
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(horizontal: 14),
                    childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                    dense: true,
                    title: Text(grahaRashiNames[index],
                      style: const TextStyle(fontSize: 12,
                        fontWeight: FontWeight.w700, color: AppTheme.ink)),
                    children: [Align(
                      alignment: Alignment.centerLeft,
                      child: Text(extended.signResults[index],
                        style: const TextStyle(fontSize: 12,
                          height: 1.55, color: AppTheme.ink)),
                    )],
                  ),
                )),
                const SizedBox(height: 14),
                _sectionTitle(context.tr('graha_dosha'),
                    context.tr('graha_dosha_subtitle')),
                const SizedBox(height: 10),
                _infoCard(extended.afflictions),
                const SizedBox(height: 20),
                _sectionTitle('Traditional remedies', 'Source-based reference · not a personal prescription'),
                const SizedBox(height: 10),
                _infoCard('Traditional associations in the uploaded source: ${remedyGrahas.firstWhere((item) => item.id == graha.id).lifeAreas}. Associated deities: ${remedyGrahas.firstWhere((item) => item.id == graha.id).deities}. Suggested worship references: ${remedyGrahas.firstWhere((item) => item.id == graha.id).remedies.join(', ')}. These are traditional associations, not predictions or diagnoses.'),
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(child: OutlinedButton.icon(
                    onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(
                      builder: (_) => const RemedyLibraryScreen(section: RemedyLibrarySection.mantras),
                    )),
                    icon: const Icon(Icons.self_improvement, size: 16),
                    label: const Text('Mantra library'),
                  )),
                  const SizedBox(width: 8),
                  Expanded(child: OutlinedButton.icon(
                    onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(
                      builder: (_) => const RemedyLibraryScreen(section: RemedyLibrarySection.gemstones),
                    )),
                    icon: const Icon(Icons.diamond_outlined, size: 16),
                    label: const Text('Gemstone guide'),
                  )),
                ]),
                const SizedBox(height: 20),
                _sectionTitle(context.tr('graha_mantra_when'),
                    context.tr('graha_mantra_when_subtitle')),
                const SizedBox(height: 10),
                _infoCard(extended.mantraUse),
                const SizedBox(height: 20),
                _sectionTitle(context.tr('graha_mantra'),
                    context.tr('graha_mantra_subtitle')),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF6E8),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFF2E5D0)),
                  ),
                  child: Text(graha.mantra,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.6,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.ink,
                      )),
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F1F8),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(context.tr('graha_education_disclaimer'),
                      style: const TextStyle(
                        fontSize: 10,
                        height: 1.55,
                        color: AppTheme.muted,
                      )),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, String subtitle) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(
            fontSize: 17, fontWeight: FontWeight.w800, color: AppTheme.ink,
          )),
          const SizedBox(height: 3),
          Text(subtitle, style: const TextStyle(
            fontSize: 10, color: AppTheme.muted,
          )),
        ],
      );

  Widget _infoCard(String text) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFECE6F0)),
        ),
        child: Text(text, style: const TextStyle(
          fontSize: 12, height: 1.55, color: AppTheme.ink,
        )),
      );

  Widget _attributeGrid(BuildContext context,
      List<(String, String, String)> items) {
    return GridView.builder(
      itemCount: items.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 9,
        mainAxisSpacing: 9,
        childAspectRatio: items.length == 3 ? 2.15 : 2.05,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFECE6F0)),
          ),
          child: Row(
            children: [
              Text(item.$3, style: const TextStyle(
                fontSize: 19, color: AppTheme.plum,
              )),
              const SizedBox(width: 7),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(item.$1, style: const TextStyle(
                      fontSize: 9, color: AppTheme.muted,
                    )),
                    const SizedBox(height: 3),
                    Text(item.$2,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 10,
                          height: 1.2,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.ink,
                        )),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
