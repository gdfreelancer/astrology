import 'package:flutter/material.dart';

import '../../l10n/app_locale.dart';
import '../../models/kundali/kundali_graha.dart';
import '../../services/varga_strength_service.dart';
import '../../services/varga_chart_service.dart';
import '../../theme/app_theme.dart';

class VargaStrengthPanel extends StatefulWidget {
  const VargaStrengthPanel({super.key, required this.chart});
  final KundaliChart chart;

  @override
  State<VargaStrengthPanel> createState() => _VargaStrengthPanelState();
}

class _VargaStrengthPanelState extends State<VargaStrengthPanel> {
  VimsopakaScheme _scheme = VimsopakaScheme.shodashavarga;

  String _schemeKey(VimsopakaScheme value) => switch (value) {
    VimsopakaScheme.shadvarga => 'vimsopaka_shadvarga',
    VimsopakaScheme.saptavarga => 'vimsopaka_saptavarga',
    VimsopakaScheme.dashavarga => 'vimsopaka_dashavarga',
    VimsopakaScheme.shodashavarga => 'vimsopaka_shodashavarga',
  };

  String _planetKey(String name) => 'planet_${name.toLowerCase()}';

  @override
  Widget build(BuildContext context) {
    final results = VargaStrengthService.calculate(widget.chart, scheme: _scheme);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.tr('varga_strength_analysis'),
          style: const TextStyle(color: AppTheme.ink, fontSize: 14, fontWeight: FontWeight.w800)),
        const SizedBox(height: 5),
        Text(context.tr('vimsopaka_method_note'),
          style: const TextStyle(color: AppTheme.muted, fontSize: 10, height: 1.5)),
        const SizedBox(height: 10),
        DropdownButtonFormField<VimsopakaScheme>(
          value: _scheme,
          isExpanded: true,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          items: [
            for (final scheme in VimsopakaScheme.values)
              DropdownMenuItem(value: scheme, child: Text(context.tr(_schemeKey(scheme)))),
          ],
          onChanged: (value) { if (value != null) setState(() => _scheme = value); },
        ),
        const SizedBox(height: 5),
        Text(context.tr('vimsopaka_weights_note'),
          style: const TextStyle(color: AppTheme.muted, fontSize: 9, height: 1.45)),
        const SizedBox(height: 8),
        for (final item in results)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: const Color(0xFFEAE5EF)),
            ),
            child: ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(horizontal: 12),
              childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              title: Row(children: [
                Expanded(child: Text(context.tr(_planetKey(item.planet)),
                  style: const TextStyle(color: AppTheme.ink, fontSize: 11, fontWeight: FontWeight.w800))),
                Text('${item.score.toStringAsFixed(2)} / 20',
                  style: const TextStyle(color: AppTheme.plum, fontSize: 12, fontWeight: FontWeight.w900)),
              ]),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Wrap(spacing: 5, runSpacing: 4, children: [
                  if (item.vargottama) _Flag(context.tr('vargottama')),
                  if (item.pushkaraNavamsa) _Flag(context.tr('pushkara_navamsa')),
                  if (item.pushkaraBhaga) _Flag(context.tr('pushkara_bhaga')),
                  if (item.d1D10SameSign) _Flag('D1 = D10'),
                ]),
              ),
              children: [
                for (final row in item.breakdown)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(children: [
                      SizedBox(width: 38, child: Text('D${row.division}',
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800))),
                      Expanded(child: Text('${kundaliRashiSymbols[row.signIndex]} ${context.tr(_rashiKeys[row.signIndex])} · ${context.tr(_dignityKey(row.dignity))}',
                        style: const TextStyle(fontSize: 9, color: AppTheme.muted))),
                      Text('${row.points.toStringAsFixed(0)} × ${row.weight.toStringAsFixed(row.weight % 1 == 0 ? 0 : 1)}',
                        style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700)),
                    ]),
                  ),
                const Divider(height: 12),
                Text(context.tr('varga_flags_note'),
                  style: const TextStyle(fontSize: 9, color: AppTheme.muted, height: 1.4)),
              ],
            ),
          ),
      ],
    );
  }

  String _dignityKey(String value) => switch (value) {
    'Exalted' => 'varga_exalted',
    'Debilitated' => 'varga_debilitated',
    'Moolatrikona' => 'varga_moolatrikona',
    'Own' => 'varga_own_sign',
    'Friendly' => 'varga_friendly_sign',
    'Enemy' => 'varga_enemy_sign',
    _ => 'varga_neutral_sign',
  };

  static const _rashiKeys = [
    'p_mesha','p_vrishabha','p_mithuna','p_karka','p_simha','p_kanya',
    'p_tula','p_vrishchika','p_dhanu','p_makara','p_kumbha','p_meena',
  ];
}

class _Flag extends StatelessWidget {
  const _Flag(this.label);
  final String label;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
    decoration: BoxDecoration(
      color: const Color(0xFFF4EFF9),
      borderRadius: BorderRadius.circular(7),
    ),
    child: Text(label, style: const TextStyle(color: AppTheme.plum, fontSize: 8, fontWeight: FontWeight.w700)),
  );
}
