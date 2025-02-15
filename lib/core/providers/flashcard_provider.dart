// flashcard_state.dart
import 'package:flashcardstudyapplication/core/interfaces/i_deck_service.dart';
import 'package:flashcardstudyapplication/core/interfaces/i_user_service.dart';
import 'package:flashcardstudyapplication/core/models/deck.dart';
import 'package:flashcardstudyapplication/core/models/flashcard.dart';
import 'package:flashcardstudyapplication/core/models/study_session.dart';
import 'package:flashcardstudyapplication/core/providers/deck_provider.dart';
import 'package:flashcardstudyapplication/core/services/deck/deck_service.dart';
import 'package:flashcardstudyapplication/core/services/progress/progress_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'provider_config.dart';

class FlashcardState {
  final bool isLoading;
  final String error;
  final Map<String, List<Flashcard>> flashcardsByDeck; // Cache by deck ID
  final int currentCardIndex;
  final bool isFlipped;
  final Map<String, String> cardConfidence; // Tracks confidence levels: 'high', 'medium', 'low'
  final Set<String> markedForLater; // Cards marked for later review
  final DateTime? lastBreakTime; // Tracks when the last break was taken
  final bool isReviewingMarked; // New field to track if we're reviewing marked cards

  const FlashcardState({
    this.isLoading = false,
    this.error = '',
    this.flashcardsByDeck = const {},
    this.currentCardIndex = 0,
    this.isFlipped = false,
    this.cardConfidence = const {},
    this.markedForLater = const {},
    this.lastBreakTime,
    this.isReviewingMarked = false,
  });

  FlashcardState copyWith({
    bool? isLoading,
    String? error,
    Map<String, List<Flashcard>>? flashcardsByDeck,
    int? currentCardIndex,
    bool? isFlipped,
    Map<String, String>? cardConfidence,
    Set<String>? markedForLater,
    DateTime? lastBreakTime,
    bool? isReviewingMarked,
  }) {
    return FlashcardState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      flashcardsByDeck: flashcardsByDeck ?? this.flashcardsByDeck,
      currentCardIndex: currentCardIndex ?? this.currentCardIndex,
      isFlipped: isFlipped ?? this.isFlipped,
      cardConfidence: cardConfidence ?? this.cardConfidence,
      markedForLater: markedForLater ?? this.markedForLater,
      lastBreakTime: lastBreakTime ?? this.lastBreakTime,
      isReviewingMarked: isReviewingMarked ?? this.isReviewingMarked,
    );
  }

  // Helper method to get current deck's cards
  List<Flashcard> getCurrentDeckCards(String deckId) {
    final allCards = flashcardsByDeck[deckId] ?? [];
    if (isReviewingMarked) {
      return allCards.where((card) => markedForLater.contains(card.id)).toList();
    }
    return allCards;
  }
}

class FlashcardNotifier extends StateNotifier<FlashcardState> {
  final IDeckService _deckService;
  final ProgressService _progressService;
  final IUserService _userService;
  final Ref _ref;
  StudySession? _currentSession;

  FlashcardNotifier(this._deckService, this._progressService, this._userService, this._ref) : super(FlashcardState());

  Future<List<Flashcard>> getFlashcardsForDeck(String deckId) async {
    if (state.flashcardsByDeck.containsKey(deckId)) {
      return state.flashcardsByDeck[deckId]!;
    }

    state = state.copyWith(isLoading: true, error: '', currentCardIndex: 0);

    try {
      final userInfo = await _userService.getCurrentUserInfo();
      if (userInfo == null) {
        throw Exception('User not logged in');
      }
      final userId = userInfo['id'];

      final flashcards = await _deckService.getFlashcards(deckId);
      flashcards.shuffle();

      // Start a new study session
      _currentSession = await _progressService.startStudySession(userId, deckId);

      // Load existing progress
      final progress = await _progressService.getFlashcardProgress(userId, deckId);
      
      // Update state with existing progress
      final confidenceMap = {for (var p in progress) p.flashcardId: p.confidenceLevel};
      final markedCards = progress.where((p) => p.isMarkedForLater).map((p) => p.flashcardId).toSet();

      final updatedCache = Map<String, List<Flashcard>>.from(state.flashcardsByDeck);
      updatedCache[deckId] = flashcards;

      state = state.copyWith(
        flashcardsByDeck: updatedCache,
        isLoading: false,
        cardConfidence: confidenceMap,
        markedForLater: markedCards,
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

  Future<void> reportCard(Flashcard flashcard) async {
    try {
      final flashcardId = flashcard.id;
      await _deckService.flagFlashcard(flashcardId);

      _ref.read(analyticsProvider.notifier).trackEvent(
        'flashcard_reported',
        properties: {
          'flashcard_id': flashcardId,
        },
      );
    } catch (e) {
      print('Error reporting flashcard: $e');
    }
  }

  void recordAnswer(String flashcardId, bool isCorrect) {
    try {
      _ref.read(analyticsProvider.notifier).trackEvent(
        'flashcard_answered',
        properties: {
          'flashcard_id': flashcardId,
          'is_correct': isCorrect,
        },
      );
    } catch (e) {
      print('Error tracking flashcard answer: $e');
    }
  }

  // Method to flip the card
  void toggleFlip() {
    state = state.copyWith(isFlipped: !state.isFlipped);
  }

  // Method to progress to the next card
  void nextCard(String deckId, int currentIndex) {
    final currentDeckCards = state.getCurrentDeckCards(deckId);
    if (currentIndex < currentDeckCards.length - 1) {
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
    state = state.copyWith(flashcardsByDeck: const {});
  }

  void recordConfidence(String flashcardId, String confidence) async {
    try {
      final userInfo = await _userService.getCurrentUserInfo();
      if (userInfo == null) {
        throw Exception('User not logged in');
      }
      final userId = userInfo['id'];

      final updatedConfidence = Map<String, String>.from(state.cardConfidence);
      updatedConfidence[flashcardId] = confidence;
      
      // Update progress in database
      await _progressService.updateFlashcardProgress(
        userId: userId,
        flashcardId: flashcardId,
        confidenceLevel: confidence,
        isMarkedForLater: state.markedForLater.contains(flashcardId),
      );

      // Update session
      if (_currentSession != null) {
        await _progressService.updateStudySession(
          _currentSession!.id,
          cardsReviewed: _currentSession!.cardsReviewed + 1,
        );
      }

      state = state.copyWith(cardConfidence: updatedConfidence);
    } catch (e) {
      print('Error recording confidence: $e');
    }
  }

  void toggleMarkForLater(String flashcardId) async {
    try {
      final userInfo = await _userService.getCurrentUserInfo();
      if (userInfo == null) {
        throw Exception('User not logged in');
      }
      final userId = userInfo['id'];

      final updatedMarked = Set<String>.from(state.markedForLater);
      final isMarked = updatedMarked.contains(flashcardId);
      
      if (isMarked) {
        updatedMarked.remove(flashcardId);
      } else {
        updatedMarked.add(flashcardId);
      }

      // Update progress in database
      await _progressService.updateFlashcardProgress(
        userId: userId,
        flashcardId: flashcardId,
        confidenceLevel: state.cardConfidence[flashcardId] ?? 'low',
        isMarkedForLater: !isMarked,
      );

      state = state.copyWith(markedForLater: updatedMarked);
    } catch (e) {
      print('Error toggling mark for later: $e');
    }
  }

  bool shouldTakeBreak() {
    if (state.lastBreakTime == null) return false;
    final timeSinceLastBreak = DateTime.now().difference(state.lastBreakTime!);
    return timeSinceLastBreak.inMinutes >= 25; // Suggest break every 25 minutes
  }

  void recordBreakTime() async {
    try {
      if (_currentSession != null) {
        await _progressService.updateStudySession(
          _currentSession!.id,
          lastBreakAt: DateTime.now(),
        );
      }
      state = state.copyWith(lastBreakTime: DateTime.now());
    } catch (e) {
      print('Error recording break time: $e');
    }
  }

  // End the current study session
  void endSession() async {
    try {
      if (_currentSession != null) {
        await _progressService.updateStudySession(
          _currentSession!.id,
          endedAt: DateTime.now(),
        );
        _currentSession = null;
      }
    } catch (e) {
      print('Error ending session: $e');
    }
  }

  // Start reviewing marked cards
  void startMarkedCardsReview(String deckId) {
    final markedCards = state.flashcardsByDeck[deckId]
        ?.where((card) => state.markedForLater.contains(card.id))
        .toList() ?? [];

    if (markedCards.isEmpty) {
      state = state.copyWith(error: 'No cards marked for review');
      return;
    }

    // Shuffle marked cards for review
    markedCards.shuffle();

    final updatedCache = Map<String, List<Flashcard>>.from(state.flashcardsByDeck);
    updatedCache[deckId] = markedCards;

    state = state.copyWith(
      flashcardsByDeck: updatedCache,
      currentCardIndex: 0,
      isFlipped: false,
      isReviewingMarked: true,
    );
  }

  // Stop reviewing marked cards and return to normal mode
  void stopMarkedCardsReview(String deckId) async {
    try {
      // Reload all cards for the deck
      final flashcards = await _deckService.getFlashcards(deckId);
      flashcards.shuffle();

      final updatedCache = Map<String, List<Flashcard>>.from(state.flashcardsByDeck);
      updatedCache[deckId] = flashcards;

      state = state.copyWith(
        flashcardsByDeck: updatedCache,
        currentCardIndex: 0,
        isFlipped: false,
        isReviewingMarked: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to load flashcards: ${e.toString()}',
      );
    }
  }

  @override
  void dispose() {
    endSession();
    super.dispose();
  }
}
