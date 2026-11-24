import 'package:flutter/material.dart';

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
        const SnackBar(content: Text('Could not save your chart preference. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose chart style', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
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
                  Text('Your Kundali, your tradition', style: TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w800)),
                  SizedBox(height: 7),
                  Text(
                    'Choose how you want your birth chart to look. We will remember this choice and use it automatically for your future Kundalis.',
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
                    : const Text('Save preference & continue  →', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
              ),
            ),
            const SizedBox(height: 9),
            const Text(
              'You can change this preference any time before creating a Kundali.',
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
              SizedBox(width: 88, height: 88, child: _ChartStylePreview(style: style)),
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

class _ChartPreviewPainter extends CustomPainter {
  _ChartPreviewPainter(this.style);
  final KundaliChartStyle style;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final fill = Paint()..color = const Color(0xFFFFF8EC);
    final line = Paint()
      ..color = const Color(0xFFB98B4C)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawRRect(RRect.fromRectAndRadius(rect.deflate(1), const Radius.circular(7)), fill);
    canvas.drawRRect(RRect.fromRectAndRadius(rect.deflate(1), const Radius.circular(7)), line);
    final w = size.width;
    final h = size.height;
    if (style == KundaliChartStyle.northIndian) {
      final path = Path()
        ..moveTo(w / 2, 2)..lineTo(w - 2, h / 2)..lineTo(w / 2, h - 2)..lineTo(2, h / 2)..close()
        ..moveTo(2, 2)..lineTo(w - 2, h - 2)
        ..moveTo(w - 2, 2)..lineTo(2, h - 2)
        ..moveTo(w / 2, 2)..lineTo(2, h / 2)
        ..moveTo(w / 2, 2)..lineTo(w - 2, h / 2)
        ..moveTo(2, h / 2)..lineTo(w / 2, h - 2)
        ..moveTo(w - 2, h / 2)..lineTo(w / 2, h - 2);
      canvas.drawPath(path, line);
    } else {
      final cellW = w / 4;
      final cellH = h / 4;
      for (var i = 1; i < 4; i++) {
        canvas.drawLine(Offset(cellW * i, 0), Offset(cellW * i, h), line);
        canvas.drawLine(Offset(0, cellH * i), Offset(w, cellH * i), line);
      }
      if (style == KundaliChartStyle.eastIndian) {
        canvas.drawLine(Offset.zero, Offset(w, h), line);
        canvas.drawLine(Offset(w, 0), Offset(0, h), line);
      }
    }
    final text = TextPainter(
      text: TextSpan(text: style == KundaliChartStyle.northIndian ? 'L' : 'R', style: const TextStyle(fontSize: 12, color: AppTheme.plum, fontWeight: FontWeight.w800)),
      textDirection: TextDirection.ltr,
    )..layout();
    text.paint(canvas, Offset((w - text.width) / 2, (h - text.height) / 2));
  }

  @override
  bool shouldRepaint(covariant _ChartPreviewPainter oldDelegate) => oldDelegate.style != style;
}
