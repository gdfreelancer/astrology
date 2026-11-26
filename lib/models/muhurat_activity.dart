class MuhuratActivity {
  const MuhuratActivity({
    required this.emoji,
    required this.key,
    required this.descriptionKey,
  });

  final String emoji;
  /// Also used as the key for the activity-specific Muhurat rules.
  final String key;
  final String descriptionKey;

  String get titleKey => key;

  static const all = <MuhuratActivity>[
    MuhuratActivity(emoji: '💍', key: 'activity_marriage', descriptionKey: 'activity_marriage_desc'),
    MuhuratActivity(emoji: '🏡', key: 'activity_griha_pravesh', descriptionKey: 'activity_griha_pravesh_desc'),
    MuhuratActivity(emoji: '🚗', key: 'activity_vehicle', descriptionKey: 'activity_vehicle_desc'),
    MuhuratActivity(emoji: '🏪', key: 'activity_business', descriptionKey: 'activity_business_desc'),
    MuhuratActivity(emoji: '🍼', key: 'activity_naming', descriptionKey: 'activity_naming_desc'),
    MuhuratActivity(emoji: '🏠', key: 'activity_property', descriptionKey: 'activity_property_desc'),
    MuhuratActivity(emoji: '🧳', key: 'activity_journey', descriptionKey: 'activity_journey_desc'),
    MuhuratActivity(emoji: '📚', key: 'activity_learning', descriptionKey: 'activity_learning_desc'),
  ];
}
