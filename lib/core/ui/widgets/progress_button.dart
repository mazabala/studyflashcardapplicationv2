import 'package:flashcardstudyapplication/core/ui/study_screen_controller.dart';
import 'package:flashcardstudyapplication/core/ui/widgets/CustomButton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flashcardstudyapplication/core/providers/provider_config.dart';

class ProgressButtonWidget extends ConsumerWidget {
  final StudyScreenController controller;

  const ProgressButtonWidget({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final flashcardState = ref.watch(flashcardStateProvider);
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;

    // Check if flashcards list is empty
    final flashcards = flashcardState.flashcardsByDeck[controller.deckId] ?? [];
    if (flashcards.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    final currentCard = flashcards[flashcardState.currentCardIndex];
    final isMarked = flashcardState.markedForLater.contains(currentCard.id);
    final shouldBreak = ref.read(flashcardStateProvider.notifier).shouldTakeBreak();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Confidence-based response buttons
        if (isSmallScreen)
          // Vertical layout for small screens
          Column(
            children: [
              CustomButton(
                text: 'Still Learning',
                isLoading: false,
                icon: Icons.sentiment_dissatisfied,
                onPressed: () => controller.handleConfidenceResponse('low'),
              ),
              const SizedBox(height: 8),
              CustomButton(
                text: 'Getting There',
                isLoading: false,
                icon: Icons.sentiment_neutral,
                onPressed: () => controller.handleConfidenceResponse('medium'),
              ),
              const SizedBox(height: 8),
              CustomButton(
                text: 'Got It!',
                isLoading: false,
                icon: Icons.sentiment_satisfied,
                onPressed: () => controller.handleConfidenceResponse('high'),
              ),
            ],
          )
        else
          // Horizontal layout for larger screens
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              SizedBox(
                width: 150,
                child: CustomButton(
                  text: 'Still Learning',
                  isLoading: false,
                  icon: Icons.sentiment_dissatisfied,
                  onPressed: () => controller.handleConfidenceResponse('low'),
                ),
              ),
              SizedBox(
                width: 150,
                child: CustomButton(
                  text: 'Getting There',
                  isLoading: false,
                  icon: Icons.sentiment_neutral,
                  onPressed: () => controller.handleConfidenceResponse('medium'),
                ),
              ),
              SizedBox(
                width: 150,
                child: CustomButton(
                  text: 'Got It!',
                  isLoading: false,
                  icon: Icons.sentiment_satisfied,
                  onPressed: () => controller.handleConfidenceResponse('high'),
                ),
              ),
            ],
          ),

        const SizedBox(height: 16),
        
        // Mark for later button
        SizedBox(
          width: isSmallScreen ? double.infinity : 200,
          child: CustomButton(
            text: isMarked ? 'Marked' : 'Mark for Later',
            isLoading: false,
            icon: isMarked ? Icons.bookmark : Icons.bookmark_border,
            onPressed: () => controller.toggleMarkForLater(),
          ),
        ),

        // Break reminder if needed
        if (shouldBreak)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Text(
              'Time for a quick break? 😊',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.secondary,
              ),
            ),
          ),
      ],
    );
  }
}
