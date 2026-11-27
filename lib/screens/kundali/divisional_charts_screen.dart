import 'package:flutter/material.dart';

import '../../l10n/app_locale.dart';
import '../../models/kundali/kundali_graha.dart';
import '../../services/varga_chart_service.dart';
import 'varga_strength_panel.dart';
import '../../theme/app_theme.dart';

class DivisionalChartsScreen extends StatefulWidget {
  const DivisionalChartsScreen({super.key, required this.chart});
  final KundaliChart chart;

  @override
  State<DivisionalChartsScreen> createState() => _DivisionalChartsScreenState();
}

class _DivisionalChartsScreenState extends State<DivisionalChartsScreen> {
  int _division = 9;

  static const _rashiKeys = [
    'p_mesha','p_vrishabha','p_mithuna','p_karka','p_simha','p_kanya',
    'p_tula','p_vrishchika','p_dhanu','p_makara','p_kumbha','p_meena',
  ];
  static const _planetKeys = {
    'Sun':'planet_sun','Moon':'planet_moon','Mars':'planet_mars',
    'Mercury':'planet_mercury','Jupiter':'planet_jupiter',
    'Venus':'planet_venus','Saturn':'planet_saturn',
    'Rahu':'planet_rahu','Ketu':'planet_ketu',
  };

  @override
  Widget build(BuildContext context) {
    final selected = VargaChartService.definitions
        .firstWhere((item) => item.division == _division);
    final varga = VargaChartService.calculate(widget.chart, _division);
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('divisional_charts'),
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF8062B5), Color(0xFF60468F)]),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(context.tr('varga_chart_label'),
                style: const TextStyle(color: Color(0xFFEDE5F8), fontSize: 9,
                  letterSpacing: 1.1, fontWeight: FontWeight.w800)),
              const SizedBox(height: 5),
              Text(selected.shortName,
                style: const TextStyle(color: Colors.white, fontSize: 25,
                  fontWeight: FontWeight.w900)),
              const SizedBox(height: 3),
              Text(context.tr(selected.nameKey),
                style: const TextStyle(color: Color(0xFFFFE3A8), fontSize: 12,
                  fontWeight: FontWeight.w700)),
              const SizedBox(height: 9),
              Text(context.tr(selected.descriptionKey),
                style: const TextStyle(color: Color(0xFFEDE5F8), fontSize: 10,
                  height: 1.45)),
            ]),
          ),
          const SizedBox(height: 14),
          Text(context.tr('select_varga'),
            style: const TextStyle(color: AppTheme.ink, fontSize: 12,
              fontWeight: FontWeight.w800)),
          const SizedBox(height: 7),
          DropdownButtonFormField<int>(
            value: _division,
            isExpanded: true,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(13),
                borderSide: const BorderSide(color: Color(0xFFEAE5EF)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(13),
                borderSide: const BorderSide(color: Color(0xFFEAE5EF)),
              ),
            ),
            items: [
              for (final item in VargaChartService.definitions)
                DropdownMenuItem(
                  value: item.division,
                  child: Text('${item.shortName} · ${context.tr(item.nameKey)}',
                    overflow: TextOverflow.ellipsis),
                ),
            ],
            onChanged: (value) {
              if (value != null) setState(() => _division = value);
            },
          ),
          const SizedBox(height: 13),
          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: const Color(0xFFF4EFF9),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE4D9EF)),
            ),
            child: Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(context.tr('varga_lagna'),
                  style: const TextStyle(color: AppTheme.muted, fontSize: 9)),
                const SizedBox(height: 4),
                Text('${kundaliRashiSymbols[varga.ascendantSignIndex]} ${context.tr(_rashiKeys[varga.ascendantSignIndex])}',
                  style: const TextStyle(color: AppTheme.plum, fontSize: 15,
                    fontWeight: FontWeight.w900)),
              ])),
              Text('${varga.planets.length} ${context.tr('grahas')}',
                style: const TextStyle(color: AppTheme.muted, fontSize: 10)),
            ]),
          ),
          const SizedBox(height: 15),
          Text(context.tr('varga_house_placements'),
            style: const TextStyle(color: AppTheme.ink, fontSize: 14,
              fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          for (var house = 1; house <= 12; house++)
            _VargaHouseTile(
              house: house,
              signIndex: (varga.ascendantSignIndex + house - 1) % 12,
              planets: varga.inHouse(house),
              rashiKeys: _rashiKeys,
              planetKeys: _planetKeys,
            ),
          const SizedBox(height: 18),
          VargaStrengthPanel(chart: widget.chart),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF6E8),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(context.tr('varga_accuracy_note'),
              style: const TextStyle(color: Color(0xFF795D36), fontSize: 10,
                height: 1.5)),
          ),
        ],
      ),
    );
  }
}

class _VargaHouseTile extends StatelessWidget {
  const _VargaHouseTile({
    required this.house,
    required this.signIndex,
    required this.planets,
    required this.rashiKeys,
    required this.planetKeys,
  });
  final int house;
  final int signIndex;
  final List<VargaPlanetPosition> planets;
  final List<String> rashiKeys;
  final Map<String, String> planetKeys;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 7),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFFEAE5EF)),
    ),
    child: Row(children: [
      Container(
        width: 30, height: 30, alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFFF4EFF9),
          borderRadius: BorderRadius.circular(9),
        ),
        child: Text(house.toString().padLeft(2, '0'),
          style: const TextStyle(color: AppTheme.plum, fontSize: 10,
            fontWeight: FontWeight.w900)),
      ),
      const SizedBox(width: 10),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('${kundaliRashiSymbols[signIndex]} ${context.tr(rashiKeys[signIndex])}',
          style: const TextStyle(color: AppTheme.ink, fontSize: 11,
            fontWeight: FontWeight.w800)),
        const SizedBox(height: 3),
        Text(planets.isEmpty
            ? context.tr('no_planets_placed')
            : planets.map((p) => context.tr(planetKeys[p.name] ?? p.name) +
                (p.isRetrograde ? ' ℞' : '')).join(' · '),
          style: const TextStyle(color: AppTheme.muted, fontSize: 9)),
      ])),
    ]),
  );
}
