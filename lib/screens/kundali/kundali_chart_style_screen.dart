import 'package:flutter/material.dart';

import '../../l10n/app_locale.dart';

import '../../models/kundali/kundali_chart_style.dart';
import '../../services/kundali/kundali_preferences_service.dart';
import '../../theme/app_theme.dart';

class KundaliChartStyleScreen extends StatefulWidget {
  const KundaliChartStyleScreen({super.key, this.currentStyle});

  final KundaliChartStyle? currentStyle;

  @override
  State<KundaliChartStyleScreen> createState() => _KundaliChartStyleScreenState();
}

class _KundaliChartStyleScreenState extends State<KundaliChartStyleScreen> {
  KundaliChartStyle? _selected;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _selected = widget.currentStyle;
  }

  Future<void> _continue() async {
    final style = _selected;
    if (style == null || _saving) return;
    setState(() => _saving = true);
    try {
      await KundaliPreferencesService.saveChartStyle(style);
      if (mounted) Navigator.of(context).pop(style);
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(context.tr('chart_style_tip'))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('chart_style_heading'), style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF8062B5), Color(0xFF60468F)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(23),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('🪷', style: TextStyle(fontSize: 34)),
                  SizedBox(height: 12),
                  Text(context.tr('chart_style_tagline'), style: TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w800)),
                  SizedBox(height: 7),
                  Text(
                    'Choose the traditional birth-chart layout you are familiar with. We will remember your choice for future Kundalis.',
                    style: TextStyle(color: Color(0xFFEDE5F8), fontSize: 12, height: 1.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            ...KundaliChartStyle.values.map((style) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _ChartStyleCard(
                style: style,
                selected: _selected == style,
                onTap: () => setState(() => _selected = style),
              ),
            )),
            const SizedBox(height: 10),
            SizedBox(
              height: 54,
              child: FilledButton(
                onPressed: _selected == null || _saving ? null : _continue,
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.plum,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: _saving
                    ? const SizedBox(width: 21, height: 21, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text(context.tr('save_preference_continue'), style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
              ),
            ),
            const SizedBox(height: 9),
            const Text(
              context.tr('chart_style_tip'),
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.muted, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChartStyleCard extends StatelessWidget {
  const _ChartStyleCard({required this.style, required this.selected, required this.onTap});

  final KundaliChartStyle style;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(19),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(19),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(19),
            border: Border.all(
              color: selected ? AppTheme.plum : const Color(0xFFEAE5EF),
              width: selected ? 1.7 : 1,
            ),
            color: selected ? const Color(0xFFF7F2FC) : Colors.white,
          ),
          child: Row(
            children: [
              SizedBox(width: 104, height: 104, child: _ChartStylePreview(style: style)),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(style.label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.ink)),
                    const SizedBox(height: 5),
                    Text(style.description, style: const TextStyle(fontSize: 10, height: 1.4, color: AppTheme.muted)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                selected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                color: selected ? AppTheme.plum : const Color(0xFFB8B2C1),
                size: 21,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChartStylePreview extends StatelessWidget {
  const _ChartStylePreview({required this.style});
  final KundaliChartStyle style;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ChartPreviewPainter(style),
      child: const SizedBox.expand(),
    );
  }
}

/// Draws the traditional geometry used by the three regional Rasi-chart styles.
/// The numbers are sign numbers in the fixed-sign layouts and house positions
/// in the North Indian house-fixed preview.
class _ChartPreviewPainter extends CustomPainter {
  _ChartPreviewPainter(this.style);
  final KundaliChartStyle style;

  static const _paper = Color(0xFFFFF8EC);
  static const _ink = Color(0xFF9E7138);
  static const _accent = Color(0xFF704C9B);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final bounds = rect.deflate(1.5);
    final fill = Paint()..color = _paper;
    final line = Paint()
      ..color = _ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.15
      ..strokeJoin = StrokeJoin.round;

    canvas.drawRect(bounds, fill);
    canvas.drawRect(bounds, line);

    switch (style) {
      case KundaliChartStyle.northIndian:
        _drawNorthIndian(canvas, bounds, line);
        break;
      case KundaliChartStyle.southIndian:
        _drawSouthIndian(canvas, bounds, line);
        break;
      case KundaliChartStyle.eastIndian:
        _drawEastIndian(canvas, bounds, line);
        break;
    }
  }

  void _drawNorthIndian(Canvas canvas, Rect r, Paint line) {
    final c = r.center;
    final top = Offset(c.dx, r.top);
    final right = Offset(r.right, c.dy);
    final bottom = Offset(c.dx, r.bottom);
    final left = Offset(r.left, c.dy);

    // The diamond joins the midpoints of the four outer sides. The four
    // corner-to-centre lines create the twelve traditional house compartments.
    final diamond = Path()
      ..moveTo(top.dx, top.dy)
      ..lineTo(right.dx, right.dy)
      ..lineTo(bottom.dx, bottom.dy)
      ..lineTo(left.dx, left.dy)
      ..close();
    canvas.drawPath(diamond, line);
    canvas.drawLine(r.topLeft, c, line);
    canvas.drawLine(r.topRight, c, line);
    canvas.drawLine(r.bottomRight, c, line);
    canvas.drawLine(r.bottomLeft, c, line);

    final w = r.width;
    final h = r.height;
    final labels = <_PreviewLabel>[
      _PreviewLabel('1', Offset(c.dx, r.top + h * .245)),
      _PreviewLabel('2', Offset(r.left + w * .245, r.top + h * .125)),
      _PreviewLabel('3', Offset(r.left + w * .125, r.top + h * .245)),
      _PreviewLabel('4', Offset(r.left + w * .245, c.dy)),
      _PreviewLabel('5', Offset(r.left + w * .125, r.top + h * .755)),
      _PreviewLabel('6', Offset(r.left + w * .245, r.top + h * .875)),
      _PreviewLabel('7', Offset(c.dx, r.top + h * .755)),
      _PreviewLabel('8', Offset(r.left + w * .755, r.top + h * .875)),
      _PreviewLabel('9', Offset(r.left + w * .875, r.top + h * .755)),
      _PreviewLabel('10', Offset(r.left + w * .755, c.dy)),
      _PreviewLabel('11', Offset(r.left + w * .875, r.top + h * .245)),
      _PreviewLabel('12', Offset(r.left + w * .755, r.top + h * .125)),
    ];
    for (final label in labels) {
      _drawText(canvas, label.text, label.center, fontSize: 8.5);
    }
    _drawText(canvas, 'Lagna', c, fontSize: 6.5, color: _accent);
  }

  void _drawSouthIndian(Canvas canvas, Rect r, Paint line) {
    final cellW = r.width / 4;
    final cellH = r.height / 4;

    // A 4x4 square ring: the central 2x2 area remains open.
    for (var i = 1; i < 4; i++) {
      canvas.drawLine(Offset(r.left + cellW * i, r.top), Offset(r.left + cellW * i, r.bottom), line);
      canvas.drawLine(Offset(r.left, r.top + cellH * i), Offset(r.right, r.top + cellH * i), line);
    }

    // Fixed zodiac signs, clockwise: Pisces is top-left and Aries is the
    // second cell of the top row in the common South Indian convention.
    const positions = <int, List<int>>{
      12: [0, 0], 1: [0, 1], 2: [0, 2], 3: [0, 3],
      4: [1, 3], 5: [2, 3], 6: [3, 3], 7: [3, 2],
      8: [3, 1], 9: [3, 0], 10: [2, 0], 11: [1, 0],
    };
    for (final entry in positions.entries) {
      final row = entry.value[0];
      final col = entry.value[1];
      final center = Offset(
        r.left + cellW * (col + .5),
        r.top + cellH * (row + .5),
      );
      _drawText(canvas, entry.key.toString(), center, fontSize: 8.5);
    }
    _drawText(canvas, 'RASI', r.center, fontSize: 8, color: _accent);
    _drawText(canvas, 'CHART', Offset(r.center.dx, r.center.dy + 9), fontSize: 5.5, color: _accent);
  }

  void _drawEastIndian(Canvas canvas, Rect r, Paint line) {
    final x1 = r.left + r.width / 3;
    final x2 = r.left + 2 * r.width / 3;
    final y1 = r.top + r.height / 3;
    final y2 = r.top + 2 * r.height / 3;

    // Bengali/East Indian presentation: a central open square, four side
    // compartments and diagonally divided corner compartments.
    canvas.drawLine(Offset(x1, r.top), Offset(x1, r.bottom), line);
    canvas.drawLine(Offset(x2, r.top), Offset(x2, r.bottom), line);
    canvas.drawLine(Offset(r.left, y1), Offset(r.right, y1), line);
    canvas.drawLine(Offset(r.left, y2), Offset(r.right, y2), line);

    canvas.drawLine(r.topLeft, Offset(x1, y1), line);
    canvas.drawLine(r.topRight, Offset(x2, y1), line);
    canvas.drawLine(r.bottomRight, Offset(x2, y2), line);
    canvas.drawLine(r.bottomLeft, Offset(x1, y2), line);

    // Twelve fixed-sign compartments: four side boxes and two triangles
    // in each corner. Aries starts at the top; signs continue anticlockwise.
    final labels = <_PreviewLabel>[
      _PreviewLabel('1', Offset(r.center.dx, r.top + r.height * .17)),
      _PreviewLabel('2', Offset(r.left + r.width * .17, r.top + r.height * .08)),
      _PreviewLabel('3', Offset(r.left + r.width * .08, r.top + r.height * .17)),
      _PreviewLabel('4', Offset(r.left + r.width * .17, r.center.dy)),
      _PreviewLabel('5', Offset(r.left + r.width * .08, r.bottom - r.height * .17)),
      _PreviewLabel('6', Offset(r.left + r.width * .17, r.bottom - r.height * .08)),
      _PreviewLabel('7', Offset(r.center.dx, r.bottom - r.height * .17)),
      _PreviewLabel('8', Offset(r.right - r.width * .17, r.bottom - r.height * .08)),
      _PreviewLabel('9', Offset(r.right - r.width * .08, r.bottom - r.height * .17)),
      _PreviewLabel('10', Offset(r.right - r.width * .17, r.center.dy)),
      _PreviewLabel('11', Offset(r.right - r.width * .08, r.top + r.height * .17)),
      _PreviewLabel('12', Offset(r.right - r.width * .17, r.top + r.height * .08)),
    ];
    for (final label in labels) {
      _drawText(canvas, label.text, label.center, fontSize: 7.5);
    }
    _drawText(canvas, 'RASI', r.center, fontSize: 7.5, color: _accent);
  }

  void _drawText(
    Canvas canvas,
    String value,
    Offset center, {
    double fontSize = 8,
    Color color = _ink,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: value,
        style: TextStyle(
          fontSize: fontSize,
          color: color,
          fontWeight: FontWeight.w800,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout();
    painter.paint(canvas, center - Offset(painter.width / 2, painter.height / 2));
  }

  @override
  bool shouldRepaint(covariant _ChartPreviewPainter oldDelegate) => oldDelegate.style != style;
}

class _PreviewLabel {
  const _PreviewLabel(this.text, this.center);
  final String text;
  final Offset center;
}
