import 'package:flutter/material.dart';

import '../../l10n/app_locale.dart';

import '../../models/birth_chart_result.dart';
import '../../theme/app_theme.dart';
import 'baby_names_screen.dart';

class RashiResultScreen extends StatelessWidget {
  const RashiResultScreen({super.key, required this.result});

  final BirthChartResult result;

  String _dateTime(DateTime value) {
    final date = '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}';
    final hour = value.hour % 12 == 0 ? 12 : value.hour % 12;
    final minute = value.minute.toString().padLeft(2, '0');
    final period = value.hour >= 12 ? 'PM' : 'AM';
    return '$date · $hour:$minute $period';
  }

  String _degrees(double value) {
    final degrees = value.floor();
    final minutesValue = (value - degrees) * 60;
    final minutes = minutesValue.floor();
    final seconds = ((minutesValue - minutes) * 60).round();
    return '$degrees° $minutes′ $seconds″';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('‹', style: TextStyle(fontSize: 32, height: 1, color: AppTheme.plum)),
        ),
        title: Text(context.tr('birth_details'), style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 21),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              gradient: const LinearGradient(colors: [Color(0xFF8062B5), Color(0xFF60468F)], begin: Alignment.topLeft, end: Alignment.bottomRight),
            ),
            child: Column(
              children: [
                Text(context.tr('janma_rashi'), style: TextStyle(color: Color(0xFFE9DFF8), fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.w800)),
                const SizedBox(height: 12),
                Text(result.rashiSymbol, style: const TextStyle(fontSize: 48, color: Colors.white)),
                const SizedBox(height: 7),
                Text(result.rashi, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Text(context.tr('your_moon_sign'), style: TextStyle(color: Color(0xFFE9DFF8), fontSize: 11)),
              ],
            ),
          ),
          const SizedBox(height: 19),
          Row(
            children: [
              Expanded(child: _HighlightCard(label: context.tr('nakshatra'), value: result.nakshatra, emoji: '✨')),
              const SizedBox(width: 11),
              Expanded(child: _HighlightCard(label: context.tr('pada'), value: '${context.tr('pada')} ${result.pada}', emoji: '🌙')),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(color: const Color(0xFFFFF2DF), borderRadius: BorderRadius.circular(21), border: Border.all(color: const Color(0xFFF0E0C6))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(context.tr('recommended_naming_sound'), style: TextStyle(color: AppTheme.muted, fontSize: 9, letterSpacing: 1.3, fontWeight: FontWeight.w800)),
                const SizedBox(height: 9),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(child: Text(result.namingSyllable, style: const TextStyle(color: AppTheme.plum, fontSize: 37, fontWeight: FontWeight.w900))),
                    Text(context.tr('based_on_nakshatra_pada'), style: TextStyle(color: AppTheme.muted, fontSize: 10)),
                  ],
                ),
                const SizedBox(height: 5),
                Text(context.tr('naming_sound_help'), style: TextStyle(color: AppTheme.muted, fontSize: 11, height: 1.45)),
              ],
            ),
          ),
          const SizedBox(height: 21),
          Text(context.tr('kundali_overview'), style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.ink)),
          const SizedBox(height: 11),
          _DetailRow(label: context.tr('birth_date_time'), value: _dateTime(result.birthLocal)),
          _DetailRow(label: context.tr('birth_place'), value: result.placeName),
          _DetailRow(label: context.tr('time_zone'), value: result.timeZoneId),
          _DetailRow(label: context.tr('sidereal_moon_longitude'), value: _degrees(result.siderealMoonLongitude)),
          _DetailRow(label: context.tr('tropical_moon_longitude'), value: _degrees(result.tropicalMoonLongitude)),
          _DetailRow(label: context.tr('lahiri_ayanamsha'), value: _degrees(result.ayanamsa)),
          _DetailRow(label: context.tr('moon_latitude'), value: _degrees(result.moonLatitude.abs()) + (result.moonLatitude < 0 ? ' S' : ' N')),
          _DetailRow(label: context.tr('moon_distance'), value: '${result.moonDistanceAu.toStringAsFixed(6)} AU'),
          const SizedBox(height: 15),
          if (result.nearBoundary)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: const Color(0xFFFFF0E8), borderRadius: BorderRadius.circular(15)),
              child: const Text(
                'This birth time is very close to a Nakshatra/Pada boundary. Small differences in ephemeris or recorded birth time may change the result. Please verify with a professional Panchang or ephemeris.',
                style: TextStyle(color: Color(0xFF9A5C35), fontSize: 11, height: 1.5),
              ),
            ),
          const SizedBox(height: 18),
          SizedBox(
            height: 56,
            child: FilledButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => BabyNamesScreen(result: result)),
              ),
              style: FilledButton.styleFrom(backgroundColor: AppTheme.plum, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17))),
              child: Text(context.tr('explore_suggested_baby_names'), style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
            ),
          ),
          const SizedBox(height: 13),
          const Text(
            'Astrology is a traditional belief system. The calculation uses a geocentric lunar model and an approximate Lahiri ayanamsha; boundary cases should be cross-checked.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.muted, fontSize: 10, height: 1.5),
          ),
        ],
      ),
    );
  }
}

class _HighlightCard extends StatelessWidget {
  const _HighlightCard({required this.label, required this.value, required this.emoji});
  final String label;
  final String value;
  final String emoji;

  @override
  Widget build(BuildContext context) => Container(
        height: 115,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(19), border: Border.all(color: const Color(0xFFEAE5EF))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const Spacer(),
            Text(label, style: const TextStyle(fontSize: 8, color: AppTheme.muted, letterSpacing: 0.7, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, color: AppTheme.ink, fontWeight: FontWeight.w800)),
          ],
        ),
      );
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 11),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: Text(label, style: const TextStyle(color: AppTheme.muted, fontSize: 11))),
            const SizedBox(width: 14),
            Flexible(child: Text(value, textAlign: TextAlign.right, style: const TextStyle(color: AppTheme.ink, fontSize: 11, fontWeight: FontWeight.w700))),
          ],
        ),
      );
}
