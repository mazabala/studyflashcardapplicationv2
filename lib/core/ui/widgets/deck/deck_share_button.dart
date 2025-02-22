import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flashcardstudyapplication/core/models/deck.dart';
import 'package:flashcardstudyapplication/core/providers/provider_config.dart';
import 'package:flashcardstudyapplication/core/ui/widgets/CustomButton.dart';

class DeckShareButton extends ConsumerWidget {
  final Deck deck;

  const DeckShareButton({
    Key? key,
    required this.deck,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CustomButton(
      text: 'Share Deck',
      icon: Icons.share,
      isLoading: false,
      onPressed: () async {
        try {
          // Update deck to be public
          await ref.read(deckServiceProvider).updateDeck(
            deck.id,
            deck.title,
            deck.difficultyLevel,
            deck.creatorid
          );

          if (context.mounted) {
            // Show success dialog with shareable link
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Share Deck'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Your deck is now public and can be shared with this link:'),
                    const SizedBox(height: 16),
                    SelectableText(
                      'https://yourdomain.com/decks/${deck.id}', //TODO: change to the actual domain
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ],
              ),
            );
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to share deck: $e')),
            );
          }
        }
      },
    );
  }
} 