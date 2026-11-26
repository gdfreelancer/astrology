import 'package:flutter/material.dart';
import 'package:timezone/data/latest.dart' as timezone_data;

import '../../models/birth_profile.dart';
import '../../models/birth_chart_result.dart';
import '../../models/kundali/kundali_graha.dart';
import '../../services/birth_profile_service.dart';
import '../../services/birth_chart_service.dart';
import '../../services/vimshottari_dasha_service.dart';
import '../../theme/app_theme.dart';
import 'remedy_data.dart';

class PersonalizedRemediesScreen extends StatefulWidget {
  const PersonalizedRemediesScreen({super.key});
  @override State<PersonalizedRemediesScreen> createState()=>_PersonalizedRemediesScreenState();
}

class _PersonalizedRemediesScreenState extends State<PersonalizedRemediesScreen> {
  List<BirthProfile> _profiles=[];
  BirthProfile? _selected;
  BirthChartResult? _chart;
  bool _loading=true;
  String? _error;
  List<_AssessmentFactor> _factors=[];

  @override void initState(){super.initState();timezone_data.initializeTimeZones();_load();}
  Future<void> _load() async {
    try {
      final profiles=await BirthProfileService.getAll();
      if(!mounted)return;
      setState(()=>_profiles=profiles);
      if(profiles.isNotEmpty)await _select(profiles.first);
    } catch (_) { if(mounted)setState(()=>_error='Saved birth profiles could not be loaded.'); }
    if(mounted)setState(()=>_loading=false);
  }
  Future<void> _select(BirthProfile p) async {
    setState(()=>_loading=true);
    try {
      final result=BirthChartService.calculate(
        birthDate:p.birthDate,hour:p.hour,minute:p.minute,timeZoneId:p.timeZoneId,
        placeName:p.placeName,latitude:p.latitude,longitude:p.longitude,gender:p.gender,
      );
      final factors=_evaluate(result);
      if(!mounted)return;
      setState(() { _selected=p; _chart=result; _factors=factors; _error=null; _loading=false; });
    } catch (_) {
      if(mounted)setState(() { _error='The saved birth details could not be recalculated. Check the time zone and location.'; _chart=null; _loading=false; });
    }
  }

  List<_AssessmentFactor> _evaluate(BirthChartResult result) {
    final chart=result.kundaliChart;
    final asc=chart.ascendantSignIndex;
    final houseLords=<int,String>{
      0:'Mars',1:'Venus',2:'Mercury',3:'Moon',4:'Sun',5:'Mercury',
      6:'Venus',7:'Mars',8:'Jupiter',9:'Saturn',10:'Saturn',11:'Jupiter',
    };
    final ownSigns=<String,Set<int>>{
      'Sun':{4},'Moon':{3},'Mars':{0,7},'Mercury':{2,5},
      'Jupiter':{8,11},'Venus':{1,6},'Saturn':{9,10},
    };
    final exalted=<String,int>{'Sun':0,'Moon':1,'Mars':9,'Mercury':5,'Jupiter':3,'Venus':11,'Saturn':6};
    final debilitated=<String,int>{'Sun':6,'Moon':7,'Mars':3,'Mercury':11,'Jupiter':9,'Venus':5,'Saturn':0};
    final factors=<_AssessmentFactor>[];
    final kendras=[1,4,7,10].map((h)=>houseLords[(asc+h-1)%12]!).toSet();
    final trikonas=[1,5,9].map((h)=>houseLords[(asc+h-1)%12]!).toSet();
    factors.add(_AssessmentFactor('Kendra and Trikona lords','Evaluated', 'Kendra lords: ${kendras.join(', ')}. Trikona lords: ${trikonas.join(', ')}. Their dignity and placement are shown below; a full strength judgement is not made.'));
    final retro=chart.grahas.where((g)=>g.isRetrograde).map((g)=>g.name).toList();
    factors.add(_AssessmentFactor('Retrograde planets','Evaluated',retro.isEmpty?'No retrograde planets are flagged by the current chart data.':'Retrograde: ${retro.join(', ')}. Retrogression alone is not classified as good or bad.'));
    factors.add(const _AssessmentFactor('Combust planets','Not evaluated','The current chart model does not expose a validated combustion calculation. This factor is intentionally not inferred.'));
    final dignity=<String>[];
    for(final g in chart.grahas.where((g)=>ownSigns.containsKey(g.name))) {
      final state=g.signIndex==exalted[g.name]?'exalted':g.signIndex==debilitated[g.name]?'debilitated':ownSigns[g.name]!.contains(g.signIndex)?'own sign':'other sign';
      dignity.add('${g.name}: $state');
    }
    factors.add(_AssessmentFactor('Exaltation, debilitation and own signs','Evaluated',dignity.join(' · ')));
    factors.add(const _AssessmentFactor('Enemy sign and planetary friendship','Partial','Sign dignity is available, but a complete, source-validated natural and temporal friendship matrix is not implemented in this assessment.'));
    factors.add(const _AssessmentFactor('Yogakaraka classification','Partial','Kendra/Trikona ownership is visible. A complete functional benefic/malefic judgement requires additional school-specific rules.'));
    factors.add(_AssessmentFactor('Mahadasha and Antardasha','Evaluated',_currentDasha(result)));
    factors.add(const _AssessmentFactor('Most afflicted house','Not evaluated','No validated house-affliction scoring model is available. Empty houses are not automatically treated as afflicted.'));
    factors.add(const _AssessmentFactor('Most afflicted planet','Not evaluated','A complete affliction score requires validated aspects, combustion, dignity, conjunction and strength rules.'));
    factors.add(const _AssessmentFactor('Important Yogas','Partial','Existing Yoga screening is preliminary. It is not a complete Yoga judgement or a gemstone prescription.'));
    factors.add(const _AssessmentFactor('House, lord and significator','Partial','House lords and Graha Karakatvas can be reviewed, but significator strength and full Bhava assessment need additional rules.'));
    factors.add(const _AssessmentFactor('Badhaka and Maraka classification','Not evaluated','These classifications vary by tradition and are not currently validated for personalised gemstone decisions.'));
    factors.add(const _AssessmentFactor('Divisional chart condition','Partial','The app has divisional charts, but this assessment does not combine all Vargas into a validated remedy score. D9 can be reviewed separately.'));
    return factors;
  }

  String _currentDasha(BirthChartResult result) {
    final timeline=VimshottariDashaService.calculate(siderealMoonLongitude:result.siderealMoonLongitude,birthDate:result.birthLocal);
    final now=DateTime.now();
    final maha=timeline.mahadashaAt(now);
    final antar=timeline.antardashaAt(now);
    return 'Current calculated period: Mahadasha ${maha?.planet??'not available'}; Antardasha ${antar?.planet??'not available'}. This is contextual information, not a recommendation by itself.';
  }

  @override Widget build(BuildContext context)=>Scaffold(
    appBar:AppBar(title:const Text('Personalized Remedies',style:TextStyle(fontSize:17,fontWeight:FontWeight.w800))),
    body:_loading?const Center(child:CircularProgressIndicator(color:AppTheme.plum)):ListView(padding:const EdgeInsets.fromLTRB(17,8,17,28),children:[
      _intro(),
      const SizedBox(height:14),
      if(_profiles.isEmpty) _empty() else ...[
        const Text('Select saved Kundali',style:TextStyle(fontSize:13,fontWeight:FontWeight.w800)),
        const SizedBox(height:7),
        DropdownButtonFormField<String>(
          value:_selected?.id,
          isExpanded:true,
          decoration:const InputDecoration(border:OutlineInputBorder(),contentPadding:EdgeInsets.symmetric(horizontal:12,vertical:10)),
          items:_profiles.map((p)=>DropdownMenuItem(value:p.id,child:Text(p.name,overflow:TextOverflow.ellipsis))).toList(),
          onChanged:(id){final p=_profiles.where((x)=>x.id==id).firstOrNull;if(p!=null)_select(p);},
        ),
        if(_error!=null) Padding(padding:const EdgeInsets.only(top:10),child:Text(_error!,style:const TextStyle(color:Colors.red,fontSize:11))),
        if(_chart!=null)...[
          const SizedBox(height:14),_chartSummary(),
          const SizedBox(height:16),
          const Text('12-factor assessment from the PDF',style:TextStyle(fontSize:15,fontWeight:FontWeight.w900,color:AppTheme.ink)),
          const SizedBox(height:5),
          const Text('The source lists these checks for remedy selection. Each is labelled according to what this app can currently evaluate; unsupported factors are not guessed.',style:TextStyle(fontSize:10,height:1.5,color:AppTheme.muted)),
          const SizedBox(height:9),
          for(var i=0;i<_factors.length;i++) _factorCard(i+1,_factors[i]),
          const SizedBox(height:12),_recommendations(),
        ],
      ],
    ]),
  );

  Widget _intro()=>Container(padding:const EdgeInsets.all(15),decoration:BoxDecoration(gradient:const LinearGradient(colors:[Color(0xFF3D2D58),Color(0xFF7657A5)]),borderRadius:BorderRadius.circular(18)),child:const Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
    Text('Chart-based traditional reference',style:TextStyle(color:Color(0xFFFFDFA8),fontSize:10,fontWeight:FontWeight.w800)),
    SizedBox(height:6),Text('Understand the factors before considering a remedy.',style:TextStyle(color:Colors.white,fontSize:17,fontWeight:FontWeight.w900)),
    SizedBox(height:5),Text('This assessment explains available chart data. It does not prescribe gemstones or guarantee outcomes.',style:TextStyle(color:Color(0xFFECE4F5),fontSize:10,height:1.5)),
  ]));
  Widget _empty()=>Container(padding:const EdgeInsets.all(16),decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(15),border:Border.all(color:const Color(0xFFEAE5EF))),child:const Text('No saved birth profiles were found. Create and save a Kundali profile first, then return here to review its available factors.',style:TextStyle(fontSize:12,height:1.5,color:AppTheme.muted)));
  Widget _chartSummary()=>Container(padding:const EdgeInsets.all(14),decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(15),border:Border.all(color:const Color(0xFFEAE5EF))),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
    Text(_selected?.name??'Selected chart',style:const TextStyle(fontSize:14,fontWeight:FontWeight.w900)),
    const SizedBox(height:5),Text('Lagna: ${kundaliRashiNames[_chart!.kundaliChart.ascendantSignIndex]} · Moon: ${_chart!.rashi} · Nakshatra: ${_chart!.nakshatra}',style:const TextStyle(fontSize:10,color:AppTheme.muted)),
    Text('Birth place: ${_selected!.placeName}',style:const TextStyle(fontSize:10,color:AppTheme.muted)),
  ]));
  Widget _factorCard(int n,_AssessmentFactor f)=>Container(margin:const EdgeInsets.only(bottom:7),padding:const EdgeInsets.all(12),decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(13),border:Border.all(color:const Color(0xFFEAE5EF))),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
    Row(children:[Container(width:23,height:23,alignment:Alignment.center,decoration:BoxDecoration(color:const Color(0xFFF2EDF8),borderRadius:BorderRadius.circular(7)),child:Text('$n',style:const TextStyle(fontSize:10,fontWeight:FontWeight.w900,color:AppTheme.plum))),const SizedBox(width:8),Expanded(child:Text(f.title,style:const TextStyle(fontSize:11,fontWeight:FontWeight.w800))),Text(f.status,style:TextStyle(fontSize:9,fontWeight:FontWeight.w800,color:f.status=='Evaluated'?Colors.green:Colors.deepOrange))]),
    const SizedBox(height:6),Text(f.detail,style:const TextStyle(fontSize:10,height:1.45,color:AppTheme.muted)),
  ]));
  Widget _recommendations()=>Container(padding:const EdgeInsets.all(14),decoration:BoxDecoration(color:const Color(0xFFFFF6E8),borderRadius:BorderRadius.circular(15)),child:const Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
    Text('Traditional reference options',style:TextStyle(fontSize:13,fontWeight:FontWeight.w900,color:AppTheme.ink)),
    SizedBox(height:6),Text('Explore the Graha mantra, worship and gemstone catalogue for educational reference. A Lagna gemstone table or a weak/retrograde planet alone is not enough to determine suitability. The PDF cautions against stones for Maraka, Badhaka, debilitated or inauspicious planets.',style:TextStyle(fontSize:10,height:1.5,color:Color(0xFF795D36))),
  ]));

}

class _AssessmentFactor {
  const _AssessmentFactor(this.title,this.status,this.detail);
  final String title,status,detail;
}
