import 'package:flutter/material.dart';

import '../../l10n/app_locale.dart';
import 'package:timezone/data/latest.dart' as timezone_data;

import '../../models/birth_chart_result.dart';
import '../../services/matching/matching_database_service.dart';
import '../../services/matching/matching_service.dart';
import '../../theme/app_theme.dart';
import 'matching_person_form.dart';
import 'matching_result_screen.dart';

class MatchingDetailsScreen extends StatefulWidget {
  const MatchingDetailsScreen({super.key});

  @override
  State<MatchingDetailsScreen> createState() => _MatchingDetailsScreenState();
}

class _MatchingDetailsScreenState extends State<MatchingDetailsScreen> {
  final _brideKey = GlobalKey<MatchingPersonFormState>();
  final _groomKey = GlobalKey<MatchingPersonFormState>();
  bool _calculating = false;

  @override
  void initState() {
    super.initState();
    timezone_data.initializeTimeZones();
  }

  Future<void> _calculate() async {
    if (_calculating) return;
    setState(() => _calculating = true);
    try {
      final BirthChartResult? bride = await _brideKey.currentState!.calculate();
      if (!mounted) return;
      if (bride == null) return;
      final BirthChartResult? groom = await _groomKey.currentState!.calculate();
      if (!mounted || groom == null) return;

      final report = MatchingService.calculate(
        brideName: _brideKey.currentState!.name,
        bride: bride,
        groomName: _groomKey.currentState!.name,
        groom: groom,
      );
      final id = await MatchingDatabaseService.instance.save(report);
      if (!mounted) return;
      await Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (_) => MatchingResultScreen(report: report, reportId: id),
      ));
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(context.tr('matching_calculation_error')),
          behavior: SnackBarBehavior.floating,
        ));
      }
    } finally {
      if (mounted) setState(() => _calculating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('new_matching'), style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800))),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(21),
                gradient: const LinearGradient(colors: [Color(0xFF9A648E), Color(0xFF7255A5)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              ),
              child: Row(children: [
                Text('💞', style: TextStyle(fontSize: 38)),
                SizedBox(width: 13),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(context.tr('two_charts_comparison'), style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                  SizedBox(height: 5),
                  Text(context.tr('matching_birth_details_help'), style: TextStyle(color: Color(0xFFF3E8F1), fontSize: 10, height: 1.5)),
                ])),
              ]),
            ),
            const SizedBox(height: 20),
            Row(children: [
              Expanded(child: Text(context.tr('bride_details'), style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.ink))),
              Text('01 / 02', style: TextStyle(fontSize: 10, color: AppTheme.muted, fontWeight: FontWeight.w700)),
            ]),
            const SizedBox(height: 10),
            MatchingPersonForm(key: _brideKey, role: 'Bride', accent: const Color(0xFFB45D82)),
            const SizedBox(height: 19),
            Row(children: [
              Expanded(child: Text(context.tr('groom_details'), style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.ink))),
              Text('02 / 02', style: TextStyle(fontSize: 10, color: AppTheme.muted, fontWeight: FontWeight.w700)),
            ]),
            const SizedBox(height: 10),
            MatchingPersonForm(key: _groomKey, role: 'Groom', accent: AppTheme.plum),
            const SizedBox(height: 19),
            Container(
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(color: const Color(0xFFFFF6E8), borderRadius: BorderRadius.circular(15), border: Border.all(color: const Color(0xFFF1E2C9))),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Icon(Icons.info_outline_rounded, color: Color(0xFF9C7138), size: 17),
                SizedBox(width: 8),
                Expanded(child: Text(context.tr('matching_method_note'), style: TextStyle(fontSize: 10, height: 1.5, color: Color(0xFF795D36)))),
              ]),
            ),
            const SizedBox(height: 18),
            SizedBox(
              height: 54,
              child: FilledButton(
                onPressed: _calculating ? null : _calculate,
                style: FilledButton.styleFrom(backgroundColor: AppTheme.plum, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                child: _calculating
                    ? const SizedBox(width: 21, height: 21, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text(context.tr('calculate_36_gunas'), style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
