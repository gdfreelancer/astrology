import 'package:flutter/material.dart';

import '../l10n/app_locale.dart';
import '../models/kundali/kundali_chart_style.dart';
import '../models/kundali/kundali_graha.dart';
import '../theme/app_theme.dart';

/// Renders the same calculated D1 chart in the user's selected regional style.
class KundaliChartView extends StatelessWidget {
  const KundaliChartView({
    super.key,
    required this.chart,
    required this.style,
  });

  final KundaliChart chart;
  final KundaliChartStyle style;

  static const _rashiKeys = [
    'p_mesha','p_vrishabha','p_mithuna','p_karka','p_simha','p_kanya',
    'p_tula','p_vrishchika','p_dhanu','p_makara','p_kumbha','p_meena',
  ];

  String _rashi(int index) => AppLocale.text(_rashiKeys[index]);
  String _planet(String name) {
    const keys = {
      'Sun':'planet_sun','Moon':'planet_moon','Mars':'planet_mars',
      'Mercury':'planet_mercury','Jupiter':'planet_jupiter',
      'Venus':'planet_venus','Saturn':'planet_saturn',
      'Rahu':'planet_rahu','Ketu':'planet_ketu',
    };
    return AppLocale.text(keys[name] ?? name);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9EF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8D5B5)),
      ),
      child: Column(children: [
        Row(children: [
          const Icon(Icons.auto_awesome, color: AppTheme.plum, size: 16),
          const SizedBox(width: 7),
          Expanded(child: Text(
            'Lagna: ${_rashi(chart.ascendantSignIndex)} · ${_degree(chart.ascendantLongitude)}',
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.ink),
          )),
          Text(style.name == 'northIndian' ? 'D1' : 'D1',
            style: const TextStyle(fontSize: 9, color: AppTheme.muted, fontWeight: FontWeight.w800)),
        ]),
        const SizedBox(height: 10),
        if (style == KundaliChartStyle.northIndian)
          _northChart(context)
        else if (style == KundaliChartStyle.southIndian)
          _southChart(context)
        else
          _eastChart(context),
        const SizedBox(height: 9),
        Wrap(spacing: 12, runSpacing: 5, children: [
          _legend('House', AppTheme.plum),
          _legend('Rashi', const Color(0xFF9B7542)),
          _legend('Graha', const Color(0xFF60468F)),
          _legend('℞ Retrograde', const Color(0xFFB65C35)),
        ]),
        const SizedBox(height: 5),
        Text('Tap any house to view its sign, lord and planetary placements.',
          style: TextStyle(fontSize: 9, color: AppTheme.muted)),
      ]),
    );
  }

  Widget _legend(String label, Color color) => Row(mainAxisSize: MainAxisSize.min, children: [
    Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
    const SizedBox(width: 4),
    Text(label, style: const TextStyle(fontSize: 8, color: AppTheme.muted)),
  ]);

  Widget _northChart(BuildContext context) {
    const centers = <int, Offset>{
      1:Offset(.50,.25), 2:Offset(.75,.125), 3:Offset(.875,.25),
      4:Offset(.75,.50), 5:Offset(.875,.75), 6:Offset(.75,.875),
      7:Offset(.50,.75), 8:Offset(.25,.875), 9:Offset(.125,.75),
      10:Offset(.25,.50), 11:Offset(.125,.25), 12:Offset(.25,.125),
    };
    return AspectRatio(
      aspectRatio: 1,
      child: LayoutBuilder(builder: (context, constraints) {
        final size = constraints.maxWidth;
        return Stack(children: [
          Positioned.fill(child: CustomPaint(painter: _NorthChartPainter())),
          for (var house = 1; house <= 12; house++)
            Positioned(
              left: centers[house]!.dx * size - size * .105,
              top: centers[house]!.dy * size - size * .075,
              width: size * .21,
              height: size * .15,
              child: _houseCell(context, house, compact: true),
            ),
          Positioned(
            left: size * .34, top: size * .43, width: size * .32, height: size * .14,
            child: Center(child: Text('LAGNA', style: TextStyle(
              color: AppTheme.plum.withValues(alpha: .75), fontSize: 9,
              fontWeight: FontWeight.w900, letterSpacing: 1.2))),
          ),
        ]);
      }),
    );
  }

  Widget _southChart(BuildContext context) {
    const slots = <int>[0,1,2,3,7,11,15,14,13,12,8,4];
    final cells = List<Widget>.filled(16, const SizedBox.shrink());
    for (var sign = 0; sign < 12; sign++) {
      final house = ((sign - chart.ascendantSignIndex + 12) % 12) + 1;
      cells[slots[sign]] = _houseCell(context, house, signOverride: sign, compact: true);
    }
    cells[5] = _centerLabel(context, 'SOUTH INDIAN', 'Fixed Rashi layout');
    cells[6] = _centerLabel(context, 'JANMA KUNDALI', 'D1 · Rashi chart');
    cells[9] = _centerLabel(context, 'LAGNA', _rashi(chart.ascendantSignIndex));
    cells[10] = _centerLabel(context, 'ASC', _degree(chart.ascendantLongitude));
    return AspectRatio(
      aspectRatio: 1,
      child: GridView.count(
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 4,
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
        children: cells.map((cell) => Container(
          decoration: BoxDecoration(border: Border.all(color: const Color(0xFFD9C5A6), width: .8)),
          child: cell,
        )).toList(),
      ),
    );
  }

  Widget _eastChart(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 12,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, crossAxisSpacing: 3, mainAxisSpacing: 3,
        childAspectRatio: 1.18,
      ),
      itemBuilder: (context, index) => _houseCell(context, index + 1),
    );
  }

  Widget _centerLabel(BuildContext context, String title, String subtitle) =>
      Center(child: Padding(
        padding: const EdgeInsets.all(3),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(title, textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 8, color: AppTheme.plum, fontWeight: FontWeight.w900)),
          const SizedBox(height: 3),
          Text(subtitle, textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 7, color: AppTheme.muted)),
        ]),
      ));

  Widget _houseCell(BuildContext context, int house, {int? signOverride, bool compact = false}) {
    final sign = signOverride ?? (chart.ascendantSignIndex + house - 1) % 12;
    final occupants = chart.inHouse(house);
    return Material(
      color: house == 1 ? const Color(0xFFEDE5F8) : Colors.white,
      child: InkWell(
        onTap: () => _showHouse(context, house, sign, occupants),
        child: Padding(
          padding: EdgeInsets.all(compact ? 3 : 7),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${house.toString().padLeft(2, '0')}',
              style: TextStyle(fontSize: compact ? 7 : 9, color: AppTheme.plum, fontWeight: FontWeight.w900)),
            const SizedBox(height: 1),
            Text('${kundaliRashiSymbols[sign]} ${_rashi(sign)}',
              maxLines: 1, overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: compact ? 7 : 9, color: const Color(0xFF9B7542), fontWeight: FontWeight.w800)),
            const Spacer(),
            Text(occupants.isEmpty ? '—' : occupants.map((g) => '${g.symbol}${g.isRetrograde ? '℞' : ''}').join(' '),
              maxLines: 2, overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: compact ? 8 : 10, color: AppTheme.plum, fontWeight: FontWeight.w900)),
          ]),
        ),
      ),
    );
  }

  void _showHouse(BuildContext context, int house, int sign, List<KundaliGraha> occupants) {
    const lords = ['Mars','Venus','Mercury','Moon','Sun','Mercury','Venus','Mars','Jupiter','Saturn','Saturn','Jupiter'];
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
        decoration: const BoxDecoration(color: Color(0xFFFFFCF7),
          borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
        child: SafeArea(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(width: 38, height: 4, decoration: BoxDecoration(color: const Color(0xFFD8D0DC), borderRadius: BorderRadius.circular(8)))),
          const SizedBox(height: 14),
          Text('House $house · ${_rashi(sign)}', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: AppTheme.ink)),
          const SizedBox(height: 5),
          Text('Rashi lord: ${_planet(lords[sign])}', style: const TextStyle(fontSize: 11, color: AppTheme.plum, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          Text('Planetary placements', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
          const SizedBox(height: 7),
          if (occupants.isEmpty)
            const Text('No Graha is placed in this house. Its lord and planetary aspects still contribute to interpretation.',
              style: TextStyle(fontSize: 11, color: AppTheme.muted, height: 1.45))
          else
            for (final graha in occupants)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(children: [
                  Text(graha.symbol, style: const TextStyle(fontSize: 17, color: AppTheme.plum, fontWeight: FontWeight.w900)),
                  const SizedBox(width: 9),
                  Expanded(child: Text('${_planet(graha.name)} · ${_degree(graha.longitude)} · Nakshatra pada ${graha.pada}${graha.isRetrograde ? ' · ℞ Retrograde' : ''}',
                    style: const TextStyle(fontSize: 10, color: AppTheme.ink))),
                ]),
              ),
          const SizedBox(height: 8),
          SizedBox(width: double.infinity, child: OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          )),
        ])),
      ),
    );
  }

  static String _degree(double longitude) {
    final value = longitude % 30;
    final degrees = value.floor();
    final minutes = ((value - degrees) * 60).floor();
    return '$degrees° ${minutes.toString().padLeft(2, '0')}′';
  }
}

class _NorthChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFB99B72)
      ..strokeWidth = 1.15
      ..style = PaintingStyle.stroke;
    final rect = Offset.zero & size;
    final path = Path()..addRect(rect)
      ..moveTo(0, 0)..lineTo(size.width, size.height)
      ..moveTo(size.width, 0)..lineTo(0, size.height)
      ..moveTo(size.width / 2, 0)..lineTo(size.width, size.height / 2)
      ..lineTo(size.width / 2, size.height)..lineTo(0, size.height / 2)
      ..close();
    canvas.drawPath(path, paint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
