// lib/core/models/flashcard.dart

class Flashcard {
  final String id;
  final String deckid;
  final String front;
  final String back;
  final String difficultyLevel;
  final String created_at;
  final String last_reviewed;
  

  Flashcard({
    required this.id,
    required this.deckid,
    required this.front,
    required this.back,
    required this.difficultyLevel,
    required this.created_at,
    required this.last_reviewed,
    
  });



  // Factory constructor to create a Flashcard from a json
  factory Flashcard.fromjson(Map<String, dynamic> json) {
    try {
    return Flashcard(
      id: json['id']?.toString() ?? '',
      deckid: json['deck_id']?.toString() ?? '',
      front: json['front']?.toString() ?? '',
      back: json['back']?.toString() ?? '',
      created_at: json['created_at']?.toString() ?? '',
      last_reviewed: json['last_reviewed']?.toString() ?? '',
      difficultyLevel: json['difficulty']?.toString() ?? '',
     
     
    );
  } catch (e) {
    print('Error in Flashcard.fromJson: $e');
    print('Full JSON: $json');
    rethrow;
  }
}
Map<String, dynamic> toJson() => {
    'id': id,
    'deck_id': deckid,
    'front': front,
    'back': back,
    'difficultyLevel':difficultyLevel,
    'created_at':created_at,
    'last_reviewed': last_reviewed,
    


  };
}