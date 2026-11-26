import 'dart:isolate';
import 'package:flutter/material.dart';
import '../../models/kundali/kundali_graha.dart';
import '../../services/gochar_service.dart';
import '../../theme/app_theme.dart';

class _TransitCalendarEvent {
  const _TransitCalendarEvent(this.date,this.planet,this.title,this.detail);
  final DateTime date;
  final String planet,title,detail;
}
List<_TransitCalendarEvent> _calculateTransitEvents(DateTime start) {
  final events=<_TransitCalendarEvent>[];
  var previous=GocharService.positionsAt(start);
  for(var day=1;day<=180;day++){
    final date=start.add(Duration(days:day));
    final current=GocharService.positionsAt(date);
    for(final now in current){
      final before=previous.firstWhere((p)=>p.name==now.name);
      if(before.signIndex!=now.signIndex){
        events.add(_TransitCalendarEvent(date,now.name,'Enters '+kundaliRashiNames[now.signIndex],
          'Sidereal sign ingress · previous: '+kundaliRashiNames[before.signIndex]));
      }
      if(before.isRetrograde!=now.isRetrograde){
        events.add(_TransitCalendarEvent(date,now.name,now.isRetrograde?'Turns retrograde':'Turns direct',
          'Direction change detected from daily position sampling.'));
      }
    }
    previous=current;
  }
  events.sort((a,b)=>a.date.compareTo(b.date));
  return events;
}

class TransitCalendarScreen extends StatefulWidget {
  const TransitCalendarScreen({super.key});
  @override State<TransitCalendarScreen> createState()=>_TransitCalendarScreenState();
}
class _TransitCalendarScreenState extends State<TransitCalendarScreen>{
  late Future<List<_TransitCalendarEvent>> _events;
  @override void initState(){super.initState();_load();}
  void _load(){
    final now=DateTime.now();
    final start=DateTime(now.year,now.month,now.day,12).toUtc();
    _events=Isolate.run(()=>_calculateTransitEvents(start));
  }
  @override Widget build(BuildContext context)=>Scaffold(
    appBar:AppBar(title:const Text('Planetary transit calendar',style:TextStyle(fontSize:17,fontWeight:FontWeight.w800)),actions:[
      IconButton(onPressed:()=>setState(_load),tooltip:'Refresh',icon:const Icon(Icons.refresh_rounded,color:AppTheme.plum)),
    ]),
    body:FutureBuilder<List<_TransitCalendarEvent>>(future:_events,builder:(context,snapshot){
      if(snapshot.connectionState!=ConnectionState.done)return const Center(child:Column(mainAxisSize:MainAxisSize.min,children:[CircularProgressIndicator(color:AppTheme.plum),SizedBox(height:12),Text('Calculating the next 180 days…',style:TextStyle(fontSize:11,color:AppTheme.muted))]));
      if(snapshot.hasError)return Center(child:Padding(padding:const EdgeInsets.all(24),child:Text('Could not calculate transit events: ${snapshot.error}',style:const TextStyle(fontSize:11,color:AppTheme.muted))));
      final events=snapshot.data??const <_TransitCalendarEvent>[];
      return ListView(padding:const EdgeInsets.all(16),children:[
        const _Notice('Events are estimated to the calendar day by daily sidereal position sampling. Retrograde stations and sign ingresses can occur at any time of day; use a high-precision ephemeris for exact timestamps. Rahu/Ketu use mean-node positions.'),
        const SizedBox(height:12),
        Text('Upcoming events · 180 days',style:const TextStyle(fontSize:14,fontWeight:FontWeight.w800,color:AppTheme.ink)),
        const SizedBox(height:8),
        if(events.isEmpty)const Text('No sign changes or direction changes detected in this window.',style:TextStyle(fontSize:11,color:AppTheme.muted)),
        for(final event in events)Container(margin:const EdgeInsets.only(bottom:8),padding:const EdgeInsets.all(13),decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(14),border:Border.all(color:const Color(0xFFEAE5EF))),child:Row(children:[
          Container(width:52,padding:const EdgeInsets.symmetric(vertical:7),decoration:BoxDecoration(color:const Color(0xFFF2EDF8),borderRadius:BorderRadius.circular(10)),child:Column(children:[
            Text(_month(event.date.month),style:const TextStyle(fontSize:8,color:AppTheme.plum,fontWeight:FontWeight.w800)),
            Text(event.date.day.toString(),style:const TextStyle(fontSize:16,color:AppTheme.plum,fontWeight:FontWeight.w900)),
          ])),
          const SizedBox(width:11),
          Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
            Text(event.planet+' · '+event.title,style:const TextStyle(fontSize:11,fontWeight:FontWeight.w800,color:AppTheme.ink)),
            const SizedBox(height:3),Text(event.detail,style:const TextStyle(fontSize:9.5,color:AppTheme.muted)),
          ])),
        ])),
      ]);
    }),
  );
  String _month(int m)=>const ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'][m-1];
}
class _Notice extends StatelessWidget{
  const _Notice(this.text);final String text;
  @override Widget build(BuildContext context)=>Container(padding:const EdgeInsets.all(13),decoration:BoxDecoration(color:const Color(0xFFFFF6E8),borderRadius:BorderRadius.circular(13),border:Border.all(color:const Color(0xFFF1E2C9))),child:Text(text,style:const TextStyle(fontSize:10,height:1.5,color:Color(0xFF795D36))));
}
