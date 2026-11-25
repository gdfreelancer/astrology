import 'package:flutter/material.dart';

import '../../l10n/app_locale.dart';
import 'package:geocoding/geocoding.dart';
import 'package:timezone/data/latest.dart' as timezone_data;
import 'package:timezone/timezone.dart' as tz;
import '../../models/panchang_data.dart';
import '../../services/panchang_service.dart';
import '../../services/settings/app_preferences_service.dart';
import '../../theme/app_theme.dart';

class PanchangScreen extends StatefulWidget {
  const PanchangScreen({super.key});
  @override
  State<PanchangScreen> createState()=>_PanchangScreenState();
}
class _PanchangScreenState extends State<PanchangScreen>{
  DateTime _date=DateUtils.dateOnly(DateTime.now());
  PanchangLocation _location=const PanchangLocation(name:'Ahmedabad, Gujarat, India',latitude:23.0225,longitude:72.5714,timeZoneId:'Asia/Kolkata');
  PanchangData? _data;
  bool _loading=true;
  String? _error;
  @override
  void initState(){super.initState();timezone_data.initializeTimeZones();_loadSavedLocation();}
  Future<void> _loadSavedLocation() async {
    final saved = await AppPreferencesService.defaultLocation();
    if (!mounted) return;
    setState(() => _location = PanchangLocation(name: saved.name, latitude: saved.latitude, longitude: saved.longitude, timeZoneId: saved.timeZoneId));
    await _load();
  }
  Future<void> _load() async{
    setState(() { _loading=true; _error=null; });
    try{
      final result=await Future<PanchangData>(()=>PanchangService.calculate(date:_date,location:_location));
      if(!mounted)return;setState(()=>_data=result);
    }catch(e){if(!mounted)return;setState(()=>_error=e.toString());}
    if(mounted)setState(()=>_loading=false);
  }
  void _move(int days){setState(()=>_date=DateUtils.dateOnly(_date.add(Duration(days:days))));_load();}
  Future<void> _pickDate()async{
    final d=await showDatePicker(context:context,initialDate:_date,firstDate:DateTime(1900),lastDate:DateTime(2100));
    if(d!=null){setState(()=>_date=DateUtils.dateOnly(d));_load();}
  }
  Future<void> _editLocation()async{
    final input=TextEditingController(text:_location.name);
    String zone=_location.timeZoneId;String? error;bool busy=false;
    await showModalBottomSheet<void>(context:context,isScrollControlled:true,backgroundColor:Colors.transparent,builder:(sheet)=>StatefulBuilder(builder:(ctx,ss)=>Padding(
      padding:EdgeInsets.only(bottom:MediaQuery.of(ctx).viewInsets.bottom),
      child:Container(padding:const EdgeInsets.fromLTRB(20,16,20,24),decoration:const BoxDecoration(color:Color(0xFFFFFCF8),borderRadius:BorderRadius.vertical(top:Radius.circular(24))),child:SafeArea(top:false,child:Column(mainAxisSize:MainAxisSize.min,crossAxisAlignment:CrossAxisAlignment.start,children:[
        Text(context.tr('panchang_location'),style:TextStyle(fontSize:18,fontWeight:FontWeight.w800)),
        const SizedBox(height:6),Text(context.tr('location_timezone_help'),style:TextStyle(fontSize:11,color:AppTheme.muted)),
        const SizedBox(height:14),TextField(controller:input,autofocus:true,textCapitalization:TextCapitalization.words,decoration:InputDecoration(hintText:context.tr('city_state_country'),prefixIcon:const Icon(Icons.location_on_outlined))),
        const SizedBox(height:10),
        DropdownButtonFormField<String>(value:zone,decoration:InputDecoration(labelText:context.tr('time_zone')),items:[
          DropdownMenuItem(value:'Asia/Kolkata',child:Text(context.tr('india_timezone'))),
          DropdownMenuItem(value:'Asia/Dubai',child:Text(context.tr('uae_timezone'))),
          DropdownMenuItem(value:'Asia/Singapore',child:Text(context.tr('singapore_timezone'))),
          DropdownMenuItem(value:'Europe/London',child:Text(context.tr('uk_timezone'))),
          DropdownMenuItem(value:'Europe/Paris',child:Text(context.tr('central_europe_timezone'))),
          DropdownMenuItem(value:'America/New_York',child:Text(context.tr('us_eastern_timezone'))),
          DropdownMenuItem(value:'America/Los_Angeles',child:Text(context.tr('us_pacific_timezone'))),
          DropdownMenuItem(value:'Australia/Sydney',child:Text(context.tr('australia_timezone'))),
        ],onChanged:(v){if(v!=null)ss(()=>zone=v);}),
        if(error!=null)Padding(padding:const EdgeInsets.only(top:8),child:Text(error!,style:const TextStyle(color:Colors.red,fontSize:11))),
        const SizedBox(height:14),SizedBox(width:double.infinity,height:48,child:FilledButton(
          onPressed:busy?null:()async{
            if(input.text.trim().isEmpty){ss(()=>error='Enter a city or town.');return;}
            ss(()=>busy=true);
            try{
              final found=await Geocoding().locationFromAddress(input.text.trim());
              if(found.isEmpty)throw StateError('not found');
              if(!mounted)return;
              setState(()=>_location=PanchangLocation(name:input.text.trim(),latitude:found.first.latitude,longitude:found.first.longitude,timeZoneId:zone));
              if(sheet.mounted)Navigator.pop(sheet);_load();
            }catch(_){ss(() { busy=false; error='Could not find this place. Add the state and country.'; });}
          },
          style:FilledButton.styleFrom(backgroundColor:AppTheme.plum),child:busy?const SizedBox(width:18,height:18,child:CircularProgressIndicator(color:Colors.white,strokeWidth:2)):Text(context.tr('use_this_location')),
        )),
      ]))),
    )));
    input.dispose();
  }
  Future<void> _open(Widget page)async{await Navigator.push(context,MaterialPageRoute<void>(builder:(_)=>page));}
  @override
  Widget build(BuildContext context)=>Scaffold(
    appBar:AppBar(title:Text(context.tr('panchang'),style:const TextStyle(fontSize:18,fontWeight:FontWeight.w800)),actions:[IconButton(onPressed:_pickDate,icon:const Icon(Icons.calendar_month_rounded))]),
    body:SafeArea(child:_loading?const Center(child:CircularProgressIndicator(color:AppTheme.plum)): _error!=null?Center(child:Padding(padding:const EdgeInsets.all(24),child:Column(mainAxisSize:MainAxisSize.min,children:[const Icon(Icons.wb_sunny_outlined,size:40,color:AppTheme.plum),const SizedBox(height:12),Text(context.tr('panchang_failed'),style:TextStyle(fontWeight:FontWeight.w800)),const SizedBox(height:8),Text(_error!,textAlign:TextAlign.center,style:const TextStyle(fontSize:10,color:AppTheme.muted)),const SizedBox(height:12),FilledButton(onPressed:_load,child:Text(context.tr('try_again')))]))):_body(_data!)),
  );
  Widget _body(PanchangData d)=>ListView(padding:const EdgeInsets.fromLTRB(18,8,18,28),children:[
    Row(children:[
      Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(_dateLabel(d.date),style:const TextStyle(fontSize:17,fontWeight:FontWeight.w800)),Text(AppLocale.text('weekday_${d.date.weekday}'),style:const TextStyle(fontSize:10,color:AppTheme.muted))])),
      _iconButton(Icons.chevron_left,()=>_move(-1)),const SizedBox(width:5),
      _iconButton(Icons.today,(){setState(()=>_date=DateUtils.dateOnly(DateTime.now()));_load();}),const SizedBox(width:5),
      _iconButton(Icons.chevron_right,()=>_move(1)),
    ]),
    const SizedBox(height:13),
    Container(padding:const EdgeInsets.all(17),decoration:BoxDecoration(gradient:const LinearGradient(colors:[Color(0xFF7658A6),Color(0xFF4D3B78)]),borderRadius:BorderRadius.circular(22)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      Row(children:[const Icon(Icons.location_on_outlined,size:14,color:Color(0xFFE8DDF8)),const SizedBox(width:5),Expanded(child:Text(d.location.name,overflow:TextOverflow.ellipsis,style:const TextStyle(fontSize:10,color:Color(0xFFE8DDF8)))),TextButton(onPressed:_editLocation,child:Text(context.tr('change'),style:TextStyle(fontSize:9,color:Color(0xFFFFDFA0),fontWeight:FontWeight.w800)))]),
      Text(d.element('Tithi').value,style:const TextStyle(fontSize:23,color:Colors.white,fontWeight:FontWeight.w800)),
      const SizedBox(height:3),Text(d.paksha+' · '+d.element('Nakshatra').value,style:const TextStyle(fontSize:10,color:Color(0xFFE8DDF8))),
      const SizedBox(height:14),Container(height:1,color:Colors.white24),const SizedBox(height:12),
      Row(children:[
        _heroTime(context.tr('sunrise'),_fmt(d.sunrise,d.location.timeZoneId)),
        _heroTime(context.tr('sunset'),_fmt(d.sunset,d.location.timeZoneId)),
        _heroTime(context.tr('moonrise'),d.moonrise==null?'—':_fmt(d.moonrise!,d.location.timeZoneId)),
      ]),
    ])),
    const SizedBox(height:19),_heading(context.tr('panchang_elements'),context.tr('tap_element')),
    const SizedBox(height:10),
    GridView.builder(shrinkWrap:true,physics:const NeverScrollableScrollPhysics(),itemCount:d.elements.length,gridDelegate:const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:2,crossAxisSpacing:9,mainAxisSpacing:9,childAspectRatio:1.55),itemBuilder:(ctx,i)=>_ElementTile(item:d.elements[i],onTap:()=>_open(PanchangDetailScreen(data:d)))),
    const SizedBox(height:19),_heading(context.tr('sun_moon_timings'),context.tr('calculated_selected_location')),
    const SizedBox(height:10),Row(children:[
      _metric('☀️',context.tr('sunrise'),_fmt(d.sunrise,d.location.timeZoneId)),
      const SizedBox(width:7),_metric('🌇',context.tr('sunset'),_fmt(d.sunset,d.location.timeZoneId)),
      const SizedBox(width:7),_metric('🌙',context.tr('moonrise'),d.moonrise==null?'—':_fmt(d.moonrise!,d.location.timeZoneId)),
      const SizedBox(width:7),_metric('🌘',context.tr('moonset'),d.moonset==null?'—':_fmt(d.moonset!,d.location.timeZoneId)),
    ]),
    const SizedBox(height:19),_heading(context.tr('daily_time_windows'),context.tr('auspicious_inauspicious_periods')),
    const SizedBox(height:9),_preview(d),
    const SizedBox(height:19),_heading(context.tr('explore_panchang'),context.tr('more_calendar_information')),
    const SizedBox(height:9),
    _link('⏳',context.tr('choghadiya'),context.tr('day_night_periods'),()=>_open(ChoghadiyaScreen(data:d))),
    _link('🕉️',context.tr('daily_timings'),context.tr('rahu_yamaganda_muhurat'),()=>_open(DailyTimingsScreen(data:d))),
    _link('🗓️',context.tr('hindu_calendar'),'Monthly Tithi calendar',()=>_open(PanchangCalendarScreen(date:_date,location:_location,onDateSelected:(v){Navigator.pop(context);setState(()=>_date=v);_load();}))),
    _link('🌼',context.tr('vrat_observances'),'Upcoming Tithi-based days',()=>_open(FestivalsScreen(date:_date,location:_location))),
    const SizedBox(height:10),
    Container(padding:const EdgeInsets.all(14),decoration:BoxDecoration(color:const Color(0xFFFFF5E7),borderRadius:BorderRadius.circular(15)),child:Text(d.sunRashi+' · '+d.ritu+' · '+d.ayana+'\nAyanamsha: '+d.ayanamsha.toStringAsFixed(2)+'°',style:const TextStyle(fontSize:10,height:1.6,fontWeight:FontWeight.w700,color:AppTheme.ink))),
    const SizedBox(height:12),Text(context.tr('panchang_disclaimer'),style:TextStyle(fontSize:9,height:1.5,color:AppTheme.muted)),
  ]);
  Widget _iconButton(IconData icon,VoidCallback tap)=>IconButton(onPressed:tap,icon:Icon(icon,size:19,color:AppTheme.plum),style:IconButton.styleFrom(backgroundColor:Colors.white,shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(12))));
  Widget _heroTime(String title,String value)=>Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(title,style:const TextStyle(fontSize:8,color:Color(0xFFD7C9EB),fontWeight:FontWeight.w700)),const SizedBox(height:4),Text(value,style:const TextStyle(fontSize:11,color:Colors.white,fontWeight:FontWeight.w800))]));
  Widget _heading(String title,String sub)=>Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(title,style:const TextStyle(fontSize:15,fontWeight:FontWeight.w800)),const SizedBox(height:3),Text(sub,style:const TextStyle(fontSize:9,color:AppTheme.muted))]);
  Widget _metric(String emoji,String title,String value)=>Expanded(child:Container(padding:const EdgeInsets.symmetric(vertical:11,horizontal:5),decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(13),border:Border.all(color:const Color(0xFFF0EBE5))),child:Column(children:[Text(emoji,style:const TextStyle(fontSize:17)),const SizedBox(height:5),Text(title,style:const TextStyle(fontSize:8,color:AppTheme.muted)),const SizedBox(height:3),FittedBox(child:Text(value,style:const TextStyle(fontSize:9,fontWeight:FontWeight.w800)))])));
  Widget _preview(PanchangData d)=>Container(padding:const EdgeInsets.all(13),decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(15),border:Border.all(color:const Color(0xFFF0EBE5))),child:Column(children:[
    _period(d.rahuKaal,d.location.timeZoneId),_period(d.yamaganda,d.location.timeZoneId),_period(d.gulika,d.location.timeZoneId),_period(d.abhijit,d.location.timeZoneId),
  ]));
  Widget _period(PanchangPeriod p,String zone)=>Padding(padding:const EdgeInsets.symmetric(vertical:6),child:Row(children:[Expanded(child:Text(p.name,style:const TextStyle(fontSize:10,fontWeight:FontWeight.w700))),Text(_fmt(p.start,zone)+' – '+_fmt(p.end,zone),style:const TextStyle(fontSize:10,fontWeight:FontWeight.w800))]));
  Widget _link(String icon,String title,String sub,VoidCallback tap)=>Padding(padding:const EdgeInsets.only(bottom:8),child:Material(color:Colors.white,borderRadius:BorderRadius.circular(14),child:InkWell(onTap:tap,borderRadius:BorderRadius.circular(14),child:Container(padding:const EdgeInsets.all(12),decoration:BoxDecoration(borderRadius:BorderRadius.circular(14),border:Border.all(color:const Color(0xFFF0EBE5))),child:Row(children:[Text(icon,style:const TextStyle(fontSize:22)),const SizedBox(width:11),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(title,style:const TextStyle(fontSize:11,fontWeight:FontWeight.w800)),Text(sub,style:const TextStyle(fontSize:9,color:AppTheme.muted))])),const Icon(Icons.chevron_right_rounded,size:18,color:AppTheme.muted)])))));
  String _dateLabel(DateTime d)=>_monthName(d.month)+' '+d.day.toString()+', '+d.year.toString();
}

class _ElementTile extends StatelessWidget{
  const _ElementTile({required this.item,required this.onTap});
  final PanchangElement item;final VoidCallback onTap;
  @override Widget build(BuildContext context)=>Material(color:Colors.white,borderRadius:BorderRadius.circular(15),child:InkWell(onTap:onTap,borderRadius:BorderRadius.circular(15),child:Container(padding:const EdgeInsets.all(12),decoration:BoxDecoration(borderRadius:BorderRadius.circular(15),border:Border.all(color:const Color(0xFFF0EBE5))),child:Column(crossAxisAlignment:CrossAxisAlignment.start,mainAxisAlignment:MainAxisAlignment.center,children:[Text(item.name.toUpperCase(),style:const TextStyle(fontSize:8,letterSpacing:1,color:AppTheme.muted,fontWeight:FontWeight.w800)),const SizedBox(height:6),Text(item.value,maxLines:1,overflow:TextOverflow.ellipsis,style:const TextStyle(fontSize:14,fontWeight:FontWeight.w800)),const SizedBox(height:4),Text(item.description,maxLines:1,overflow:TextOverflow.ellipsis,style:const TextStyle(fontSize:8,color:AppTheme.muted)),const SizedBox(height:5),Text(context.tr('view_details'),style:TextStyle(fontSize:8,color:AppTheme.plum,fontWeight:FontWeight.w800))]))));
}

class PanchangDetailScreen extends StatelessWidget{
  const PanchangDetailScreen({super.key,required this.data});final PanchangData data;
  @override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:Text(context.tr('panchang_details'))),body:ListView(padding:const EdgeInsets.all(17),children:[
    ...data.elements.map((e)=>Container(margin:const EdgeInsets.only(bottom:10),padding:const EdgeInsets.all(15),decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(15),border:Border.all(color:const Color(0xFFF0EBE5))),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      Text(e.name.toUpperCase(),style:const TextStyle(fontSize:8,letterSpacing:1,color:AppTheme.plum,fontWeight:FontWeight.w800)),const SizedBox(height:5),Text(e.value,style:const TextStyle(fontSize:16,fontWeight:FontWeight.w800)),Text(e.description,style:const TextStyle(fontSize:10,color:AppTheme.muted)),const SizedBox(height:10),
      Row(children:[Expanded(child:_timeBox('STARTS',e.start,data.location.timeZoneId)),Expanded(child:_timeBox('ENDS',e.end,data.location.timeZoneId))]),
      const SizedBox(height:9),Text(e.detail,style:const TextStyle(fontSize:10,height:1.5,color:AppTheme.muted)),
    ]))),
  ]));
}

Widget _timeBox(String label,DateTime time,String zone)=>Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(label,style:const TextStyle(fontSize:8,color:AppTheme.muted)),const SizedBox(height:3),Text(_fmt(time,zone),style:const TextStyle(fontSize:12,fontWeight:FontWeight.w800))]);

class ChoghadiyaScreen extends StatefulWidget{
  const ChoghadiyaScreen({super.key,required this.data});final PanchangData data;
  @override State<ChoghadiyaScreen> createState()=>_ChoghadiyaScreenState();
}
class _ChoghadiyaScreenState extends State<ChoghadiyaScreen>{
  bool day=true;
  @override Widget build(BuildContext context){
    final periods=day?widget.data.choghadiyaDay:widget.data.choghadiyaNight;
    return Scaffold(appBar:AppBar(title:Text(context.tr('choghadiya'))),body:ListView(padding:const EdgeInsets.all(17),children:[
      Container(padding:const EdgeInsets.all(16),decoration:BoxDecoration(gradient:const LinearGradient(colors:[Color(0xFF8062B5),Color(0xFF60468F)]),borderRadius:BorderRadius.circular(18)),child:Text(context.tr('choghadiya_description'),style:TextStyle(color:Colors.white,fontSize:12,height:1.5))),
      const SizedBox(height:14),
      SegmentedButton<bool>(segments:[ButtonSegment(value:true,label:Text(context.tr('day_eight'))),ButtonSegment(value:false,label:Text(context.tr('night_eight')))],selected:{day},onSelectionChanged:(v)=>setState(()=>day=v.first)),
      const SizedBox(height:12),
      ...List.generate(periods.length,(i){final p=periods[i];final good=['Amrit','Shubh','Labh','Char'].contains(p.name);final active=DateTime.now().toUtc().isAfter(p.start)&&DateTime.now().toUtc().isBefore(p.end);final color=good?const Color(0xFF438466):const Color(0xFFB75B54);return Container(margin:const EdgeInsets.only(bottom:8),padding:const EdgeInsets.all(12),decoration:BoxDecoration(color:active?const Color(0xFFF2EDF9):Colors.white,borderRadius:BorderRadius.circular(13),border:Border.all(color:active?AppTheme.plum:const Color(0xFFF0EBE5))),child:Row(children:[Container(width:30,height:30,alignment:Alignment.center,decoration:BoxDecoration(color:color.withValues(alpha:.1),borderRadius:BorderRadius.circular(9)),child:Text((i+1).toString(),style:TextStyle(color:color,fontWeight:FontWeight.w800))),const SizedBox(width:10),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(p.name,style:const TextStyle(fontSize:12,fontWeight:FontWeight.w800)),Text(p.category,style:TextStyle(fontSize:9,color:color))])),Text(_fmt(p.start,widget.data.location.timeZoneId)+'\n'+_fmt(p.end,widget.data.location.timeZoneId),textAlign:TextAlign.right,style:const TextStyle(fontSize:10,height:1.5,fontWeight:FontWeight.w800))]));}),
      Text(context.tr('traditional_classifications'),style:TextStyle(fontSize:9,color:AppTheme.muted)),
    ]));
  }
}

class DailyTimingsScreen extends StatelessWidget{
  const DailyTimingsScreen({super.key,required this.data});final PanchangData data;
  @override Widget build(BuildContext context){
    final items=[data.brahma,data.rahuKaal,data.yamaganda,data.gulika,data.abhijit];
    return Scaffold(appBar:AppBar(title:Text(context.tr('daily_timings'))),body:ListView(padding:const EdgeInsets.all(17),children:[
      ...items.map((p){final good=p.category=='Auspicious';final color=good?const Color(0xFF438466):const Color(0xFFB75B54);return Container(margin:const EdgeInsets.only(bottom:9),padding:const EdgeInsets.all(14),decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(14),border:Border.all(color:const Color(0xFFF0EBE5))),child:Row(children:[Icon(good?Icons.auto_awesome:Icons.schedule,color:color),const SizedBox(width:10),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(p.name,style:const TextStyle(fontSize:12,fontWeight:FontWeight.w800)),Text(p.category,style:TextStyle(fontSize:9,color:color))])),Text(_fmt(p.start,data.location.timeZoneId)+'\n'+_fmt(p.end,data.location.timeZoneId),textAlign:TextAlign.right,style:const TextStyle(fontSize:10,height:1.5,fontWeight:FontWeight.w800))]));}),
      Text(context.tr('rahu_yamaganda_description'),style:TextStyle(fontSize:9,height:1.5,color:AppTheme.muted)),
    ]));
  }
}

class PanchangCalendarScreen extends StatefulWidget{
  const PanchangCalendarScreen({super.key,required this.date,required this.location,required this.onDateSelected});
  final DateTime date;final PanchangLocation location;final ValueChanged<DateTime> onDateSelected;
  @override State<PanchangCalendarScreen> createState()=>_PanchangCalendarScreenState();
}
class _PanchangCalendarScreenState extends State<PanchangCalendarScreen>{
  late DateTime month;late List<PanchangCalendarDay> days;DateTime? selected;
  @override void initState(){super.initState();month=DateTime(widget.date.year,widget.date.month);selected=widget.date;days=PanchangService.monthDays(month:month,location:widget.location);}
  void move(int n){setState(()=>month=DateTime(month.year,month.month+n));days=PanchangService.monthDays(month:month,location:widget.location);}
  @override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:Text(context.tr('hindu_calendar'))),body:ListView(padding:const EdgeInsets.all(15),children:[
    Row(children:[IconButton(onPressed:()=>move(-1),icon:const Icon(Icons.chevron_left)),Expanded(child:Text(_monthName(month.month)+' '+month.year.toString(),textAlign:TextAlign.center,style:const TextStyle(fontSize:16,fontWeight:FontWeight.w800))),IconButton(onPressed:()=>move(1),icon:const Icon(Icons.chevron_right))]),
    Row(children:['S','M','T','W','T','F','S'].map((s)=>Expanded(child:Center(child:Text(s,style:const TextStyle(fontSize:10,color:AppTheme.muted,fontWeight:FontWeight.w800)) ))).toList()),
    const SizedBox(height:8),
    GridView.builder(shrinkWrap:true,physics:const NeverScrollableScrollPhysics(),itemCount:42,gridDelegate:const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:7,mainAxisSpacing:5,crossAxisSpacing:4,childAspectRatio:.78),itemBuilder:(ctx,i){
      final d=days[i];final same=d.date.month==month.month;final active=selected!=null&&DateUtils.isSameDay(selected,d.date);
      return InkWell(onTap:()=>setState(()=>selected=d.date),borderRadius:BorderRadius.circular(10),child:Container(decoration:BoxDecoration(color:active?AppTheme.plum:Colors.white,borderRadius:BorderRadius.circular(10),border:Border.all(color:active?AppTheme.plum:const Color(0xFFF0EBE5))),child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[Text(d.date.day.toString(),style:TextStyle(fontSize:12,fontWeight:FontWeight.w800,color:active?Colors.white:same?AppTheme.ink:const Color(0xFFBDB7C4))),const SizedBox(height:3),Text(d.paksha+' '+d.tithi,style:TextStyle(fontSize:7,color:active?Colors.white70:AppTheme.muted)),if(d.isObservance)Container(width:4,height:4,margin:const EdgeInsets.only(top:3),decoration:BoxDecoration(color:active?const Color(0xFFFFDFA0):AppTheme.saffron,shape:BoxShape.circle))])));
    }),
    const SizedBox(height:12),Text(context.tr('calendar_disclaimer'),style:TextStyle(fontSize:9,color:AppTheme.muted)),
    if(selected!=null)Padding(padding:const EdgeInsets.only(top:14),child:FilledButton(onPressed:()=>widget.onDateSelected(selected!),style:FilledButton.styleFrom(backgroundColor:AppTheme.plum),child:Text(context.tr('view_panchang')+' · '+selected!.day.toString()+' '+_monthName(selected!.month)))),
  ]));
}

class FestivalsScreen extends StatefulWidget{
  const FestivalsScreen({super.key,required this.date,required this.location});final DateTime date;final PanchangLocation location;
  @override State<FestivalsScreen> createState()=>_FestivalsScreenState();
}
class _FestivalsScreenState extends State<FestivalsScreen>{
  late List<PanchangObservance> items;
  @override void initState(){super.initState();items=PanchangService.upcomingObservances(from:widget.date,location:widget.location,days:60);}
  @override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:Text(context.tr('vrat_observances'))),body:ListView(padding:const EdgeInsets.all(17),children:[
    Container(padding:const EdgeInsets.all(16),decoration:BoxDecoration(gradient:const LinearGradient(colors:[Color(0xFF9A7044),Color(0xFF76512F)]),borderRadius:BorderRadius.circular(18)),child:Text(context.tr('upcoming_observances_title')+'\n'+context.tr('upcoming_observances_description'),style:TextStyle(fontSize:15,height:1.5,color:Colors.white,fontWeight:FontWeight.w800))),
    const SizedBox(height:14),
    if(items.isEmpty)Text(context.tr('no_observances'),style:TextStyle(fontSize:11,color:AppTheme.muted)),
    ...items.map((e)=>Container(margin:const EdgeInsets.only(bottom:8),padding:const EdgeInsets.all(12),decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(14),border:Border.all(color:const Color(0xFFF0EBE5))),child:Row(children:[
      Container(width:43,height:45,alignment:Alignment.center,decoration:BoxDecoration(color:const Color(0xFFFFF3E1),borderRadius:BorderRadius.circular(10)),child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[Text(e.date.day.toString(),style:const TextStyle(fontSize:17,fontWeight:FontWeight.w800)),Text(_monthName(e.date.month).substring(0,3).toUpperCase(),style:const TextStyle(fontSize:7,color:AppTheme.muted,fontWeight:FontWeight.w800))])),
      const SizedBox(width:10),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(e.title,style:const TextStyle(fontSize:11,fontWeight:FontWeight.w800)),Text(e.subtitle,style:const TextStyle(fontSize:9,color:AppTheme.muted))])),Text(e.category.toUpperCase(),style:const TextStyle(fontSize:8,color:AppTheme.plum,fontWeight:FontWeight.w800)),
    ]))),
    const SizedBox(height:8),Text(context.tr('observance_disclaimer'),style:TextStyle(fontSize:9,height:1.5,color:AppTheme.muted)),
  ]));
}

String _fmt(DateTime utc,String zone){final d=tz.TZDateTime.from(utc,tz.getLocation(zone));final minute=d.minute.toString().padLeft(2,'0');if(AppPreferencesService.cachedUse24HourTime){return d.hour.toString().padLeft(2,'0')+':'+minute;}final h=d.hour%12==0?12:d.hour%12;return h.toString()+':'+minute+' '+(d.hour>=12?'PM':'AM');}
String _monthName(int m)=>AppLocale.text('month_$m');
