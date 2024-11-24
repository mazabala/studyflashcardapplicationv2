import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flashcardstudyapplication/core/providers/deck_provider.dart';
import 'package:flashcardstudyapplication/core/providers/user_provider.dart';
import 'package:flashcardstudyapplication/core/models/deck.dart';

class DeckController {
  final Ref ref;

  DeckController(this.ref);

  // Fetch deck categories asynchronously
  Future<List<String>> getDeckCategory() async {
    final deckReader = ref.read(deckServiceProvider);
    final deckCategory = await deckReader.getDeckCategory();
    return deckCategory;
  }

  // Fetch deck difficulty levels asynchronously
  Future<List<String>> getDeckDifficulty() async {
    final deckReader = ref.read(deckServiceProvider);
    final userReader = ref.read(userServiceProvider);
    final subscriptionId = await userReader.getUserSubscriptionPlan();
    final deckDifficulty = await deckReader.getDeckDifficulty(subscriptionId);
    return deckDifficulty;
  }

  // Create a new deck
  Future<void> createDeck(String title, String category, String description, String difficultyLevel, int cardCount) async {
    final userId = ref.read(userServiceProvider).getCurrentUserId();
    if (userId != null) {
      await ref.read(deckProvider.notifier).createDeck(title, category, description, difficultyLevel, userId, cardCount);
    } else {
      throw Exception("User ID not found");
    }
  }

  // Load user's decks
  Future<List<Deck>> loadUserDecks() async {
    final userId = ref.read(userServiceProvider).getCurrentUserId();
    if (userId != null) {
      return await ref.read(deckProvider.notifier).loadUserDecks();
    } else {
      throw Exception("User ID not found");
    }
  }

  // Search decks based on title
  List<Deck> searchDecks(List<Deck> decks, String query) {
    return decks.where((deck) {
      return deck.title.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }
}

final deckControllerProvider = Provider((ref) => DeckController(ref));
