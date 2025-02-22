import 'package:flutter/material.dart';

class UserPreferences {
  final String id;
  final String userId;
  final ThemeMode themeMode;
  final TimeOfDay studyReminder;
  final int dailyGoalCards;
  final int studySessionDuration;
  final bool soundEnabled;
  final bool hapticFeedback;
  final Map<String, dynamic> preferences;
  final DateTime lastUpdated;
  final bool isDarkMode;
  final bool isSpacedRepetitionEnabled;
  final String defaultDifficulty;
  final int cardsPerSession;
  final int breakInterval;
  final Map<String, dynamic> studySettings;

  UserPreferences({
    required this.id,
    required this.userId,
    this.themeMode = ThemeMode.system,
    TimeOfDay? studyReminder,
    this.dailyGoalCards = 20,
    this.studySessionDuration = 25,
    this.soundEnabled = true,
    this.hapticFeedback = true,
    this.preferences = const {},
    required this.lastUpdated,
    this.isDarkMode = false,
    this.isSpacedRepetitionEnabled = true,
    this.defaultDifficulty = 'medium',
    this.cardsPerSession = 20,
    this.breakInterval = 25,
    this.studySettings = const {},
  }) : studyReminder = studyReminder ?? const TimeOfDay(hour: 18, minute: 0);

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    final reminderParts = (json['study_reminder'] as String? ?? "18:00").split(':');
    return UserPreferences(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      themeMode: ThemeMode.values.firstWhere(
        (e) => e.toString() == json['theme_mode'],
        orElse: () => ThemeMode.system,
      ),
      studyReminder: TimeOfDay(
        hour: int.parse(reminderParts[0]),
        minute: int.parse(reminderParts[1]),
      ),
      dailyGoalCards: json['daily_goal_cards'] as int? ?? 20,
      studySessionDuration: json['study_session_duration'] as int? ?? 25,
      soundEnabled: json['sound_enabled'] as bool? ?? true,
      hapticFeedback: json['haptic_feedback'] as bool? ?? true,
      preferences: json['preferences'] as Map<String, dynamic>? ?? {},
      lastUpdated: DateTime.parse(json['last_updated'] as String),
      isDarkMode: json['isDarkMode'] ?? false,
      isSpacedRepetitionEnabled: json['isSpacedRepetitionEnabled'] ?? true,
      defaultDifficulty: json['defaultDifficulty'] ?? 'medium',
      cardsPerSession: json['cardsPerSession'] ?? 20,
      breakInterval: json['breakInterval'] ?? 25,
      studySettings: json['studySettings'] ?? {},
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'theme_mode': themeMode.toString(),
    'study_reminder': '${studyReminder.hour.toString().padLeft(2, '0')}:${studyReminder.minute.toString().padLeft(2, '0')}',
    'daily_goal_cards': dailyGoalCards,
    'study_session_duration': studySessionDuration,
    'sound_enabled': soundEnabled,
    'haptic_feedback': hapticFeedback,
    'preferences': preferences,
    'last_updated': lastUpdated.toIso8601String(),
    'isDarkMode': isDarkMode,
    'isSpacedRepetitionEnabled': isSpacedRepetitionEnabled,
    'defaultDifficulty': defaultDifficulty,
    'cardsPerSession': cardsPerSession,
    'breakInterval': breakInterval,
    'studySettings': studySettings,
  };

  T? getPreference<T>(String key) {
    final value = preferences[key];
    if (value is T) return value;
    return null;
  }

  UserPreferences copyWith({
    String? id,
    String? userId,
    ThemeMode? themeMode,
    TimeOfDay? studyReminder,
    int? dailyGoalCards,
    int? studySessionDuration,
    bool? soundEnabled,
    bool? hapticFeedback,
    Map<String, dynamic>? preferences,
    DateTime? lastUpdated,
    bool? isDarkMode,
    bool? isSpacedRepetitionEnabled,
    String? defaultDifficulty,
    int? cardsPerSession,
    int? breakInterval,
    Map<String, dynamic>? studySettings,
  }) {
    return UserPreferences(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      themeMode: themeMode ?? this.themeMode,
      studyReminder: studyReminder ?? this.studyReminder,
      dailyGoalCards: dailyGoalCards ?? this.dailyGoalCards,
      studySessionDuration: studySessionDuration ?? this.studySessionDuration,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      hapticFeedback: hapticFeedback ?? this.hapticFeedback,
      preferences: preferences ?? this.preferences,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      isSpacedRepetitionEnabled: isSpacedRepetitionEnabled ?? this.isSpacedRepetitionEnabled,
      defaultDifficulty: defaultDifficulty ?? this.defaultDifficulty,
      cardsPerSession: cardsPerSession ?? this.cardsPerSession,
      breakInterval: breakInterval ?? this.breakInterval,
      studySettings: studySettings ?? this.studySettings,
    );
  }
} 