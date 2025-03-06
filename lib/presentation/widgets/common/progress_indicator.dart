import 'package:flashcardstudyapplication/core/providers/provider_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flashcardstudyapplication/core/providers/flashcard_provider.dart';

class ProgressIndicatorWidget extends ConsumerWidget {
  final String deckId;

  const ProgressIndicatorWidget({Key? key, required this.deckId}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get the flashcard state from the provider
    final flashcardState = ref.watch(flashcardStateProvider);
    final flashcards = flashcardState.flashcardsByDeck[deckId] ?? [];


    // If there are no flashcards, no progress to show
    if (flashcards.isEmpty) {
      return const SizedBox.shrink();
    }

    // Calculate progress as a fraction of completed cards
    double progress = flashcardState.currentCardIndex / flashcards.length;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: LinearProgressIndicator(
        value: progress.isNaN ? 0 : progress,  // Ensure no NaN value
        backgroundColor: Theme.of(context).colorScheme.surface,
        valueColor: AlwaysStoppedAnimation<Color>(
          Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
