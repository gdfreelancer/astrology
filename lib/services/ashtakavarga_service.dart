import '../models/kundali/kundali_graha.dart';

class AshtakavargaResult {
  const AshtakavargaResult({required this.bhinna,required this.sarva});
  final Map<String,List<int>> bhinna;
  final List<int> sarva;
  int total(String graha)=>bhinna[graha]!.fold(0,(a,b)=>a+b);
}
/// Classical unreduced Parashari BAV tables. Rahu and Ketu are not contributors.
class AshtakavargaService {
  AshtakavargaService._();
  static const planets=['Sun','Moon','Mars','Mercury','Jupiter','Venus','Saturn'];
  static const sources=['Sun','Moon','Mars','Mercury','Jupiter','Venus','Saturn','Lagna'];
  static const expected={'Sun':48,'Moon':49,'Mars':39,'Mercury':54,'Jupiter':56,'Venus':52,'Saturn':39};
  static const rules=<String,List<List<int>>>{
    'Sun':[[1,2,4,7,8,9,10,11],[3,6,10,11],[1,2,4,7,8,9,10,11],[3,5,6,9,10,11,12],[5,6,9,11],[6,7,12],[1,2,4,7,8,9,10,11],[3,4,6,10,11,12]],
    'Moon':[[3,6,7,8,10,11],[1,3,6,7,10,11],[2,3,5,6,9,10,11],[1,3,4,5,7,8,10,11],[1,4,7,8,10,11,12],[3,4,5,7,9,10,11],[3,5,6,11],[3,6,10,11]],
    'Mars':[[3,5,6,10,11],[3,6,11],[1,2,4,7,8,10,11],[3,5,6,11],[6,10,11,12],[6,8,11,12],[1,4,7,8,9,10,11],[1,3,6,10,11]],
    'Mercury':[[5,6,9,11,12],[2,4,6,8,10,11],[1,2,4,7,8,9,10,11],[1,3,5,6,9,10,11,12],[6,8,11,12],[1,2,3,4,5,8,9,11],[1,2,4,7,8,9,10,11],[1,2,4,6,8,10,11]],
    'Jupiter':[[1,2,3,4,7,8,9,10,11],[2,5,7,9,11],[1,2,4,7,8,10,11],[1,2,4,5,6,9,10,11],[1,2,3,4,7,8,10,11],[2,5,6,9,10,11],[3,5,6,12],[1,2,4,5,6,7,9,10,11]],
    'Venus':[[8,11,12],[1,2,3,4,5,8,9,11,12],[3,5,6,9,11,12],[3,5,6,9,11],[5,8,9,10,11],[1,2,3,4,5,8,9,10,11],[3,4,5,8,9,10,11],[1,2,3,4,5,8,9,11]],
    'Saturn':[[1,2,4,7,8,10,11],[3,6,11],[3,5,6,10,11,12],[6,8,9,10,11,12],[5,6,11,12],[6,11,12],[3,5,6,11],[1,3,4,6,10,11]],
  };
  static AshtakavargaResult calculate(KundaliChart chart) {
    final signs=<String,int>{'Lagna':chart.ascendantSignIndex};
    for(final g in chart.grahas){if(planets.contains(g.name))signs[g.name]=g.signIndex;}
    if(planets.any((p)=>!signs.containsKey(p))) {
      throw StateError('The chart is missing one or more classical planets.');
    }
    final tables=<String,List<int>>{};
    for(final target in planets) {
      final points=List<int>.filled(12,0);
      final targetRules=rules[target]!;
      for(var source=0;source<sources.length;source++) {
        final sourceSign=signs[sources[source]]!;
        for(final house in targetRules[source]) {
          final sign=(sourceSign+house-1)%12;
          points[sign]++;
        }
      }
      final total=points.fold<int>(0,(a,b)=>a+b);
      if(total!=expected[target]) {
        throw StateError('$target Ashtakavarga checksum failed: $total / ${expected[target]}.');
      }
      tables[target]=List<int>.unmodifiable(points);
    }
    final sarva=List<int>.generate(12,(i)=>planets.fold<int>(0,(sum,p)=>sum+tables[p]![i]));
    if(sarva.fold<int>(0,(a,b)=>a+b)!=337) {
      throw StateError('Sarvashtakavarga checksum failed.');
    }
    return AshtakavargaResult(bhinna:Map.unmodifiable(tables),sarva:List.unmodifiable(sarva));
  }
}
