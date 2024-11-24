import 'package:flashcardstudyapplication/core/models/deck.dart';
import 'package:flashcardstudyapplication/core/providers/auth_provider.dart';
import 'package:flashcardstudyapplication/core/ui/widgets/CustomScaffold.dart';
import 'package:flashcardstudyapplication/core/ui/widgets/deck/category_dropdown.dart';
import 'package:flashcardstudyapplication/core/ui/widgets/deck/create_deck_dialog.dart';
import 'package:flashcardstudyapplication/core/ui/widgets/deck/deck_action_buttons.dart';
import 'package:flashcardstudyapplication/core/ui/widgets/deck/deck_display.dart';

import 'package:flashcardstudyapplication/core/ui/widgets/deck/difficulty_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flashcardstudyapplication/core/providers/deck_provider.dart';
import 'package:flashcardstudyapplication/core/providers/user_provider.dart';

import 'widgets/deck/deck_search_bar.dart';


class MyDeckScreen extends ConsumerStatefulWidget {
  @override
  _MyDeckScreenState createState() => _MyDeckScreenState();
}

class _MyDeckScreenState extends ConsumerState<MyDeckScreen> {
  TextEditingController _searchController = TextEditingController();
  String? _selectedDifficulty;
  String? _selectedCategory;
 List<Deck>? _filteredDecks = [];
  Future<List<String>> _getDeckCategory() async {
    final deckReader = ref.read(deckServiceProvider);
    return await deckReader.getDeckCategory();
  }

  Future<List<String>> _getDeckDifficulty() async {
    final deckReader = ref.read(deckServiceProvider);
    final userReader = ref.read(userServiceProvider);
    final subscriptionId = await userReader.getUserSubscriptionPlan();
    return await deckReader.getDeckDifficulty(subscriptionId);
  }

  void _searchDecks(String query) {
    setState(() {
      // Add filtering logic here if needed
    });
  }

  // Function to handle logout
  Future<void> _signOut() async {
  final authNotifier = ref.read(authProvider.notifier);
  await authNotifier.signOut(); // Ensure signOut is called using the notifier
  
  if (mounted) { // Check if widget is still mounted before navigating
    Navigator.pushReplacementNamed(context, '/login');
  } else {
    print("Widget already disposed, can't navigate.");
  }
}
  // Function to show the Create Deck dialog and create the deck
  void _createDeck() async {
  final deckCategory = await _getDeckCategory();
  final deckDifficulty = await _getDeckDifficulty();

  showDialog(
    context: context,
    builder: (context) {
      return CreateDeckDialog(
        onSubmit: (String title, String description, String category, String difficultyLevel, int cardCount) async {
          final userId = ref.read(userServiceProvider).getCurrentUserId();
          if (userId != null) {
            await ref.read(deckProvider.notifier).createDeck(title, category, description, difficultyLevel, userId, cardCount);
            
            if (mounted) { // Ensure the widget is still mounted before popping
             
              _loadUserDecks(); // Refresh the deck list
            }
          } else {
            print('User ID not found');
          }
        },
      );
    },
  );
}
  // Function to load user decks from the service
Future<void> _loadUserDecks() async {
  final userId = ref.read(userServiceProvider).getCurrentUserId();
  if (userId != null) {
    final decks = await ref.read(deckProvider.notifier).loadUserDecks();
    if (mounted) { // Ensure the widget is still mounted before calling setState
      setState(() {
        _filteredDecks = decks;
      });
    }
  }
}
  @override
  Widget build(BuildContext context) {
    final String currentRoute = ModalRoute.of(context)?.settings.name ?? '/';
    return CustomScaffold(
      currentRoute: currentRoute,

      body: SingleChildScrollView(
        child: Column(
          children: [
            SearchBarWidget(
              controller: _searchController,
              onChanged: _searchDecks,
            ),
            FetchAndDisplayDifficultyLevelWidget(
              selectedDifficulty: _selectedDifficulty,
             onChanged: (value) {
                        if (mounted) {
                          setState(() {
                            _selectedDifficulty = value;
                          });
                        }
                      },
              fetchDifficulty: _getDeckDifficulty,
            ),
            FetchAndDisplayCategorySelectionWidget(
              selectedCategory: _selectedCategory,
              onChanged: (value) { setState(() {
                if(mounted){
                _selectedCategory = value;
                }
              });}
              ,
              fetchCategory: _getDeckCategory,
            ),
            DeckDisplayWidget(
              filteredDecks: [],
              searchController: _searchController,
            ),
            DeckButtonsWidget(
              onCreateDeck: () {_createDeck();}, // Implement create deck logic here
              onSignOut: () {_signOut();}, // Implement sign-out logic here
            ),
          ],
        ),
      ),
    );
  }
}
