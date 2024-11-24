import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flashcardstudyapplication/core/models/deck.dart';
import 'package:flashcardstudyapplication/core/providers/deck_provider.dart';
import 'package:flashcardstudyapplication/core/providers/flashcard_provider.dart';

class DeckDisplayWidget extends StatelessWidget {
  final List<Deck>? filteredDecks;
  final TextEditingController searchController;

  const DeckDisplayWidget({
    Key? key,
    required this.filteredDecks,
    required this.searchController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final deckState = ref.watch(deckProvider);
        final flashcardState = ref.watch(flashcardProvider);
        final ThemeData theme = Theme.of(context);

        if (deckState.isLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (deckState.error.isNotEmpty) {
          return Center(child: Text('Error: ${deckState.error}'));
        } else if (deckState.decks.isEmpty) {
          return const Center(child: Text('No decks found.'));
        }

        var filteredDecks = deckState.decks;
        if (searchController.text.isNotEmpty) {
          filteredDecks = deckState.decks.where((deck) {
            return deck.title.toLowerCase().contains(searchController.text.toLowerCase());
          }).toList();
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: filteredDecks.length,
          itemBuilder: (context, index) {
            final deck = filteredDecks[index];
            return ListTile(
              tileColor: theme.scaffoldBackgroundColor,
              focusColor: theme.secondaryHeaderColor,
              title: Text(
                deck.title,
                style: theme.textTheme.bodyMedium,
                ),
              subtitle: Text(
                'Difficulty: ${deck.difficultyLevel}',
                style:  theme.textTheme.bodyMedium,
                ),
                
              onTap: () async {
                try {
                  await ref.read(flashcardProvider.notifier).getFlashcardsForDeck(deck.id);
                  if (context.mounted) {
                    Navigator.pushNamed(context, '/study', arguments: deck.id);
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error loading flashcards: $e')));
                  }
                }
              },
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => ref.read(deckProvider.notifier).deleteDeck(deck.id),
              ),
            );
          },
        );
      },
    );
  }
}
