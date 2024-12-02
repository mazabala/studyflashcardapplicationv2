import 'package:flashcardstudyapplication/core/models/deck.dart';
import 'package:flashcardstudyapplication/core/providers/auth_provider.dart';
import 'package:flashcardstudyapplication/core/services/deck/deck_service.dart';
import 'package:flashcardstudyapplication/core/ui/widgets/CategoryMultiSelect.dart';
import 'package:flashcardstudyapplication/core/ui/widgets/CustomButton.dart';
import 'package:flashcardstudyapplication/core/ui/widgets/CustomDialog.dart';
import 'package:flashcardstudyapplication/core/ui/widgets/CustomScaffold.dart';
import 'package:flashcardstudyapplication/core/ui/widgets/CustomTextField.dart';
import 'package:flashcardstudyapplication/core/ui/widgets/deck/create_deck_dialog.dart';
import 'package:flashcardstudyapplication/core/ui/widgets/deck/deck_action_buttons.dart';
import 'package:flashcardstudyapplication/core/ui/widgets/deck/deck_display.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flashcardstudyapplication/core/providers/deck_provider.dart';
import 'package:flashcardstudyapplication/core/providers/user_provider.dart';
import 'package:flashcardstudyapplication/core/providers/subscription_provider.dart'; // Correct import

import 'widgets/deck/deck_search_bar.dart';

class MyDeckScreen extends ConsumerStatefulWidget {
  const MyDeckScreen({super.key});

  @override
  _MyDeckScreenState createState() => _MyDeckScreenState();
}

class _MyDeckScreenState extends ConsumerState<MyDeckScreen> {
  TextEditingController _searchController = TextEditingController();
  String? _selectedDifficulty;
  String? _selectedCategory;
  List<Deck>? _filteredDecks = [];
  bool isSearchingNewDecks = false;
  bool isSystemUser = false;
  List<String>? _selectedCategories = [];
  Map<String, TextEditingController> _descriptionControllers = {};


TextEditingController _categoriesController = TextEditingController();
TextEditingController _descriptionsController = TextEditingController();
TextEditingController _cardCountController = TextEditingController();



   @override
  void initState() {
    super.initState();
    _checkSystemUser();
  }


  // Check if current user is system admin
  Future<void> _checkSystemUser() async {

    // You would need to implement this method in your UserService
    final isAdmin = await ref.read(userServiceProvider).isSystemAdmin();
    print ('user is : $isAdmin');
    if (mounted) {
      setState(() {
        isSystemUser = isAdmin;
      });
    }
  }
  // Method to reset the search state and navigate to study screen
  void _resetSearchStateAndNavigate() {
    if (mounted) {
      setState(() {
        isSearchingNewDecks = false; // Reset search state
      });
      _loadUserDecks();
      Navigator.pushReplacementNamed(context, '/myDecks'); // Navigate to /study
    }
  }

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



  void _searchNewDecks() async {
    try {
      final decks = await ref.read(deckProvider.notifier).loadAvailableDecks();
      if (mounted) { // Ensure the widget is still mounted before calling setState
        setState(() {
          if (decks.isEmpty || decks == null || decks == []) {
            isSearchingNewDecks = false;
            _filteredDecks = decks;
            _loadUserDecks();
          } else {
            isSearchingNewDecks = true;
          }
        });
      }
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  void _searchDecks(String query) {
    if (mounted) {
      setState(() {
        // Add filtering logic here if needed
      });
    }
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
          isSearchingNewDecks = false;
        });
      }
    
    }
  }

  // Show a blocking dialog if subscription is expired
  void _showSubscriptionExpiredDialog() {
    showDialog(
      barrierDismissible: false, // Prevent interaction with the screen outside the dialog
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Subscription Expired'),
          content: const Text('Your subscription has expired. Please renew your subscription to continue.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                // Navigate to subscription renewal page
                Navigator.pushNamed(context, '/renewSubscription');
              },
              child: const Text('Renew Subscription'),
            ),
              TextButton(
              onPressed: () {
                // Navigate to subscription renewal page
                      _signOut(); // Implement sign-out logic here
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

 // Show system deck creation dialog
 void _showSystemDeckDialog() async {
  final deckDifficulty = await _getDeckDifficulty();
  final categories = await _getDeckCategory();

  // Map to store description controllers dynamically
  final descriptionControllers = <String, TextEditingController>{};

  showDialog(
    context: context,
    builder: (context) => SystemDeckDialog(
      categories: categories,
      difficulties: deckDifficulty,
      selectedCategories: _selectedCategories ?? [],
      selectedDifficulty: _selectedDifficulty,
      cardCountController: _cardCountController,
      descriptionControllers: descriptionControllers,
      onCategoryToggle: (category) {
        setState(() {
          if (_selectedCategories?.contains(category) ?? false) {
            _selectedCategories?.remove(category);
            descriptionControllers.remove(category);
          } else {
            _selectedCategories?.add(category);
            descriptionControllers[category] = TextEditingController();
          }
        });
      },
      onAddCategory: (newCategory) async {
        await ref.read(deckProvider.notifier).addDeckCategory(newCategory);
        final updatedCategories = await _getDeckCategory(); // Ensure updated list

        setState(() {
          categories.clear();
          categories.addAll(updatedCategories);
          if (!categories.contains(newCategory)) {
            categories.add(newCategory);
          }
        });
      },
      onDifficultyChanged: (difficulty) {
        setState(() {
          _selectedDifficulty = difficulty;
        });
      },
      onConfirm: () async { 

        // Extract descriptions
      List<String> descriptions = descriptionControllers.values
          .map((controller) => controller.text)
          .toList();

        print('$_selectedCategories and: $descriptions');
         _createSystemDecks(_selectedCategories!,descriptions);
         }
    ),
  );
}




 Future<void> _createSystemDecks(List<String> categories, List<String> descriptions) async {
  try {
    // Split the input strings into lists and trim whitespace

    final cardCount = int.tryParse(_cardCountController.text) ?? 10;

    // Validate that we have matching categories and descriptions
    if (categories.length != descriptions.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Categories and descriptions must match in number')),
      );
      return;
    }

    // Create a list of SystemDeckConfig objects by mapping the input data
    final configs = List<SystemDeckConfig>.generate(
      categories.length,
      (index) => SystemDeckConfig(
        category: categories[index],
        description: descriptions[index],
        difficultyLevel: _selectedDifficulty ?? '',
        cardCount: cardCount
      )
    );
  

      
    // Call the new systemCreateDecks method with our configurations
    await ref.read(deckProvider.notifier).systemCreateDecks(configs);

    // If successful, close the dialog and refresh the view
    if (mounted) {
      Navigator.pop(context);
      _resetSearchStateAndNavigate();
    }
  } catch (e) {
    // Handle any errors that occur during deck creation
    if (mounted) {
      print (e);      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating system decks: $e')),
      );
    }
  }
}







  @override
  Widget build(BuildContext context) {
    final String currentRoute = ModalRoute.of(context)?.settings.name ?? '/';

    // Check subscription status using the subscription provider
    final subscriptionStatus = ref.watch(subscriptionProvider);

    // If subscription is expired, show the blocking dialog
    if (subscriptionStatus.isExpired) {
      // Show the subscription expired popup
      Future.delayed(Duration.zero, () => _showSubscriptionExpiredDialog());
    }

    // Regular screen if subscription is not expired
    return CustomScaffold(
      currentRoute: currentRoute,
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (isSystemUser) ...[
              const SizedBox(height: 16),
              CustomButton(
                text: 'Create System Decks',
                isLoading: false,
                onPressed: _showSystemDeckDialog,
              ),
              const SizedBox(height: 16),
              const Divider(),
            ],
            SearchBarWidget(
              controller: _searchController,
              onChanged: _searchDecks,
            ),
            DeckDisplayWidget(
              filteredDecks: _filteredDecks ?? [],
              searchController: _searchController,
              isSearchingNewDecks: isSearchingNewDecks,
              onDeckAdded: _resetSearchStateAndNavigate,
            ),
            // If subscription expired, disable the Deck buttons
            if (!subscriptionStatus.isExpired)
              DeckButtonsWidget(
                isSearchingNewDecks: isSearchingNewDecks,
                onSeachNewDecks: () {
                  if (!isSearchingNewDecks) {
                       _searchNewDecks();
                            }
                  else {_loadUserDecks();}
                  },
                onCreateDeck: () {_createDeck();}, // Implement create deck logic here
                onSignOut: () {_signOut();}, // Implement sign-out logic here
              ),
          ],
        ),
      ),
    );
  }
}
