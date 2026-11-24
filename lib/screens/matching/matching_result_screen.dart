import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/matching/koota_result.dart';
import '../../models/matching/matching_report.dart';
import '../../models/matching/matching_person.dart';
import '../../theme/app_theme.dart';

class MatchingResultScreen extends StatelessWidget {
  const MatchingResultScreen({super.key, required this.report, this.reportId});

  final MatchingReport report;
  final int? reportId;

  String get _interpretation {
    final score = report.totalPoints;
    if (score < 18) return 'Below the commonly used traditional threshold';
    if (score < 25) return 'Moderate traditional Guna Milan score';
    if (score < 33) return 'Good traditional Guna Milan score';
    return 'High traditional Guna Milan score';
  }

  Color get _scoreColor {
    if (report.totalPoints < 18) return const Color(0xFFB65D58);
    if (report.totalPoints < 25) return const Color(0xFFC18A3B);
    return const Color(0xFF438466);
  }

  Future<void> _copySummary(BuildContext context) async {
    final text = StringBuffer()
      ..writeln('Kundali Matching')
      ..writeln('${report.bride.name} & ${report.groom.name}')
      ..writeln('Ashtakoota score: ${report.totalPoints.toStringAsFixed(1)} / 36')
      ..writeln(_interpretation)
      ..writeln();
    for (final item in report.kootas) {
      text.writeln('${item.name}: ${item.points.toStringAsFixed(1)} / ${item.maxPoints.toStringAsFixed(0)}');
    }
    text.writeln('\nTraditional astrology reference only; not a scientific assessment or prediction of relationship success.');
    await Clipboard.setData(ClipboardData(text: text.toString()));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Matching summary copied.'), behavior: SnackBarBehavior.floating));
    }
  }

  @override
  Widget build(BuildContext context) {
    final score = report.totalPoints;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Matching report', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
        actions: [
          IconButton(onPressed: () => _copySummary(context), tooltip: 'Copy summary', icon: const Icon(Icons.copy_rounded, color: AppTheme.plum)),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(23),
                gradient: const LinearGradient(colors: [Color(0xFF9A648E), Color(0xFF7255A5)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              ),
              child: Column(children: [
                const Text('ASHTAKOOTA GUNA MILAN', style: TextStyle(color: Color(0xFFF3E8F1), fontSize: 9, letterSpacing: 1.6, fontWeight: FontWeight.w800)),
                const SizedBox(height: 14),
                SizedBox(
                  width: 148,
                  height: 148,
                  child: Stack(alignment: Alignment.center, children: [
                    SizedBox.expand(child: CircularProgressIndicator(
                      value: (score / 36).clamp(0, 1),
                      strokeWidth: 10,
                      strokeCap: StrokeCap.round,
                      backgroundColor: Colors.white.withValues(alpha: .2),
                      valueColor: const AlwaysStoppedAnimation(Color(0xFFFFE3A8)),
                    )),
                    Column(mainAxisSize: MainAxisSize.min, children: [
                      Text(score.toStringAsFixed(score % 1 == 0 ? 0 : 1), style: const TextStyle(color: Colors.white, fontSize: 35, fontWeight: FontWeight.w800, height: 1)),
                      const SizedBox(height: 4),
                      const Text('OUT OF 36', style: TextStyle(color: Color(0xFFEDE5F8), fontSize: 9, letterSpacing: 1.2, fontWeight: FontWeight.w700)),
                    ]),
                  ]),
                ),
                const SizedBox(height: 13),
                Text(_interpretation, textAlign: TextAlign.center, style: TextStyle(color: _scoreColor == const Color(0xFF438466) ? const Color(0xFFDDF4E7) : const Color(0xFFFFE3A8), fontSize: 12, fontWeight: FontWeight.w800)),
                const SizedBox(height: 5),
                const Text('Traditional score band, not a prediction of relationship success', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFFEDE5F8), fontSize: 9)),
              ]),
            ),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: _PersonCard(role: 'Bride', person: report.bride, accent: const Color(0xFFB45D82))),
              const SizedBox(width: 10),
              Expanded(child: _PersonCard(role: 'Groom', person: report.groom, accent: AppTheme.plum)),
            ]),
            const SizedBox(height: 21),
            Row(children: [
              const Expanded(child: Text('Eight Koota breakdown', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.ink))),
              Text('${report.kootas.length} categories', style: const TextStyle(fontSize: 10, color: AppTheme.muted)),
            ]),
            const SizedBox(height: 10),
            ...report.kootas.map((item) => _KootaTile(item: item)),
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(color: const Color(0xFFFFF6E8), borderRadius: BorderRadius.circular(17), border: Border.all(color: const Color(0xFFF1E2C9))),
              child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [Icon(Icons.info_outline_rounded, color: Color(0xFF9C7138), size: 17), SizedBox(width: 7), Text('What this report covers', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF795D36)))]),
                SizedBox(height: 8),
                Text('This report calculates the eight Ashtakoota categories using Moon sign and Nakshatra data. The scoring uses a documented baseline table; regional traditions can differ. It does not calculate Manglik Dosha, planetary aspects, Lagna compatibility or Dosha cancellation because a validated full planetary chart engine is not yet available.', style: TextStyle(fontSize: 10, height: 1.55, color: Color(0xFF795D36))),
              ]),
            ),
            if (report.bride.nearBoundary || report.groom.nearBoundary) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(color: const Color(0xFFFFEEEE), borderRadius: BorderRadius.circular(14)),
                child: const Text('One or both Moon positions are close to a Nakshatra or Pada boundary. Small birth-time or ephemeris differences may change the matching result. Verify both birth details independently.', style: TextStyle(color: Color(0xFF9C4545), fontSize: 10, height: 1.5)),
              ),
            ],
            const SizedBox(height: 13),
            Text('Calculation version: ${report.calculationVersion} · ${report.createdAt.toLocal().toString().substring(0, 16)}', textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.muted, fontSize: 9)),
          ],
        ),
      ),
    );
  }
}

class _PersonCard extends StatelessWidget {
  const _PersonCard({required this.role, required this.person, required this.accent});
  final String role;
  final MatchingPerson person;
  final Color accent;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(17), border: Border.all(color: accent.withValues(alpha: .25))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(role.toUpperCase(), style: TextStyle(color: accent, fontSize: 8, letterSpacing: 1.1, fontWeight: FontWeight.w800)),
      const SizedBox(height: 5),
      Text(person.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppTheme.ink, fontSize: 12, fontWeight: FontWeight.w800)),
      const SizedBox(height: 8),
      Text('${person.rashiSymbol}  ${person.rashi}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppTheme.ink, fontSize: 10, fontWeight: FontWeight.w700)),
      const SizedBox(height: 4),
      Text('${person.nakshatra} · Pada ${person.pada}', maxLines: 2, style: const TextStyle(color: AppTheme.muted, fontSize: 9)),
    ]),
  );
}

class _KootaTile extends StatelessWidget {
  const _KootaTile({required this.item});
  final KootaResult item;

  @override
  Widget build(BuildContext context) {
    final ratio = item.maxPoints == 0 ? 0.0 : item.points / item.maxPoints;
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFEAE5EF))),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent, splashColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
          childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          title: Row(children: [
            Expanded(child: Text(item.name, style: const TextStyle(color: AppTheme.ink, fontSize: 12, fontWeight: FontWeight.w800))),
            Text('${item.points.toStringAsFixed(item.points % 1 == 0 ? 0 : 1)} / ${item.maxPoints.toStringAsFixed(0)}', style: const TextStyle(color: AppTheme.plum, fontSize: 11, fontWeight: FontWeight.w800)),
          ]),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 7, right: 8),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              ClipRRect(borderRadius: BorderRadius.circular(5), child: LinearProgressIndicator(value: ratio, minHeight: 5, backgroundColor: const Color(0xFFF0ECF3), color: ratio >= .75 ? const Color(0xFF5B9877) : ratio >= .4 ? const Color(0xFFC18A3B) : const Color(0xFFB96B68))),
              const SizedBox(height: 6),
              Text(item.summary, style: const TextStyle(color: AppTheme.muted, fontSize: 9)),
            ]),
          ),
          children: [
            Row(children: [
              Expanded(child: _ValueBox(label: 'Bride', value: item.brideValue)),
              const SizedBox(width: 8),
              Expanded(child: _ValueBox(label: 'Groom', value: item.groomValue)),
            ]),
            const SizedBox(height: 10),
            Align(alignment: Alignment.centerLeft, child: Text(item.explanation, style: const TextStyle(color: AppTheme.muted, fontSize: 10, height: 1.5))),
          ],
        ),
      ),
    );
  }
}

class _ValueBox extends StatelessWidget {
  const _ValueBox({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(9),
    decoration: BoxDecoration(color: const Color(0xFFF9F6FB), borderRadius: BorderRadius.circular(10)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(color: AppTheme.muted, fontSize: 8)),
      const SizedBox(height: 3),
      Text(value, style: const TextStyle(color: AppTheme.ink, fontSize: 10, fontWeight: FontWeight.w700)),
    ]),
  );
}
