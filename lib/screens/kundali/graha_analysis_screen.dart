import 'package:flutter/material.dart';

import '../../data/nakshatra_data.dart';
import '../../l10n/app_locale.dart';
import '../../models/kundali/kundali_graha.dart';
import '../../theme/app_theme.dart';
import '../graha/graha_data.dart' as reference_data;
import '../graha/graha_detail_screen.dart';

class GrahaAnalysisScreen extends StatelessWidget {
  const GrahaAnalysisScreen({super.key, required this.chart});
  final KundaliChart chart;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('graha_analysis'),
        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: const LinearGradient(colors: [Color(0xFF8062B5), Color(0xFF60468F)]),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(context.tr('nine_grahas'), style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
              const SizedBox(height: 5),
              Text(context.tr('graha_analysis_intro'),
                style: const TextStyle(color: Color(0xFFEDE5F8), fontSize: 10, height: 1.45)),
            ]),
          ),
          const SizedBox(height: 14),
          for (final graha in chart.grahas) _GrahaCard(graha: graha),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(color: const Color(0xFFFFF6E8), borderRadius: BorderRadius.circular(14)),
            child: Text(context.tr('graha_motion_note'),
              style: const TextStyle(color: Color(0xFF795D36), fontSize: 10, height: 1.5)),
          ),
        ],
      ),
    );
  }
}

class _GrahaCard extends StatelessWidget {
  const _GrahaCard({required this.graha});
  final KundaliGraha graha;

  @override
  Widget build(BuildContext context) {
    final nakshatra = nakshatras[graha.nakshatraIndex].name;
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFEAE5EF))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 36, height: 36, alignment: Alignment.center,
            decoration: BoxDecoration(color: const Color(0xFFF4EFF9), borderRadius: BorderRadius.circular(11)),
            child: Text(graha.symbol, style: const TextStyle(color: AppTheme.plum, fontSize: 12, fontWeight: FontWeight.w900))),
          const SizedBox(width: 10),
          Expanded(child: Text(_planetName(context, graha.name),
            style: const TextStyle(fontSize: 13, color: AppTheme.ink, fontWeight: FontWeight.w800))),
          if (graha.isRetrograde)
            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: const Color(0xFFFFF0E8), borderRadius: BorderRadius.circular(20)),
              child: Text(context.tr('retrograde_short'), style: const TextStyle(fontSize: 9, color: Color(0xFFB65C35), fontWeight: FontWeight.w800))),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: _Metric(label: context.tr('sidereal_longitude'), value: _longitude(graha.longitude))),
          Expanded(child: _Metric(label: context.tr('rashi'), value: '${kundaliRashiSymbols[graha.signIndex]} ${_rashi(context, graha.signIndex)}')),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(child: _Metric(label: context.tr('nakshatra_pada'), value: '$nakshatra · Pada ${graha.pada}')),
          Expanded(child: _Metric(label: context.tr('d1_bhava'), value: '${context.tr('house_number').replaceAll('{n}', '${graha.houseNumber}')} / ${context.tr('house_number').replaceAll('{n}', '${graha.bhavaNumber}')}')),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(child: _Metric(label: context.tr('daily_motion'), value: '${graha.dailyMotion.toStringAsFixed(4)}°/day')),
          Expanded(child: _Metric(label: context.tr('motion'), value: graha.isRetrograde ? context.tr('retrograde') : context.tr('direct'))),
        ]),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: () {
              final id = graha.name.toLowerCase();
              final matches = reference_data.grahas.where((item) => item.id == id);
              if (matches.isEmpty) return;
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => GrahaDetailScreen(graha: matches.first),
              ));
            },
            icon: const Icon(Icons.open_in_new_rounded, size: 14),
            label: const Text('Full Graha Phala & remedies', style: TextStyle(fontSize: 10)),
          ),
        ),
      ]),
    );
  }

  static String _longitude(double value) {
    final d = value.floor();
    final m = ((value - d) * 60).floor();
    final s = (((value - d) * 60 - m) * 60).round();
    return '$d° $m′ $s″';
  }

  static String _planetName(BuildContext context, String name) {
    const keys = {'Sun':'planet_sun','Moon':'planet_moon','Mars':'planet_mars','Mercury':'planet_mercury','Jupiter':'planet_jupiter','Venus':'planet_venus','Saturn':'planet_saturn','Rahu':'planet_rahu','Ketu':'planet_ketu'};
    return context.tr(keys[name] ?? name);
  }

  static String _rashi(BuildContext context, int index) {
    const keys = ['p_mesha','p_vrishabha','p_mithuna','p_karka','p_simha','p_kanya','p_tula','p_vrishchika','p_dhanu','p_makara','p_kumbha','p_meena'];
    return context.tr(keys[index]);
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label, style: const TextStyle(color: AppTheme.muted, fontSize: 9)),
    const SizedBox(height: 3),
    Text(value, maxLines: 2, overflow: TextOverflow.ellipsis,
      style: const TextStyle(color: AppTheme.ink, fontSize: 10, fontWeight: FontWeight.w700)),
  ]);
}
