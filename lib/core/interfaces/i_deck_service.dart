// lib/core/interfaces/i_deck_service.dart


import 'package:flashcardstudyapplication/core/models/deck.dart';

abstract class IDeckService {


  // Add the missing method to get details of a single deck
  Future<List<Deck>> getDeckDetails(List<String> deckIds);

  // Get decks for a user
  Future<List<Deck>> getUserDecks(String userId);

  // Add flashcard to a deck
  Future<void> addFlashcardToDeck(String deckId, String question, String answer, String difficultyLevel);

  // Create a new deck
  Future<void> createDeck(String title,String category, String description,String difficultyLevel, String userid, int cardCount);
  // Update dec
  Future<void> updateDeck(String deckId, String title, String difficultyLevel, String userid);

  // Delete deck
  Future<void> deleteDeck(String deckId, String userid);

  //Get deck category
  Future<List> getDeckCategory();
}
