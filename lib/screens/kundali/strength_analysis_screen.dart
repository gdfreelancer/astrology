import 'package:flutter/material.dart';

import '../../l10n/app_locale.dart';
import '../../models/kundali/kundali_graha.dart';
import '../../services/shadbala_analysis_service.dart';
import '../../theme/app_theme.dart';

class StrengthAnalysisScreen extends StatelessWidget {
  const StrengthAnalysisScreen({super.key, required this.chart});

  final KundaliChart chart;

  @override
  Widget build(BuildContext context) {
    final grahas = ShadbalaAnalysisService.grahaStrength(chart);
    final bhavas = ShadbalaAnalysisService.bhavaStrength(chart);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.tr('strength_analysis_title')),
          bottom: TabBar(
            labelColor: AppTheme.plum,
            tabs: [
              Tab(text: context.tr('graha_strength')),
              Tab(text: context.tr('bhava_strength')),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _GrahaStrengthList(items: grahas),
            _BhavaStrengthList(items: bhavas),
          ],
        ),
      ),
    );
  }
}

class _GrahaStrengthList extends StatelessWidget {
  const _GrahaStrengthList({required this.items});
  final List<GrahaStrengthReport> items;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _Notice(context.tr('partial_shadbala_notice')),
          const SizedBox(height: 12),
          for (final item in items)
            Container(
              margin: const EdgeInsets.only(bottom: 11),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFEAE5EF)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: const Color(0xFFF4EFF9),
                        child: Text(
                          item.planet.symbol,
                          style: const TextStyle(
                            color: AppTheme.plum,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          item.planet.name,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppTheme.ink,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      if (item.vargottama)
                        _Pill(context.tr('vargottama')),
                    ],
                  ),
                  const SizedBox(height: 13),
                  _StrengthBar(
                    label: context.tr('uchcha_bala'),
                    value: item.uchchaBala,
                  ),
                  _StrengthBar(
                    label: context.tr('dig_bala'),
                    value: item.digBala,
                  ),
                  _StrengthBar(
                    label: context.tr('naisargika_bala'),
                    value: item.naisargikaBala,
                  ),
                  _StrengthBar(
                    label: context.tr('paksha_bala'),
                    value: item.pakshaBala,
                  ),
                  const SizedBox(height: 7),
                  Text(
                    '${context.tr('directional_peak_house')}: ${item.directionalPeakHouse}',
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppTheme.muted,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 4),
          Text(
            'Uchcha, Dig and Paksha values are component estimates in virupas. They must not be added together and presented as full Shadbala.',
            style: const TextStyle(
              fontSize: 10,
              height: 1.5,
              color: AppTheme.muted,
            ),
          ),
        ],
      );
}

class _StrengthBar extends StatelessWidget {
  const _StrengthBar({required this.label, required this.value});
  final String label;
  final double value;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppTheme.ink,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  '${value.toStringAsFixed(2)} ${context.tr('virupa')}',
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppTheme.plum,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: LinearProgressIndicator(
                value: (value / 60).clamp(0.0, 1.0),
                minHeight: 6,
                backgroundColor: const Color(0xFFF0ECF3),
                color: AppTheme.plum,
              ),
            ),
          ],
        ),
      );
}

class _BhavaStrengthList extends StatelessWidget {
  const _BhavaStrengthList({required this.items});
  final List<BhavaStrengthReport> items;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _Notice(context.tr('bhava_strength_notice')),
          const SizedBox(height: 12),
          for (final item in items)
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: const Color(0xFFEAE5EF)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bhava ${item.house.number} · ${kundaliRashiNames[item.signIndex]}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.ink,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 9),
                  _DetailLine(
                    label: context.tr('bhava_lord'),
                    value: item.houseLord,
                  ),
                  _DetailLine(
                    label: context.tr('lord_placed_house'),
                    value: item.lordHouse == null
                        ? context.tr('not_calculated')
                        : 'House ${item.lordHouse} · ${item.lordDignity}',
                  ),
                  _DetailLine(
                    label: context.tr('bhava_occupants'),
                    value: item.occupants.isEmpty
                        ? context.tr('no_planets')
                        : item.occupants.map((p) => p.name).join(', '),
                  ),
                  _DetailLine(
                    label: context.tr('graha_aspects_on_bhava'),
                    value: item.aspectingGrahas.isEmpty
                        ? context.tr('no_planets')
                        : item.aspectingGrahas.join(', '),
                  ),
                ],
              ),
            ),
        ],
      );
}

class _DetailLine extends StatelessWidget {
  const _DetailLine({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 7),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 112,
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  color: AppTheme.muted,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                value,
                textAlign: TextAlign.end,
                style: const TextStyle(
                  fontSize: 10,
                  color: AppTheme.ink,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      );
}

class _Pill extends StatelessWidget {
  const _Pill(this.label);
  final String label;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFFF4EFF9),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 9,
            color: AppTheme.plum,
            fontWeight: FontWeight.w800,
          ),
        ),
      );
}

class _Notice extends StatelessWidget {
  const _Notice(this.message);
  final String message;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF6E8),
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: const Color(0xFFF1E2C9)),
        ),
        child: Text(
          message,
          style: const TextStyle(
            fontSize: 10,
            height: 1.5,
            color: Color(0xFF795D36),
          ),
        ),
      );
}
