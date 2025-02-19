import 'package:flashcardstudyapplication/core/models/collection.dart';

class UserCollectionDeck {
  final String deckId;
  final DateTime addedAt;
  final int displayOrder;

  UserCollectionDeck({
    required this.deckId,
    required this.addedAt,
    required this.displayOrder,
  });

  factory UserCollectionDeck.fromJson(Map<String, dynamic> json) {
    return UserCollectionDeck(
      deckId: json['deck_id'],
      addedAt: DateTime.parse(json['added_at']),
      displayOrder: json['display_order'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'deck_id': deckId,
      'added_at': addedAt.toIso8601String(),
      'display_order': displayOrder,
    };
  }
}

class UserCollection {
  final String id;
  final String userId;
  final String collectionId;
  final List<UserCollectionDeck> decks;
  final DateTime addedAt;
  final double completionRate;

  UserCollection({
    required this.id,
    required this.userId,
    required this.collectionId,
    required this.decks,
    required this.addedAt,
    this.completionRate = 0.0,
  });

  factory UserCollection.fromJson(Map<String, dynamic> json) {
    var decksJson = json['decks'] as List<dynamic>? ?? [];
    return UserCollection(
      id: json['id'],
      userId: json['user_id'],
      collectionId: json['collection_id'],
      decks: decksJson.map((deck) => UserCollectionDeck.fromJson(deck)).toList(),
      addedAt: DateTime.parse(json['added_at']),
      completionRate: json['completion_rate']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'collection_id': collectionId,
      'decks': decks.map((deck) => deck.toJson()).toList(),
      'added_at': addedAt.toIso8601String(),
      'completion_rate': completionRate,
    };
  }

  UserCollection copyWith({
    String? id,
    String? userId,
    String? collectionId,
    List<UserCollectionDeck>? decks,
    DateTime? addedAt,
    double? completionRate,
  }) {
    return UserCollection(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      collectionId: collectionId ?? this.collectionId,
      decks: decks ?? this.decks,
      addedAt: addedAt ?? this.addedAt,
      completionRate: completionRate ?? this.completionRate,
    );
  }

  List<String> get deckIds => decks.map((deck) => deck.deckId).toList();
} 