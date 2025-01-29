// lib/core/interfaces/i_deck_service.dart


import 'package:flashcardstudyapplication/core/models/deck.dart';
import 'package:flashcardstudyapplication/core/services/deck/deck_service.dart';

abstract class IDeckService {


  // Add the missing method to get details of a single deck
  Future<List<Deck>> getDeckDetails(List<String> deckIds);

  // Get decks for a user
  Future<List<Deck>> getUserDecks(String userId);

  // Add flashcard to a deck
  Future<void> decktoUser(String deckId, String userId);

  //Future<void> systemCreateDeck(List<SystemDeckConfig> configs, String userId);

  // Create a new deck
  Future<void> createDeck(String subject, String concept, String description,String category, String difficultyLevel, String userid, int cardCount);
  // Update dec
  Future<void> updateDeck(String deckId, String title, String difficultyLevel, String userid);

  // Delete deck
  Future<void> removeDeck(String deckId);

  //Get deck category
  Future<List> getDeckCategory();
}
