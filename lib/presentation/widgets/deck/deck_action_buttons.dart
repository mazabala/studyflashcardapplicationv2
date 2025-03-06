import 'package:flashcardstudyapplication/core/constants/responsive_constants.dart';
import 'package:flutter/material.dart';

class DeckButtonsWidget extends StatelessWidget {
  final VoidCallback onCreateDeck;
  final VoidCallback onSeachNewDecks;
  final VoidCallback onSignOut;
  final bool isSearchingNewDecks;

  const DeckButtonsWidget({
    Key? key,
    required this.onCreateDeck,
    required this.onSignOut,
    required this.onSeachNewDecks,
    required this.isSearchingNewDecks,
  }) : super(key: key);

   @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(ResponsiveConstants.defaultPadding),
      child: Wrap(
        spacing: ResponsiveConstants.defaultPadding,
        runSpacing: ResponsiveConstants.defaultPadding,
        alignment: WrapAlignment.spaceBetween,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: ResponsiveConstants.maxButtonWidth,
              minWidth: ResponsiveConstants.minButtonWidth,
            ),
            child: ElevatedButton(
              onPressed: onCreateDeck,
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.add),
                  SizedBox(width: ResponsiveConstants.smallPadding),
                  const Flexible(
                    child: Text(
                      'Create Deck',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: ResponsiveConstants.maxButtonWidth,
              minWidth: ResponsiveConstants.minButtonWidth,
            ),
            child: ElevatedButton(
              onPressed: isSearchingNewDecks ? onSeachNewDecks : onSeachNewDecks,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(isSearchingNewDecks ? Icons.arrow_back : Icons.search),
                  const SizedBox(width: ResponsiveConstants.smallPadding),
                  Flexible(
                    child: Text(
                      isSearchingNewDecks ? 'My Decks' : 'Search New Decks',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}