// lib/core/interfaces/i_deck_service.dart

import 'package:flashcardstudyapplication/core/models/deck.dart';
import 'package:flashcardstudyapplication/core/models/flashcard.dart';
import 'package:flashcardstudyapplication/core/models/deck_import.dart';

abstract class IDeckService {
  Future<List<String>> getDeckDifficulty(String? subscriptionId);

  Future<void> flagFlashcard(String flashcardId);

  Future<List<Deck>> loadDeckPool(String userId);

  Future<List<Flashcard>> getFlashcards(String deckid);
  // Add the missing method to get details of a single deck
  Future<List<Deck>> getDeckDetails(List<String> deckIds);

  // Get decks for a user
  Future<List<Deck>> getUserDecks(String userId);

  // Add flashcard to a deck
  Future<void> decktoUser(String deckId, String userId);

  //Future<void> systemCreateDeck(List<SystemDeckConfig> configs, String userId);

  // Create a new deck
  Future<void> createDeck(String topic, String focus, String category,
      String difficultyLevel, String userid, int cardCount);
  // Update deck
  Future<void> updateDeck(
      String deckId, String title, String difficultyLevel, String userid);

  // Delete deck
  Future<void> removeDeck(String deckId);

  //Get deck category
  Future<List<String>> getDeckCategory();

  Future<void> addDeckCategory(String category);

  // Import decks from JSON file (admin only)
  Future<DeckImportResult> importDecksFromJson(
      String jsonContent, String userId);
}
