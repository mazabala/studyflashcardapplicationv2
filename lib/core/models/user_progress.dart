class UserProgress {
  final String id;
  final String userId;
  final Map<String, int> dailyCardsCovered;
  final Map<String, Duration> studyTime;
  final Map<String, Map<String, int>> confidenceLevels;
  final int currentStreak;
  final int longestStreak;
  final DateTime lastStudyDate;
  final Map<String, dynamic> achievements;
  final Map<String, List<double>> performanceMetrics;

  UserProgress({
    required this.id,
    required this.userId,
    required this.dailyCardsCovered,
    required this.studyTime,
    required this.confidenceLevels,
    required this.currentStreak,
    required this.longestStreak,
    required this.lastStudyDate,
    required this.achievements,
    required this.performanceMetrics,
  });

  factory UserProgress.fromJson(Map<String, dynamic> json) {
    return UserProgress(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      dailyCardsCovered: Map<String, int>.from(json['daily_cards_covered'] ?? {}),
      studyTime: (json['study_time'] as Map<String, dynamic>?)?.map(
        (k, v) => MapEntry(k, Duration(minutes: v as int)),
      ) ?? {},
      confidenceLevels: (json['confidence_levels'] as Map<String, dynamic>?)?.map(
        (k, v) => MapEntry(k, Map<String, int>.from(v as Map)),
      ) ?? {},
      currentStreak: json['current_streak'] as int? ?? 0,
      longestStreak: json['longest_streak'] as int? ?? 0,
      lastStudyDate: DateTime.parse(json['last_study_date'] as String),
      achievements: Map<String, dynamic>.from(json['achievements'] ?? {}),
      performanceMetrics: (json['performance_metrics'] as Map<String, dynamic>?)?.map(
        (k, v) => MapEntry(k, List<double>.from(v as List)),
      ) ?? {},
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'daily_cards_covered': dailyCardsCovered,
    'study_time': studyTime.map((k, v) => MapEntry(k, v.inMinutes)),
    'confidence_levels': confidenceLevels,
    'current_streak': currentStreak,
    'longest_streak': longestStreak,
    'last_study_date': lastStudyDate.toIso8601String(),
    'achievements': achievements,
    'performance_metrics': performanceMetrics,
  };

  double getAverageConfidence() {
    if (confidenceLevels.isEmpty) return 0.0;
    final allValues = confidenceLevels.values
        .expand((map) => map.values)
        .toList();
    if (allValues.isEmpty) return 0.0;
    return allValues.fold<double>(0, (sum, value) => sum + value) / allValues.length;
  }

  double getAverageCardsPerDay() {
    if (dailyCardsCovered.isEmpty) return 0.0;
    return dailyCardsCovered.values.fold<int>(0, (sum, value) => sum + value) / 
        dailyCardsCovered.length;
  }

  Duration getTotalStudyTime() {
    return studyTime.values.fold<Duration>(
      Duration.zero,
      (total, duration) => total + duration,
    );
  }

  UserProgress copyWith({
    String? id,
    String? userId,
    Map<String, int>? dailyCardsCovered,
    Map<String, Duration>? studyTime,
    Map<String, Map<String, int>>? confidenceLevels,
    int? currentStreak,
    int? longestStreak,
    DateTime? lastStudyDate,
    Map<String, dynamic>? achievements,
    Map<String, List<double>>? performanceMetrics,
  }) {
    return UserProgress(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      dailyCardsCovered: dailyCardsCovered ?? this.dailyCardsCovered,
      studyTime: studyTime ?? this.studyTime,
      confidenceLevels: confidenceLevels ?? this.confidenceLevels,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastStudyDate: lastStudyDate ?? this.lastStudyDate,
      achievements: achievements ?? this.achievements,
      performanceMetrics: performanceMetrics ?? this.performanceMetrics,
    );
  }
} 