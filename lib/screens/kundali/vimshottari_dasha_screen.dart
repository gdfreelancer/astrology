import 'dart:collection';
import 'package:flutter/material.dart';

import '../../l10n/app_locale.dart';
import '../../models/vimshottari_timeline.dart';
import '../../services/vimshottari_dasha_service.dart';
import '../../services/vimshottari_subperiod_service.dart';
import '../../theme/app_theme.dart';

class VimshottariDashaScreen extends StatelessWidget {
  const VimshottariDashaScreen({
    super.key,
    required this.siderealMoonLongitude,
    required this.birthDate,
  });

  final double siderealMoonLongitude;
  final DateTime birthDate;

  static const _planetKeys = {
    'Ketu':'planet_ketu',
    'Venus':'planet_venus','Sun':'planet_sun','Moon':'planet_moon',
    'Mars':'planet_mars','Rahu':'planet_rahu','Jupiter':'planet_jupiter',
    'Saturn':'planet_saturn','Mercury':'planet_mercury',
  };

  @override
  Widget build(BuildContext context) {
    final timeline = VimshottariDashaService.calculate(
      siderealMoonLongitude: siderealMoonLongitude,
      birthDate: birthDate,
    );
    final now = DateTime.now();
    final currentMaha = timeline.mahadashaAt(now);
    final currentAntar = timeline.antardashaAt(now);
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('vimshottari_dasha'),
        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF8062B5), Color(0xFF60468F)]),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(context.tr('birth_dasha_basis'),
                style: const TextStyle(color: Color(0xFFEDE5F8), fontSize: 9, fontWeight: FontWeight.w800)),
              const SizedBox(height: 5),
              Text(_nakshatra(context, timeline.birthNakshatra),
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text('${context.tr('birth_dasha_lord')}: ${_planet(context, timeline.birthNakshatraLord)}',
                style: const TextStyle(color: Color(0xFFFFE3A8), fontSize: 11, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              Text('${context.tr('balance_at_birth')}: ${timeline.balanceAtBirthYears.toStringAsFixed(2)} ${context.tr('years')}',
                style: const TextStyle(color: Colors.white, fontSize: 11)),
            ]),
          ),
          const SizedBox(height: 15),
          Text(context.tr('running_dasha'),
            style: const TextStyle(color: AppTheme.ink, fontSize: 15, fontWeight: FontWeight.w800)),
          const SizedBox(height: 9),
          if (currentMaha != null && currentAntar != null)
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(color: const Color(0xFFF4EFF9),
                borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2D8ED))),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('${_planet(context, currentMaha.planet)}  /  ${_planet(context, currentAntar.planet)}',
                  style: const TextStyle(color: AppTheme.plum, fontSize: 16, fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                Text(context.tr('mahadasha_antardasha'),
                  style: const TextStyle(color: AppTheme.muted, fontSize: 10)),
                const SizedBox(height: 10),
                _DateLine(label: context.tr('period_start'), date: currentAntar.start),
                _DateLine(label: context.tr('period_end'), date: currentAntar.end),
              ]),
            )
          else
            Text(context.tr('dasha_timeline_range_note'),
              style: const TextStyle(color: AppTheme.muted, fontSize: 10, height: 1.45)),
          const SizedBox(height: 19),
          Text(context.tr('mahadasha_timeline'),
            style: const TextStyle(color: AppTheme.ink, fontSize: 15, fontWeight: FontWeight.w800)),
          const SizedBox(height: 9),
          for (final period in timeline.mahadashas)
            _PeriodTile(period: period, isCurrent: period.contains(now),
              title: _planet(context, period.planet)),
          const SizedBox(height: 18),
          Text(context.tr('antardasha_timeline'),
            style: const TextStyle(color: AppTheme.ink, fontSize: 15, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          for (final period in timeline.antardashas.where((p) =>
              currentMaha == null ||
              (p.start.isBefore(currentMaha.end) && p.end.isAfter(currentMaha.start))).take(9))
            _PeriodTile(period: period, isCurrent: period.contains(now),
              title: _planet(context, period.planet)),
          if (currentAntar != null) ...[
            const SizedBox(height: 18),
            Text('Pratyantardasha', style: const TextStyle(color: AppTheme.ink, fontSize: 15, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            for (final period in VimshottariSubperiodService.children(currentAntar))
              _PeriodTile(period: period, isCurrent: period.contains(now), title: _planet(context, period.planet)),
            Builder(builder: (context) {
              final currentPratyantar = VimshottariSubperiodService.children(currentAntar).where((p) => p.contains(now)).firstOrNull;
              if (currentPratyantar == null) return const SizedBox.shrink();
              final sookshma = VimshottariSubperiodService.children(currentPratyantar);
              final currentSookshma = sookshma.where((p) => p.contains(now)).firstOrNull;
              return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const SizedBox(height: 14),
                Text('Sookshma Dasha', style: const TextStyle(color: AppTheme.ink, fontSize: 15, fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                for (final period in sookshma)
                  _PeriodTile(period: period, isCurrent: period.contains(now), title: _planet(context, period.planet)),
                if (currentSookshma != null) ...[
                  const SizedBox(height: 14),
                  Text('Prana Dasha', style: const TextStyle(color: AppTheme.ink, fontSize: 15, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  for (final period in VimshottariSubperiodService.children(currentSookshma))
                    _PeriodTile(period: period, isCurrent: period.contains(now), title: _planet(context, period.planet)),
                ],
              ]);
            }),
          ],
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(color: const Color(0xFFFFF6E8),
              borderRadius: BorderRadius.circular(14)),
            child: Text(context.tr('dasha_calculation_note'),
              style: const TextStyle(color: Color(0xFF795D36), fontSize: 10, height: 1.5)),
          ),
        ],
      ),
    );
  }

  static String _planet(BuildContext context, String name) {
    return context.tr(_planetKeys[name]!);
  }

  static String _nakshatra(BuildContext context, String name) {
    final slug = name.toLowerCase().replaceAll(RegExp('[^a-z0-9]+'), '_');
    final key = 'p_$slug';
    final translated = context.tr(key);
    return translated == key ? name : translated;
  }
}

class _PeriodTile extends StatelessWidget {
  const _PeriodTile({required this.period, required this.isCurrent, required this.title});
  final VimshottariPeriod period;
  final bool isCurrent;
  final String title;
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 7),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
    decoration: BoxDecoration(
      color: isCurrent ? const Color(0xFFF4EFF9) : Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: isCurrent ? AppTheme.plum : const Color(0xFFEAE5EF)),
    ),
    child: Row(children: [
      Expanded(child: Text(title, style: TextStyle(color: isCurrent ? AppTheme.plum : AppTheme.ink,
        fontSize: 11, fontWeight: FontWeight.w800))),
      Text('${_date(period.start)} – ${_date(period.end)}',
        style: const TextStyle(color: AppTheme.muted, fontSize: 9)),
    ]),
  );
}

class _DateLine extends StatelessWidget {
  const _DateLine({required this.label, required this.date});
  final String label;
  final DateTime date;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Row(children: [
      Expanded(child: Text(label, style: const TextStyle(color: AppTheme.muted, fontSize: 9))),
      Text(_date(date), style: const TextStyle(color: AppTheme.ink, fontSize: 10, fontWeight: FontWeight.w700)),
    ]),
  );
}

String _date(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
