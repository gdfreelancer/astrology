import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import 'personalized_remedies_screen.dart';
import 'remedy_library_screen.dart';

class RemediesHomeScreen extends StatelessWidget {
  const RemediesHomeScreen({super.key});

  void _open(BuildContext context, RemedyLibrarySection section) =>
      Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (_) => RemedyLibraryScreen(section: section),
      ));

  @override Widget build(BuildContext context)=>Scaffold(
    appBar:AppBar(title:const Text('Remedies',style:TextStyle(fontSize:18,fontWeight:FontWeight.w900))),
    body:ListView(padding:const EdgeInsets.fromLTRB(17,8,17,28),children:[
      Container(padding:const EdgeInsets.all(17),decoration:BoxDecoration(
        borderRadius:BorderRadius.circular(19),
        gradient:const LinearGradient(begin:Alignment.topLeft,end:Alignment.bottomRight,colors:[Color(0xFF302544),Color(0xFF7656A7)]),
      ),child:const Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Text('Traditional Jyotish references',style:TextStyle(color:Color(0xFFFFDCA0),fontSize:10,fontWeight:FontWeight.w800,letterSpacing:.5)),
        SizedBox(height:7),Text('Explore remedies with context.',style:TextStyle(color:Colors.white,fontSize:21,fontWeight:FontWeight.w900)),
        SizedBox(height:6),Text('Mantras, gemstones, worship and traditional guidance from your offline library.',style:TextStyle(color:Color(0xFFE8DFF3),fontSize:11,height:1.5)),
      ])),
      const SizedBox(height:14),
      _personalCard(context),
      const SizedBox(height:18),
      const Text('Reference libraries',style:TextStyle(fontSize:15,fontWeight:FontWeight.w900,color:AppTheme.ink)),
      const SizedBox(height:9),
      _tile(context,'Gemstone Guide','Nine gemstones, Lagna table and wearing references',Icons.diamond_outlined,RemedyLibrarySection.gemstones),
      _tile(context,'Mantra Library','Nine Graha mantras, source counts and local progress tracker',Icons.self_improvement,RemedyLibrarySection.mantras),
      _tile(context,'Navagraha Worship','Shanti Shloka, meaning and traditional worship sequence',Icons.temple_outlined,RemedyLibrarySection.navagraha),
      _tile(context,'Yantra Library','Navagraha Yantra and preparation notes',Icons.grid_on,RemedyLibrarySection.yantras),
      _tile(context,'Rudraksha Guide','Gauri Shankar and 1–15 Mukhi catalogue',Icons.circle_outlined,RemedyLibrarySection.rudraksha),
      _tile(context,'Shani Dhaiya','Three-phase Moon-sign reference and remedies',Icons.nights_stay_outlined,RemedyLibrarySection.shani),
      _tile(context,'Kaal Sarp Yoga','Traditional effects and remedy references',Icons.all_inclusive,RemedyLibrarySection.kaalSarp),
      const SizedBox(height:10),
      Container(padding:const EdgeInsets.all(13),decoration:BoxDecoration(color:const Color(0xFFFFF6E8),borderRadius:BorderRadius.circular(14)),child:const Text('Important: These are traditional religious and astrological references, not medical treatments or guaranteed outcomes. Personal gemstone suitability needs a complete chart review and qualified, tradition-specific judgement.',style:TextStyle(fontSize:10,height:1.5,color:Color(0xFF795D36)))),
    ]),
  );

  Widget _personalCard(BuildContext context)=>Material(
    color:const Color(0xFFF2EDF8),borderRadius:BorderRadius.circular(16),
    child:InkWell(borderRadius:BorderRadius.circular(16),onTap:()=>Navigator.of(context).push(MaterialPageRoute<void>(builder:(_)=>const PersonalizedRemediesScreen())),
      child:Padding(padding:const EdgeInsets.all(15),child:Row(children:[
        Container(width:43,height:43,decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(13)),child:const Icon(Icons.auto_awesome,color:AppTheme.plum)),
        const SizedBox(width:12),const Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
          Text('Personalized Remedies',style:TextStyle(fontSize:13,fontWeight:FontWeight.w900,color:AppTheme.ink)),
          SizedBox(height:3),Text('Review the 12 source criteria against a saved Kundali',style:TextStyle(fontSize:10,color:AppTheme.muted,height:1.35)),
        ])),const Icon(Icons.arrow_forward_ios_rounded,size:15,color:AppTheme.plum),
      ]))),
  );
  Widget _tile(BuildContext context,String title,String subtitle,IconData icon,RemedyLibrarySection section)=>Card(
    elevation:0,margin:const EdgeInsets.only(bottom:8),color:Colors.white,
    shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(14),side:const BorderSide(color:Color(0xFFEAE5EF))),
    child:ListTile(leading:Icon(icon,color:AppTheme.plum,size:22),title:Text(title,style:const TextStyle(fontSize:12,fontWeight:FontWeight.w800)),subtitle:Text(subtitle,style:const TextStyle(fontSize:10,color:AppTheme.muted)),trailing:const Icon(Icons.chevron_right_rounded),onTap:()=>_open(context,section)),
  );
}
