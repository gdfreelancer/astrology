import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/birth_chart_result.dart';

class KundaliPdfService {
  KundaliPdfService._();
  static Future<List<int>> build({required String name,required BirthChartResult result}) async {
    final document=pw.Document();
    final chart=result.kundaliChart;
    final date=result.birthLocal;
    document.addPage(pw.MultiPage(
      pageFormat:PdfPageFormat.a4,
      margin:const pw.EdgeInsets.all(34),
      build:(context)=>[
        pw.Header(level:0,child:pw.Text('Saral Jyotish',style:pw.TextStyle(fontSize:24,fontWeight:pw.FontWeight.bold))),
        pw.Text('Janma Kundali Report',style:pw.TextStyle(fontSize:17,fontWeight:pw.FontWeight.bold)),
        pw.SizedBox(height:8),
        pw.Text('Name: ${name.trim().isEmpty?'Not specified':name.trim()}'),
        pw.Text('Birth: ${date.day.toString().padLeft(2,'0')}/${date.month.toString().padLeft(2,'0')}/${date.year} at ${date.hour.toString().padLeft(2,'0')}:${date.minute.toString().padLeft(2,'0')}'),
        pw.Text('Place: ${result.placeName}'),
        pw.Text('Coordinates: ${result.latitude.toStringAsFixed(4)}, ${result.longitude.toStringAsFixed(4)} · ${result.timeZoneId}'),
        pw.Divider(),
        pw.Text('Birth details',style:pw.TextStyle(fontSize:14,fontWeight:pw.FontWeight.bold)),
        pw.Bullet(text:'Janma Rashi: ${result.rashi}'),
        pw.Bullet(text:'Nakshatra: ${result.nakshatra} · Pada ${result.pada}'),
        pw.Bullet(text:'Naming syllable: ${result.namingSyllable}'),
        pw.Bullet(text:'Ayanamsha (approx.): ${result.ayanamsha.toStringAsFixed(4)}°'),
        pw.SizedBox(height:12),
        pw.Text('D1 planetary placements',style:pw.TextStyle(fontSize:14,fontWeight:pw.FontWeight.bold)),
        pw.TableHelper.fromTextArray(
          headers:['Graha','Rashi','Longitude','House','Motion'],
          data:chart.grahas.map((g)=>[
            g.name,
            kundaliRashiNames[g.signIndex],
            '${(g.longitude%30).toStringAsFixed(2)}°',
            g.houseNumber.toString(),
            g.isRetrograde?'Retrograde':'Direct',
          ]).toList(),
          headerStyle:pw.TextStyle(fontWeight:pw.FontWeight.bold,fontSize:9),
          cellStyle:const pw.TextStyle(fontSize:8),
          border:pw.TableBorder.all(color:PdfColors.grey400,width:.4),
          cellPadding:const pw.EdgeInsets.all(5),
        ),
        pw.SizedBox(height:12),
        pw.Text('Whole-sign house placements',style:pw.TextStyle(fontSize:14,fontWeight:pw.FontWeight.bold)),
        pw.TableHelper.fromTextArray(
          headers:['House','Rashi','Grahas'],
          data:List.generate(12,(i){
            final house=i+1;
            final sign=(chart.ascendantSignIndex+i)%12;
            final occupants=chart.inHouse(house).map((g)=>g.name).join(', ');
            return [house.toString(),kundaliRashiNames[sign],occupants.isEmpty?'—':occupants];
          }),
          headerStyle:pw.TextStyle(fontWeight:pw.FontWeight.bold,fontSize:9),
          cellStyle:const pw.TextStyle(fontSize:8),
          border:pw.TableBorder.all(color:PdfColors.grey400,width:.4),
          cellPadding:const pw.EdgeInsets.all(5),
        ),
        pw.SizedBox(height:14),
        pw.Text('Calculation and interpretation note',style:pw.TextStyle(fontSize:12,fontWeight:pw.FontWeight.bold)),
        pw.Text('This report uses the app\'s current GeoEngine calculations and an approximate mean Lahiri ayanamsha. It is a traditional astrology reference, not a scientifically validated prediction. Birth-time accuracy, location, timezone and calculation conventions can affect results. Verify important decisions independently.'),
      ],
      footer:(context)=>pw.Align(alignment:pw.Alignment.centerRight,child:pw.Text('Page ${context.pageNumber} of ${context.pagesCount}',style:const pw.TextStyle(fontSize:8,color:PdfColors.grey600))),
    ));
    return document.save();
  }
}
