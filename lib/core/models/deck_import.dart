// lib/core/models/deck_import.dart

class DeckImportItem {
  final String topic;
  final String focus;
  final String category;
  final String difficultyLevel;
  final int cardCount;

  DeckImportItem({
    required this.topic,
    required this.focus,
    required this.category,
    required this.difficultyLevel,
    required this.cardCount,
  });

  factory DeckImportItem.fromJson(Map<String, dynamic> json) {
    return DeckImportItem(
      topic: json['topic'] as String,
      focus: json['focus'] as String,
      category: json['category'] as String,
      difficultyLevel: json['difficultyLevel'] as String,
      cardCount: json['cardCount'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
        'topic': topic,
        'focus': focus,
        'category': category,
        'difficultyLevel': difficultyLevel,
        'cardCount': cardCount,
      };
}

class CollectionInfo {
  final String name;
  final String subject;
  final String description;
  final bool isPublic;
  final List<DeckImportItem> decks;

  CollectionInfo({
    required this.name,
    required this.subject,
    this.description = '',
    this.isPublic = false,
    required this.decks,
  });

  factory CollectionInfo.fromJson(Map<String, dynamic> json) {
    final List<dynamic> decksList = json['decks'] as List? ?? [];

    return CollectionInfo(
      name: json['name'] as String,
      subject: json['subject'] as String,
      description: json['description'] as String? ?? '',
      isPublic: json['isPublic'] as bool? ?? false,
      decks: decksList
          .map((deckJson) =>
              DeckImportItem.fromJson(deckJson as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'subject': subject,
        'description': description,
        'isPublic': isPublic,
        'decks': decks.map((deck) => deck.toJson()).toList(),
      };
}

class DeckImport {
  final List<CollectionInfo> collections;

  DeckImport({
    required this.collections,
  });

  factory DeckImport.fromJson(Map<String, dynamic> json) {
    final List<dynamic> collectionsList = json['collections'] as List? ?? [];

    return DeckImport(
      collections: collectionsList
          .map((collectionJson) =>
              CollectionInfo.fromJson(collectionJson as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'collections':
          collections.map((collection) => collection.toJson()).toList(),
    };
  }
}

class DeckImportResult {
  final bool success;
  final String message;
  final int totalDecks;
  final int successfulDecks;
  final List<String> errors;
  final List<String>? collectionIds;

  DeckImportResult({
    required this.success,
    required this.message,
    required this.totalDecks,
    required this.successfulDecks,
    required this.errors,
    this.collectionIds,
  });
}
