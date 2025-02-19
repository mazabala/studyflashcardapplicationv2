import 'package:flashcardstudyapplication/core/models/deck.dart';
import 'package:flashcardstudyapplication/core/navigation/router_manager.dart';
import 'package:flashcardstudyapplication/core/providers/auth_provider.dart';
import 'package:flashcardstudyapplication/core/providers/provider_config.dart';
import 'package:flashcardstudyapplication/core/services/deck/deck_service.dart';
import 'package:flashcardstudyapplication/core/ui/widgets/CategoryMultiSelect.dart';
import 'package:flashcardstudyapplication/core/ui/widgets/CustomButton.dart';
import 'package:flashcardstudyapplication/core/ui/widgets/CustomDialog.dart';
import 'package:flashcardstudyapplication/core/ui/widgets/CustomScaffold.dart';
import 'package:flashcardstudyapplication/core/ui/widgets/CustomTextField.dart';
import 'package:flashcardstudyapplication/core/ui/widgets/deck/create_deck_dialog.dart';
import 'package:flashcardstudyapplication/core/ui/widgets/deck/deck_action_buttons.dart';
import 'package:flashcardstudyapplication/core/ui/widgets/deck/deck_display.dart';
import 'package:flashcardstudyapplication/core/ui/widgets/myDeckToolBar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flashcardstudyapplication/core/providers/deck_provider.dart';
import 'package:flashcardstudyapplication/core/providers/user_provider.dart';
import 'package:flashcardstudyapplication/core/providers/subscription_provider.dart'; // Correct import
import 'package:flashcardstudyapplication/core/services/api/api_manager.dart';
import 'package:flashcardstudyapplication/core/ui/widgets/progress_dashboard_widget.dart';

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
  bool isInitialized= false;



TextEditingController _categoriesController = TextEditingController();
TextEditingController _descriptionsController = TextEditingController();
TextEditingController _cardCountController = TextEditingController();



   @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    if (!isInitialized) {
  _initializeServices();
}
  }

  Future<void> _initializeServices() async {
    try {

      // First check if user is authenticated
      final userState = ref.read(authStateProvider);
      

      if (!userState.isAuthenticated) {
        // Instead of showing a dialog, just navigate to login
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/login');
        }
        return;
      }
      
      // Then check if user is admin (only if authenticated)
      _checkSystemUser();
      if (ref.read(deckStateProvider).deckloaded == false) {
        await _loadUserDecks();
      }
      isInitialized = true;

    } catch (e) {
      print('Initialization error: $e');
      // Instead of showing dialog, you could use a SnackBar or just log the error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to initialize: $e'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  // Modify _checkSystemUser to watch the provider state
  void _checkSystemUser() {
   
    // Watch the provider instead of just reading it once
    final userState = ref.watch(userStateProvider);


    print(userState.isAdmin);
    // Check both isAdmin and role for superAdmin
    if (userState.isAdmin == true || userState.role == 'superAdmin') {
      print('Setting isSystemUser to true - user is an admin');
      
      
          isSystemUser = true;
       
      
    } else {
      print('User is not an admin - isSystemUser remains $isSystemUser');
    }
  }
  // Method to reset the search state and navigate to study screen
  void _resetSearchStateAndNavigate() {
 

        isSearchingNewDecks = false; // Reset search state

      _loadUserDecks();
      Navigator.pushReplacementNamed(context, '/myDecks'); // Navigate to /study
    
  }

  Future<List<String>> _getDeckCategory() async {
    
    final deckReader = ref.read(deckServiceProvider);
    return await deckReader.getDeckCategory();
  }

 
 Future<List<String>> _getDeckDifficulty() async {

  
    final deckReader = ref.read(deckServiceProvider);

    final userService = ref.read(userStateProvider);
    


    return await deckReader.getDeckDifficulty(userService.subscriptionPlanID);
  }


  void _searchNewDecks() async {
    try {
      final decks = await ref.read(deckStateProvider.notifier).loadAvailableDecks();
      if (mounted) { // Ensure the widget is still mounted before calling setState
        setState(() {

          if (decks.isEmpty || decks == []) {

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
    final authNotifier = ref.read(authStateProvider.notifier);
    await authNotifier.signOut(); // Ensure signOut is called using the notifier


    if (mounted) { // Check if widget is still mounted before navigating
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      print("Widget already disposed, can't navigate.");
    }
  }

  // Function to show the Create Deck dialog and create the deck
  void _createDeck() async {

    final userService = ref.read(userStateProvider);

    showDialog(
      context: context,
      builder: (context) {
        return CreateDeckDialog(
          onSubmit: (String subject, String concept, String category,
              String difficultyLevel, int cardCount) async {
            final userId = userService.userId;
            if (userId != null) {
              await ref.read(deckStateProvider.notifier).createDeck(subject,
                  concept, category, difficultyLevel, userId, cardCount);

              if (mounted) {
                // Ensure the widget is still mounted before popping
                _loadUserDecks(); // Refresh the deck list
              }
            } else {

            }
          },
        );
      },
    );
  }

  // Function to load user decks from the service
  Future<void> _loadUserDecks() async {
    final userService = ref.read(userStateProvider);
    

    final userId = userService.userId;

    if (userId != null) {
        print('(inside the if statement) loading users decks with user id: $userId');
        
      //await ref.read(deckStateProvider.notifier).loadUserDecks(userId);
      final decks = await ref.read(deckStateProvider.notifier).loadUserDecks(userId);

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


 







  @override
  Widget build(BuildContext context) {
    final String currentRoute = ModalRoute.of(context)?.settings.name ?? '/';

    // Check subscription status using the subscription provider
    final subscriptionStatus = ref.watch(subscriptionStateProvider);


    // If subscription is expired, show the blocking dialog
    if (subscriptionStatus.isExpired) {
      // Show the subscription expired popup
      Future.delayed(Duration.zero, () => _showSubscriptionExpiredDialog());
    }

    // Regular screen if subscription is not expired
    var children = [
      MyDeckToolBar(
          isAdmin: isSystemUser,
          onCreateDeck: _createDeck,
          onSeachNewDecks: () {
            if (!isSearchingNewDecks) {
              _searchNewDecks();  
            } else {
              _loadUserDecks();
            }
          },
          isSearchingNewDecks: isSearchingNewDecks),


            
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
      
             
          ];
   
    return CustomScaffold(
      currentRoute: currentRoute,

      body: SingleChildScrollView(
        child: Column(
          children: children,
        ),
      ),
    );
  }
}
