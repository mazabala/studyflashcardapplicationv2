import 'package:flashcardstudyapplication/core/models/collection.dart';
import 'package:flashcardstudyapplication/core/models/deck.dart';
import 'package:flashcardstudyapplication/core/providers/provider_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CollectionDeckManager extends ConsumerStatefulWidget {
  final Collection collection;

  const CollectionDeckManager({
    super.key,
    required this.collection,
  });

  @override
  ConsumerState<CollectionDeckManager> createState() => _CollectionDeckManagerState();
}

class _CollectionDeckManagerState extends ConsumerState<CollectionDeckManager> {
  bool _isLoading = false;
  String _error = '';
  List<Deck> _availableDecks = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadAvailableDecks();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAvailableDecks() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final deckState = ref.read(deckStateProvider.notifier);
      final decks = await deckState.loadUserDecks(null);
      setState(() {
        _availableDecks = decks;
      });
    } catch (e) {
      setState(() {
        _error = 'Error loading decks: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _addDeckToCollection(Deck deck) async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final collectionService = ref.read(collectionServiceProvider);
      await collectionService.addDeckToCollection(widget.collection.id, deck.id);
      
      // Remove the deck from available decks
      setState(() {
        _availableDecks.removeWhere((d) => d.id == deck.id);
      });
      
      // Refresh the collections in the parent screen
      ref.invalidate(userCollectionsProvider);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Deck added to collection successfully')),
      );
      
      // Close the dialog if no more decks are available
      if (_getFilteredDecks().isEmpty && mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      setState(() {
        _error = 'Error adding deck to collection: $e';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding deck to collection: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<Deck> _getFilteredDecks() {
    final searchTerm = _searchController.text.toLowerCase();
    return _availableDecks.where((deck) {
      // Filter out decks that are already in the collection
      if (widget.collection.deckIds.contains(deck.id)) {
        return false;
      }
      // Apply search filter
      if (searchTerm.isEmpty) {
        return true;
      }
      return deck.title.toLowerCase().contains(searchTerm) ||
          deck.description.toLowerCase().contains(searchTerm);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredDecks = _getFilteredDecks();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Search Decks',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            onChanged: (_) => setState(() {}),
          ),
        ),
        if (_error.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SelectableText.rich(
              TextSpan(
                children: [
                  const TextSpan(text: 'Error: '),
                  TextSpan(
                    text: _error,
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
              ),
            ),
          ),
        if (_isLoading)
          const Center(child: CircularProgressIndicator())
        else if (filteredDecks.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('No available decks found'),
          )
        else
          Expanded(
            child: ListView.builder(
              itemCount: filteredDecks.length,
              itemBuilder: (context, index) {
                final deck = filteredDecks[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                  child: ListTile(
                    title: Text(deck.title),
                    subtitle: Text(
                      'Cards: ${deck.totalCards} • Difficulty: ${deck.difficultyLevel}',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: () => _addDeckToCollection(deck),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
} 