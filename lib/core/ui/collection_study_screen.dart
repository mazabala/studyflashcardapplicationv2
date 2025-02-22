import 'package:flashcardstudyapplication/core/models/collection.dart';
import 'package:flashcardstudyapplication/core/models/deck.dart';
import 'package:flashcardstudyapplication/core/models/user_collection.dart';
import 'package:flashcardstudyapplication/core/providers/provider_config.dart';
import 'package:flashcardstudyapplication/core/ui/widgets/CustomScaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CollectionStudyScreen extends ConsumerStatefulWidget {
  final Collection collection;
  final UserCollection userCollection;

  const CollectionStudyScreen({
    Key? key,
    required this.collection,
    required this.userCollection,
  }) : super(key: key);

  @override
  ConsumerState<CollectionStudyScreen> createState() => _CollectionStudyScreenState();
}

class _CollectionStudyScreenState extends ConsumerState<CollectionStudyScreen> {
  List<Deck> _decks = [];
  final Map<String, Future<void>> _preloadedDecks = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeDecks();
  }

  Future<void> _initializeDecks() async {
    try {
      final decks = await ref.read(deckStateProvider.notifier).getDecksForCollection(widget.collection.id);
      if (mounted) {
        setState(() {
          _decks = decks;
          _isLoading = false;
        });
        _preloadNextDecks();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading decks: $e')),
        );
      }
    }
  }

  void _preloadNextDecks() {
    // Preload next 3 decks
    for (var i = 0; i < _decks.length && i < 3; i++) {
      final deck = _decks[i];
      if (!_preloadedDecks.containsKey(deck.id)) {
        _preloadedDecks[deck.id] = ref
            .read(flashcardStateProvider.notifier)
            .getFlashcardsForDeck(deck.id);
      }
    }
  }

  void _onDeckVisible(int index) {
    // Preload next deck when user scrolls near the end
    if (index >= _decks.length - 2) {
      final nextIndex = index + 2;
      if (nextIndex < _decks.length) {
        final nextDeck = _decks[nextIndex];
        if (!_preloadedDecks.containsKey(nextDeck.id)) {
          _preloadedDecks[nextDeck.id] = ref
              .read(flashcardStateProvider.notifier)
              .getFlashcardsForDeck(nextDeck.id);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentRoute = ModalRoute.of(context)?.settings.name ?? '';

    return CustomScaffold(
      currentRoute: currentRoute,
      useScroll: false,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Decks in ${widget.collection.name}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          if (_isLoading)
            const Expanded(
              child: Center(child: CircularProgressIndicator()),
            )
          else
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: _decks.length,
                itemBuilder: (context, index) {
                  _onDeckVisible(index);
                  final deck = _decks[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(deck.title),
                      subtitle: Text('Cards: ${deck.totalCards} • Difficulty: ${deck.difficultyLevel}'),
                      trailing: FutureBuilder(
                        future: _preloadedDecks[deck.id],
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            );
                          }
                          return const Icon(Icons.chevron_right);
                        },
                      ),
                      onTap: () async {
                        try {
                          // Wait for preloading to complete if it's still ongoing
                          await _preloadedDecks[deck.id];
                          if (mounted) {
                            Navigator.pushNamed(
                              context,
                              '/study',
                              arguments: deck,
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error loading flashcards: $e')),
                            );
                          }
                        }
                      },
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
} 