import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import '../../services/kundali_pdf_service.dart';

import '../../l10n/app_locale.dart';
import '../../models/birth_chart_result.dart';
import '../../services/settings/app_preferences_service.dart';
import '../../models/kundali/kundali_chart_style.dart';
import '../../models/kundali/kundali_graha.dart';
import '../../theme/app_theme.dart';
import '../../widgets/bhava_chalit_card.dart';
import 'graha_analysis_screen.dart';
import 'rashi_bhava_analysis_screen.dart';
import 'vimshottari_dasha_screen.dart';
import 'divisional_charts_screen.dart';
import 'gochar_yogas_screen.dart';
import 'advanced_chart_analysis_screen.dart';
import 'ashtakavarga_screen.dart';


String _localizedRashi(int index) {
  const keys = ['p_mesha','p_vrishabha','p_mithuna','p_karka','p_simha','p_kanya','p_tula','p_vrishchika','p_dhanu','p_makara','p_kumbha','p_meena'];
  return AppLocale.text(keys[index]);
}
String _localizedGraha(String name) {
  const keys = {'Sun':'planet_sun','Moon':'planet_moon','Mars':'planet_mars','Mercury':'planet_mercury','Jupiter':'planet_jupiter','Venus':'planet_venus','Saturn':'planet_saturn','Rahu':'planet_rahu','Ketu':'planet_ketu'};
  final key = keys[name];
  return key == null ? name : AppLocale.text(key);
}

String _localizedAstroName(String value) {
  final slug = value.split(' (').first.toLowerCase().replaceAll(RegExp('[^a-z0-9]+'), '_');
  final key = 'p_' + slug;
  final translated = AppLocale.text(key);
  return translated == key ? value : translated;
}

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
        title: Text(context.tr('kundali_overview'), style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            tooltip: 'Export Kundali PDF',
            onPressed: () async {
              try {
                final bytes = await KundaliPdfService.build(name: name, result: birthResult);
                await Printing.sharePdf(bytes: bytes, filename: 'saral-jyotish-kundali.pdf');
              } catch (_) {
                if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not create the Kundali PDF.')));
              }
            },
            icon: const Icon(Icons.picture_as_pdf_outlined, color: AppTheme.plum),
          ),
          IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.edit_outlined, color: AppTheme.plum), tooltip: context.tr('edit_birth_details')),
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
                Text(context.tr('your_birth_chart'), style: TextStyle(color: Color(0xFFEDE5F8), fontSize: 9, letterSpacing: 1.5, fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                Text(name.isEmpty ? context.tr('your_kundali') : name, style: const TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w800)),
                const SizedBox(height: 5),
                Text('${local.day.toString().padLeft(2, '0')} ${_month(local.month)} ${local.year}  ·  ${_time(local)}', style: const TextStyle(color: Color(0xFFEDE5F8), fontSize: 11)),
                const SizedBox(height: 3),
                Text(birthResult.placeName, style: const TextStyle(color: Color(0xFFEDE5F8), fontSize: 11)),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: .14), borderRadius: BorderRadius.circular(30)),
                  child: Text('${context.tr(switch (chartStyle) { KundaliChartStyle.northIndian => 'north_indian', KundaliChartStyle.southIndian => 'south_indian', KundaliChartStyle.eastIndian => 'east_indian' })} ${context.tr('chart')} preference', style: const TextStyle(color: Color(0xFFFFE3A8), fontSize: 10, fontWeight: FontWeight.w800)),
                ),
              ]),
            ),
            const SizedBox(height: 19),
            Text(context.tr('birth_details_calculated'), style: TextStyle(fontSize: 15, color: AppTheme.ink, fontWeight: FontWeight.w800)),
            const SizedBox(height: 11),
            Row(children: [
              Expanded(child: _InfoCard(label: context.tr('janma_rashi'), value: _localizedAstroName(birthResult.rashi), symbol: birthResult.rashiSymbol)),
              const SizedBox(width: 10),
              Expanded(child: _InfoCard(label: context.tr('nakshatra'), value: _localizedAstroName(birthResult.nakshatra), symbol: '✦')),
            ]),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: _InfoCard(label: context.tr('pada'), value: birthResult.pada.toString(), symbol: '◈')),
              const SizedBox(width: 10),
              Expanded(child: _InfoCard(label: context.tr('naming_syllable'), value: birthResult.namingSyllable, symbol: 'ॐ')),
            ]),

            const SizedBox(height: 20),
            Text(context.tr('janma_kundali_d1'), style: TextStyle(fontSize: 15, color: AppTheme.ink, fontWeight: FontWeight.w800)),
            const SizedBox(height: 5),
            Text(
              '${context.tr(switch (chartStyle) { KundaliChartStyle.northIndian => 'north_indian', KundaliChartStyle.southIndian => 'south_indian', KundaliChartStyle.eastIndian => 'east_indian' })} ${context.tr('chart')} · Whole-sign houses',
              style: const TextStyle(fontSize: 10, color: AppTheme.muted),
            ),
            const SizedBox(height: 11),
            _KundaliHouseGrid(chart: birthResult.kundaliChart),
            const SizedBox(height: 16),
            BhavaChalitCard(chart: birthResult.kundaliChart),
            const SizedBox(height: 12),
            _AnalysisShortcut(
              icon: Icons.account_tree_outlined,
              title: context.tr('rashi_bhava_analysis'),
              subtitle: context.tr('rashi_bhava_analysis_short'),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => RashiBhavaAnalysisScreen(chart: birthResult.kundaliChart),
              )),
            ),
            const SizedBox(height: 8),
            _AnalysisShortcut(
              icon: Icons.grid_view_rounded,
              title: 'Ashtakavarga analysis',
              subtitle: 'Bhinnashtakavarga and Sarvashtakavarga bindu tables',
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => AshtakavargaScreen(chart: birthResult.kundaliChart),
              )),
            ),
            const SizedBox(height: 8),
            _AnalysisShortcut(
              icon: Icons.insights_rounded,
              title: 'Advanced chart analysis',
              subtitle: 'Graha Drishti, Avastha and supported Yoga checks',
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => AdvancedChartAnalysisScreen(chart: birthResult.kundaliChart),
              )),
            ),
            const SizedBox(height: 8),
            _AnalysisShortcut(
              icon: Icons.auto_awesome_outlined,
              title: context.tr('vimshottari_dasha'),
              subtitle: context.tr('vimshottari_dasha_short'),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => VimshottariDashaScreen(
                  siderealMoonLongitude: birthResult.siderealMoonLongitude,
                  birthDate: birthResult.birthLocal,
                ),
              )),
            ),
            const SizedBox(height: 8),
            _AnalysisShortcut(
              icon: Icons.auto_graph_rounded,
              title: context.tr('gochar_yogas'),
              subtitle: context.tr('gochar_yogas_short'),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => GocharYogasScreen(chart: birthResult.kundaliChart),
              )),
            ),
            const SizedBox(height: 8),
            _AnalysisShortcut(
              icon: Icons.grid_view_rounded,
              title: context.tr('divisional_charts'),
              subtitle: context.tr('divisional_charts_short'),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => DivisionalChartsScreen(chart: birthResult.kundaliChart),
              )),
            ),
            const SizedBox(height: 20),
            Text(context.tr('graha_placements'), style: TextStyle(fontSize: 15, color: AppTheme.ink, fontWeight: FontWeight.w800)),
            const SizedBox(height: 5),
            Text(context.tr('graha_placements_help'), style: TextStyle(fontSize: 10, color: AppTheme.muted)),
            const SizedBox(height: 10),
            _GrahaPlacementList(chart: birthResult.kundaliChart),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => GrahaAnalysisScreen(chart: birthResult.kundaliChart),
                )),
                icon: const Icon(Icons.analytics_outlined, size: 16),
                label: Text(context.tr('view_graha_analysis')),
              ),
            ),
            const SizedBox(height: 19),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFEAE5EF))),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(context.tr('calculation_details'), style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.ink)),
                const SizedBox(height: 12),
                _DetailLine(label: context.tr('birth_time_zone'), value: birthResult.timeZoneId),
                _DetailLine(label: context.tr('coordinates'), value: '${birthResult.latitude.toStringAsFixed(4)}, ${birthResult.longitude.toStringAsFixed(4)}'),
                _DetailLine(label: context.tr('ayanamsha'), value: '${birthResult.ayanamsa.toStringAsFixed(4)}°'),
                _DetailLine(label: context.tr('sidereal_moon_longitude'), value: '${birthResult.siderealMoonLongitude.toStringAsFixed(4)}°'),
              ]),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(color: const Color(0xFFFFF6E8), borderRadius: BorderRadius.circular(17), border: Border.all(color: const Color(0xFFF1E2C9))),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Icon(Icons.info_outline_rounded, color: Color(0xFF9C7138), size: 18),
                SizedBox(width: 9),
                Expanded(child: Text(
                  context.tr('kundali_accuracy_disclaimer'),
                  style: TextStyle(color: Color(0xFF795D36), fontSize: 10, height: 1.5),
                )),
              ]),
            ),
            if (birthResult.nearBoundary) ...[
              const SizedBox(height: 10),
              Text(context.tr('verify_boundary'), style: TextStyle(color: Color(0xFFB94C4C), fontSize: 10, height: 1.45)),
            ],
          ],
        ),
      ),
    );
  }

  static String _month(int month) => AppLocale.text('month_short_$month');
  static String _time(DateTime value) {
    final minute = value.minute.toString().padLeft(2, '0');
    if (AppPreferencesService.cachedUse24HourTime) return '${value.hour.toString().padLeft(2, '0')}:$minute';
    final h = value.hour % 12 == 0 ? 12 : value.hour % 12;
    return '$h:$minute ${value.hour >= 12 ? 'PM' : 'AM'}';
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
                  'Lagna: ${_localizedRashi(chart.ascendantSignIndex)} · ${_degree(chart.ascendantLongitude)}',
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
                    Text(context.tr('house_number').replaceAll('{n}', '$house'), style: const TextStyle(fontSize: 8, color: AppTheme.muted, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(
                      '${kundaliRashiSymbols[sign]} ${_localizedRashi(sign)}',
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
          Text(context.tr('house_one_note'), style: TextStyle(fontSize: 9, color: AppTheme.muted)),
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
                        Text(_localizedGraha(chart.grahas[i].name), style: const TextStyle(fontSize: 11, color: AppTheme.ink, fontWeight: FontWeight.w800)),
                        Text('${_localizedRashi(chart.grahas[i].signIndex)} · ${_degree(chart.grahas[i].longitude)}', style: const TextStyle(fontSize: 9, color: AppTheme.muted)),
                      ],
                    ),
                  ),
                  Text(context.tr('house_number').replaceAll('{n}', '${chart.grahas[i].houseNumber}'), style: const TextStyle(fontSize: 10, color: AppTheme.plum, fontWeight: FontWeight.w800)),
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

class _AnalysisShortcut extends StatelessWidget {
  const _AnalysisShortcut({
    required this.icon, required this.title, required this.subtitle,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    borderRadius: BorderRadius.circular(15),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: const Color(0xFFEAE5EF)),
        ),
        child: Row(children: [
          Container(width: 36, height: 36, alignment: Alignment.center,
            decoration: BoxDecoration(color: const Color(0xFFF4EFF9), borderRadius: BorderRadius.circular(11)),
            child: Icon(icon, color: AppTheme.plum, size: 18)),
          const SizedBox(width: 11),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(color: AppTheme.ink, fontSize: 11, fontWeight: FontWeight.w800)),
            const SizedBox(height: 3),
            Text(subtitle, style: const TextStyle(color: AppTheme.muted, fontSize: 9)),
          ])),
          const Icon(Icons.chevron_right_rounded, color: AppTheme.plum, size: 20),
        ]),
      ),
    ),
  );
}
