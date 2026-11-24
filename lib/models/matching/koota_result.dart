class KootaResult {
  const KootaResult({
    required this.key,
    required this.name,
    required this.maxPoints,
    required this.points,
    required this.brideValue,
    required this.groomValue,
    required this.summary,
    required this.explanation,
  });

  final String key;
  final String name;
  final double maxPoints;
  final double points;
  final String brideValue;
  final String groomValue;
  final String summary;
  final String explanation;

  Map<String, dynamic> toJson() => {
    'key': key,
    'name': name,
    'maxPoints': maxPoints,
    'points': points,
    'brideValue': brideValue,
    'groomValue': groomValue,
    'summary': summary,
    'explanation': explanation,
  };

  factory KootaResult.fromJson(Map<String, dynamic> json) => KootaResult(
    key: json['key'] as String,
    name: json['name'] as String,
    maxPoints: (json['maxPoints'] as num).toDouble(),
    points: (json['points'] as num).toDouble(),
    brideValue: json['brideValue'] as String,
    groomValue: json['groomValue'] as String,
    summary: json['summary'] as String,
    explanation: json['explanation'] as String,
  );
}
