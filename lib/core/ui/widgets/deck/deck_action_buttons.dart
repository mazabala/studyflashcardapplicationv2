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
      
      padding: const EdgeInsets.all(8.0),
      child: Row(  //TODO: this is overflowing on the phone. 
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton(
            onPressed: onCreateDeck,
            child: const Row(
              children: [Icon(Icons.add), Text('Create Deck')],
            ),
          ),
ElevatedButton(
  onPressed: isSearchingNewDecks ? onSeachNewDecks : onSeachNewDecks,
  child: Row(
    children: [
      
      Icon(isSearchingNewDecks ? Icons.arrow_back :Icons.search ),
      Text(isSearchingNewDecks ? 'My Decks' : 'Search New Decks'),
    ],
  ),
),


          ElevatedButton(
            onPressed: onSignOut,
            child: const Row(
              children: [Icon(Icons.exit_to_app), Text('Logout')],
            ),
          ),
        ],
      ),
    );
  }


}
