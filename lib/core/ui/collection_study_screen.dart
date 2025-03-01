import 'package:flashcardstudyapplication/core/models/collection.dart';
import 'package:flashcardstudyapplication/core/models/deck.dart';
import 'package:flashcardstudyapplication/core/models/user_collection.dart';
import 'package:flashcardstudyapplication/core/providers/provider_config.dart';
import 'package:flashcardstudyapplication/core/ui/widgets/CustomScaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math';

class CollectionStudyScreen extends ConsumerStatefulWidget {
  final Collection collection;
  final UserCollection userCollection;

  const CollectionStudyScreen({
    Key? key,
    required this.collection,
    required this.userCollection,
  }) : super(key: key);

  @override
  ConsumerState<CollectionStudyScreen> createState() =>
      _CollectionStudyScreenState();
}

class _CollectionStudyScreenState extends ConsumerState<CollectionStudyScreen> {
  List<Deck> _decks = [];
  List<Deck> _filteredDecks = [];
  final Map<String, Future<void>> _preloadedDecks = {};
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedDifficulty = 'All';
  final List<String> _difficultyLevels = ['All', 'Easy', 'Medium', 'Hard'];

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _initializeDecks());
  }

  Future<void> _initializeDecks() async {
    try {
      final decks = await ref
          .read(deckStateProvider.notifier)
          .getDecksForCollection(widget.collection.id);
      if (mounted) {
        setState(() {
          _decks = decks;
          _filteredDecks = decks;
          _isLoading = false;
        });
        _preloadNextDecks();
        _updateDifficultyLevels();
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

  void _updateDifficultyLevels() {
    // Get unique difficulty levels from decks
    final Set<String> difficulties = {'All'};
    for (var deck in _decks) {
      difficulties.add(deck.difficultyLevel);
    }
    setState(() {
      _difficultyLevels.clear();
      _difficultyLevels.addAll(difficulties.toList()..sort());
    });
  }

  void _filterDecks() {
    setState(() {
      _filteredDecks = _decks.where((deck) {
        final matchesSearch =
            deck.title.toLowerCase().contains(_searchQuery.toLowerCase());
        final matchesDifficulty = _selectedDifficulty == 'All' ||
            deck.difficultyLevel == _selectedDifficulty;
        return matchesSearch && matchesDifficulty;
      }).toList();

      // Sort by difficulty level (Easy to Hard by default)
      _sortDecksByDifficulty(false);
    });
  }

  void _sortDecksByDifficulty(bool randomize) {
    if (randomize) {
      // Randomize the deck order
      _filteredDecks.shuffle(Random());
    } else {
      // Sort by difficulty level: Easy, Medium, Hard
      _filteredDecks.sort((a, b) {
        // Define difficulty order: Easy, Medium, Hard
        final difficultyOrder = {'Easy': 0, 'Medium': 1, 'Hard': 2};
        final aOrder = difficultyOrder[a.difficultyLevel] ?? 0;
        final bOrder = difficultyOrder[b.difficultyLevel] ?? 0;
        return aOrder.compareTo(bOrder);
      });
    }
  }

  void _preloadNextDecks() {
    // Preload next 3 decks
    for (var i = 0; i < _filteredDecks.length && i < 3; i++) {
      final deck = _filteredDecks[i];
      if (!_preloadedDecks.containsKey(deck.id)) {
        _preloadedDecks[deck.id] = ref
            .read(flashcardStateProvider.notifier)
            .getFlashcardsForDeck(deck.id);
      }
    }
  }

  void _onDeckVisible(int index) {
    // Preload next deck when user scrolls near the end
    if (index >= _filteredDecks.length - 2) {
      final nextIndex = index + 2;
      if (nextIndex < _filteredDecks.length) {
        final nextDeck = _filteredDecks[nextIndex];
        if (!_preloadedDecks.containsKey(nextDeck.id)) {
          _preloadedDecks[nextDeck.id] = ref
              .read(flashcardStateProvider.notifier)
              .getFlashcardsForDeck(nextDeck.id);
        }
      }
    }
  }

  void _studyRandomDeck() {
    if (_filteredDecks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No decks available to study')),
      );
      return;
    }

    // Randomize the deck order
    final List<Deck> randomizedDecks = List.from(_filteredDecks);
    randomizedDecks.shuffle(Random());

    setState(() {
      _filteredDecks = randomizedDecks;
    });

    // Start studying with the first deck in the randomized list
    _startStudySession(randomizedDecks.first);
  }

  void _startStudySession(Deck deck) async {
    try {
      // Wait for preloading to complete if it's still ongoing
      if (_preloadedDecks.containsKey(deck.id)) {
        await _preloadedDecks[deck.id];
      } else {
        await ref
            .read(flashcardStateProvider.notifier)
            .getFlashcardsForDeck(deck.id);
      }

      if (mounted) {
        // Create a list of remaining decks that starts with the selected deck's position
        // This ensures the study flow continues with the current order
        final int deckIndex = _filteredDecks.indexWhere((d) => d.id == deck.id);
        final List<Deck> remainingDecks = [];

        // Add decks after the current deck
        if (deckIndex != -1 && deckIndex < _filteredDecks.length - 1) {
          remainingDecks.addAll(_filteredDecks.sublist(deckIndex + 1));
        }

        Navigator.pushNamed(
          context,
          '/study',
          arguments: {
            'deck': deck,
            'collection': widget.collection,
            'isCollectionStudy': true,
            'remainingDecks': remainingDecks,
          },
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading flashcards: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentRoute = ModalRoute.of(context)?.settings.name ?? '';
    final ThemeData theme = Theme.of(context);
    final bool isDarkMode = theme.brightness == Brightness.dark;
    final cardColor = isDarkMode ? theme.cardColor : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final subtitleColor = isDarkMode ? Colors.white70 : Colors.black54;

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
          // Search and filter bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search decks...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                    _filterDecks();
                  },
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Difficulty',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                        ),
                        value: _selectedDifficulty,
                        items: _difficultyLevels.map((difficulty) {
                          return DropdownMenuItem<String>(
                            value: difficulty,
                            child: Text(difficulty),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedDifficulty = value!;
                          });
                          _filterDecks();
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: _studyRandomDeck,
                      icon: const Icon(Icons.shuffle),
                      label: const Text('Random'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          if (_isLoading)
            const Expanded(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_filteredDecks.isEmpty)
            Expanded(
              child: Center(
                child: Text(
                  _decks.isEmpty
                      ? 'No decks in this collection'
                      : 'No decks match your search',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: _filteredDecks.length,
                itemBuilder: (context, index) {
                  _onDeckVisible(index);
                  final deck = _filteredDecks[index];

                  // Determine difficulty color
                  Color difficultyColor;
                  switch (deck.difficultyLevel.toLowerCase()) {
                    case 'easy':
                      difficultyColor = Colors.green;
                      break;
                    case 'medium':
                      difficultyColor = Colors.orange;
                      break;
                    case 'hard':
                      difficultyColor = Colors.red;
                      break;
                    default:
                      difficultyColor = Colors.blue;
                  }

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    color: cardColor,
                    child: ListTile(
                      title: Text(
                        deck.title,
                        style: TextStyle(
                          fontSize: theme.textTheme.titleMedium?.fontSize,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      subtitle: Row(
                        children: [
                          Text(
                            'Cards: ${deck.totalCards}',
                            style: TextStyle(
                              fontSize: theme.textTheme.bodyMedium?.fontSize,
                              color: subtitleColor,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: difficultyColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: difficultyColor),
                            ),
                            child: Text(
                              deck.difficultyLevel,
                              style: TextStyle(
                                fontSize: theme.textTheme.bodySmall?.fontSize,
                                color: difficultyColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      trailing: FutureBuilder(
                        future: _preloadedDecks[deck.id],
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            );
                          }
                          return Icon(Icons.chevron_right, color: textColor);
                        },
                      ),
                      onTap: () => _startStudySession(deck),
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
