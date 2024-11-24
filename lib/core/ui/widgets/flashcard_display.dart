import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flashcardstudyapplication/core/providers/flashcard_provider.dart';

class FlashcardDisplay extends ConsumerWidget {
  final String deckId;

  const FlashcardDisplay({Key? key, required this.deckId}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get the flashcard state from the provider
    final flashcardState = ref.watch(flashcardProvider);
    final flashcards = flashcardState.flashcardsByDeck[deckId] ?? [];

    // If there are no flashcards, display a message
    if (flashcards.isEmpty) {
      return const Center(child: Text('No flashcards available'));
    }

    // Get the current flashcard based on the current index
    final currentFlashcard = flashcards[flashcardState.currentCardIndex];

    return GestureDetector(
      onTap: () {
        // Flip the card by calling the provider method via controller
        ref.read(flashcardProvider.notifier).toggleFlip();
      },
      child: Card(
        elevation: 5,
        margin: const EdgeInsets.all(16),
        color: Theme.of(context).cardColor, // Use card color from theme
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // Rounded corners for a modern look
        ),
        child: Container(
          padding: const EdgeInsets.all(35),
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12), // Same border radius as the card
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.primary.withOpacity(0.1),
                Theme.of(context).colorScheme.primary.withOpacity(0.2),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                flashcardState.isFlipped ? 'Answer' : 'Question',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
              ),
              const SizedBox(height: 16),
              Text(
                flashcardState.isFlipped
                    ? currentFlashcard.back
                    : currentFlashcard.front,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold, // Make the question/answer bold
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Icon(
                Icons.touch_app,
                color: Theme.of(context).colorScheme.secondary.withOpacity(0.5),
              ),
              Text(
                'Tap to flip',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6), // Lighter color for secondary text
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
