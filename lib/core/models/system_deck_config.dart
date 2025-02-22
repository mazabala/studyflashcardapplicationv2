class SystemDeckConfig {
  final String title;
  final String description;
  final String difficultyLevel;
  final int cardCount;
  final String category;
  final String focus;

  SystemDeckConfig({
    required this.title,
    required this.description,
    required this.difficultyLevel,
    required this.cardCount,
    required this.category,
    required this.focus,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'difficulty_level': difficultyLevel,
      'card_count': cardCount,
      'category': category,
      'focus': focus,
    };
  }

  factory SystemDeckConfig.fromJson(Map<String, dynamic> json) {
    return SystemDeckConfig(
      title: json['title'],
      description: json['description'],
      difficultyLevel: json['difficulty_level'],
      cardCount: json['card_count'],
      category: json['category'],
      focus: json['focus'],
    );
  }
} 