import 'package:flutter/material.dart';

import '../../models/birth_chart_result.dart';
import '../../models/kundali/kundali_chart_style.dart';
import '../../models/kundali/kundali_graha.dart';
import '../../theme/app_theme.dart';

class KundaliResultScreen extends StatelessWidget {
  const KundaliResultScreen({
    super.key,
    required this.name,
    required this.chartStyle,
    required this.birthResult,
  });

  final String name;
  final KundaliChartStyle chartStyle;
  final BirthChartResult birthResult;

  @override
  Widget build(BuildContext context) {
    final local = birthResult.birthLocal;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kundali overview', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
        actions: [
          IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.edit_outlined, color: AppTheme.plum), tooltip: 'Edit birth details'),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          children: [
            Container(
              padding: const EdgeInsets.all(19),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                gradient: const LinearGradient(colors: [Color(0xFF8062B5), Color(0xFF60468F)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('YOUR BIRTH CHART', style: TextStyle(color: Color(0xFFEDE5F8), fontSize: 9, letterSpacing: 1.5, fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                Text(name.isEmpty ? 'Your Kundali' : name, style: const TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w800)),
                const SizedBox(height: 5),
                Text('${local.day.toString().padLeft(2, '0')} ${_month(local.month)} ${local.year}  ·  ${_time(local)}', style: const TextStyle(color: Color(0xFFEDE5F8), fontSize: 11)),
                const SizedBox(height: 3),
                Text(birthResult.placeName, style: const TextStyle(color: Color(0xFFEDE5F8), fontSize: 11)),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: .14), borderRadius: BorderRadius.circular(30)),
                  child: Text('${chartStyle.label} chart preference', style: const TextStyle(color: Color(0xFFFFE3A8), fontSize: 10, fontWeight: FontWeight.w800)),
                ),
              ]),
            ),
            const SizedBox(height: 19),
            const Text('Birth details calculated', style: TextStyle(fontSize: 15, color: AppTheme.ink, fontWeight: FontWeight.w800)),
            const SizedBox(height: 11),
            Row(children: [
              Expanded(child: _InfoCard(label: 'Janma Rashi', value: birthResult.rashi, symbol: birthResult.rashiSymbol)),
              const SizedBox(width: 10),
              Expanded(child: _InfoCard(label: 'Nakshatra', value: birthResult.nakshatra, symbol: '✦')),
            ]),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: _InfoCard(label: 'Pada', value: birthResult.pada.toString(), symbol: '◈')),
              const SizedBox(width: 10),
              Expanded(child: _InfoCard(label: 'Naming syllable', value: birthResult.namingSyllable, symbol: 'ॐ')),
            ]),

            const SizedBox(height: 20),
            const Text('Janma Kundali · D1 Rashi chart', style: TextStyle(fontSize: 15, color: AppTheme.ink, fontWeight: FontWeight.w800)),
            const SizedBox(height: 5),
            Text(
              '${chartStyle.label} presentation · Whole-sign houses',
              style: const TextStyle(fontSize: 10, color: AppTheme.muted),
            ),
            const SizedBox(height: 11),
            _KundaliHouseGrid(chart: birthResult.kundaliChart),
            const SizedBox(height: 20),
            const Text('Graha placements', style: TextStyle(fontSize: 15, color: AppTheme.ink, fontWeight: FontWeight.w800)),
            const SizedBox(height: 5),
            const Text('See the Rashi and house occupied by each graha.', style: TextStyle(fontSize: 10, color: AppTheme.muted)),
            const SizedBox(height: 10),
            _GrahaPlacementList(chart: birthResult.kundaliChart),
            const SizedBox(height: 19),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFEAE5EF))),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Calculation details', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.ink)),
                const SizedBox(height: 12),
                _DetailLine(label: 'Birth time zone', value: birthResult.timeZoneId),
                _DetailLine(label: 'Coordinates', value: '${birthResult.latitude.toStringAsFixed(4)}, ${birthResult.longitude.toStringAsFixed(4)}'),
                _DetailLine(label: 'Ayanamsha', value: '${birthResult.ayanamsa.toStringAsFixed(4)}°'),
                _DetailLine(label: 'Sidereal Moon longitude', value: '${birthResult.siderealMoonLongitude.toStringAsFixed(4)}°'),
              ]),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(color: const Color(0xFFFFF6E8), borderRadius: BorderRadius.circular(17), border: Border.all(color: const Color(0xFFF1E2C9))),
              child: const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Icon(Icons.info_outline_rounded, color: Color(0xFF9C7138), size: 18),
                SizedBox(width: 9),
                Expanded(child: Text(
                  'Planet positions use GeoEngine with the app’s approximate Lahiri ayanamsha. Houses are whole-sign houses derived from the calculated Ascendant. Verify important readings against a trusted Panchang or professional ephemeris; this is not a Swiss Ephemeris-validated chart.',
                  style: TextStyle(color: Color(0xFF795D36), fontSize: 10, height: 1.5),
                )),
              ]),
            ),
            if (birthResult.nearBoundary) ...[
              const SizedBox(height: 10),
              const Text('The Moon is close to a Nakshatra or Pada boundary. Verify the birth time and compare with a trusted ephemeris.', style: TextStyle(color: Color(0xFFB94C4C), fontSize: 10, height: 1.45)),
            ],
          ],
        ),
      ),
    );
  }

  static String _month(int month) => const ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'][month - 1];
  static String _time(DateTime value) {
    final h = value.hour % 12 == 0 ? 12 : value.hour % 12;
    return '$h:${value.minute.toString().padLeft(2, '0')} ${value.hour >= 12 ? 'PM' : 'AM'}';
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.label, required this.value, required this.symbol});
  final String label;
  final String value;
  final String symbol;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(17), border: Border.all(color: const Color(0xFFEAE5EF))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(symbol, style: const TextStyle(fontSize: 22, color: AppTheme.plum)),
      const SizedBox(height: 9),
      Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppTheme.ink, fontSize: 14, fontWeight: FontWeight.w800)),
      const SizedBox(height: 3),
      Text(label, style: const TextStyle(color: AppTheme.muted, fontSize: 10)),
    ]),
  );
}

class _DetailLine extends StatelessWidget {
  const _DetailLine({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 9),
    child: Row(children: [
      Expanded(child: Text(label, style: const TextStyle(color: AppTheme.muted, fontSize: 10))),
      const SizedBox(width: 10),
      Flexible(child: Text(value, textAlign: TextAlign.end, style: const TextStyle(color: AppTheme.ink, fontSize: 10, fontWeight: FontWeight.w700))),
    ]),
  );
}


class _KundaliHouseGrid extends StatelessWidget {
  const _KundaliHouseGrid({required this.chart});
  final KundaliChart chart;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8EC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8D5B5)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.star_rounded, color: AppTheme.plum, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Lagna: ${kundaliRashiNames[chart.ascendantSignIndex]} · ${_degree(chart.ascendantLongitude)}',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.ink),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 12,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 6,
              mainAxisSpacing: 6,
              childAspectRatio: 1.12,
            ),
            itemBuilder: (context, index) {
              final house = index + 1;
              final sign = (chart.ascendantSignIndex + index) % 12;
              final occupants = chart.inHouse(house);
              return Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: house == 1 ? const Color(0xFFEDE5F8) : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: house == 1 ? AppTheme.plum : const Color(0xFFE8D5B5),
                    width: house == 1 ? 1.3 : .8,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('House $house', style: const TextStyle(fontSize: 8, color: AppTheme.muted, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(
                      '${kundaliRashiSymbols[sign]} ${kundaliRashiNames[sign]}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 9, color: AppTheme.ink, fontWeight: FontWeight.w800),
                    ),
                    const Spacer(),
                    Text(
                      occupants.isEmpty ? '—' : occupants.map((g) => g.symbol).join(' · '),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 10, color: AppTheme.plum, fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          const Text('House 1 begins from the Ascendant sign. Empty houses are shown with —.', style: TextStyle(fontSize: 9, color: AppTheme.muted)),
        ],
      ),
    );
  }
}

class _GrahaPlacementList extends StatelessWidget {
  const _GrahaPlacementList({required this.chart});
  final KundaliChart chart;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFFEAE5EF)),
      ),
      child: Column(
        children: [
          for (var i = 0; i < chart.grahas.length; i++) ...[
            if (i > 0) const Divider(height: 1, indent: 14, endIndent: 14, color: Color(0xFFF0ECF3)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: const Color(0xFFF4EFF9), borderRadius: BorderRadius.circular(10)),
                    child: Text(chart.grahas[i].symbol, style: const TextStyle(color: AppTheme.plum, fontSize: 11, fontWeight: FontWeight.w900)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(chart.grahas[i].name, style: const TextStyle(fontSize: 11, color: AppTheme.ink, fontWeight: FontWeight.w800)),
                        Text('${kundaliRashiNames[chart.grahas[i].signIndex]} · ${_degree(chart.grahas[i].longitude)}', style: const TextStyle(fontSize: 9, color: AppTheme.muted)),
                      ],
                    ),
                  ),
                  Text('House ${chart.grahas[i].houseNumber}', style: const TextStyle(fontSize: 10, color: AppTheme.plum, fontWeight: FontWeight.w800)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

String _degree(double longitude) {
  final withinSign = longitude % 30;
  final degrees = withinSign.floor();
  final minutes = ((withinSign - degrees) * 60).round();
  return '${degrees}° ${minutes.toString().padLeft(2, '0')}′';
}
