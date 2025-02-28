import 'package:flashcardstudyapplication/core/providers/provider_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flashcardstudyapplication/core/models/deck.dart';

class DeckDisplayWidget extends StatelessWidget {
  final List<Deck>? filteredDecks;
  final TextEditingController searchController;
  final bool isSearchingNewDecks;
  final VoidCallback onDeckAdded;

  const DeckDisplayWidget({
    Key? key,
    required this.filteredDecks,
    required this.searchController,
    required this.isSearchingNewDecks,
    required this.onDeckAdded,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final deckState = ref.watch(deckStateProvider);
        final flashcardState = ref.watch(flashcardStateProvider);
        final ThemeData theme = Theme.of(context);
        final bool isDarkMode = theme.brightness == Brightness.dark;

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
            return deck.title
                .toLowerCase()
                .contains(searchController.text.toLowerCase());
          }).toList();
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: filteredDecks.length,
          padding: const EdgeInsets.all(8),
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final deck = filteredDecks[index];
            // Use a card color that adapts to the theme
            final cardColor = isDarkMode ? theme.cardColor : Colors.white;
            // Use text colors that contrast with the card color
            final textColor = isDarkMode ? Colors.white : Colors.black87;
            final subtitleColor = isDarkMode ? Colors.white70 : Colors.black54;

            return ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              tileColor: cardColor,
              focusColor: theme.secondaryHeaderColor,
              title: Text(
                deck.title,
                style: TextStyle(
                  fontSize: theme.textTheme.bodyLarge?.fontSize,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              subtitle: Text(
                'Difficulty: ${deck.difficultyLevel}',
                style: TextStyle(
                  fontSize: theme.textTheme.bodyMedium?.fontSize,
                  color: subtitleColor,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              onTap: () async {
                if (!isSearchingNewDecks) {
                  // Proceed with studying if not in search mode
                  try {
                    await ref
                        .read(flashcardStateProvider.notifier)
                        .getFlashcardsForDeck(deck.id);
                    if (context.mounted) {
                      Navigator.pushNamed(context, '/study', arguments: deck);
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Error loading flashcards: $e')));
                    }
                  }
                }
              },
              trailing: isSearchingNewDecks
                  ? IconButton(
                      icon: Icon(Icons.add, color: textColor),
                      onPressed: () {
                        // Add deck to library logic here
                        ref
                            .read(deckStateProvider.notifier)
                            .addDecktoUser(deck.id);
                        onDeckAdded();
                        Navigator.pushNamed(context, '/myDecks');
                      },
                    )
                  : IconButton(
                      icon: Icon(Icons.delete, color: textColor),
                      onPressed: () => ref
                          .read(deckStateProvider.notifier)
                          .deleteDeck(deck.id),
                    ),
            );
          },
        );
      },
    );
  }
}
