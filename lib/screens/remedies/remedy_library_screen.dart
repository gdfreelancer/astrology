import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../theme/app_theme.dart';
import 'remedy_data.dart';

enum RemedyLibrarySection { gemstones, mantras, yantras, rudraksha, navagraha, shani, kaalSarp }

class RemedyLibraryScreen extends StatefulWidget {
  const RemedyLibraryScreen({super.key, required this.section, this.grahaId});
  final RemedyLibrarySection section;
  final String? grahaId;
  @override State<RemedyLibraryScreen> createState() => _RemedyLibraryScreenState();
}

class _RemedyLibraryScreenState extends State<RemedyLibraryScreen> {
  final Map<String,int> _progress = {};
  final Set<String> _favourites = {};
  bool _loading = true;
  String _language = 'en';

  @override void initState() { super.initState(); _load(); }
  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    for (final g in remedyGrahas) {
      _progress[g.id] = p.getInt('remedy_mantra_count_${g.id}') ?? 0;
      if (p.getBool('remedy_mantra_fav_${g.id}') ?? false) _favourites.add(g.id);
    }
    if (mounted) setState(() => _loading = false);
  }
  Future<void> _setCount(String id, int value) async {
    final count = value.clamp(0, 100000000);
    setState(() => _progress[id] = count);
    final p = await SharedPreferences.getInstance();
    await p.setInt('remedy_mantra_count_$id', count);
  }
  Future<void> _toggleFavourite(String id) async {
    setState(() => _favourites.contains(id) ? _favourites.remove(id) : _favourites.add(id));
    final p = await SharedPreferences.getInstance();
    await p.setBool('remedy_mantra_fav_$id', _favourites.contains(id));
  }
  String get _title => switch(widget.section) {
    RemedyLibrarySection.gemstones => 'Gemstone Guide',
    RemedyLibrarySection.mantras => 'Mantra Library',
    RemedyLibrarySection.yantras => 'Yantra Library',
    RemedyLibrarySection.rudraksha => 'Rudraksha Guide',
    RemedyLibrarySection.navagraha => 'Navagraha Worship',
    RemedyLibrarySection.shani => 'Shani Dhaiya Remedies',
    RemedyLibrarySection.kaalSarp => 'Kaal Sarp Yoga Remedies',
  };

  @override Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child:CircularProgressIndicator()));
    return Scaffold(
      appBar: AppBar(title: Text(_title, style: const TextStyle(fontSize:17,fontWeight:FontWeight.w800))),
      body: ListView(padding: const EdgeInsets.fromLTRB(16,8,16,28), children: [
        _notice('Traditional Jyotish reference', 'Content transcribed from Ratna va Jyotishiya Upay, pages 6–25. Traditions vary; this information is not a guarantee or professional advice.'),
        const SizedBox(height:12),
        switch(widget.section) {
          RemedyLibrarySection.gemstones => _gemstoneList(),
          RemedyLibrarySection.mantras => _mantraList(),
          RemedyLibrarySection.yantras => _yantraList(),
          RemedyLibrarySection.rudraksha => _rudrakshaList(),
          RemedyLibrarySection.navagraha => _navagraha(),
          RemedyLibrarySection.shani => _shani(),
          RemedyLibrarySection.kaalSarp => _kaalSarp(),
        },
        const SizedBox(height:16),
        _caution(),
      ]),
    );
  }

  Widget _notice(String title, String body) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color:const Color(0xFFF3EEF8),borderRadius:BorderRadius.circular(15)),
    child: Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      Text(title,style:const TextStyle(fontSize:12,fontWeight:FontWeight.w800,color:AppTheme.plum)),
      const SizedBox(height:5),Text(body,style:const TextStyle(fontSize:10,height:1.5,color:AppTheme.muted)),
    ]),
  );
  Widget _caution()=>Container(
    padding:const EdgeInsets.all(13),
    decoration:BoxDecoration(color:const Color(0xFFFFF6E8),borderRadius:BorderRadius.circular(14)),
    child:const Text('Astrological remedies are presented as traditional cultural and religious references. They are not medical treatments, financial advice or guaranteed outcomes. Consult a qualified practitioner for tradition-specific guidance.',style:TextStyle(fontSize:10,height:1.5,color:Color(0xFF795D36))),
  );
  Widget _card({required String title,required String subtitle,required IconData icon,VoidCallback? onTap,Widget? trailing})=>Card(
    elevation:0, margin:const EdgeInsets.only(bottom:8), color:Colors.white,
    shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(14),side:const BorderSide(color:Color(0xFFEAE5EF))),
    child:ListTile(leading:Icon(icon,color:AppTheme.plum),title:Text(title,style:const TextStyle(fontSize:12,fontWeight:FontWeight.w800)),subtitle:Text(subtitle,style:const TextStyle(fontSize:10,color:AppTheme.muted)),trailing:trailing??const Icon(Icons.chevron_right_rounded),onTap:onTap),
  );

  Widget _gemstoneList()=>Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
    const Text('Nine traditional Graha gemstones',style:TextStyle(fontSize:15,fontWeight:FontWeight.w800,color:AppTheme.ink)),
    const SizedBox(height:8),
    for(final g in gemstones) _card(title:'${g.name} · ${g.hindi}',subtitle:'${g.graha} · ${g.colour}',icon:Icons.diamond_outlined,onTap:()=>_showGemstone(g)),
    const SizedBox(height:12),
    const Text('Gemstones by Lagna',style:TextStyle(fontSize:15,fontWeight:FontWeight.w800,color:AppTheme.ink)),
    const SizedBox(height:6),
    const Text('The table below reproduces the PDF’s three categories. It is a source reference only, not a personal prescription.',style:TextStyle(fontSize:10,color:AppTheme.muted,height:1.4)),
    const SizedBox(height:8),
    for(final l in lagnaGemstones) Container(
      margin:const EdgeInsets.only(bottom:7),padding:const EdgeInsets.all(12),
      decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(13),border:Border.all(color:const Color(0xFFEAE5EF))),
      child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Text(l.name,style:const TextStyle(fontSize:12,fontWeight:FontWeight.w800,color:AppTheme.plum)),
        const SizedBox(height:6),
        _kv('Jeevan Ratna',l.life),_kv('Karak Ratna',l.karaka),_kv('Bhagya Ratna',l.fortune),
      ]),
    ),
    const SizedBox(height:8),
    _card(title:'Navratna arrangement',subtitle:'Nine-stone arrangement shown on PDF page 15',icon:Icons.grid_3x3,onTap:()=>_showNavratna()),
  ]);
  Widget _kv(String k,String v)=>Padding(padding:const EdgeInsets.symmetric(vertical:2),child:Row(children:[Expanded(child:Text(k,style:const TextStyle(fontSize:10,color:AppTheme.muted))),Text(v,style:const TextStyle(fontSize:10,fontWeight:FontWeight.w700,color:AppTheme.ink))]));

  void _showGemstone(GemstoneInfo g)=>showModalBottomSheet<void>(context:context,isScrollControlled:true,backgroundColor:Colors.transparent,builder:(ctx)=>Container(
    height:MediaQuery.of(ctx).size.height*.82,padding:const EdgeInsets.fromLTRB(18,18,18,26),
    decoration:const BoxDecoration(color:Color(0xFFFFFCF8),borderRadius:BorderRadius.vertical(top:Radius.circular(24))),
    child:SafeArea(top:false,child:ListView(children:[
      Center(child:Container(width:38,height:4,decoration:BoxDecoration(color:const Color(0xFFD9D1DF),borderRadius:BorderRadius.circular(8)))),
      const SizedBox(height:16),Text(g.name,style:const TextStyle(fontSize:22,fontWeight:FontWeight.w900,color:AppTheme.ink)),
      Text('${g.hindi} · Associated Graha: ${g.graha}',style:const TextStyle(fontSize:11,color:AppTheme.muted)),
      const SizedBox(height:14),
      _kv('Traditional weight',g.weight),_kv('Metal',g.metal),_kv('Finger',g.finger),_kv('Weekday',g.weekday),_kv('Time',g.time),_kv('Traditional lifespan',g.lifespan),_kv('PDF-listed combinations to avoid',g.avoid),
      const SizedBox(height:12),Text(g.note,style:const TextStyle(fontSize:10,height:1.5,color:AppTheme.muted)),
      const SizedBox(height:12),_notice('Suitability warning','Do not wear this stone based only on Sun sign, Moon sign or Lagna. The source advises checking functional lordship, Maraka/Badhaka status, dignity, Dasha and the whole chart. This app does not certify gemstone suitability.'),
    ])),
  ));
  void _showNavratna()=>showModalBottomSheet<void>(context:context,isScrollControlled:true,backgroundColor:Colors.transparent,builder:(ctx)=>Container(
    padding:const EdgeInsets.all(20),decoration:const BoxDecoration(color:Color(0xFFFFFCF8),borderRadius:BorderRadius.vertical(top:Radius.circular(24))),
    child:SafeArea(child:Column(mainAxisSize:MainAxisSize.min,children:[
      const Text('Navratna arrangement',style:TextStyle(fontSize:18,fontWeight:FontWeight.w900)),
      const SizedBox(height:6),const Text('Transcribed from PDF page 15. The source describes a nine-stone ring or pendant.',style:TextStyle(fontSize:10,color:AppTheme.muted)),
      const SizedBox(height:14),
      for(final row in navratnaArrangement) Row(children:[for(final stone in row) Expanded(child:Container(margin:const EdgeInsets.all(3),padding:const EdgeInsets.symmetric(vertical:16,horizontal:4),decoration:BoxDecoration(color:const Color(0xFFF3EEF8),borderRadius:BorderRadius.circular(10)),child:Text(stone,textAlign:TextAlign.center,style:const TextStyle(fontSize:9,fontWeight:FontWeight.w700))))]),
    ])),
  ));
  Widget _mantraList()=>Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
    const Text('Navagraha mantra reference',style:TextStyle(fontSize:15,fontWeight:FontWeight.w800,color:AppTheme.ink)),
    const SizedBox(height:5),const Text('The counts below are the traditional counts printed on PDF page 9. They are not universal requirements.',style:TextStyle(fontSize:10,color:AppTheme.muted,height:1.4)),
    const SizedBox(height:10),
    for(final g in remedyGrahas) _mantraCard(g),
    _card(title:'Navagraha Shanti Shloka',subtitle:'Collective prayer from PDF page 6',icon:Icons.self_improvement,onTap:()=>_showShloka()),
  ]);
  Widget _mantraCard(RemedyGraha g) {
    final done=_progress[g.id]??0;
    return Container(margin:const EdgeInsets.only(bottom:9),padding:const EdgeInsets.all(13),decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(14),border:Border.all(color:const Color(0xFFEAE5EF))),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      Row(children:[Expanded(child:Text(g.name,style:const TextStyle(fontSize:12,fontWeight:FontWeight.w800))),IconButton(visualDensity:VisualDensity.compact,onPressed:()=>_toggleFavourite(g.id),icon:Icon(_favourites.contains(g.id)?Icons.favorite:Icons.favorite_border,color:AppTheme.plum,size:19))]),
      SelectableText(g.mantra,textAlign:TextAlign.center,style:const TextStyle(fontSize:17,height:1.5,fontWeight:FontWeight.w800,color:AppTheme.plum)),
      const SizedBox(height:5),Text('Traditional count: ${g.count.toString()} · ${g.weekday}',style:const TextStyle(fontSize:10,color:AppTheme.muted)),
      const SizedBox(height:8),LinearProgressIndicator(value:(done/g.count).clamp(0,1).toDouble(),minHeight:5,backgroundColor:const Color(0xFFEDE7F2),color:AppTheme.plum,borderRadius:BorderRadius.circular(8)),
      const SizedBox(height:6),Row(children:[Expanded(child:Text('$done / ${g.count} completed',style:const TextStyle(fontSize:10,fontWeight:FontWeight.w700))),IconButton(tooltip:'Undo one',onPressed:done==0?null:()=>_setCount(g.id,done-1),icon:const Icon(Icons.remove_circle_outline,size:19)),IconButton(tooltip:'Add one',onPressed:()=>_setCount(g.id,done+1),icon:const Icon(Icons.add_circle_outline,size:19)),TextButton(onPressed:()=>_customCount(g.id,done),child:const Text('Add count'))]),
      Align(alignment:Alignment.centerRight,child:TextButton(onPressed:()=>_resetCount(g.id),child:const Text('Reset progress',style:TextStyle(fontSize:10)))),
    ]));
  }
  Future<void> _customCount(String id,int current) async {
    final c=TextEditingController(text:'108');
    final value=await showDialog<int>(context:context,builder:(ctx)=>AlertDialog(title:const Text('Add chanting count'),content:TextField(controller:c,keyboardType:TextInputType.number,decoration:const InputDecoration(labelText:'Repetitions')),actions:[TextButton(onPressed:()=>Navigator.pop(ctx),child:const Text('Cancel')),FilledButton(onPressed:()=>Navigator.pop(ctx,int.tryParse(c.text)),child:const Text('Add'))]));
    c.dispose();if(value!=null&&value>0)await _setCount(id,current+value);
  }
  Future<void> _resetCount(String id) async {
    final yes=await showDialog<bool>(context:context,builder:(ctx)=>AlertDialog(title:const Text('Reset progress?'),content:const Text('This clears the saved total for this mantra.'),actions:[TextButton(onPressed:()=>Navigator.pop(ctx,false),child:const Text('Cancel')),FilledButton(onPressed:()=>Navigator.pop(ctx,true),child:const Text('Reset'))]));
    if(yes==true)await _setCount(id,0);
  }
  void _showShloka()=>showModalBottomSheet<void>(context:context,isScrollControlled:true,backgroundColor:Colors.transparent,builder:(ctx)=>Container(padding:const EdgeInsets.all(22),decoration:const BoxDecoration(color:Color(0xFFFFFCF8),borderRadius:BorderRadius.vertical(top:Radius.circular(24))),child:SafeArea(child:Column(mainAxisSize:MainAxisSize.min,children:[
    const Text('Navagraha Shanti Shloka',style:TextStyle(fontSize:18,fontWeight:FontWeight.w900)),
    const SizedBox(height:14),const SelectableText(navagrahaShanti,textAlign:TextAlign.center,style:TextStyle(fontSize:18,height:1.8,fontWeight:FontWeight.w800,color:AppTheme.plum)),
    const SizedBox(height:10),const Text(navagrahaMeaning,textAlign:TextAlign.center,style:TextStyle(fontSize:11,color:AppTheme.muted,height:1.5)),
  ]))));
  Widget _yantraList()=>Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
    _card(title:'Navagraha Yantra',subtitle:'The PDF includes a Navagraha Yantra illustration on page 8',icon:Icons.grid_on,onTap:()=>_showText('Navagraha Yantra','The source describes yantras on paper, Bhojpatra, copper, gold or silver. It says mantra, suitable Nakshatra, Tithi and Yoga are considered in preparation and purification. The supplied PDF image should be used as the reference artwork.')),
    _notice('Content limitation','The PDF does not supply nine complete individual Graha Yantra diagrams with verified inscriptions. This library therefore does not invent missing diagrams or yantra grids.'),
  ]);
  Widget _rudrakshaList()=>Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
    const Text('Rudraksha catalogue',style:TextStyle(fontSize:15,fontWeight:FontWeight.w800)),
    const SizedBox(height:5),const Text('The PDF page 20 illustrates Gauri Shankar and 1–15 Mukhi Rudraksha. It does not provide Mukhi-wise benefits or detailed wearing instructions.',style:TextStyle(fontSize:10,color:AppTheme.muted,height:1.5)),
    const SizedBox(height:10),
    for(final name in rudrakshaNames) _card(title:name,subtitle:'Illustrated in the source; detailed properties not supplied',icon:Icons.circle_outlined,onTap:()=>_showText(name,'The uploaded PDF shows this Rudraksha illustration but does not provide a detailed description, deity association or wearing rule for this entry. No additional benefit is inferred.')),
  ]);
  Widget _navagraha()=>Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
    const Text('Navagraha Shanti',style:TextStyle(fontSize:16,fontWeight:FontWeight.w800)),
    const SizedBox(height:10),_card(title:'Shanti Shloka',subtitle:'Sanskrit verse and meaning',icon:Icons.self_improvement,onTap:()=>_showShloka()),
    _notice('Traditional worship sequence','PDF page 6 describes Graha worship, mantra japa, Dashansh Homa, Tarpan, Marjan and Brahmin Bhojan as a traditional sequence. These are not mandatory steps for every user; ritual practice should be guided by a knowledgeable practitioner.'),
    const SizedBox(height:10),
    for(final g in remedyGrahas) _card(title:g.name,subtitle:'Deity associations: ${g.deities}',icon:Icons.temple_outlined,onTap:()=>_showText(g.name,'Associated deities listed by the source: ${g.deities}. The PDF labels this as a traditional source-specific association, including Lal Kitab references.')),
  ]);
  Widget _shani()=>Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
    const Text('Three-phase traditional reference',style:TextStyle(fontSize:15,fontWeight:FontWeight.w800)),
    const SizedBox(height:5),const Text('The table reproduces PDF page 21. It is a traditional classification, not a forecast of events.',style:TextStyle(fontSize:10,color:AppTheme.muted)),
    const SizedBox(height:10),
    Container(padding:const EdgeInsets.all(10),decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(14),border:Border.all(color:const Color(0xFFEAE5EF))),child:Column(children:[
      const Row(children:[Expanded(flex:2,child:Text('Moon sign',style:TextStyle(fontSize:9,fontWeight:FontWeight.w800))),Expanded(child:Text('Phase 1',style:TextStyle(fontSize:9,fontWeight:FontWeight.w800))),Expanded(child:Text('Phase 2',style:TextStyle(fontSize:9,fontWeight:FontWeight.w800))),Expanded(child:Text('Phase 3',style:TextStyle(fontSize:9,fontWeight:FontWeight.w800)))]),
      const Divider(),
      for(final e in shaniDhaiya.entries) Padding(padding:const EdgeInsets.symmetric(vertical:5),child:Row(children:[
        Expanded(flex:2,child:Text(e.key,style:const TextStyle(fontSize:10,fontWeight:FontWeight.w700))),
        for(final v in e.value) Expanded(child:Text(v,style:TextStyle(fontSize:9,fontWeight:FontWeight.w700,color:v=='Favourable'?Colors.green:v=='Unfavourable'?Colors.deepOrange:AppTheme.muted))),
      ])),
    ])),
    const SizedBox(height:12),const Text('Remedies listed by the PDF',style:TextStyle(fontSize:14,fontWeight:FontWeight.w800)),
    for(final item in shaniRemedies) _card(title:item,subtitle:'Traditional reference · PDF page 22',icon:Icons.spa_outlined,onTap:()=>_showText(item,'This remedy is listed on PDF page 22. It is a traditional religious practice, not a guaranteed way to change transit outcomes. The PDF’s Blue Sapphire suggestion is conditional on Shani being Yogakaraka; do not use it as an automatic recommendation.')),
  ]);
  Widget _kaalSarp()=>Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
    _notice('About this reference','PDF page 23 lists traditional beliefs about Kaal Sarp Yoga. These effects are not predictions and should not be used to label a person or cause fear. Detection rules vary by tradition and require validation.'),
    const SizedBox(height:10),const Text('Remedies listed by the PDF',style:TextStyle(fontSize:14,fontWeight:FontWeight.w800)),
    for(final item in kaalSarpRemedies) _card(title:item,subtitle:'Traditional reference · PDF page 24',icon:Icons.spa_outlined,onTap:()=>_showText(item,'This item is transcribed or summarized from PDF page 24. It is a traditional devotional reference, not a guaranteed remedy. The source mentions feeding milk to snakes; this app does not endorse approaching or feeding wild animals.')),
  ]);
  void _showText(String title,String body)=>showModalBottomSheet<void>(context:context,backgroundColor:Colors.transparent,builder:(ctx)=>Container(padding:const EdgeInsets.all(20),decoration:const BoxDecoration(color:Color(0xFFFFFCF8),borderRadius:BorderRadius.vertical(top:Radius.circular(24))),child:SafeArea(child:Column(mainAxisSize:MainAxisSize.min,crossAxisAlignment:CrossAxisAlignment.start,children:[Text(title,style:const TextStyle(fontSize:18,fontWeight:FontWeight.w900)),const SizedBox(height:10),Text(body,style:const TextStyle(fontSize:12,height:1.6,color:AppTheme.muted)),const SizedBox(height:12)]))));
}
