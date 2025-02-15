//import 'dart:ffi';

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flashcardstudyapplication/core/providers/provider_config.dart';


class FlashcardDisplay extends ConsumerWidget {
  final String deckId;
  final String deckTitle;
  final String deckDescription;
  final String deckDifficulty;

  const FlashcardDisplay(this.deckTitle, this.deckDescription, this.deckDifficulty, {Key? key, required this.deckId}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final flashcardState = ref.watch(flashcardStateProvider);
    final flashcards = flashcardState.flashcardsByDeck[deckId] ?? [];
    

    if (flashcards.isEmpty) {
      return const Center(child: Text('No flashcards available'));
    }

    final currentFlashcard = flashcards[flashcardState.currentCardIndex];

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: IntrinsicHeight(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: 
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                   Text(
                      deckTitle,
                    style: theme.textTheme.titleLarge?.copyWith(color: Colors.white),
                  ),
                  Text(
                      deckDescription,
                    style: theme.textTheme.titleLarge?.copyWith(color: Colors.white70),
                  ),
                  ],
                  ),
                  ),
             
                  Column(
                      crossAxisAlignment:  CrossAxisAlignment.end,
                    children: [
                      // Report Button
                  GestureDetector(
                    onTap: () async {
                      await ref.read(flashcardStateProvider.notifier).reportCard(currentFlashcard);
                      if (flashcardState.currentCardIndex >= 0) {
                        ref.read(flashcardStateProvider.notifier).nextCard(deckId, flashcardState.currentCardIndex);
                        
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.report, size: 16, color: Colors.white),
                          SizedBox(width: 4),
                          Text(
                            'Report',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.secondary,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  deckDifficulty,
                                  style: theme.textTheme.bodySmall?.copyWith(color: Colors.white),
                                ),
                              ),
                               const SizedBox(height: 10),
                  Text(
                      '${flashcards.length} cards',
                      style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70)
                      
                  ),

                  ],)
                ],
              ),
            ),

            // Flashcard Content
            Expanded(
              child: GestureDetector(
                onTap: () {
                  ref.read(flashcardStateProvider.notifier).toggleFlip();
                },
                child: Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: flashcardState.isFlipped
                        ? theme.colorScheme.secondary.withOpacity(0.1)
                        : Colors.white,
                    border: Border.all(
                      color: theme.colorScheme.primary.withOpacity(0.2),
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Center(
                          child: Text(
                            flashcardState.isFlipped
                                ? currentFlashcard.back
                                : currentFlashcard.front,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.touch_app,
                              color: theme.colorScheme.primary.withOpacity(0.6),
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Tap to flip',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.primary.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}