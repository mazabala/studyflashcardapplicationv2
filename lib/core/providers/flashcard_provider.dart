// flashcard_state.dart
import 'package:flashcardstudyapplication/core/models/flashcard.dart';
import 'package:flashcardstudyapplication/core/providers/deck_provider.dart';
import 'package:flashcardstudyapplication/core/services/deck/deck_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FlashcardState {
  final bool isLoading;
  final String error;
  final Map<String, List<Flashcard>> flashcardsByDeck; // Cache by deck ID
  final int currentCardIndex;
  final bool isFlipped;

  const FlashcardState({
    this.isLoading = false,
    this.error = '',
    this.flashcardsByDeck = const {},
    this.currentCardIndex = 0,
    this.isFlipped = false,
  });

  FlashcardState copyWith({
    bool? isLoading,
    String? error,
    Map<String, List<Flashcard>>? flashcardsByDeck,
    int? currentCardIndex,
    bool? isFlipped,
  }) {
    return FlashcardState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      flashcardsByDeck: flashcardsByDeck ?? this.flashcardsByDeck,
      currentCardIndex: currentCardIndex ?? this.currentCardIndex,
      isFlipped: isFlipped ?? this.isFlipped,
    );
  }
}

class FlashcardNotifier extends StateNotifier<FlashcardState> {
  final DeckService _deckService;

  FlashcardNotifier(this._deckService) : super(const FlashcardState());

  Future<List<Flashcard>> getFlashcardsForDeck(String deckId) async {
    // If we already have the flashcards cached, return them
    if (state.flashcardsByDeck.containsKey(deckId)) {
      return state.flashcardsByDeck[deckId]!;
    }

    state = state.copyWith(isLoading: true, error: '');

    try {
      final flashcards = await _deckService.getFlashcards(deckId);

      // Shuffle the flashcards for random order
      flashcards.shuffle();

      // Update cache with new flashcards
      final updatedCache = Map<String, List<Flashcard>>.from(state.flashcardsByDeck);
      updatedCache[deckId] = flashcards;

      state = state.copyWith(
        flashcardsByDeck: updatedCache,
        isLoading: false,
      );

      return flashcards;
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to load flashcards: ${e.toString()}',
        isLoading: false,
      );
      rethrow;
    }
  }


  // Method to flip the card
  void toggleFlip() {
    state = state.copyWith(isFlipped: !state.isFlipped);
  }

  // Method to progress to the next card
  void nextCard(String deckId, int currentIndex) {
    final flashcards = state.flashcardsByDeck[deckId] ?? [];
    if (currentIndex < flashcards.length - 1) {
      state = state.copyWith(
        currentCardIndex: currentIndex + 1,
        isFlipped: false,
      );
    }
  }

  // Method to go back to the previous card
  void previousCard(String deckId, int currentIndex) {
    if (currentIndex > 0) {
      state = state.copyWith(
        currentCardIndex: currentIndex - 1,
        isFlipped: false,
      );
    }
  }

  // Method to reset the study session (start from the first card)
  void resetSession() {
    state = state.copyWith(currentCardIndex: 0, isFlipped: false);
  }
}
// providers.dart
final flashcardProvider = StateNotifierProvider<FlashcardNotifier, FlashcardState>((ref) {
  final deckService = ref.watch(deckServiceProvider);
  return FlashcardNotifier(deckService);
});