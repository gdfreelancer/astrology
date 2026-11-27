import 'package:flutter/material.dart';
import '../../l10n/app_locale.dart';
import '../../models/kundali/kundali_graha.dart';
import '../../services/gochar_service.dart';
import '../../services/yoga_dosha_analysis_service.dart';
import '../../services/ashtakavarga_service.dart';
import '../../services/vimshottari_dasha_service.dart';
import '../../theme/app_theme.dart';
import '../remedies/remedy_library_screen.dart';

class GocharYogasScreen extends StatefulWidget {
  const GocharYogasScreen({super.key,required this.chart,required this.siderealMoonLongitude,required this.birthDate});
  final KundaliChart chart;
  final double siderealMoonLongitude;
  final DateTime birthDate;
  @override State<GocharYogasScreen> createState()=>_GocharYogasScreenState();
}
class _GocharYogasScreenState extends State<GocharYogasScreen> {
  late DateTime _date;
  @override void initState(){super.initState();final now=DateTime.now();_date=DateTime(now.year,now.month,now.day,12);}
  GocharReport get _report=>GocharService.calculate(natalChart:widget.chart,date:_date);
  Future<void> _chooseDate() async {
    final picked=await showDatePicker(context:context,initialDate:_date,firstDate:DateTime(1900),lastDate:DateTime(2100));
    if(picked!=null)setState(()=>_date=DateTime(picked.year,picked.month,picked.day,12));
  }
  @override Widget build(BuildContext context) {
    final report=_report;
    final yogaAssessments = YogaDoshaAnalysisService.analyse(widget.chart);
    final doshaAssessments = YogaDoshaAnalysisService.analyseDoshas(widget.chart);
    final saturn=report.transits.firstWhere((p)=>p.name=='Saturn');
    final ashtakavarga=AshtakavargaService.calculate(widget.chart);
    final dasha=VimshottariDashaService.calculate(siderealMoonLongitude:widget.siderealMoonLongitude,birthDate:widget.birthDate);
    final currentMaha=dasha.mahadashaAt(_date);
    final currentAntar=dasha.antardashaAt(_date);
    final phase=report.sadeSati.phase;
    final natalMoonSign=report.sadeSati.moonSignIndex;
    final natalLagnaSign=widget.chart.ascendantSignIndex;
    return Scaffold(
      appBar:AppBar(title:Text(context.tr('gochar_yogas'))),
      body:SafeArea(child:ListView(padding:const EdgeInsets.fromLTRB(18,8,18,28),children:[
        Container(padding:const EdgeInsets.all(16),decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(18),border:Border.all(color:const Color(0xFFEAE5EF))),child:Row(children:[
          const Icon(Icons.calendar_month_rounded,color:AppTheme.plum),const SizedBox(width:10),
          Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(context.tr('transit_date'),style:const TextStyle(fontSize:10,color:AppTheme.muted)),Text('${_date.day.toString().padLeft(2,'0')}/${_date.month.toString().padLeft(2,'0')}/${_date.year}',style:const TextStyle(fontSize:15,fontWeight:FontWeight.w800,color:AppTheme.ink))])),
          TextButton(onPressed:_chooseDate,child:Text(context.tr('change_date')))
        ])),
        const SizedBox(height:14),
        Container(padding:const EdgeInsets.all(14),decoration:BoxDecoration(color:const Color(0xFFF2EDF8),borderRadius:BorderRadius.circular(15)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
          const Text('Dasha + Gochar context',style:TextStyle(fontSize:12,fontWeight:FontWeight.w900,color:AppTheme.plum)),
          const SizedBox(height:6),
          Text('Mahadasha: ${currentMaha?.planet??'Not available'}',style:const TextStyle(fontSize:11,fontWeight:FontWeight.w800,color:AppTheme.ink)),
          Text('Antardasha: ${currentAntar?.planet??'Not available'}',style:const TextStyle(fontSize:10,color:AppTheme.muted)),
          const SizedBox(height:4),
          const Text('Use the running Dasha together with transit positions and Ashtakavarga support; this screen does not generate event predictions.',style:TextStyle(fontSize:9.5,height:1.4,color:AppTheme.muted)),
        ])),
        const SizedBox(height:16),
        Text(context.tr('transit_positions'),style:const TextStyle(fontSize:15,fontWeight:FontWeight.w800,color:AppTheme.ink)),
        const SizedBox(height:8),
        Container(decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(16),border:Border.all(color:const Color(0xFFEAE5EF))),child:Column(children:[
          for(var i=0;i<report.transits.length;i++) ...[
            if(i>0)const Divider(height:1,indent:14,endIndent:14,color:Color(0xFFF0ECF3)),
            Padding(padding:const EdgeInsets.symmetric(horizontal:14,vertical:11),child:Row(children:[
              SizedBox(width:34,child:Text(report.transits[i].symbol,style:const TextStyle(fontWeight:FontWeight.w900,color:AppTheme.plum))),
              Expanded(child:Text(context.tr('planet_${report.transits[i].name.toLowerCase()}'),style:const TextStyle(fontSize:12,fontWeight:FontWeight.w700,color:AppTheme.ink))),
              Column(crossAxisAlignment:CrossAxisAlignment.end,children:[
                Text('${context.tr(_rashiKey(report.transits[i].signIndex))} · ${report.transits[i].degreeInSign.toStringAsFixed(1)}°',style:const TextStyle(fontSize:10,color:AppTheme.muted)),
                Text('${context.tr('moon_house_short')} ${(report.transits[i].signIndex-natalMoonSign+12)%12+1}  ·  ${context.tr('lagna_house_short')} ${(report.transits[i].signIndex-natalLagnaSign+12)%12+1}',style:const TextStyle(fontSize:8,color:AppTheme.muted)),
                if(AshtakavargaService.planets.contains(report.transits[i].name)) Text('BAV ${ashtakavarga.bhinna[report.transits[i].name]![report.transits[i].signIndex]}/8 · SAV ${ashtakavarga.sarva[report.transits[i].signIndex]}',style:const TextStyle(fontSize:8,color:AppTheme.plum,fontWeight:FontWeight.w700)),
              ]),
              if(report.transits[i].isRetrograde)const Padding(padding:EdgeInsets.only(left:5),child:Text('℞',style:TextStyle(color:Color(0xFFB56A32),fontWeight:FontWeight.w900)))
            ]))
          ]
        ])),
        const SizedBox(height:18),
        if(report.sadeSati.isDhaiya) ...[
          Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(color: const Color(0xFFF3EEF8), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFEAE5EF))),
            child: Row(children: [
              const Icon(Icons.spa_outlined, color: AppTheme.plum),
              const SizedBox(width: 10),
              const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Shani Dhaiya reference', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.ink)),
                Text('Traditional three-phase table and remedies', style: TextStyle(fontSize: 10, color: AppTheme.muted)),
              ])),
              TextButton(onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(
                builder: (_) => const RemedyLibraryScreen(section: RemedyLibrarySection.shani),
              )), child: const Text('View')),
            ]),
          ),
        ],
        Text(context.tr('sade_sati'),style:const TextStyle(fontSize:15,fontWeight:FontWeight.w800,color:AppTheme.ink)),
        const SizedBox(height:8),
        Container(padding:const EdgeInsets.all(15),decoration:BoxDecoration(color:phase==null?const Color(0xFFF5F2F8):const Color(0xFFFFF6E8),borderRadius:BorderRadius.circular(16),border:Border.all(color:phase==null?const Color(0xFFEAE5EF):const Color(0xFFF1E2C9))),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
          Text(context.tr(phase==null?'sade_sati_inactive':'sade_sati_active'),style:const TextStyle(fontSize:13,fontWeight:FontWeight.w900,color:AppTheme.ink)),
          const SizedBox(height:5),
          Text(context.tr(phase==null?'sade_sati_inactive_desc':'sade_sati_phase_$phase'),style:const TextStyle(fontSize:11,height:1.45,color:AppTheme.muted)),
          const SizedBox(height:8),
          Text('${context.tr('natal_moon')}: ${context.tr(_rashiKey(report.sadeSati.moonSignIndex))}  ·  ${context.tr('transit_saturn')}: ${context.tr(_rashiKey(saturn.signIndex))}',style:const TextStyle(fontSize:10,fontWeight:FontWeight.w700,color:AppTheme.plum))
        ])),
        const SizedBox(height:12),
        Text('Saturn Dhaiya',style:const TextStyle(fontSize:15,fontWeight:FontWeight.w800,color:AppTheme.ink)),
        const SizedBox(height:8),
        Container(padding:const EdgeInsets.all(14),decoration:BoxDecoration(color:report.sadeSati.isDhaiya?const Color(0xFFFFF6E8):Colors.white,borderRadius:BorderRadius.circular(15),border:Border.all(color:const Color(0xFFEAE5EF))),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
          Text(report.sadeSati.isDhaiya?'Dhaiya indicator present':'No Dhaiya indicator on selected date',style:const TextStyle(fontSize:12,fontWeight:FontWeight.w800,color:AppTheme.ink)),
          const SizedBox(height:4),
          Text(report.sadeSati.dhaiyaHouse==null?'Saturn is not in the 4th or 8th sign from the natal Moon on this date.':'Saturn is in the ${report.sadeSati.dhaiyaHouse}th sign from the natal Moon.',style:const TextStyle(fontSize:10,height:1.4,color:AppTheme.muted)),
          const SizedBox(height:5),
          const Text('This is a sign-based traditional indicator, not a prediction or a full Saturn transit timeline.',style:TextStyle(fontSize:9.5,color:AppTheme.muted)),
        ])),
        const SizedBox(height:18),
        Text(context.tr('detected_yogas'),style:const TextStyle(fontSize:15,fontWeight:FontWeight.w800,color:AppTheme.ink)),
        const SizedBox(height:8),
        if(report.yogas.isEmpty)Container(padding:const EdgeInsets.all(15),decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(15),border:Border.all(color:const Color(0xFFEAE5EF))),child:Text(context.tr('no_supported_yogas'),style:const TextStyle(fontSize:11,color:AppTheme.muted)))
        else for(final yoga in report.yogas)Container(margin:const EdgeInsets.only(bottom:8),padding:const EdgeInsets.all(14),decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(15),border:Border.all(color:const Color(0xFFEAE5EF))),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
          Text(context.tr('yoga_${yoga.key}'),style:const TextStyle(fontSize:12,fontWeight:FontWeight.w900,color:AppTheme.ink)),
          const SizedBox(height:4),Text(context.tr(yoga.descriptionKey),style:const TextStyle(fontSize:10,height:1.45,color:AppTheme.muted)),
          const SizedBox(height:5),Text(yoga.planetNames.map((p)=>context.tr('planet_${p.toLowerCase()}')).join(' · '),style:const TextStyle(fontSize:10,fontWeight:FontWeight.w700,color:AppTheme.plum))
        ])),
        const SizedBox(height:18),
        Text(context.tr('yoga_assessment'),style:const TextStyle(fontSize:15,fontWeight:FontWeight.w800,color:AppTheme.ink)),
        const SizedBox(height:8),
        if(yogaAssessments.isEmpty)
          Container(padding:const EdgeInsets.all(14),decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(14),border:Border.all(color:const Color(0xFFEAE5EF))),child:Text(context.tr('no_yoga_assessments'),style:const TextStyle(fontSize:10,color:AppTheme.muted)))
        else
          for(final assessment in yogaAssessments)
            Container(margin:const EdgeInsets.only(bottom:8),padding:const EdgeInsets.all(13),decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(14),border:Border.all(color:const Color(0xFFEAE5EF))),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
              Row(children:[Expanded(child:Text(context.tr('yoga_name_${assessment.key}'),style:const TextStyle(fontSize:11,fontWeight:FontWeight.w900,color:AppTheme.ink))),Text(context.tr(assessment.status==YogaStatus.formed?'yoga_status_formed':assessment.status==YogaStatus.modified?'yoga_status_modified':'yoga_status_weakened'),style:const TextStyle(fontSize:9,fontWeight:FontWeight.w800,color:AppTheme.plum))]),
              const SizedBox(height:5),
              Text(context.tr(assessment.formation),style:const TextStyle(fontSize:10,height:1.4,color:AppTheme.muted)),
              if(assessment.modifiers.isNotEmpty) ...[
                const SizedBox(height:5),
                Text(assessment.modifiers.map((m) => context.tr('yoga_modifier_${m.toLowerCase().replaceAll(' ', '_').replaceAll('-', '_')}')).join(' · '),style:const TextStyle(fontSize:9,height:1.4,color:Color(0xFF9A6836))),
              ],
              const SizedBox(height:5),
              Text(assessment.planetNames.map((p)=>context.tr('planet_${p.toLowerCase()}')).join(' · '),style:const TextStyle(fontSize:9,fontWeight:FontWeight.w700,color:AppTheme.plum)),
            ])),
        const SizedBox(height:18),
        Text(context.tr('dosha_screening_title'),style:const TextStyle(fontSize:15,fontWeight:FontWeight.w800,color:AppTheme.ink)),
        const SizedBox(height:8),
        if(doshaAssessments.isEmpty)
          Container(padding:const EdgeInsets.all(14),decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(14),border:Border.all(color:const Color(0xFFEAE5EF))),child:Text(context.tr('dosha_none_detected'),style:const TextStyle(fontSize:10,color:AppTheme.muted)))
        else
          for(final dosha in doshaAssessments)
            Container(margin:const EdgeInsets.only(bottom:8),padding:const EdgeInsets.all(13),decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(14),border:Border.all(color:const Color(0xFFEAE5EF))),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
              Text(context.tr('dosha_name_${dosha.key}'),style:const TextStyle(fontSize:11,fontWeight:FontWeight.w900,color:AppTheme.ink)),
              const SizedBox(height:5),
              Text(context.tr(dosha.formation),style:const TextStyle(fontSize:10,height:1.4,color:AppTheme.muted)),
              if(dosha.bases.isNotEmpty) Text('${context.tr('dosha_reference_from')}: ${dosha.bases.map((b)=>context.tr('dosha_basis_${b.toLowerCase()}')).join(' · ')}',style:const TextStyle(fontSize:9,color:AppTheme.plum)),
              if(dosha.mitigationIndicators.isNotEmpty) Text('${context.tr('dosha_mitigation_review')}: ${dosha.mitigationIndicators.map((m)=>context.tr(m)).join(' · ')}',style:const TextStyle(fontSize:9,color:Color(0xFF9A6836))),
              Text(dosha.planetNames.map((p)=>context.tr('planet_${p.toLowerCase()}')).join(' · '),style:const TextStyle(fontSize:9,fontWeight:FontWeight.w700,color:AppTheme.plum)),
              const SizedBox(height:4),Text(context.tr(dosha.caveat),style:const TextStyle(fontSize:9,height:1.4,color:AppTheme.muted)),
            ])),
        const SizedBox(height:10),
        Container(padding:const EdgeInsets.all(13),decoration:BoxDecoration(color:const Color(0xFFF3EEF8),borderRadius:BorderRadius.circular(14)),child:Text(context.tr('yoga_assessment_disclaimer'),style:const TextStyle(fontSize:9.5,height:1.5,color:AppTheme.muted))),
        const SizedBox(height:10),
        Container(padding:const EdgeInsets.all(13),decoration:BoxDecoration(color:const Color(0xFFFFF6E8),borderRadius:BorderRadius.circular(14)),child:Text(context.tr('gochar_accuracy_note'),style:const TextStyle(fontSize:10,height:1.5,color:Color(0xFF795D36))))
      ]))
    );
  }
  String _rashiKey(int i)=>const ['p_mesha','p_vrishabha','p_mithuna','p_karka','p_simha','p_kanya','p_tula','p_vrishchika','p_dhanu','p_makara','p_kumbha','p_meena'][i];
}
