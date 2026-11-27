import 'package:flutter/material.dart';
import '../../models/birth_chart_result.dart';
import '../../models/kundali/kundali_graha.dart';
import '../../models/panchang_data.dart';
import '../../services/jyotish_reference_service.dart';
import '../../services/panchang_service.dart';
import '../../theme/app_theme.dart';

class JyotishReferenceScreen extends StatelessWidget {
  const JyotishReferenceScreen({super.key, required this.result});
  final BirthChartResult result;

  @override
  Widget build(BuildContext context) {
    final chart = result.kundaliChart;
    final hora = _hora();
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Extended Jyotish analysis', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
          bottom: const TabBar(isScrollable: true, labelColor: AppTheme.plum, tabs: [
            Tab(text: 'Graha states'), Tab(text: 'Maitri & Karaka'),
            Tab(text: 'Rashi traits'), Tab(text: 'Hora'), Tab(text: 'Graha reference'),
          ]),
        ),
        body: TabBarView(children: [
          _GrahaStates(chart: chart),
          _MaitriKarakas(chart: chart),
          const _RashiTraits(),
          _HoraView(data: hora, birthTime: result.birthLocal),
          _GrahaReference(chart: chart),
        ]),
      ),
    );
  }

  _HoraResult _hora() {
    try {
      final p = PanchangService.calculate(
        date: result.birthLocal,
        location: PanchangLocation(name: result.placeName, latitude: result.latitude,
          longitude: result.longitude, timeZoneId: result.timeZoneId),
      );
      return _HoraResult(JyotishReferenceService.horas(p), null);
    } catch (_) {
      return const _HoraResult([], 'Sunrise/sunset could not be calculated for this birth date and location.');
    }
  }
}

class _HoraResult {
  const _HoraResult(this.entries, this.error);
  final List<HoraEntry> entries;
  final String? error;
}

class _GrahaStates extends StatelessWidget {
  const _GrahaStates({required this.chart});
  final KundaliChart chart;
  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(16), children: [
    const _Notice('Baladi Avastha uses five 6° segments, reversed for even-sign Rashis. Dashavidha Avastha is included as a classical reference. Its ten labels are not auto-assigned because detailed rules vary by text and require method-specific dignity, association and strength checks.'),
    const SizedBox(height: 12),
    const _Heading('Baladi Avastha · computed from D1 degrees'),
    for (final g in chart.grahas)
      _Tile(leading: g.symbol, title: g.name,
        subtitle: '${kundaliRashiNames[g.signIndex]} · ${g.signDegree.toStringAsFixed(2)}° within sign',
        trailing: JyotishReferenceService.baladiAvastha(g)),
    const SizedBox(height: 14),
    const _Heading('Dashavidha Avastha · ten-state reference'),
    for (var i = 0; i < JyotishReferenceService.dashavidhaNames.length; i++)
      _Tile(leading: '${i + 1}', title: JyotishReferenceService.dashavidhaNames[i],
        subtitle: JyotishReferenceService.dashavidhaNotes[i], trailing: 'Reference'),
  ]);
}

class _MaitriKarakas extends StatelessWidget {
  const _MaitriKarakas({required this.chart});
  final KundaliChart chart;
  @override
  Widget build(BuildContext context) {
    final friendships = JyotishReferenceService.panchadhaMaitri(chart);
    final karakas = JyotishReferenceService.charaKarakas(chart);
    return ListView(padding: const EdgeInsets.all(16), children: [
      const _Notice('Panchadha Maitri combines natural planetary relationships with temporary relationships derived from sign placement. Rahu/Ketu friendship traditions differ between schools.'),
      const SizedBox(height: 12),
      const _Heading('Jaimini Chara Karaka'),
      const _Notice('Eight-karaka scheme: Rahu degrees are counted in reverse within its sign. Some traditions use seven karakas; this chart uses the eight-karaka scheme when all required grahas are present.'),
      for (final item in karakas)
        _Tile(leading: item.planet.symbol, title: item.role, subtitle: item.planet.name, trailing: '${item.degree.toStringAsFixed(2)}°'),
      const SizedBox(height: 14),
      const _Heading('Panchadha Maitri Chakra'),
      for (final item in friendships)
        _Tile(leading: '${item.first.symbol} · ${item.second.symbol}',
          title: '${item.first.name} – ${item.second.name}',
          subtitle: 'Natural: ${item.natural} · Temporary: ${item.temporary}', trailing: item.compound),
    ]);
  }
}

class _RashiTraits extends StatelessWidget {
  const _RashiTraits();
  @override
  Widget build(BuildContext context) {
    final items = JyotishReferenceService.rashiAttributes();
    return ListView(padding: const EdgeInsets.all(16), children: [
      const _Notice('Traditional Rashi classifications are reference attributes, not standalone predictions. Day/night strength and other classifications can vary by lineage.'),
      const SizedBox(height: 12),
      for (final item in items)
        Container(margin: const EdgeInsets.only(bottom: 9), padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: const Color(0xFFEAE5EF))),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(item['name']!, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.ink)),
            const SizedBox(height: 8),
            Wrap(spacing: 6, runSpacing: 6, children: [
              _Pill(item['element']!), _Pill(item['modality']!), _Pill(item['gender']!),
              _Pill('Lord: ${item['lord']}'), _Pill(item['dayNight']!),
            ]),
            const SizedBox(height: 6),
            Text('Direction: ${item['direction']} · Kālapuruṣa body association: ${item['bodyPart']}',
              style: const TextStyle(fontSize: 10, color: AppTheme.muted, height: 1.4)),
          ]),
        ),
    ]);
  }
}

class _HoraView extends StatelessWidget {
  const _HoraView({required this.data, required this.birthTime});
  final _HoraResult data;
  final DateTime birthTime;
  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(16), children: [
    const _Notice('Hora divides local sunrise-to-sunset into 12 equal parts and sunset-to-next-sunrise into 12 equal parts. Each period is not always exactly 60 clock minutes. The sequence follows the traditional Chaldean planetary order.'),
    const SizedBox(height: 12),
    if (data.error != null) _Notice(data.error!)
    else ...[
      const _Heading('24 planetary hours for the birth date'),
      for (final item in data.entries)
        _Tile(leading: item.index.toString().padLeft(2, '0'), title: '${item.planet} Hora',
          subtitle: '${item.isNight ? 'Night' : 'Day'} · ${_clock(item.start)} – ${_clock(item.end)}',
          trailing: item.contains(birthTime) ? 'Birth Hora' : ''),
    ],
    const SizedBox(height: 8),
    const Text('Traditional hora associations are symbolic and are not a guarantee of outcomes.', style: TextStyle(fontSize: 10, color: AppTheme.muted)),
  ]);
  static String _clock(DateTime d) => '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
}

class _GrahaReference extends StatelessWidget {
  const _GrahaReference({required this.chart});
  final KundaliChart chart;
  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(16), children: [
    const _Notice('Planetary directions, colours, natural significations and body associations are traditional Jyotish correspondences. Body references are symbolism only, not medical information or diagnosis.'),
    const SizedBox(height: 12),
    for (final g in chart.grahas)
      Container(margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: const Color(0xFFEAE5EF))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [Text(g.symbol, style: const TextStyle(fontSize: 19, color: AppTheme.plum)), const SizedBox(width: 9), Text(g.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800))]),
          const SizedBox(height: 8),
          Text(JyotishReferenceService.karakatva(g.name) ?? 'Traditional significations vary by school.', style: const TextStyle(fontSize: 10, height: 1.45, color: AppTheme.ink)),
          const SizedBox(height: 6),
          Text('Direction: ${JyotishReferenceService.direction(g.name) ?? 'Varies'} · Colour: ${JyotishReferenceService.colour(g.name) ?? 'Varies'}',
            style: const TextStyle(fontSize: 10, color: AppTheme.muted)),
        ]),
      ),
  ]);
}

class _Heading extends StatelessWidget {
  const _Heading(this.value);
  final String value;
  @override Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(bottom: 9),
    child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.ink)));
}
class _Notice extends StatelessWidget {
  const _Notice(this.value);
  final String value;
  @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(color: const Color(0xFFFFF6E8), borderRadius: BorderRadius.circular(13), border: Border.all(color: const Color(0xFFF1E2C9))),
    child: Text(value, style: const TextStyle(fontSize: 10, height: 1.5, color: Color(0xFF795D36))));
}
class _Tile extends StatelessWidget {
  const _Tile({required this.leading, required this.title, required this.subtitle, required this.trailing});
  final String leading, title, subtitle, trailing;
  @override Widget build(BuildContext context) => Container(margin: const EdgeInsets.only(bottom: 7), padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(13), border: Border.all(color: const Color(0xFFEAE5EF))),
    child: Row(children: [
      Container(width: 34, height: 34, alignment: Alignment.center, decoration: BoxDecoration(color: const Color(0xFFF4EFF9), borderRadius: BorderRadius.circular(10)),
        child: Text(leading, style: const TextStyle(fontSize: 11, color: AppTheme.plum, fontWeight: FontWeight.w800))),
      const SizedBox(width: 10),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontSize: 11, color: AppTheme.ink, fontWeight: FontWeight.w800)),
        const SizedBox(height: 3), Text(subtitle, style: const TextStyle(fontSize: 9, color: AppTheme.muted, height: 1.4)),
      ])),
      if (trailing.isNotEmpty) ...[const SizedBox(width: 8), Flexible(child: Text(trailing, textAlign: TextAlign.end, style: const TextStyle(fontSize: 9, color: AppTheme.plum, fontWeight: FontWeight.w800)))],
    ]));
}
class _Pill extends StatelessWidget {
  const _Pill(this.value);
  final String value;
  @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
    decoration: BoxDecoration(color: const Color(0xFFF4EFF9), borderRadius: BorderRadius.circular(20)),
    child: Text(value, style: const TextStyle(fontSize: 9, color: AppTheme.plum, fontWeight: FontWeight.w700)));
}
