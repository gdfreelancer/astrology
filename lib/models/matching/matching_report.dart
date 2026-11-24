import 'koota_result.dart';
import 'matching_person.dart';

class MatchingReport {
  const MatchingReport({
    this.id,
    required this.createdAt,
    required this.bride,
    required this.groom,
    required this.kootas,
    required this.calculationVersion,
  });

  final int? id;
  final DateTime createdAt;
  final MatchingPerson bride;
  final MatchingPerson groom;
  final List<KootaResult> kootas;
  final String calculationVersion;

  double get totalPoints => kootas.fold(0, (sum, item) => sum + item.points);
  double get maximumPoints => kootas.fold(0, (sum, item) => sum + item.maxPoints);
  double get percentage => maximumPoints == 0 ? 0 : totalPoints / maximumPoints * 100;

  Map<String, dynamic> toJson() => {
    'createdAt': createdAt.toIso8601String(),
    'bride': bride.toJson(),
    'groom': groom.toJson(),
    'kootas': kootas.map((item) => item.toJson()).toList(),
    'calculationVersion': calculationVersion,
  };

  factory MatchingReport.fromJson(Map<String, dynamic> json, {int? id}) => MatchingReport(
    id: id,
    createdAt: DateTime.parse(json['createdAt'] as String),
    bride: MatchingPerson.fromJson(json['bride'] as Map<String, dynamic>),
    groom: MatchingPerson.fromJson(json['groom'] as Map<String, dynamic>),
    kootas: (json['kootas'] as List<dynamic>)
        .map((item) => KootaResult.fromJson(item as Map<String, dynamic>))
        .toList(),
    calculationVersion: json['calculationVersion'] as String,
  );
}
