import 'package:flashcardstudyapplication/core/models/deck.dart';

class CollectionDeck {
  final String deckId;
  final DateTime addedAt;
  final int displayOrder;

  CollectionDeck({
    required this.deckId,
    required this.addedAt,
    required this.displayOrder,
  });

  factory CollectionDeck.fromJson(Map<String, dynamic> json) {
    return CollectionDeck(
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

class Collection {
  final String id;
  final String name;
  final String subject;
  final String description;
  final String creatorId;
  final bool isPublic;
  final DateTime createdAt;
  final DateTime modifiedAt;
  final List<CollectionDeck> decks;
  final double completionRate;

  Collection({
    required this.id,
    required this.name,
    required this.subject,
    required this.description,
    required this.creatorId,
    required this.isPublic,
    required this.createdAt,
    required this.modifiedAt,
    required this.decks,
    this.completionRate = 0.0,
  });

  factory Collection.fromJson(Map<String, dynamic> json) {
    var decksJson = json['decks'] as List<dynamic>? ?? [];
    return Collection(
      id: json['id'],
      name: json['name'],
      subject: json['subject'],
      description: json['description'] ?? '',
      creatorId: json['creator_id'],
      isPublic: json['is_public'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      modifiedAt: DateTime.parse(json['modified_at']),
      decks: decksJson.map((deck) => CollectionDeck.fromJson(deck)).toList(),
      completionRate: json['completion_rate']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'subject': subject,
      'description': description,
      'creator_id': creatorId,
      'is_public': isPublic,
      'created_at': createdAt.toIso8601String(),
      'modified_at': modifiedAt.toIso8601String(),
      'decks': decks.map((deck) => deck.toJson()).toList(),
      'completion_rate': completionRate,
    };
  }

  Collection copyWith({
    String? id,
    String? name,
    String? subject,
    String? description,
    String? creatorId,
    bool? isPublic,
    DateTime? createdAt,
    DateTime? modifiedAt,
    List<CollectionDeck>? decks,
    double? completionRate,
  }) {
    return Collection(
      id: id ?? this.id,
      name: name ?? this.name,
      subject: subject ?? this.subject,
      description: description ?? this.description,
      creatorId: creatorId ?? this.creatorId,
      isPublic: isPublic ?? this.isPublic,
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? this.modifiedAt,
      decks: decks ?? this.decks,
      completionRate: completionRate ?? this.completionRate,
    );
  }

  List<String> get deckIds => decks.map((deck) => deck.deckId).toList();
} 