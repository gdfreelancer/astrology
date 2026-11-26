import 'package:flutter/material.dart';
import '../../models/birth_profile.dart';
import '../../models/birth_chart_result.dart';
import '../../services/birth_chart_service.dart';
import '../../services/birth_profile_service.dart';
import '../../theme/app_theme.dart';

class ProfileComparisonScreen extends StatefulWidget {
  const ProfileComparisonScreen({super.key});
  @override State<ProfileComparisonScreen> createState()=>_ProfileComparisonScreenState();
}
class _ProfileComparisonScreenState extends State<ProfileComparisonScreen> {
  List<BirthProfile> _profiles=[];
  String? _first,_second;
  bool _loading=true;
  @override void initState(){super.initState();_load();}
  Future<void> _load()async{
    final items=await BirthProfileService.getAll();
    if(!mounted)return;
    setState((){_profiles=items;_loading=false;if(items.length>1){_first=items[0].id;_second=items[1].id;}else if(items.isNotEmpty){_first=items[0].id;}});
  }
  BirthChartResult? _chart(String? id){
    if(id==null)return null;
    final p=_profiles.where((x)=>x.id==id).firstOrNull;
    if(p==null)return null;
    try{return BirthChartService.calculate(
      birthDate:p.birthDate,hour:p.hour,minute:p.minute,timeZoneId:p.timeZoneId,
      placeName:p.placeName,latitude:p.latitude,longitude:p.longitude,gender:p.gender,
    );}catch(_){return null;}
  }
  @override Widget build(BuildContext context){
    final a=_chart(_first),b=_chart(_second);
    return Scaffold(appBar:AppBar(title:const Text('Kundali comparison',style:TextStyle(fontSize:17,fontWeight:FontWeight.w800))),
      body:_loading?const Center(child:CircularProgressIndicator(color:AppTheme.plum)):
      _profiles.length<2?Center(child:Padding(padding:const EdgeInsets.all(24),child:Column(mainAxisSize:MainAxisSize.min,children:[
        const Icon(Icons.people_outline_rounded,size:42,color:AppTheme.plum),const SizedBox(height:12),
        const Text('Add at least two saved birth profiles to compare their charts.',textAlign:TextAlign.center,style:TextStyle(fontSize:12,color:AppTheme.muted)),
        const SizedBox(height:8),TextButton(onPressed:()=>Navigator.pop(context),child:const Text('Back to profiles')),
      ]))):
      ListView(padding:const EdgeInsets.all(16),children:[
        DropdownButtonFormField<String>(value:_first,decoration:const InputDecoration(labelText:'First profile'),items:[for(final p in _profiles)DropdownMenuItem(value:p.id,child:Text(p.name))],onChanged:(v)=>setState(()=>_first=v)),
        const SizedBox(height:10),
        DropdownButtonFormField<String>(value:_second,decoration:const InputDecoration(labelText:'Second profile'),items:[for(final p in _profiles)DropdownMenuItem(value:p.id,child:Text(p.name))],onChanged:(v)=>setState(()=>_second=v)),
        const SizedBox(height:16),
        if(_first==_second)const _Notice('Choose two different profiles to compare.'),
        if(_first!=_second&&a!=null&&b!=null)...[
          Row(children:[
            Expanded(child:_SummaryCard(name:_profiles.firstWhere((p)=>p.id==_first).name,rashi:a.rashi,nakshatra:a.nakshatra)),
            const SizedBox(width:9),
            Expanded(child:_SummaryCard(name:_profiles.firstWhere((p)=>p.id==_second).name,rashi:b.rashi,nakshatra:b.nakshatra)),
          ]),
          const SizedBox(height:16),
          const Text('Graha placement comparison',style:TextStyle(fontSize:15,fontWeight:FontWeight.w800,color:AppTheme.ink)),
          const SizedBox(height:8),
          for(final name in ['Sun','Moon','Mars','Mercury','Jupiter','Venus','Saturn','Rahu','Ketu'])
            _CompareRow(name:name,a:a.kundaliChart.grahas.firstWhere((g)=>g.name==name),b:b.kundaliChart.grahas.firstWhere((g)=>g.name==name)),
          const SizedBox(height:12),
          const _Notice('This compares chart placements only. It is not a marriage compatibility score or a prediction. Use the dedicated Kundali Matching section for traditional compatibility methods. Calculations inherit the app’s approximate GeoEngine and mean Lahiri ayanamsha.'),
        ],
        if(a==null||b==null)const _Notice('A chart could not be calculated for one of the selected profiles. Check the saved birth time, timezone and location.'),
      ]));
  }
}
class _SummaryCard extends StatelessWidget{
  const _SummaryCard({required this.name,required this.rashi,required this.nakshatra});
  final String name,rashi,nakshatra;
  @override Widget build(BuildContext context)=>Container(padding:const EdgeInsets.all(12),decoration:BoxDecoration(color:const Color(0xFFF2EDF8),borderRadius:BorderRadius.circular(14)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
    Text(name,style:const TextStyle(fontSize:12,fontWeight:FontWeight.w800,color:AppTheme.plum)),const SizedBox(height:6),
    Text('Rashi: '+rashi,style:const TextStyle(fontSize:10,color:AppTheme.ink)),Text('Nakshatra: '+nakshatra,style:const TextStyle(fontSize:10,color:AppTheme.ink)),
  ]));
}
class _CompareRow extends StatelessWidget{
  const _CompareRow({required this.name,required this.a,required this.b});
  final String name;final dynamic a,b;
  @override Widget build(BuildContext context)=>Container(margin:const EdgeInsets.only(bottom:6),padding:const EdgeInsets.symmetric(horizontal:12,vertical:10),decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(12),border:Border.all(color:const Color(0xFFEAE5EF))),child:Row(children:[
    SizedBox(width:58,child:Text(name,style:const TextStyle(fontSize:10,fontWeight:FontWeight.w800,color:AppTheme.ink))),
    Expanded(child:Text('Sign '+(a.signIndex+1).toString()+' · House '+a.houseNumber.toString(),style:const TextStyle(fontSize:10,color:AppTheme.plum))),
    Expanded(child:Text('Sign '+(b.signIndex+1).toString()+' · House '+b.houseNumber.toString(),style:const TextStyle(fontSize:10,color:AppTheme.plum))),
  ]));
}
class _Notice extends StatelessWidget{
  const _Notice(this.text);final String text;
  @override Widget build(BuildContext context)=>Container(padding:const EdgeInsets.all(13),decoration:BoxDecoration(color:const Color(0xFFFFF6E8),borderRadius:BorderRadius.circular(13),border:Border.all(color:const Color(0xFFF1E2C9))),child:Text(text,style:const TextStyle(fontSize:10,height:1.5,color:Color(0xFF795D36))));
}
