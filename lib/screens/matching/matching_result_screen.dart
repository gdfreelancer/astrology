import 'package:flutter/material.dart';

import '../../l10n/app_locale.dart';
import 'package:flutter/services.dart';

import '../../models/matching/koota_result.dart';
import '../../models/matching/matching_report.dart';
import '../../models/matching/matching_person.dart';
import '../../models/kundali/kundali_graha.dart';
import '../../theme/app_theme.dart';
import '../../services/matching/advanced_matching_service.dart';


String _matchingRashi(int index) {
  const keys = ['p_mesha','p_vrishabha','p_mithuna','p_karka','p_simha','p_kanya','p_tula','p_vrishchika','p_dhanu','p_makara','p_kumbha','p_meena'];
  return AppLocale.text(keys[index]);
}
String _matchingGraha(String name) {
  const keys = {'Sun':'planet_sun','Moon':'planet_moon','Mars':'planet_mars','Mercury':'planet_mercury','Jupiter':'planet_jupiter','Venus':'planet_venus','Saturn':'planet_saturn','Rahu':'planet_rahu','Ketu':'planet_ketu'};
  final key = keys[name];
  return key == null ? name : AppLocale.text(key);
}
String _matchingValue(BuildContext context, String value) {
  const keys = {
    'Brahmin':'match_brahmin','Kshatriya':'match_kshatriya','Vaishya':'match_vaishya','Shudra':'match_shudra',
    'Chatushpada':'match_chatushpada','Manava':'match_manava','Jalachara':'match_jalachara','Vanachara':'match_vanachara','Keeta':'match_keeta',
    'Deva':'match_deva','Manushya':'match_manushya','Rakshasa':'match_rakshasa','Adi':'match_adi','Madhya':'match_madhya','Antya':'match_antya',
    'Horse':'match_horse','Elephant':'match_elephant','Sheep':'match_sheep','Serpent':'match_serpent','Dog':'match_dog','Cat':'match_cat','Rat':'match_rat','Cow':'match_cow','Buffalo':'match_buffalo','Tiger':'match_tiger','Deer':'match_deer','Monkey':'match_monkey','Mongoose':'match_mongoose','Lion':'match_lion'
  };
  final key = keys[value];
  return key == null ? value : context.tr(key);
}

String _localizedAstroName(String value) {
  final slug = value.split(' (').first.toLowerCase().replaceAll(RegExp('[^a-z0-9]+'), '_');
  final key = 'p_' + slug;
  final translated = AppLocale.text(key);
  return translated == key ? value : translated;
}
class MatchingResultScreen extends StatelessWidget {
  const MatchingResultScreen({super.key, required this.report, this.reportId});

  final MatchingReport report;
  final int? reportId;

  String _interpretation(BuildContext context) {
    final score = report.totalPoints;
    if (score < 18) return context.tr('score_below');
    if (score < 25) return context.tr('score_moderate');
    if (score < 33) return context.tr('score_good');
    return context.tr('score_high');
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
      ..writeln(_interpretation(context))
      ..writeln();
    for (final item in report.kootas) {
      text.writeln('${item.name}: ${item.points.toStringAsFixed(1)} / ${item.maxPoints.toStringAsFixed(0)}');
    }
    text.writeln('\nTraditional astrology reference only; not a scientific assessment or prediction of relationship success.');
    await Clipboard.setData(ClipboardData(text: text.toString()));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.tr('matching_summary_copied')), behavior: SnackBarBehavior.floating));
    }
  }

  @override
  Widget build(BuildContext context) {
    final score = report.totalPoints;
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('matching_report'), style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
        actions: [
          IconButton(onPressed: () => _copySummary(context), tooltip: context.tr('copy_summary'), icon: const Icon(Icons.copy_rounded, color: AppTheme.plum)),
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
                Text(context.tr('ashtakoota_guna_milan'), style: TextStyle(color: Color(0xFFF3E8F1), fontSize: 9, letterSpacing: 1.6, fontWeight: FontWeight.w800)),
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
                      Text(context.tr('out_of_36'), style: TextStyle(color: Color(0xFFEDE5F8), fontSize: 9, letterSpacing: 1.2, fontWeight: FontWeight.w700)),
                    ]),
                  ]),
                ),
                const SizedBox(height: 13),
                Text(_interpretation(context), textAlign: TextAlign.center, style: TextStyle(color: _scoreColor == const Color(0xFF438466) ? const Color(0xFFDDF4E7) : const Color(0xFFFFE3A8), fontSize: 12, fontWeight: FontWeight.w800)),
                const SizedBox(height: 5),
                Text(context.tr('traditional_score_note'), textAlign: TextAlign.center, style: TextStyle(color: Color(0xFFEDE5F8), fontSize: 9)),
              ]),
            ),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: _PersonCard(role: context.tr('bride_details'), person: report.bride, accent: const Color(0xFFB45D82))),
              const SizedBox(width: 10),
              Expanded(child: _PersonCard(role: context.tr('groom_details'), person: report.groom, accent: AppTheme.plum)),
            ]),
            const SizedBox(height: 20),
            Text(context.tr('birth_charts_planetary_placements'), style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.ink)),
            const SizedBox(height: 5),
            Text(context.tr('review_d1_charts'), style: TextStyle(fontSize: 10, color: AppTheme.muted)),
            const SizedBox(height: 10),
            _PersonBirthChart(person: report.bride, accent: const Color(0xFFB45D82)),
            const SizedBox(height: 9),
            _PersonBirthChart(person: report.groom, accent: AppTheme.plum),
            const SizedBox(height: 21),
            Row(children: [
              Expanded(child: Text(context.tr('eight_koota_breakdown'), style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.ink))),
              Text('${report.kootas.length} ${context.tr('categories')}', style: const TextStyle(fontSize: 10, color: AppTheme.muted)),
            ]),
            const SizedBox(height: 10),
            ...report.kootas.map((item) => _KootaTile(item: item)),
            const SizedBox(height: 18),
            _AdvancedCompatibilitySection(report: report),
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(color: const Color(0xFFFFF6E8), borderRadius: BorderRadius.circular(17), border: Border.all(color: const Color(0xFFF1E2C9))),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [const Icon(Icons.info_outline_rounded, color: Color(0xFF9C7138), size: 17), const SizedBox(width: 7), Text(context.tr('what_report_covers'), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF795D36)))]),
                SizedBox(height: 8),
                Text(context.tr('matching_report_scope'), style: TextStyle(fontSize: 10, height: 1.55, color: Color(0xFF795D36))),
              ]),
            ),
            if (report.bride.nearBoundary || report.groom.nearBoundary) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(color: const Color(0xFFFFEEEE), borderRadius: BorderRadius.circular(14)),
                child: Text(context.tr('matching_boundary_warning'), style: TextStyle(color: Color(0xFF9C4545), fontSize: 10, height: 1.5)),
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
      Text('${person.rashiSymbol}  ${_localizedAstroName(person.rashi)}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppTheme.ink, fontSize: 10, fontWeight: FontWeight.w700)),
      const SizedBox(height: 4),
      Text('${_localizedAstroName(person.nakshatra)} · ${context.tr('pada')} ${person.pada}', maxLines: 2, style: const TextStyle(color: AppTheme.muted, fontSize: 9)),
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
            Expanded(child: Text(context.tr('koota_${item.key}_name'), style: const TextStyle(color: AppTheme.ink, fontSize: 12, fontWeight: FontWeight.w800))),
            Text('${item.points.toStringAsFixed(item.points % 1 == 0 ? 0 : 1)} / ${item.maxPoints.toStringAsFixed(0)}', style: const TextStyle(color: AppTheme.plum, fontSize: 11, fontWeight: FontWeight.w800)),
          ]),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 7, right: 8),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              ClipRRect(borderRadius: BorderRadius.circular(5), child: LinearProgressIndicator(value: ratio, minHeight: 5, backgroundColor: const Color(0xFFF0ECF3), color: ratio >= .75 ? const Color(0xFF5B9877) : ratio >= .4 ? const Color(0xFFC18A3B) : const Color(0xFFB96B68))),
              const SizedBox(height: 6),
              Text(context.tr('koota_${item.key}_summary'), style: const TextStyle(color: AppTheme.muted, fontSize: 9)),
            ]),
          ),
          children: [
            Row(children: [
              Expanded(child: _ValueBox(label: context.tr('bride_details'), value: _matchingValue(context, item.brideValue))),
              const SizedBox(width: 8),
              Expanded(child: _ValueBox(label: context.tr('groom_details'), value: _matchingValue(context, item.groomValue))),
            ]),
            const SizedBox(height: 10),
            Align(alignment: Alignment.centerLeft, child: Text(context.tr('koota_${item.key}_explanation'), style: const TextStyle(color: AppTheme.muted, fontSize: 10, height: 1.5))),
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

class _PersonBirthChart extends StatelessWidget {
  const _PersonBirthChart({required this.person, required this.accent});
  final MatchingPerson person;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final chart = person.kundaliChart;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withValues(alpha: .24)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: false,
          tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
          childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 13),
          leading: Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: accent.withValues(alpha: .1), borderRadius: BorderRadius.circular(10)),
            child: Icon(Icons.auto_awesome_rounded, color: accent, size: 18),
          ),
          title: Text('${person.role}: ${person.name}', style: const TextStyle(fontSize: 12, color: AppTheme.ink, fontWeight: FontWeight.w800)),
          subtitle: Text(chart == null ? context.tr('birth_chart_unavailable') : '${context.tr('lagna')}: ${_matchingRashi(chart.ascendantSignIndex)} · ${_matchingDegree(chart.ascendantLongitude)}', style: const TextStyle(fontSize: 9, color: AppTheme.muted)),
          children: [
            if (chart == null)
              Padding(
                padding: const EdgeInsets.all(10),
                child: Text(context.tr('old_report_chart_notice'), style: TextStyle(fontSize: 10, color: AppTheme.muted)),
              )
            else ...[
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 12,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 5,
                  mainAxisSpacing: 5,
                  childAspectRatio: 1.15,
                ),
                itemBuilder: (context, index) {
                  final house = index + 1;
                  final sign = (chart.ascendantSignIndex + index) % 12;
                  final occupants = chart.inHouse(house);
                  return Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: house == 1 ? accent.withValues(alpha: .09) : const Color(0xFFFFF9F0),
                      borderRadius: BorderRadius.circular(9),
                      border: Border.all(color: house == 1 ? accent.withValues(alpha: .65) : const Color(0xFFECE3D7)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(context.tr('house_number').replaceAll('{n}', '$house'), style: const TextStyle(fontSize: 7, color: AppTheme.muted, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 2),
                        Text('${kundaliRashiSymbols[sign]} ${_matchingRashi(sign)}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 8, color: AppTheme.ink, fontWeight: FontWeight.w800)),
                        const Spacer(),
                        Text(occupants.isEmpty ? '—' : occupants.map((g) => g.symbol).join(' · '), maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 9, color: accent, fontWeight: FontWeight.w900)),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
              for (var i = 0; i < chart.grahas.length; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    children: [
                      SizedBox(width: 28, child: Text(chart.grahas[i].symbol, style: TextStyle(fontSize: 10, color: accent, fontWeight: FontWeight.w900))),
                      Expanded(child: Text(_matchingGraha(chart.grahas[i].name), style: const TextStyle(fontSize: 10, color: AppTheme.ink, fontWeight: FontWeight.w700))),
                      Expanded(child: Text(_matchingRashi(chart.grahas[i].signIndex), style: const TextStyle(fontSize: 9, color: AppTheme.muted))),
                      Text(context.tr('house_number').replaceAll('{n}', '${chart.grahas[i].houseNumber}'), style: TextStyle(fontSize: 9, color: accent, fontWeight: FontWeight.w800)),
                    ],
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

String _matchingDegree(double longitude) {
  final value = longitude % 30;
  final degrees = value.floor();
  final minutes = ((value - degrees) * 60).round();
  return '${degrees}° ${minutes.toString().padLeft(2, '0')}′';
}


class _AdvancedCompatibilitySection extends StatelessWidget {
  const _AdvancedCompatibilitySection({required this.report});
  final MatchingReport report;
  @override Widget build(BuildContext context) {
    final a=AdvancedMatchingService.calculate(bride:report.bride.kundaliChart,groom:report.groom.kundaliChart);
    return Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      Text(context.tr('advanced_compatibility'),style:const TextStyle(fontSize:15,fontWeight:FontWeight.w800,color:AppTheme.ink)),
      const SizedBox(height:5),Text(context.tr('advanced_compatibility_help'),style:const TextStyle(fontSize:10,color:AppTheme.muted,height:1.45)),
      const SizedBox(height:10),
      _AdvancedPersonCard(name:report.bride.name,assessment:a.brideManglik,profile:a.brideSeventhHouse),
      const SizedBox(height:8),
      _AdvancedPersonCard(name:report.groom.name,assessment:a.groomManglik,profile:a.groomSeventhHouse),
      const SizedBox(height:9),
      Container(padding:const EdgeInsets.all(12),decoration:BoxDecoration(color:const Color(0xFFFFF6E8),borderRadius:BorderRadius.circular(14)),child:Text(context.tr('advanced_compatibility_note'),style:const TextStyle(fontSize:9.5,height:1.5,color:Color(0xFF795D36))))
    ]);
  }
}
class _AdvancedPersonCard extends StatelessWidget {
  const _AdvancedPersonCard({required this.name,required this.assessment,required this.profile});
  final String name; final ManglikAssessment assessment; final HouseCompatibilityProfile profile;
  @override Widget build(BuildContext context){
    String status(bool? v)=>v==null?context.tr('not_available'):v?context.tr('indicator_present'):context.tr('indicator_not_present');
    String sign(int? v)=>v==null?'—':_matchingRashi(v);
    return Container(padding:const EdgeInsets.all(13),decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(15),border:Border.all(color:const Color(0xFFEAE5EF))),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      Text(name,style:const TextStyle(fontSize:12,fontWeight:FontWeight.w800,color:AppTheme.ink)),
      const SizedBox(height:9),Text(context.tr('manglik_dosha'),style:const TextStyle(fontSize:11,fontWeight:FontWeight.w800,color:AppTheme.plum)),
      _AnalysisLine(label:context.tr('from_lagna'),value:status(assessment.fromLagna)),
      _AnalysisLine(label:context.tr('from_moon'),value:status(assessment.fromMoon)),
      _AnalysisLine(label:context.tr('from_venus'),value:status(assessment.fromVenus)),
      if(assessment.marsHouseFromLagna!=null)_AnalysisLine(label:context.tr('mars_position'),value:'${context.tr('house')} ${assessment.marsHouseFromLagna} · ${sign(assessment.marsSignIndex)}'),
      const Divider(height:17,color:Color(0xFFF0ECF3)),
      Text(context.tr('seventh_house_profile'),style:const TextStyle(fontSize:11,fontWeight:FontWeight.w800,color:AppTheme.plum)),
      _AnalysisLine(label:context.tr('seventh_house_sign'),value:sign(profile.seventhHouseSign)),
      _AnalysisLine(label:context.tr('seventh_house_occupants'),value:profile.seventhHouseOccupants.isEmpty?context.tr('none_listed'):profile.seventhHouseOccupants.map(_matchingGraha).join(', ')),
      _AnalysisLine(label:context.tr('seventh_lord'),value:profile.seventhLord==null?'—':'${_matchingGraha(profile.seventhLord!)} · ${context.tr('house')} ${profile.seventhLordHouse??'—'}')
    ]));
  }
}
class _AnalysisLine extends StatelessWidget{
  const _AnalysisLine({required this.label,required this.value});
  final String label,value;
  @override Widget build(BuildContext context)=>Padding(padding:const EdgeInsets.symmetric(vertical:3),child:Row(crossAxisAlignment:CrossAxisAlignment.start,children:[
    Expanded(child:Text(label,style:const TextStyle(fontSize:9.5,color:AppTheme.muted))),const SizedBox(width:10),
    Flexible(child:Text(value,textAlign:TextAlign.end,style:const TextStyle(fontSize:9.5,fontWeight:FontWeight.w700,color:AppTheme.ink)))
  ]));
}
