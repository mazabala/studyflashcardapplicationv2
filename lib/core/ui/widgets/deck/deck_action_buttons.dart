import 'package:flutter/material.dart';

class DeckButtonsWidget extends StatelessWidget {
  final VoidCallback onCreateDeck;
  final VoidCallback onSignOut;

  const DeckButtonsWidget({
    Key? key,
    required this.onCreateDeck,
    required this.onSignOut,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton(
            onPressed: onCreateDeck,
            child: Row(
              children: [Icon(Icons.add), Text('Create Deck')],
            ),
          ),
          ElevatedButton(
            onPressed: onSignOut,
            child: Row(
              children: [Icon(Icons.exit_to_app), Text('Logout')],
            ),
          ),
        ],
      ),
    );
  }
}
