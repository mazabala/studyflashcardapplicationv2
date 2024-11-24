// lib/core/models/deck.dart

import 'flashcard.dart';

class Deck {
  final String id;
  final String title;
  final String categoryid;
  final String creatorid;

  final bool? ispublic;
  final DateTime createdat;
  final int totalCards;
  final String description;
  final String difficultyLevel;
  final String difficulty;
  final String modified_by;
  

  Deck({
    required this.id,
    required this.title,
    required this.categoryid,
    required this.creatorid,
    required this.totalCards,
    this.ispublic,
    required this.createdat,
    required this.description,
    required this.difficultyLevel,
    required this.difficulty,
    required this.modified_by,
    
    
  });

  // Factory constructor to create a Deck from a map
factory Deck.fromJson(Map<String, dynamic> json) {
    return Deck(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      difficulty: json['difficulty'] as String,
      difficultyLevel: json['difficulty_level'] as String,
      createdat: DateTime.parse(json['created_at']),
      creatorid: json['creator_id'] as String,
      ispublic: json['is_public'] as bool,
      totalCards: json['total_cards'] as int,
      categoryid: json['category_id'] as String,  // Fixed this line
      modified_by: json['modified_by'] as String,
    );
}

  // Method to convert Deck to a map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'categoryid': categoryid,
      'created_at': createdat,
      'creator_id': creatorid,
      'is_public' : ispublic,
      'total_cards': totalCards,
      'difficulty_level': difficultyLevel,
      'modified_by':creatorid,
      'difficulty':difficultyLevel,
      
    };
  }
}
