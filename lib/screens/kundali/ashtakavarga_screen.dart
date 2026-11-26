import 'package:flutter/material.dart';
import '../../models/kundali/kundali_graha.dart';
import '../../services/ashtakavarga_service.dart';
import '../../theme/app_theme.dart';

class AshtakavargaScreen extends StatefulWidget {
  const AshtakavargaScreen({super.key,required this.chart});
  final KundaliChart chart;
  @override State<AshtakavargaScreen> createState()=>_AshtakavargaScreenState();
}
class _AshtakavargaScreenState extends State<AshtakavargaScreen> {
  String _selected='Sun';
  @override Widget build(BuildContext context) {
    final result=AshtakavargaService.calculate(widget.chart);
    final points=result.bhinna[_selected]!;
    return Scaffold(appBar:AppBar(title:const Text('Ashtakavarga analysis',style:TextStyle(fontSize:17,fontWeight:FontWeight.w800))),
      body:ListView(padding:const EdgeInsets.all(16),children:[
        Container(padding:const EdgeInsets.all(14),decoration:BoxDecoration(color:const Color(0xFFF2EDF8),borderRadius:BorderRadius.circular(15)),child:Row(children:[
          const Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
            Text('Sarvashtakavarga',style:TextStyle(fontSize:13,fontWeight:FontWeight.w800,color:AppTheme.ink)),
            SizedBox(height:3),Text('Combined score from the seven classical planetary BAV tables.',style:TextStyle(fontSize:10,color:AppTheme.muted)),
          ])),
          Text('337',style:const TextStyle(fontSize:22,fontWeight:FontWeight.w900,color:AppTheme.plum)),
        ])),
        const SizedBox(height:14),
        const Text('Bhinnashtakavarga',style:TextStyle(fontSize:15,fontWeight:FontWeight.w800,color:AppTheme.ink)),
        const SizedBox(height:8),
        DropdownButtonFormField<String>(value:_selected,decoration:const InputDecoration(labelText:'Select Graha'),items:[
          for(final p in AshtakavargaService.planets) DropdownMenuItem(value:p,child:Text(p)),
        ],onChanged:(v){if(v!=null)setState(()=>_selected=v);}),
        const SizedBox(height:10),
        _ScoreCard(title:_selected+' BAV',total:result.total(_selected),child:Column(children:[
          for(var i=0;i<12;i++) _ScoreRow(sign:i,points:points[i],selected:widget.chart.grahas.firstWhere((g)=>g.name==_selected).signIndex,max:8),
        ])),
        const SizedBox(height:12),
        _ScoreCard(title:'Sarvashtakavarga (SAV)',total:337,child:Column(children:[
          for(var i=0;i<12;i++) _ScoreRow(sign:i,points:result.sarva[i],selected:widget.chart.ascendantSignIndex,max:56),
        ])),
        const SizedBox(height:12),
        const _Notice('These are unreduced classical BAV and SAV bindu counts. Rahu and Ketu do not participate. Some published traditions differ in a few Moon and Venus table entries; this implementation uses one documented Parashari table set and checks fixed totals (48, 49, 39, 54, 56, 52, 39; SAV 337). Bindus are supporting indicators, not standalone predictions.'),
      ]));
  }
}
class _ScoreCard extends StatelessWidget {
  const _ScoreCard({required this.title,required this.total,required this.child});
  final String title; final int total; final Widget child;
  @override Widget build(BuildContext context)=>Container(margin:const EdgeInsets.only(top:5),padding:const EdgeInsets.all(13),decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(15),border:Border.all(color:const Color(0xFFEAE5EF))),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
    Row(children:[Expanded(child:Text(title,style:const TextStyle(fontSize:12,fontWeight:FontWeight.w800))),Text('Total '+total.toString(),style:const TextStyle(fontSize:11,color:AppTheme.plum,fontWeight:FontWeight.w800))]),
    const Divider(height:18),child,
  ]));
}
class _ScoreRow extends StatelessWidget {
  const _ScoreRow({required this.sign,required this.points,required this.selected,required this.max});
  final int sign,points,selected,max;
  static const names=['Aries','Taurus','Gemini','Cancer','Leo','Virgo','Libra','Scorpio','Sagittarius','Capricorn','Aquarius','Pisces'];
  @override Widget build(BuildContext context)=>Padding(padding:const EdgeInsets.symmetric(vertical:5),child:Row(children:[
    SizedBox(width:22,child:Text((sign+1).toString().padLeft(2,'0'),style:const TextStyle(fontSize:9,color:AppTheme.muted))),
    Expanded(child:Text(names[sign],style:TextStyle(fontSize:10,fontWeight:sign==selected?FontWeight.w900:FontWeight.w500,color:sign==selected?AppTheme.plum:AppTheme.ink))),
    SizedBox(width:100,child:ClipRRect(borderRadius:BorderRadius.circular(5),child:LinearProgressIndicator(value:points/max,minHeight:7,backgroundColor:const Color(0xFFF0ECF3),color:AppTheme.plum))),
    const SizedBox(width:10),SizedBox(width:22,child:Text(points.toString(),textAlign:TextAlign.end,style:const TextStyle(fontSize:11,fontWeight:FontWeight.w800))),
  ]));
}
class _Notice extends StatelessWidget {
  const _Notice(this.text);final String text;
  @override Widget build(BuildContext context)=>Container(padding:const EdgeInsets.all(13),decoration:BoxDecoration(color:const Color(0xFFFFF6E8),borderRadius:BorderRadius.circular(13),border:Border.all(color:const Color(0xFFF1E2C9))),child:Text(text,style:const TextStyle(fontSize:10,height:1.5,color:Color(0xFF795D36))));
}
