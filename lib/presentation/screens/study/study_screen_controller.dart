import 'package:flashcardstudyapplication/core/models/flashcard.dart';
import 'package:flashcardstudyapplication/core/providers/provider_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flashcardstudyapplication/core/providers/flashcard_provider.dart'; // Import the flashcard provider

class StudyScreenController {
  final WidgetRef ref;
  final String deckId;
  final VoidCallback onFinish;
  final bool isCollectionStudy;

  StudyScreenController({
    required this.ref,
    required this.deckId,
    required this.onFinish,
    this.isCollectionStudy = false,
  });

  // Get the current state of flashcards for the deck
  FlashcardState get flashcardState => ref.read(flashcardStateProvider);

  // Get the list of flashcards for the deck
  List<Flashcard> get flashcards {
    final cards = flashcardState.flashcardsByDeck[deckId] ?? [];
    if (cards.isEmpty) {
      // Try to load flashcards if they haven't been loaded yet
      ref.read(flashcardStateProvider.notifier).getFlashcardsForDeck(deckId);
    }
    return cards;
  }

  // Check if it's time for a break
  bool shouldTakeBreak() {
    return ref.read(flashcardStateProvider.notifier).shouldTakeBreak();
  }

  // Handle confidence-based response
  void handleConfidenceResponse(String confidence) {
    final state = ref.read(flashcardStateProvider);
    final flashcards = state.flashcardsByDeck[deckId] ?? [];

    if (flashcards.isEmpty) return;

    final currentCard = flashcards[state.currentCardIndex];

    // Record the confidence level
    ref
        .read(flashcardStateProvider.notifier)
        .recordConfidence(currentCard.id, confidence);

    // Track analytics
    ref.read(analyticsProvider.notifier).trackEvent(
      'flashcard_confidence_recorded',
      properties: {
        'flashcard_id': currentCard.id,
        'confidence_level': confidence,
      },
    );

    // Move to next card
    nextCard(ref.context);
  }

  // Toggle mark for later
  void toggleMarkForLater() {
    final state = ref.read(flashcardStateProvider);
    final flashcards = state.flashcardsByDeck[deckId] ?? [];

    if (flashcards.isEmpty) return;

    final currentCard = flashcards[state.currentCardIndex];
    ref
        .read(flashcardStateProvider.notifier)
        .toggleMarkForLater(currentCard.id);
  }

  // Navigate to the next card
  void nextCard(BuildContext context) {
    final state = ref.read(flashcardStateProvider);
    final flashcards = state.flashcardsByDeck[deckId] ?? [];

    if (state.currentCardIndex < flashcards.length - 1) {
      ref
          .read(flashcardStateProvider.notifier)
          .nextCard(deckId, state.currentCardIndex);

      // Check if it's time for a break
      if (ref.read(flashcardStateProvider.notifier).shouldTakeBreak()) {
        _suggestBreak(context);
      }
    } else {
      // Capture all necessary state before showing dialog
      final confidenceLevels = state.cardConfidence;
      final highConfidenceCount =
          confidenceLevels.values.where((level) => level == 'high').length;
      final totalCards = flashcards.length;
      final progressPercentage =
          totalCards > 0 ? (highConfidenceCount / totalCards * 100).round() : 0;
      final isReviewingMarked = state.isReviewingMarked;
      final markedCount = state.markedForLater.length;

      // Show completion dialog with captured state
      _showCompletionDialog(
        context: context,
        progressPercentage: progressPercentage,
        isReviewingMarked: isReviewingMarked,
        markedCount: markedCount,
        hasMarkedCards: state.markedForLater.isNotEmpty,
      );
    }
  }

  // Navigate to the previous card
  void previousCard() {
    final state = ref.read(flashcardStateProvider);
    final flashcards = state.flashcardsByDeck[deckId] ?? [];

    if (state.currentCardIndex > 0) {
      ref
          .read(flashcardStateProvider.notifier)
          .previousCard(deckId, state.currentCardIndex);
    }
  }

  // Show break suggestion dialog
  void _suggestBreak(BuildContext context) {
    final notifier = ref.read(flashcardStateProvider.notifier);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Time for a Break! 🌟'),
        content: const Text(
            'You\'ve been studying for a while. Taking regular breaks helps with retention and reduces stress. How about a 5-minute break?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              notifier.recordBreakTime();
            },
            child: const Text('Take a Break'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Continue Studying'),
          ),
        ],
      ),
    );
  }

  // Review only marked cards
  void _reviewMarkedCards() {
    ref.read(flashcardStateProvider.notifier).startMarkedCardsReview(deckId);
  }

  // Stop reviewing marked cards
  void stopMarkedCardsReview() {
    ref.read(flashcardStateProvider.notifier).stopMarkedCardsReview(deckId);
  }

  // Show the deck completion dialog with encouraging message
  void _showCompletionDialog({
    required BuildContext context,
    required int progressPercentage,
    required bool isReviewingMarked,
    required int markedCount,
    required bool hasMarkedCards,
  }) {
    final notifier = ref.read(flashcardStateProvider.notifier);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          title: Text(
              isReviewingMarked ? 'Review Complete! 🎯' : 'Great Progress! 🎉'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(isReviewingMarked
                  ? 'You\'ve reviewed all your marked cards!'
                  : 'You\'ve completed this study session!'),
              const SizedBox(height: 8),
              if (!isReviewingMarked) ...[
                Text(
                    'You\'re feeling confident about $progressPercentage% of the cards.'),
                if (hasMarkedCards)
                  Text('$markedCount cards marked for later review.'),
              ],
              if (isCollectionStudy) ...[
                const SizedBox(height: 8),
                const Text(
                    'Ready to continue with the next deck in the collection?'),
              ],
            ],
          ),
          actions: [
            if (isCollectionStudy)
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // Automatically continue to the next deck
                  onFinish();
                },
                child: const Text('Continue to Next Deck'),
              )
            else
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onFinish();
                },
                child: const Text('Finish'),
              ),
            if (!isReviewingMarked && hasMarkedCards)
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  notifier.startMarkedCardsReview(deckId);
                },
                child: const Text('Review Marked Cards'),
              ),
            if (isReviewingMarked)
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  notifier.stopMarkedCardsReview(deckId);
                },
                child: const Text('Return to Full Deck'),
              ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                notifier.resetSession();
              },
              child: Text(isReviewingMarked ? 'Review Again' : 'Study Again'),
            ),
          ],
        ),
      ),
    );

    // If this is a collection study, automatically continue to the next deck after a short delay
    if (isCollectionStudy && !isReviewingMarked) {
      Future.delayed(const Duration(seconds: 3), () {
        // Check if the dialog is still showing
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
          onFinish();
        }
      });
    }
  }
}
