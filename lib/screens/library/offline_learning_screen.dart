import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/app_theme.dart';

class OfflineLearningScreen extends StatefulWidget {
  const OfflineLearningScreen({super.key});
  @override State<OfflineLearningScreen> createState()=>_OfflineLearningScreenState();
}
class _OfflineLearningScreenState extends State<OfflineLearningScreen> {
  static const _key='saral_jyotish_diary_v1';
  final _note=TextEditingController();
  List<Map<String,dynamic>> _entries=[];
  bool _loading=true;
  int _tab=0;
  static const _lessons=<({String title,String body})>[
    (title:'The nine Grahas',body:'Surya, Chandra, Mangala, Budha, Guru, Shukra, Shani, Rahu and Ketu are interpreted through sign, house, dignity, aspects, strength and Dasha. A single placement should not be read in isolation.'),
    (title:'The twelve Rashis',body:'The zodiac is divided into twelve equal 30-degree signs. Each sign has an element, modality and planetary ruler. The same planet can express differently in different signs.'),
    (title:'The twelve Bhavas',body:'Houses describe life topics: identity, resources, communication, home, creativity, health and service, partnership, transformation, dharma, career, gains and release. House results depend on the whole chart.'),
    (title:'The 27 Nakshatras',body:'Ashwini, Bharani, Krittika, Rohini, Mrigashira, Ardra, Punarvasu, Pushya, Ashlesha, Magha, Purva Phalguni, Uttara Phalguni, Hasta, Chitra, Swati, Vishakha, Anuradha, Jyeshtha, Mula, Purva Ashadha, Uttara Ashadha, Shravana, Dhanishta, Shatabhisha, Purva Bhadrapada, Uttara Bhadrapada and Revati. Each spans 13°20′ and has four padas.'),
    (title:'Ashtakavarga',body:'Bhinna Ashtakavarga counts bindus for each of the seven classical planets using eight contributors (seven planets and Lagna). Sarvashtakavarga adds the seven tables by sign. Traditional totals are fixed; different table variants can shift a few bindus.'),
    (title:'Graha Drishti',body:'All seven classical Grahas have a 7th aspect in the common Parashari system. Mars additionally aspects the 4th and 8th, Jupiter the 5th and 9th, and Saturn the 3rd and 10th. Rahu and Ketu special aspects vary by lineage.'),
    (title:'Shadbala',body:'Shadbala is a six-fold strength calculation: Sthana, Dig, Kala, Cheshta, Naisargika and Drik Bala. It requires exact astronomical and chart geometry; simplified dignity or house position alone is not a Shadbala score.'),
    (title:'Divisional charts',body:'Vargas divide the zodiac into finer parts. D9 (Navamsa) and D10 (Dasamsa) are commonly consulted alongside D1. Higher divisional charts are especially sensitive to birth-time accuracy and different calculation traditions.'),
    (title:'Kundali matching methods',body:'North Indian Ashtakoota scores eight kootas out of 36. South Indian Porutham uses a separate directional set of ten checks. These totals are not comparable and neither method alone determines relationship outcomes.'),
    (title:'Jyotish glossary',body:'Lagna: Ascendant. Rashi: sidereal sign. Bhava: house. Graha: planetary indicator. Nakshatra: lunar mansion. Pada: one quarter of a Nakshatra. Gochar: transit. Dasha: planetary period. Yoga: planetary combination. Dosha: a traditional affliction concept. Ayanamsha: offset between tropical and sidereal zodiacs.'),
    (title:'The 27 Nakshatras',body:'Each Nakshatra spans 13°20′ and is divided into four padas. The Moon’s sidereal Nakshatra is the starting point for traditional Vimshottari Dasha.'),
    (title:'Vimshottari Dasha',body:'The 120-year cycle begins from the lord of the Moon’s birth Nakshatra. Remaining balance is proportional to the untraversed part of that Nakshatra.'),
    (title:'Gochar and Sade Sati',body:'Gochar studies current planetary positions relative to natal placements. Sade Sati describes Saturn’s passage through the 12th, 1st and 2nd signs from the natal Moon in a common tradition.'),
    (title:'Panchang basics',body:'Panchang combines Tithi, Vara, Nakshatra, Yoga and Karana. Their transitions are time- and location-dependent, especially when a day is judged from local sunrise.'),
    (title:'Yoga and Dosha',body:'Yogas are combinations with specific conditions; Dosha rules vary across schools. Check dignity, lordship, aspects, strength, cancellation and divisional charts before drawing conclusions.'),
  ];
  static const _mantras=<({String planet,String mantra,String use,String note})>[
    (planet:'Surya',mantra:'ॐ घृणिः सूर्याय नमः',use:'Traditionally recited at sunrise for Surya upasana, gratitude and discipline.',note:'Face the morning Sun only when comfortable; never look directly at the Sun.'),
    (planet:'Chandra',mantra:'ॐ सोमाय नमः',use:'Traditionally used on Mondays or during Chandra worship for calmness and emotional steadiness.',note:'A devotional practice; not a medical treatment.'),
    (planet:'Mangala',mantra:'ॐ अं अंगारकाय नमः',use:'Traditionally recited on Tuesdays for courage, patience and disciplined action.',note:'Choose a simple, consistent practice rather than fear-based remedies.'),
    (planet:'Budha',mantra:'ॐ बुं बुधाय नमः',use:'Traditionally recited on Wednesdays for learning, speech and clear thinking.',note:'A mantra does not replace study or professional advice.'),
    (planet:'Guru',mantra:'ॐ बृं बृहस्पतये नमः',use:'Traditionally recited on Thursdays for wisdom, teaching and guidance.',note:'Traditions differ in bija pronunciation and initiation requirements.'),
    (planet:'Shukra',mantra:'ॐ शुं शुक्राय नमः',use:'Traditionally recited on Fridays for harmony, refinement and gratitude.',note:'Do not treat gemstones or rituals as guaranteed outcomes.'),
    (planet:'Shani',mantra:'ॐ शं शनैश्चराय नमः',use:'Traditionally recited on Saturdays for patience, responsibility and service.',note:'Avoid fear-driven claims about Saturn or Sade Sati.'),
    (planet:'Rahu',mantra:'ॐ रां राहवे नमः',use:'Traditionally used in Rahu worship, often on Saturdays; practices vary by lineage.',note:'Bija mantras may be lineage-specific; a simple nama mantra is a conservative option.'),
    (planet:'Ketu',mantra:'ॐ कें केतवे नमः',use:'Traditionally used in Ketu worship for detachment and spiritual reflection.',note:'Rahu/Ketu practices vary considerably among traditions.'),
    (planet:'Navagraha',mantra:'ॐ आदित्याय च सोमाय मङ्गलाय बुधाय च । गुरु शुक्र शनिभ्यश्च राहवे केतवे नमः ॥',use:'A traditional collective salutation to the nine Grahas when no single Graha focus is intended.',note:'Use a trusted text for exact recitation and pronunciation.'),
  ];
  @override void initState(){super.initState();_load();}
  @override void dispose(){_note.dispose();super.dispose();}
  Future<void> _load() async {
    final p=await SharedPreferences.getInstance();
    try {
      final raw=p.getString(_key);
      final decoded=raw==null?[]:jsonDecode(raw) as List<dynamic>;
      _entries=decoded.map((e)=>Map<String,dynamic>.from(e as Map)).toList();
    } catch (_) {_entries=[];}
    if(mounted)setState(()=>_loading=false);
  }
  Future<void> _save() async {
    final p=await SharedPreferences.getInstance();
    await p.setString(_key,jsonEncode(_entries));
  }
  Future<void> _addNote() async {
    final text=_note.text.trim();
    if(text.isEmpty)return;
    setState(() {
      _entries.insert(0,{'text':text,'created':DateTime.now().toIso8601String()});
      _note.clear();
    });
    await _save();
  }
  Future<void> _delete(int index) async {
    setState(()=>_entries.removeAt(index));
    await _save();
  }
  @override Widget build(BuildContext context)=>Scaffold(
    appBar:AppBar(title:const Text('Offline Jyotish library',style:TextStyle(fontSize:17,fontWeight:FontWeight.w800))),
    body:Column(children:[
      Padding(padding:const EdgeInsets.fromLTRB(16,8,16,12),child:SegmentedButton<int>(
        segments:const [
          ButtonSegment(value:0,label:Text('Learn'),icon:Icon(Icons.menu_book_outlined)),
          ButtonSegment(value:1,label:Text('Mantras'),icon:Icon(Icons.self_improvement)),
          ButtonSegment(value:2,label:Text('Diary'),icon:Icon(Icons.edit_note)),
        ],
        selected:{_tab},onSelectionChanged:(s)=>setState(()=>_tab=s.first),
      )),
      Expanded(child:IndexedStack(index:_tab,children:[
        _learning(),_mantras(),_diary(),
      ])),
    ]),
  );
  Widget _learning()=>ListView(padding:const EdgeInsets.fromLTRB(16,4,16,24),children:[
    const Text('Learn Jyotish offline',style:TextStyle(fontSize:17,fontWeight:FontWeight.w800,color:AppTheme.ink)),
    const SizedBox(height:5),const Text('Short reference lessons stored on this device.',style:TextStyle(fontSize:11,color:AppTheme.muted)),
    const SizedBox(height:12),
    for(final lesson in _lessons) Card(elevation:0,color:Colors.white,shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(14),side:const BorderSide(color:Color(0xFFEAE5EF))),child:ExpansionTile(title:Text(lesson.title,style:const TextStyle(fontSize:12,fontWeight:FontWeight.w800)),childrenPadding:const EdgeInsets.fromLTRB(15,0,15,15),children:[Text(lesson.body,style:const TextStyle(fontSize:11,height:1.5,color:AppTheme.muted))])),
  ]);
  Widget _mantras()=>ListView(padding:const EdgeInsets.fromLTRB(16,4,16,24),children:[
    const Text('Traditional mantra reference',style:TextStyle(fontSize:17,fontWeight:FontWeight.w800,color:AppTheme.ink)),
    const SizedBox(height:5),const Text('Common devotional options and customary contexts. Mantra traditions and pronunciation may differ.',style:TextStyle(fontSize:11,color:AppTheme.muted)),
    const SizedBox(height:12),
    for(final item in _mantras) Card(elevation:0,color:Colors.white,shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(14),side:const BorderSide(color:Color(0xFFEAE5EF))),child:ExpansionTile(title:Text(item.planet,style:const TextStyle(fontSize:12,fontWeight:FontWeight.w800)),subtitle:Text(item.mantra,style:const TextStyle(fontSize:13,color:AppTheme.plum)),childrenPadding:const EdgeInsets.fromLTRB(15,0,15,15),children:[
      Align(alignment:Alignment.centerLeft,child:Text('When traditionally used',style:TextStyle(fontSize:10,fontWeight:FontWeight.w800,color:AppTheme.ink))),
      const SizedBox(height:4),Text(item.use,style:const TextStyle(fontSize:11,height:1.45,color:AppTheme.muted)),
      const SizedBox(height:8),Text(item.note,style:const TextStyle(fontSize:10,height:1.4,color:Color(0xFF8B6A3C))),
    ])),
  ]);
  Widget _diary()=>_loading?const Center(child:CircularProgressIndicator(color:AppTheme.plum)):ListView(padding:const EdgeInsets.fromLTRB(16,4,16,24),children:[
    const Text('Personal astrology diary',style:TextStyle(fontSize:17,fontWeight:FontWeight.w800,color:AppTheme.ink)),
    const SizedBox(height:5),const Text('Private notes are saved locally on this device. They are not uploaded or synced.',style:TextStyle(fontSize:11,color:AppTheme.muted)),
    const SizedBox(height:12),
    TextField(controller:_note,minLines:3,maxLines:6,decoration:const InputDecoration(hintText:'Write an observation, event or Dasha / transit note…',alignLabelWithHint:true)),
    const SizedBox(height:8),SizedBox(height:44,child:FilledButton.icon(onPressed:_addNote,icon:const Icon(Icons.add),label:const Text('Save note'),style:FilledButton.styleFrom(backgroundColor:AppTheme.plum))),
    const SizedBox(height:16),
    if(_entries.isEmpty) const Center(child:Padding(padding:EdgeInsets.all(24),child:Text('No diary notes yet.',style:TextStyle(color:AppTheme.muted,fontSize:12)))),
    for(var i=0;i<_entries.length;i++) Card(elevation:0,color:Colors.white,shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(13),side:const BorderSide(color:Color(0xFFEAE5EF))),child:ListTile(title:Text(_entries[i]['text'] as String,style:const TextStyle(fontSize:11,height:1.4)),subtitle:Text((_entries[i]['created'] as String).substring(0,16).replaceFirst('T',' · '),style:const TextStyle(fontSize:9,color:AppTheme.muted)),trailing:IconButton(onPressed:()=>_delete(i),icon:const Icon(Icons.delete_outline,color:AppTheme.muted,size:19)))),
  ]);
}
