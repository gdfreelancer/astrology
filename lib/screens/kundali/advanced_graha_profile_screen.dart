import 'package:flutter/material.dart';
import '../../l10n/app_locale.dart';
import '../../services/graha_profile_analysis_service.dart';
import '../../models/kundali/kundali_graha.dart';
import '../../theme/app_theme.dart';

class AdvancedGrahaProfileScreen extends StatelessWidget {
  const AdvancedGrahaProfileScreen({super.key, required this.chart});
  final KundaliChart chart;

  @override
  Widget build(BuildContext context) {
    final profiles = GrahaProfileAnalysisService.analyse(chart);
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('advanced_graha_profile'),
        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800))),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        _notice(context.tr('graha_profile_method_note')),
        const SizedBox(height: 12),
        for (final item in profiles)
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15),
              border: Border.all(color: const Color(0xFFEAE5EF))),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text(item.planet.symbol, style: const TextStyle(fontSize: 19, color: AppTheme.plum)),
                const SizedBox(width: 9),
                Expanded(child: Text(context.tr('planet_${item.planet.name.toLowerCase()}'),
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.ink))),
                if (item.isVargottama) _pill(context.tr('vargottama')),
                if (item.isYogakaraka) _pill(context.tr('yogakaraka')),
              ]),
              const SizedBox(height: 9),
              _line(context.tr('natural_nature'), item.naturalNature),
              _line(context.tr('functional_nature'), item.functionalNature),
              _line(context.tr('owned_houses'), item.ownedHouses.isEmpty ? '—' : item.ownedHouses.join(', ')),
              _line(context.tr('d1_d9_sign'), '${context.tr('rashi')} ${item.d1Sign + 1} → ${context.tr('navamsa')} ${item.d9Sign + 1}'),
              _line(context.tr('placement_house_theme'), '${context.tr('house_number').replaceAll('{n}', '${item.planet.houseNumber}')} · ${item.houseTheme}'),
            ]),
          ),
      ]),
    );
  }

  Widget _notice(String value) => Container(padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(color: const Color(0xFFFFF6E8), borderRadius: BorderRadius.circular(13)),
    child: Text(value, style: const TextStyle(fontSize: 10, height: 1.5, color: Color(0xFF795D36))));
  Widget _line(String label, String value) => Padding(padding: const EdgeInsets.only(top: 5),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(width: 112, child: Text(label, style: const TextStyle(fontSize: 9, color: AppTheme.muted))),
      Expanded(child: Text(value, style: const TextStyle(fontSize: 10, color: AppTheme.ink, fontWeight: FontWeight.w600))),
    ]));
  Widget _pill(String value) => Container(margin: const EdgeInsets.only(left: 4),
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
    decoration: BoxDecoration(color: const Color(0xFFF4EFF9), borderRadius: BorderRadius.circular(20)),
    child: Text(value, style: const TextStyle(fontSize: 8, color: AppTheme.plum, fontWeight: FontWeight.w800)));
}
