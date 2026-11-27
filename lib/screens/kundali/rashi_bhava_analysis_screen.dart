import 'package:flutter/material.dart';

import '../../l10n/app_locale.dart';
import '../../models/kundali/kundali_graha.dart';
import '../../services/bhava_analysis_service.dart';
import '../../theme/app_theme.dart';

class RashiBhavaAnalysisScreen extends StatefulWidget {
  const RashiBhavaAnalysisScreen({super.key, required this.chart});
  final KundaliChart chart;

  @override
  State<RashiBhavaAnalysisScreen> createState() =>
      _RashiBhavaAnalysisScreenState();
}

class _RashiBhavaAnalysisScreenState extends State<RashiBhavaAnalysisScreen> {
  bool _useChalit = false;

  static const _lords = [
    'Mars', 'Venus', 'Mercury', 'Moon', 'Sun', 'Mercury',
    'Venus', 'Mars', 'Jupiter', 'Saturn', 'Saturn', 'Jupiter',
  ];
  static const _topics = [
    'self_body', 'wealth_family', 'siblings_courage', 'home_mother',
    'children_creativity', 'health_service', 'marriage_partnership',
    'longevity_transformation', 'fortune_dharma', 'career_status',
    'gains_networks', 'expenses_spirituality',
  ];
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
    final chart = widget.chart;
    final houseAspects = BhavaAnalysisService.analyse(chart, useChalit: _useChalit);
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('rashi_bhava_analysis'),
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
              Text(context.tr('twelve_bhavas'),
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
              const SizedBox(height: 5),
              Text(context.tr('bhava_analysis_intro'),
                style: const TextStyle(color: Color(0xFFEDE5F8), fontSize: 10, height: 1.45)),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: _HeaderMetric(label: context.tr('ascendant'),
                  value: '${kundaliRashiSymbols[chart.ascendantSignIndex]} ${context.tr(_rashiKeys[chart.ascendantSignIndex])}')),
                Expanded(child: _HeaderMetric(label: context.tr('midheaven'),
                  value: _degree(chart.midheavenLongitude))),
              ]),
            ]),
          ),
          const SizedBox(height: 15),
          SegmentedButton<bool>(
            segments: [
              ButtonSegment(value: false, label: Text(context.tr('d1_rashi'))),
              ButtonSegment(value: true, label: Text(context.tr('bhava_chalit'))),
            ],
            selected: {_useChalit},
            onSelectionChanged: (value) => setState(() => _useChalit = value.first),
            showSelectedIcon: false,
          ),
          const SizedBox(height: 8),
          Text(
            context.tr(_useChalit ? 'chalit_analysis_help' : 'd1_analysis_help'),
            style: const TextStyle(fontSize: 10, color: AppTheme.muted, height: 1.45),
          ),
          const SizedBox(height: 12),
          for (var index = 0; index < 12; index++)
            _HouseCard(
              number: index + 1,
              signIndex: _useChalit
                  ? chart.bhava(index + 1).signIndex
                  : (chart.ascendantSignIndex + index) % 12,
              lord: _lords[_useChalit
                  ? chart.bhava(index + 1).signIndex
                  : (chart.ascendantSignIndex + index) % 12],
              planets: _useChalit
                  ? chart.inBhava(index + 1)
                  : chart.inHouse(index + 1),
              lordPlacement: chart.grahas.where((g) => g.name == _lords[
                _useChalit ? chart.bhava(index + 1).signIndex :
                (chart.ascendantSignIndex + index) % 12
              ]).isEmpty ? null : (_useChalit
                ? chart.grahas.firstWhere((g) => g.name == _lords[chart.bhava(index + 1).signIndex]).bhavaNumber
                : chart.grahas.firstWhere((g) => g.name == _lords[(chart.ascendantSignIndex + index) % 12]).houseNumber),
              topic: context.tr(_topics[index]),
              aspectingGrahas: houseAspects[index].aspectingGrahas,
              degree: _useChalit
                  ? _degree(chart.bhava(index + 1).middleLongitude)
                  : null,
              rashiKey: _rashiKeys,
              planetKeys: _planetKeys,
            ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF6E8),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(context.tr('house_analysis_disclaimer'),
              style: const TextStyle(color: Color(0xFF795D36), fontSize: 10, height: 1.5)),
          ),
        ],
      ),
    );
  }

  static String _degree(double value) {
    final within = value % 30;
    final degrees = within.floor();
    final minutes = ((within - degrees) * 60).round();
    return '$degrees° $minutes′';
  }
}

class _HeaderMetric extends StatelessWidget {
  const _HeaderMetric({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(color: Color(0xFFDCCFEB), fontSize: 9)),
      const SizedBox(height: 3),
      Text(value, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800)),
    ],
  );
}

class _HouseCard extends StatelessWidget {
  const _HouseCard({
    required this.number,
    required this.signIndex,
    required this.lord,
    required this.planets,
    required this.topic,
    required this.aspectingGrahas,
    required this.lordPlacement,
    required this.rashiKey,
    required this.planetKeys,
    this.degree,
  });
  final int number;
  final int signIndex;
  final String lord;
  final List<KundaliGraha> planets;
  final String topic;
  final List<KundaliGraha> aspectingGrahas;
  final int? lordPlacement;
  final String? degree;
  final List<String> rashiKey;
  final Map<String, String> planetKeys;

  @override
  Widget build(BuildContext context) {
    final lordKey = planetKeys[lord]!;
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFEAE5EF)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 32, height: 32, alignment: Alignment.center,
            decoration: BoxDecoration(color: const Color(0xFFF4EFF9), borderRadius: BorderRadius.circular(10)),
            child: Text(number.toString().padLeft(2, '0'),
              style: const TextStyle(color: AppTheme.plum, fontSize: 11, fontWeight: FontWeight.w900)),
          ),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(context.tr('house_number').replaceAll('{n}', '$number'),
              style: const TextStyle(color: AppTheme.ink, fontSize: 12, fontWeight: FontWeight.w800)),
            Text('${kundaliRashiSymbols[signIndex]} ${context.tr(rashiKey[signIndex])}${degree == null ? '' : ' · $degree'}',
              style: const TextStyle(color: AppTheme.muted, fontSize: 10)),
          ])),
          Text('${context.tr('lord')}: ${context.tr(lordKey)}',
            style: const TextStyle(color: AppTheme.plum, fontSize: 9, fontWeight: FontWeight.w800)),
        ]),
        const SizedBox(height: 10),
        Text(topic, style: const TextStyle(color: AppTheme.ink, fontSize: 10, height: 1.4)),
        const SizedBox(height: 8),
        Row(children: [
          Text('${context.tr('lord_placed_in')}: ',
            style: const TextStyle(color: AppTheme.muted, fontSize: 9)),
          Text(lordPlacement == null
              ? context.tr('placement_unavailable')
              : context.tr('house_number').replaceAll('{n}', '$lordPlacement'),
            style: const TextStyle(color: AppTheme.ink, fontSize: 9, fontWeight: FontWeight.w700)),
        ]),
        const SizedBox(height: 6),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('${context.tr('occupants')}: ',
            style: const TextStyle(color: AppTheme.muted, fontSize: 9)),
          Expanded(child: Text(
            planets.isEmpty
                ? context.tr('no_planets_placed')
                : planets.map((p) => context.tr(planetKeys[p.name] ?? p.name)).join(' · '),
            style: const TextStyle(color: AppTheme.ink, fontSize: 9, fontWeight: FontWeight.w700),
          )),
        ]),
        const SizedBox(height: 6),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('${context.tr('aspected_by')}: ',
            style: const TextStyle(color: AppTheme.muted, fontSize: 9)),
          Expanded(child: Text(
            aspectingGrahas.isEmpty
                ? context.tr('no_classical_aspects_listed')
                : aspectingGrahas.map((p) => context.tr(planetKeys[p.name] ?? p.name)).join(' · '),
            style: const TextStyle(color: AppTheme.ink, fontSize: 9, fontWeight: FontWeight.w700),
          )),
        ]),
      ]),
    );
  }
}
