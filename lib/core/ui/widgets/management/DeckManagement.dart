import 'package:flashcardstudyapplication/core/themes/app_theme.dart';
import 'package:flutter/material.dart';


// Main Deck Management Page
class DeckManagementPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Deck Management', style: Theme.of(context).textTheme.labelLarge),
      ),
      body: Column(
        children: [
          DeckActions(),
          Expanded(child: DeckListView()),
        ],
      ),
    );
  }
}

// Deck Actions Widget
class DeckActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton(
            onPressed: () => _navigateTo(context, CreateDeckPage()),
            child: Text('Create Deck'),
          ),
          ElevatedButton(
            onPressed: () => _navigateTo(context, AddCategoryPage()),
            child: Text('Add Category'),
          ),
        ],
      ),
    );
  }

  void _navigateTo(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }
}

// Deck List View
class DeckListView extends StatelessWidget {
  final List<String> decks = ['Deck 1', 'Deck 2', 'Deck 3']; // Mock data

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: decks.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(decks[index], style: Theme.of(context).textTheme.labelLarge),
          trailing: IconButton(
            icon: Icon(Icons.delete, color: Colors.red),
            onPressed: () => _deleteDeck(context, decks[index]),
          ),
          onTap: () => _navigateTo(context, DeckDetailsView(deck: decks[index])),
        );
      },
    );
  }

  void _navigateTo(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  void _deleteDeck(BuildContext context, String deck) {
    // Logic for deleting a deck
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$deck deleted')));
  }
}

// Deck Details View (Add/Edit Description)
class DeckDetailsView extends StatelessWidget {
  final String deck;

  DeckDetailsView({required this.deck});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit $deck', style: Theme.of(context).textTheme.labelLarge),
      ),
      body: Center(child: Text('Edit details for $deck', style: Theme.of(context).textTheme.labelLarge)),
    );
  }
}

// Flashcard Review Page
class ReviewFlashcardsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Review Flashcards', style: Theme.of(context).textTheme.labelLarge),
      ),
      body: Center(child: Text('Flashcards here', style: Theme.of(context).textTheme.labelLarge)),
    );
  }
}

// Mock CreateDeckPage for navigation
class CreateDeckPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Deck', style: Theme.of(context).textTheme.labelLarge)),
      body: Center(child: Text('Form to create a deck', style: Theme.of(context).textTheme.labelLarge)),
    );
  }
}

// Mock AddCategoryPage for navigation
class AddCategoryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Category', style: Theme.of(context).textTheme.labelLarge)),
      body: Center(child: Text('Form to add a category', style: Theme.of(context).textTheme.labelLarge)),
    );
  }
}
