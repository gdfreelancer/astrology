import 'package:flutter/material.dart';
import '../../l10n/app_locale.dart';
import '../../theme/app_theme.dart';
import 'personalized_remedies_screen.dart';
import 'remedy_library_screen.dart';

class RemediesHomeScreen extends StatelessWidget {
  const RemediesHomeScreen({super.key});
  void _open(BuildContext context, RemedyLibrarySection section) =>
      Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (_) => RemedyLibraryScreen(section: section),
      ));

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(context.tr('remedies'),
      style: const TextStyle(fontSize:18,fontWeight:FontWeight.w900))),
    body: ListView(padding: const EdgeInsets.fromLTRB(17,8,17,28), children: [
      Container(padding: const EdgeInsets.all(17), decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(19),
        gradient: const LinearGradient(begin: Alignment.topLeft,end: Alignment.bottomRight,
          colors: [Color(0xFF302544),Color(0xFF7656A7)]),
      ), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(context.tr('remedy_home_subtitle'),style: const TextStyle(color:Color(0xFFFFDCA0),fontSize:10,fontWeight:FontWeight.w800)),
        const SizedBox(height:7),
        Text(context.tr('remedy_intro_title'),style: const TextStyle(color:Colors.white,fontSize:21,fontWeight:FontWeight.w900)),
        const SizedBox(height:6),
        Text(context.tr('remedy_intro_body'),style: const TextStyle(color:Color(0xFFE8DFF3),fontSize:11,height:1.5)),
      ])),
      const SizedBox(height:14),
      Material(color:const Color(0xFFF2EDF8),borderRadius:BorderRadius.circular(16),
        child: InkWell(borderRadius:BorderRadius.circular(16),
          onTap:()=>Navigator.of(context).push(MaterialPageRoute<void>(builder:(_)=>const PersonalizedRemediesScreen())),
          child: Padding(padding:const EdgeInsets.all(15),child:Row(children:[
            Container(width:43,height:43,decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(13)),child:const Icon(Icons.auto_awesome,color:AppTheme.plum)),
            const SizedBox(width:12),
            Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
              Text(context.tr('personalized_remedies'),style:const TextStyle(fontSize:13,fontWeight:FontWeight.w900,color:AppTheme.ink)),
              const SizedBox(height:3),
              Text(context.tr('remedy_personalized_desc'),style:const TextStyle(fontSize:10,color:AppTheme.muted,height:1.35)),
            ])),
            const Icon(Icons.arrow_forward_ios_rounded,size:15,color:AppTheme.plum),
          ]))),
      ),
      const SizedBox(height:18),
      Text(context.tr('remedy_reference_libraries'),style:const TextStyle(fontSize:15,fontWeight:FontWeight.w900,color:AppTheme.ink)),
      const SizedBox(height:9),
      _tile(context,'gemstone_guide','gemstone_guide_desc',Icons.diamond_outlined,RemedyLibrarySection.gemstones),
      _tile(context,'mantra_library','mantra_library_desc',Icons.self_improvement,RemedyLibrarySection.mantras),
      _tile(context,'navagraha_worship','navagraha_worship_desc',Icons.temple_outlined,RemedyLibrarySection.navagraha),
      _tile(context,'yantra_library','yantra_library_desc',Icons.grid_on,RemedyLibrarySection.yantras),
      _tile(context,'rudraksha_guide','rudraksha_guide_desc',Icons.circle_outlined,RemedyLibrarySection.rudraksha),
      _tile(context,'shani_dhaiya','shani_dhaiya_desc',Icons.nights_stay_outlined,RemedyLibrarySection.shani),
      _tile(context,'kaal_sarp_remedies','kaal_sarp_desc',Icons.all_inclusive,RemedyLibrarySection.kaalSarp),
      const SizedBox(height:10),
      Container(padding:const EdgeInsets.all(13),decoration:BoxDecoration(color:const Color(0xFFFFF6E8),borderRadius:BorderRadius.circular(14)),
        child:Text(context.tr('remedy_traditional_notice'),style:const TextStyle(fontSize:10,height:1.5,color:Color(0xFF795D36)))),
    ]),
  );

  Widget _tile(BuildContext context,String titleKey,String subtitleKey,IconData icon,RemedyLibrarySection section)=>Card(
    elevation:0,margin:const EdgeInsets.only(bottom:8),color:Colors.white,
    shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(14),side:const BorderSide(color:Color(0xFFEAE5EF))),
    child:ListTile(leading:Icon(icon,color:AppTheme.plum,size:22),
      title:Text(context.tr(titleKey),style:const TextStyle(fontSize:12,fontWeight:FontWeight.w800)),
      subtitle:Text(context.tr(subtitleKey),style:const TextStyle(fontSize:10,color:AppTheme.muted)),
      trailing:const Icon(Icons.chevron_right_rounded),onTap:()=>_open(context,section)),
  );
}
