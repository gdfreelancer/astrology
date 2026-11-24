import 'package:flutter/material.dart';

import '../../models/matching/matching_report.dart';
import '../../services/matching/matching_database_service.dart';
import '../../theme/app_theme.dart';
import 'matching_details_screen.dart';
import 'matching_result_screen.dart';

class MatchingHomeScreen extends StatefulWidget {
  const MatchingHomeScreen({super.key});

  @override
  State<MatchingHomeScreen> createState() => _MatchingHomeScreenState();
}

class _MatchingHomeScreenState extends State<MatchingHomeScreen> {
  List<MatchingReport> _reports = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final reports = await MatchingDatabaseService.instance.getRecent();
      if (mounted) setState(() { _reports = reports; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _newMatching() async {
    await Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const MatchingDetailsScreen()));
    if (mounted) _load();
  }

  Future<void> _delete(MatchingReport report) async {
    if (report.id == null) return;
    await MatchingDatabaseService.instance.delete(report.id!);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kundali Matching', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800))),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _load,
          color: AppTheme.plum,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            children: [
              Container(
                padding: const EdgeInsets.all(19),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(23),
                  gradient: const LinearGradient(colors: [Color(0xFF9A648E), Color(0xFF7255A5)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('💞', style: TextStyle(fontSize: 34)),
                  const SizedBox(height: 10),
                  const Text('Find your Guna Milan', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 6),
                  const Text('Compare two birth Nakshatras and Moon signs using the traditional Ashtakoota system of 36 Gunas.', style: TextStyle(color: Color(0xFFF3E8F1), fontSize: 11, height: 1.5)),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 47,
                    child: FilledButton.icon(
                      onPressed: _newMatching,
                      icon: const Icon(Icons.favorite_rounded, size: 17),
                      label: const Text('Start new matching', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                      style: FilledButton.styleFrom(backgroundColor: const Color(0xFFFFE3A8), foregroundColor: AppTheme.plum, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                    ),
                  ),
                ]),
              ),
              const SizedBox(height: 23),
              Row(children: [
                const Expanded(child: Text('Recent matching reports', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.ink))),
                Text('${_reports.length}', style: const TextStyle(color: AppTheme.muted, fontSize: 10, fontWeight: FontWeight.w700)),
              ]),
              const SizedBox(height: 11),
              if (_loading)
                const Padding(padding: EdgeInsets.all(30), child: Center(child: CircularProgressIndicator(color: AppTheme.plum)))
              else if (_reports.isEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 26),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFEAE5EF))),
                  child: const Column(children: [
                    Text('🪷', style: TextStyle(fontSize: 31)),
                    SizedBox(height: 8),
                    Text('No matching reports yet', style: TextStyle(color: AppTheme.ink, fontSize: 12, fontWeight: FontWeight.w800)),
                    SizedBox(height: 4),
                    Text('Your completed matching reports will appear here.', textAlign: TextAlign.center, style: TextStyle(color: AppTheme.muted, fontSize: 10)),
                  ]),
                )
              else
                ..._reports.map((report) => _ReportTile(report: report, onTap: () {
                  Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => MatchingResultScreen(report: report, reportId: report.id)));
                }, onDelete: () => _delete(report))),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: const Color(0xFFFFF6E8), borderRadius: BorderRadius.circular(15), border: Border.all(color: const Color(0xFFF1E2C9))),
                child: const Text('Traditional astrology is a cultural belief system. Guna Milan scores are not scientific measures and should not replace conversations, mutual respect or personal judgment when making relationship decisions.', style: TextStyle(color: Color(0xFF795D36), fontSize: 10, height: 1.5)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReportTile extends StatelessWidget {
  const _ReportTile({required this.report, required this.onTap, required this.onDelete});
  final MatchingReport report;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 9),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFEAE5EF))),
    child: ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 13, vertical: 5),
      leading: Container(width: 42, height: 42, decoration: BoxDecoration(color: const Color(0xFFFFEDEF), borderRadius: BorderRadius.circular(13)), child: const Center(child: Text('💞', style: TextStyle(fontSize: 20)))),
      title: Text('${report.bride.name} & ${report.groom.name}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppTheme.ink, fontSize: 11, fontWeight: FontWeight.w800)),
      subtitle: Text('${report.bride.nakshatra} · ${report.groom.nakshatra}', maxLines: 1, style: const TextStyle(color: AppTheme.muted, fontSize: 9)),
      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
        Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('${report.totalPoints.toStringAsFixed(report.totalPoints % 1 == 0 ? 0 : 1)}/36', style: const TextStyle(color: AppTheme.plum, fontSize: 12, fontWeight: FontWeight.w800)),
          Text('${report.createdAt.toLocal().day}/${report.createdAt.toLocal().month}/${report.createdAt.toLocal().year}', style: const TextStyle(color: AppTheme.muted, fontSize: 8)),
        ]),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert_rounded, color: AppTheme.muted, size: 19),
          onSelected: (value) { if (value == 'delete') onDelete(); },
          itemBuilder: (_) => const [PopupMenuItem(value: 'delete', child: Text('Delete report'))],
        ),
      ]),
    ),
  );
}
