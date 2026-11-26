import 'package:flutter/material.dart';
import '../../models/kundali/kundali_graha.dart';
import '../../services/advanced_chart_analysis_service.dart';
import '../../theme/app_theme.dart';

class AdvancedChartAnalysisScreen extends StatelessWidget {
  const AdvancedChartAnalysisScreen({super.key,required this.chart});
  final KundaliChart chart;
  @override
  Widget build(BuildContext context) {
    final aspects=AdvancedChartAnalysisService.aspects(chart);
    final conditions=AdvancedChartAnalysisService.conditions(chart);
    final yogas=AdvancedChartAnalysisService.yogas(chart);
    return DefaultTabController(length:3,child:Scaffold(
      appBar:AppBar(title:const Text('Advanced chart analysis',style:TextStyle(fontSize:17,fontWeight:FontWeight.w800)),
        bottom:const TabBar(isScrollable:true,labelColor:AppTheme.plum,tabs:[
          Tab(text:'Graha Drishti'),Tab(text:'Avastha & dignity'),Tab(text:'Yoga checks'),
        ])),
      body:TabBarView(children:[
        _AspectList(aspects:aspects),_ConditionList(conditions:conditions),_YogaList(yogas:yogas),
      ]),
    ));
  }
}
class _AspectList extends StatelessWidget {
  const _AspectList({required this.aspects});
  final List<GrahaAspect> aspects;
  @override Widget build(BuildContext context)=>ListView(padding:const EdgeInsets.all(16),children:[
    const _Notice('Whole-sign Parashari aspects: all planets aspect the 7th; Mars also the 4th and 8th, Jupiter the 5th and 9th, Saturn the 3rd and 10th. Rahu/Ketu special aspects vary by school.'),
    const SizedBox(height:10),
    for(final a in aspects) Card(elevation:0,color:Colors.white,shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(14),side:const BorderSide(color:Color(0xFFEAE5EF))),
      child:ListTile(leading:CircleAvatar(backgroundColor:const Color(0xFFF2EDF8),child:Text(a.planet.symbol,style:const TextStyle(color:AppTheme.plum,fontWeight:FontWeight.w800))),
        title:Text(a.planet.name+' → House '+a.targetHouse.toString(),style:const TextStyle(fontSize:12,fontWeight:FontWeight.w800)),
        subtitle:Text(a.aspectNumber.toString()+'th aspect · '+(a.special?'Special aspect':'Common 7th aspect')+(a.occupants.isEmpty?' · No listed occupant':' · Influences '+a.occupants.map((g)=>g.name).join(', ')),style:const TextStyle(fontSize:10,color:AppTheme.muted)))),
  ]);
}
class _ConditionList extends StatelessWidget {
  const _ConditionList({required this.conditions});
  final List<GrahaCondition> conditions;
  @override Widget build(BuildContext context)=>ListView(padding:const EdgeInsets.all(16),children:[
    const _Notice('Baladi Avastha is shown as a simple degree-segment indicator. Dignity covers common own, exaltation and debilitation signs. Combustion uses approximate orbs. This is not Shadbala or a complete Avastha calculation.'),
    const SizedBox(height:10),
    for(final c in conditions) Container(margin:const EdgeInsets.only(bottom:9),padding:const EdgeInsets.all(14),decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(15),border:Border.all(color:const Color(0xFFEAE5EF))),
      child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Row(children:[Text(c.planet.symbol,style:const TextStyle(color:AppTheme.plum,fontSize:18,fontWeight:FontWeight.w900)),const SizedBox(width:9),Expanded(child:Text(c.planet.name,style:const TextStyle(fontSize:13,fontWeight:FontWeight.w800))),Text(c.dignity,style:const TextStyle(fontSize:10,color:AppTheme.plum,fontWeight:FontWeight.w700))]),
        const SizedBox(height:8),Wrap(spacing:7,runSpacing:7,children:[
          _Pill('Baladi: '+c.age),_Pill(c.combust?'Combust (approx.)':'Not combust by selected orb'),_Pill('Sun distance: '+c.sunDistance.toStringAsFixed(1)+'°'),
        ]),
      ])),
  ]);
}
class _YogaList extends StatelessWidget {
  const _YogaList({required this.yogas});
  final List<YogaFinding> yogas;
  @override Widget build(BuildContext context)=>ListView(padding:const EdgeInsets.all(16),children:[
    const _Notice('These are preliminary placement checks, not complete classical yoga judgements. House lordship, dignity, strength, aspects and cancellation rules can materially change interpretation.'),
    const SizedBox(height:10),
    for(final y in yogas) Container(margin:const EdgeInsets.only(bottom:10),padding:const EdgeInsets.all(15),decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(15),border:Border.all(color:const Color(0xFFEAE5EF))),
      child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Text(y.name,style:const TextStyle(fontSize:14,color:AppTheme.ink,fontWeight:FontWeight.w800)),const SizedBox(height:6),
        Text(y.description,style:const TextStyle(fontSize:11,height:1.45,color:AppTheme.ink)),const SizedBox(height:8),
        Text(y.caveat,style:const TextStyle(fontSize:10,height:1.4,color:AppTheme.muted)),
      ])),
  ]);
}
class _Notice extends StatelessWidget {
  const _Notice(this.text); final String text;
  @override Widget build(BuildContext context)=>Container(padding:const EdgeInsets.all(13),decoration:BoxDecoration(color:const Color(0xFFFFF6E8),borderRadius:BorderRadius.circular(13),border:Border.all(color:const Color(0xFFF1E2C9))),child:Text(text,style:const TextStyle(fontSize:10,height:1.5,color:Color(0xFF795D36))));
}
class _Pill extends StatelessWidget {
  const _Pill(this.text); final String text;
  @override Widget build(BuildContext context)=>Container(padding:const EdgeInsets.symmetric(horizontal:9,vertical:6),decoration:BoxDecoration(color:const Color(0xFFF4EFF9),borderRadius:BorderRadius.circular(20)),child:Text(text,style:const TextStyle(fontSize:9,color:AppTheme.plum,fontWeight:FontWeight.w700)));
}
