import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../models/matching/matching_report.dart';
import 'south_indian_porutham_service.dart';

class MatchingPdfService {
  MatchingPdfService._();
  static Future<Uint8List> build(MatchingReport report) async {
    final doc=pw.Document();
    final porutham=SouthIndianPoruthamService.calculate(bride:report.bride,groom:report.groom);
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
