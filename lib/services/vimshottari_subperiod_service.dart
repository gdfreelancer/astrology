import '../models/vimshottari_timeline.dart';

/// Generates nested Vimshottari sub-periods using the 120-year proportional
/// sequence. The parent interval is divided exactly; the final child is
/// clamped to the parent's end to avoid accumulated rounding drift.
class VimshottariSubperiodService {
  VimshottariSubperiodService._();
  static const sequence=['Ketu','Venus','Sun','Moon','Mars','Rahu','Jupiter','Saturn','Mercury'];
  static const years=<String,int>{'Ketu':7,'Venus':20,'Sun':6,'Moon':10,'Mars':7,'Rahu':18,'Jupiter':16,'Saturn':19,'Mercury':17};
  static List<VimshottariPeriod> children(VimshottariPeriod parent) {
    final startIndex=sequence.indexOf(parent.planet);
    if(startIndex<0)return const [];
    final total=parent.end.difference(parent.start).inMicroseconds;
    var cursor=parent.start;
    final result=<VimshottariPeriod>[];
    for(var i=0;i<sequence.length;i++){
      final lord=sequence[(startIndex+i)%sequence.length];
      final end=i==sequence.length-1?parent.end:parent.start.add(Duration(microseconds:(total*years[lord]!/120).round() + result.fold<int>(0,(sum,p)=>sum+p.end.difference(p.start).inMicroseconds) - result.fold<int>(0,(sum,p)=>sum+p.end.difference(p.start).inMicroseconds)));
      final correctedEnd=i==sequence.length-1?parent.end:cursor.add(Duration(microseconds:(total*years[lord]!/120).round()));
      result.add(VimshottariPeriod(planet:lord,years:years[lord]!,start:cursor,end:correctedEnd.isAfter(parent.end)?parent.end:correctedEnd));
      cursor=result.last.end;
    }
    return result;
  }
}
