import 'package:flutter/material.dart';

import '../l10n/app_locale.dart';
import '../models/kundali/kundali_graha.dart';
import '../theme/app_theme.dart';

class BhavaChalitCard extends StatelessWidget {
  const BhavaChalitCard({super.key, required this.chart});
  final KundaliChart chart;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEAE5EF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.account_tree_outlined, color: AppTheme.plum, size: 17),
            const SizedBox(width: 7),
            Expanded(child: Text(context.tr('bhava_chalit_chart'),
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.ink))),
            Text(context.tr('house_cusps'), style: const TextStyle(fontSize: 9, color: AppTheme.muted)),
          ]),
          const SizedBox(height: 5),
          Text(context.tr('bhava_chalit_description'),
            style: const TextStyle(fontSize: 10, color: AppTheme.muted, height: 1.4)),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 12,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, crossAxisSpacing: 7, mainAxisSpacing: 7,
              childAspectRatio: 1.25,
            ),
            itemBuilder: (context, index) {
              final house = chart.bhava(index + 1);
              final occupants = chart.inBhava(index + 1);
              final isAsc = index == 0;
              return Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isAsc ? const Color(0xFFF1EAF8) : const Color(0xFFFFFAF2),
                  borderRadius: BorderRadius.circular(11),
                  border: Border.all(color: isAsc ? AppTheme.plum : const Color(0xFFEDE4D6)),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('${context.tr('house_number').replaceAll('{n}', '${index + 1}')} · ${_deg(house.middleLongitude)}',
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 8, color: AppTheme.muted, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text('${kundaliRashiSymbols[house.signIndex]} ${_rashi(house.signIndex)}',
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 9, color: AppTheme.ink, fontWeight: FontWeight.w800)),
                  const Spacer(),
                  Text(occupants.isEmpty ? '—' : occupants.map((g) => g.symbol).join(' · '),
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 10, color: AppTheme.plum, fontWeight: FontWeight.w900)),
                ]),
              );
            },
          ),
          const SizedBox(height: 8),
          Text(context.tr('bhava_chalit_note'),
            style: const TextStyle(fontSize: 9, color: AppTheme.muted, height: 1.4)),
        ],
      ),
    );
  }

  static String _deg(double longitude) {
    final value = longitude % 30;
    final d = value.floor();
    final m = ((value - d) * 60).round();
    return '${d}°${m.toString().padLeft(2, '0')}′';
  }

  static String _rashi(int index) {
    const keys = ['p_mesha','p_vrishabha','p_mithuna','p_karka','p_simha','p_kanya','p_tula','p_vrishchika','p_dhanu','p_makara','p_kumbha','p_meena'];
    return contextText(keys[index]);
  }
  static String contextText(String key) => AppLocale.text(key);
}
