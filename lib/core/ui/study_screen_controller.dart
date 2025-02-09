import 'package:flashcardstudyapplication/core/models/flashcard.dart';
import 'package:flashcardstudyapplication/core/providers/provider_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flashcardstudyapplication/core/providers/flashcard_provider.dart'; // Import the flashcard provider

class StudyScreenController {
  final WidgetRef ref;
  final String deckId;

  StudyScreenController({required this.ref, required this.deckId});

  // Get the current state of flashcards for the deck
  FlashcardState get flashcardState => ref.read(flashcardStateProvider);


  // Get the list of flashcards for the deck
  List<Flashcard> get flashcards =>
      flashcardState.flashcardsByDeck[deckId] ?? [];

  // Navigate to the next card
  void nextCard(BuildContext context) {
    if (flashcardState.currentCardIndex < flashcards.length - 1) {
      ref.read(flashcardStateProvider.notifier).nextCard(deckId, flashcardState.currentCardIndex);
      

    } else {
      // When all cards are completed, show the completion dialog
      _showCompletionDialog(context);
    }
  }

  // Navigate to the previous card
  void previousCard() {
    if (flashcardState.currentCardIndex > 0) {
      ref.read(flashcardStateProvider.notifier).previousCard(deckId, flashcardState.currentCardIndex);
    }
  }


  // Handle when the card is marked as correct
  void handleCorrect() {
    // Update progress, mark as correct, and move to the next card
    ref.read(flashcardStateProvider.notifier).nextCard(deckId, flashcardState.currentCardIndex);
  }


  // Handle when the card is marked as incorrect
  void handleIncorrect() {
    // Update progress, mark as incorrect, and move to the next card
    ref.read(flashcardStateProvider.notifier).nextCard(deckId, flashcardState.currentCardIndex);
  }


  // Show the deck completion dialog
  // The BuildContext is passed from the widget where the dialog will be displayed
  void _showCompletionDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Deck Completed!'),
        content: const Text('You\'ve completed all flashcards in this deck.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Return to deck list
            },
            child: const Text('Finish'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              ref.read(flashcardStateProvider.notifier).resetSession(); // Reset session and start over
            },
            child: const Text('Study Again'),
          ),
        ],
      ),
    );
  }
}
