import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../models/matching/matching_report.dart';
import 'south_indian_porutham_service.dart';
import 'advanced_matching_service.dart';
import '../../models/kundali/kundali_graha.dart';

class MatchingPdfService {
  MatchingPdfService._();
  static String _status(bool? value) =>
      value == null ? 'Not available' : value ? 'Indicator present' : 'Not present';

  static String _sign(int? value) =>
      value == null ? '—' : kundaliRashiNames[value.clamp(0, 11).toInt()];

  static String _planets(List<String> values) =>
      values.isEmpty ? 'None listed' : values.join(', ');

  static String _profileSummary(HouseCompatibilityProfile profile) =>
      'Sign ${_sign(profile.seventhHouseSign)}; occupants: ${_planets(profile.seventhHouseOccupants)}; lord: ${profile.seventhLord ?? '—'} in house ${profile.seventhLordHouse ?? '—'} (${profile.seventhLordDignity ?? '—'}); house aspects: ${_planets(profile.seventhHouseAspectedBy)}; lord aspects: ${_planets(profile.seventhLordAspectedBy)}';

  static String _navamsaSummary(NavamsaCompatibilityProfile? profile) {
    if (profile == null) return 'Not available in saved chart';
    return 'D9 Lagna ${_sign(profile.ascendantSign)}; 7th sign ${_sign(profile.seventhHouseSign)}; occupants: ${_planets(profile.seventhHouseOccupants)}; lord: ${profile.seventhLord} in house ${profile.seventhLordHouse ?? '—'} (${profile.seventhLordDignity ?? '—'}); aspects: ${_planets(profile.seventhHouseAspectedBy)}';
  }

  static String _mitigationSummary(ManglikAssessment assessment) {
    if (assessment.mitigationIndicators.isEmpty) return 'No listed screening indicator';
    return assessment.mitigationIndicators.map((value) => switch (value) {
      'mars_own_sign' => 'Mars own sign',
      'mars_exalted_sign' => 'Mars exaltation sign',
      'jupiter_influence' => 'Jupiter conjunction/aspect',
      _ => value,
    }).join('; ');
  }

  static Future<Uint8List> build(MatchingReport report) async {
    final doc=pw.Document();
    final porutham=SouthIndianPoruthamService.calculate(bride:report.bride,groom:report.groom);
    final advanced=AdvancedMatchingService.calculate(bride:report.bride.kundaliChart,groom:report.groom.kundaliChart);
    doc.addPage(pw.MultiPage(
      pageFormat:PdfPageFormat.a4,
      margin:const pw.EdgeInsets.all(32),
      build:(context)=>[
        pw.Header(level:0,child:pw.Text('Saral Jyotish · Kundali Matching',style:pw.TextStyle(fontSize:20,fontWeight:pw.FontWeight.bold))),
        pw.Text('${report.bride.name}  ×  ${report.groom.name}',style:pw.TextStyle(fontSize:15,fontWeight:pw.FontWeight.bold)),
        pw.SizedBox(height:8),
        pw.Text('North Indian Ashtakoota: ${report.totalPoints.toStringAsFixed(1)} / 36'),
        pw.Text('Bride: ${report.bride.nakshatra} · ${report.bride.rashi}'),
        pw.Text('Groom: ${report.groom.nakshatra} · ${report.groom.rashi}'),
        pw.SizedBox(height:12),
        pw.Text('Ashtakoota breakdown',style:pw.TextStyle(fontSize:13,fontWeight:pw.FontWeight.bold)),
        pw.TableHelper.fromTextArray(
          headers:['Koota','Points','Maximum'],
          data:report.kootas.map((k)=>[k.name,k.points.toStringAsFixed(1),k.maxPoints.toStringAsFixed(0)]).toList(),
          headerStyle:pw.TextStyle(fontWeight:pw.FontWeight.bold,fontSize:9),
          cellStyle:const pw.TextStyle(fontSize:8),
          border:pw.TableBorder.all(color:PdfColors.grey400,width:.4),
          cellPadding:const pw.EdgeInsets.all(5),
        ),
        pw.SizedBox(height:14),
        pw.Text('South Indian 10 Porutham (directional)',style:pw.TextStyle(fontSize:13,fontWeight:pw.FontWeight.bold)),
        pw.Text('Total: ${porutham.total.toStringAsFixed(1)} / ${porutham.maximum.toStringAsFixed(0)} · Rajju ${porutham.rajjuClear?'clear':'same group'} · Vedha ${porutham.vedhaClear?'clear':'pair found'}'),
        pw.TableHelper.fromTextArray(
          headers:['Porutham','Score','Maximum','Basis'],
          data:porutham.items.map((p)=>[p.name,p.score.toStringAsFixed(1),p.maximum.toStringAsFixed(0),p.explanation]).toList(),
          headerStyle:pw.TextStyle(fontWeight:pw.FontWeight.bold,fontSize:8),
          cellStyle:const pw.TextStyle(fontSize:7),
          border:pw.TableBorder.all(color:PdfColors.grey400,width:.4),
          cellPadding:const pw.EdgeInsets.all(4),
        ),
        pw.SizedBox(height:14),
        pw.Text('Advanced D1 / Navamsa comparison (descriptive, not scored)',style:pw.TextStyle(fontSize:13,fontWeight:pw.FontWeight.bold)),
        pw.SizedBox(height:6),
        pw.TableHelper.fromTextArray(
          headers:['Factor','Bride','Groom'],
          data:[
            ['Manglik from Lagna',_status(advanced.brideManglik.fromLagna),_status(advanced.groomManglik.fromLagna)],
            ['Manglik from Moon',_status(advanced.brideManglik.fromMoon),_status(advanced.groomManglik.fromMoon)],
            ['Manglik from Venus',_status(advanced.brideManglik.fromVenus),_status(advanced.groomManglik.fromVenus)],
            ['D1 7th house',_profileSummary(advanced.brideSeventhHouse),_profileSummary(advanced.groomSeventhHouse)],
            ['D9 7th house',_navamsaSummary(advanced.brideNavamsa),_navamsaSummary(advanced.groomNavamsa)],
            ['Manglik review indicators',_mitigationSummary(advanced.brideManglik),_mitigationSummary(advanced.groomManglik)],
          ],
          headerStyle:pw.TextStyle(fontWeight:pw.FontWeight.bold,fontSize:8),
          cellStyle:const pw.TextStyle(fontSize:7),
          border:pw.TableBorder.all(color:PdfColors.grey400,width:.4),
          cellPadding:const pw.EdgeInsets.all(4),
        ),
        pw.SizedBox(height:14),
        pw.Text('Interpretation note',style:pw.TextStyle(fontSize:12,fontWeight:pw.FontWeight.bold)),
        pw.Text('The 36-point Ashtakoota and 28-point South Indian Porutham methods are separate traditions and their scores are not comparable. Rules vary by region and lineage. Manglik and seventh-house indicators are screening tools, not verdicts. A matching score cannot predict relationship success or replace the judgement, communication and consent of the people involved.'),
        pw.SizedBox(height:8),
        pw.Text('Calculation note: this report inherits the app’s current GeoEngine and approximate mean Lahiri ayanamsha. Confirm birth times, locations and tradition-specific rules before relying on the result.'),
      ],
      footer:(context)=>pw.Align(alignment:pw.Alignment.centerRight,child:pw.Text('Page ${context.pageNumber} of ${context.pagesCount}',style:const pw.TextStyle(fontSize:8,color:PdfColors.grey600))),
    ));
    return doc.save();
  }
}
