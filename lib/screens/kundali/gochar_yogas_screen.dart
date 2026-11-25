import 'package:flutter/material.dart';
import '../../l10n/app_locale.dart';
import '../../models/kundali/kundali_graha.dart';
import '../../services/gochar_service.dart';
import '../../theme/app_theme.dart';

class GocharYogasScreen extends StatefulWidget {
  const GocharYogasScreen({super.key,required this.chart});
  final KundaliChart chart;
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
    final saturn=report.transits.firstWhere((p)=>p.name=='Saturn');
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
              ]),
              if(report.transits[i].isRetrograde)const Padding(padding:EdgeInsets.only(left:5),child:Text('℞',style:TextStyle(color:Color(0xFFB56A32),fontWeight:FontWeight.w900)))
            ]))
          ]
        ])),
        const SizedBox(height:18),
        Text(context.tr('sade_sati'),style:const TextStyle(fontSize:15,fontWeight:FontWeight.w800,color:AppTheme.ink)),
        const SizedBox(height:8),
        Container(padding:const EdgeInsets.all(15),decoration:BoxDecoration(color:phase==null?const Color(0xFFF5F2F8):const Color(0xFFFFF6E8),borderRadius:BorderRadius.circular(16),border:Border.all(color:phase==null?const Color(0xFFEAE5EF):const Color(0xFFF1E2C9))),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
          Text(context.tr(phase==null?'sade_sati_inactive':'sade_sati_active'),style:const TextStyle(fontSize:13,fontWeight:FontWeight.w900,color:AppTheme.ink)),
          const SizedBox(height:5),
          Text(context.tr(phase==null?'sade_sati_inactive_desc':'sade_sati_phase_$phase'),style:const TextStyle(fontSize:11,height:1.45,color:AppTheme.muted)),
          const SizedBox(height:8),
          Text('${context.tr('natal_moon')}: ${context.tr(_rashiKey(report.sadeSati.moonSignIndex))}  ·  ${context.tr('transit_saturn')}: ${context.tr(_rashiKey(saturn.signIndex))}',style:const TextStyle(fontSize:10,fontWeight:FontWeight.w700,color:AppTheme.plum))
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
        const SizedBox(height:10),
        Container(padding:const EdgeInsets.all(13),decoration:BoxDecoration(color:const Color(0xFFFFF6E8),borderRadius:BorderRadius.circular(14)),child:Text(context.tr('gochar_accuracy_note'),style:const TextStyle(fontSize:10,height:1.5,color:Color(0xFF795D36))))
      ]))
    );
  }
  String _rashiKey(int i)=>const ['p_mesha','p_vrishabha','p_mithuna','p_karka','p_simha','p_kanya','p_tula','p_vrishchika','p_dhanu','p_makara','p_kumbha','p_meena'][i];
}
