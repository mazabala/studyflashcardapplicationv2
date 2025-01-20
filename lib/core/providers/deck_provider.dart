import 'package:flashcardstudyapplication/core/models/flashcard.dart';
import 'package:flashcardstudyapplication/core/providers/auth_provider.dart' as app_auth;
import 'package:flashcardstudyapplication/core/providers/user_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flashcardstudyapplication/core/models/deck.dart';
import 'package:flashcardstudyapplication/core/services/deck/deck_service.dart';
import 'package:flashcardstudyapplication/core/services/api/api_client.dart';
import 'package:flashcardstudyapplication/core/services/users/users_service.dart';

/// Direct Service Injection within the provider file
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});



/// DeckService injected with SupabaseClient and ApiClient directly
final deckServiceProvider = Provider<DeckService>((ref) {
  final supabaseClient = ref.watch(supabaseClientProvider);
  final apiClient = ref.watch(apiClientProvider);
  return DeckService(supabaseClient, apiClient);
});



/// DeckState class to hold the current state of the decks
class DeckState {
  final bool isLoading;
  final String error;
  final List<Deck> decks;

   DeckState({
    this.isLoading = false,
    this.error = '',
    this.decks = const [],
  });

  DeckState copyWith({
    bool? isLoading,
    String? error,
    List<Deck>? decks,
  }) {
    return DeckState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      decks: decks ?? this.decks,   
    );
  }
}



/// DeckNotifier to manage the state of the deck
class DeckNotifier extends StateNotifier<DeckState> {
  final DeckService _deckService;
  final UserState _userService;
  final Ref ref;

  DeckNotifier(this._deckService, this._userService, this.ref) : super( DeckState()) {
    // Listen to auth state changes
    ref.listen<app_auth.AuthState>(app_auth.authProvider, (previous, next) {
      
    });
  }   

  Future<void> _loadUserDecks(String ?userId) async {
    if (userId == null) {
      final usernewId = _userService.userId;
      if (usernewId == null) {
        throw Exception("User is not logged in");
      }
      userId = usernewId;
    }
    await loadUserDecks(userId);
  }

Future<void> flagCard(String flashcardId) async{

try {
  state = state.copyWith(isLoading: true, error: '');
  await _deckService.flagFlashcard(flashcardId);

}catch (e)
{
  rethrow;
  }
  finally {
      state = state.copyWith(isLoading: false);
    }
}

Future<List<Flashcard>> getDeckFlashcards (String deckid) async
{
  try{
    state = state.copyWith(isLoading: true, error: '');
      final deckFlashcards = _deckService.getFlashcards(deckid);
     return deckFlashcards;
  }
  catch (e)
  {
      print(e);
      rethrow;

  }
  finally{  
    state = state.copyWith(isLoading: false);
    }
}

  Future<void> createDeck(String title,String category, String description, String difficultyLevel, String userid,int cardCount) async {
    state = state.copyWith(isLoading: true, error: '');
    try {
      final userId = _userService.userId;
      if (userId == null) {
        throw Exception("User is not logged in");
      }
      final userSubscription = _userService.subscriptionPlanID;

      await _deckService.createDeck(title, category, description ,difficultyLevel, userid, cardCount);  
      
      //final decks = await _deckService.getUserDecks(userId);
      //state = state.copyWith(decks: decks);
    } catch (e) {
      print (e);
      state = state.copyWith(error: e.toString());
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

 Future<List<Deck>> loadAvailableDecks() async {
  state = state.copyWith(isLoading: true, error: '');

  try {
    print(
          'fetching available decks'
    );
    final userId = _userService.userId;
    if (userId == null) {
      throw Exception("User is not logged in");
    }

    final decks = await _deckService.loadDeckPool(userId);
    if (decks != null) {
          state = state.copyWith(decks: decks);
          return decks; 
        }
        else return [];
// Return the list of decks
  } catch (e) {
    state = state.copyWith(error: e.toString());
    return []; // Return an empty list in case of error
  } finally {
    state = state.copyWith(isLoading: false);
  }
}

Future<void>addDecktoUser(String deckId) async {

try{
    state = state.copyWith(isLoading: true, error: '');
    
    final userId = _userService.userId;
    if (userId == null) {
      throw Exception("User is not logged in");
    }
    
    await _deckService.decktoUser(deckId, userId);


  }
  catch (e)
  {
      print(e);
      rethrow;

  }
  finally{  
    state = state.copyWith(isLoading: false);
    }

}

 Future<List<Deck>> loadUserDecks(String ?userId) async {
  try {
    //state = state.copyWith(isLoading: true);
    
    if (userId == null) {
      final usernewId = _userService.userId;
      if (usernewId == null) {
        state = state.copyWith(error: "User is not logged in", isLoading: false);
        return [];
      }
      userId = usernewId;
    }
    
    final decks = await _deckService.getUserDecks(userId);
    // Always update state with the decks, even if empty
    print('decks: $decks');
    state = state.copyWith(decks: decks, isLoading: false);
    return decks;

  } catch (e) {
    print('error in the catch block of Deck Provider loadUserDecks: $e');
    final errorMsg = e.toString();
    state = state.copyWith(error: errorMsg, isLoading: false, decks: []);
    rethrow;
    
  }
}
 
  Future<void> updateDeck(String deckId, String title, String difficultyLevel) async {
    state = state.copyWith(isLoading: true, error: '');
    try {
      final userId = _userService.userId;
      if (userId == null) {
        throw Exception("User is not logged in");
      }

      await _deckService.updateDeck(deckId, title, difficultyLevel, userId);
      final decks = await _deckService.getUserDecks(userId);
      state = state.copyWith(decks: decks);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> deleteDeck(String deckId) async {
    state = state.copyWith(isLoading: true, error: '');
    try {
      final userId = _userService.userId;
      if (userId == null) {
        throw Exception("User is not logged in");
      }

      await _deckService.removeDeck(deckId);
      final decks = await _deckService.getUserDecks(userId);
      state = state.copyWith(decks: decks);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

Future<List<String>> getDeckDifficulty(String subcriptionID) async{

  final deckDifficulty = _deckService.getDeckDifficulty(subcriptionID);

  return deckDifficulty;


}

Future<List<String>> getDeckCategory() async{  
  try{
    final deckCategory = _deckService.getDeckCategory();
    return deckCategory;
  }catch (error)
  {throw Exception(error);}
}

Future<void> addDeckCategory(String category) async {

try{
    final deckinsert = _deckService.addDeckCategory(category);

}catch (e)
{
  print('unable to add category - Error: $e');
  throw e;

}

}

Future<void> systemCreateDecks(List<SystemDeckConfig> configs) async {
  state = state.copyWith(isLoading: true, error: '');
  try {
    final userId = _userService.userId;
    if (userId == null) {
      throw Exception("System user is not logged in");
    }

      
    await _deckService.systemCreateDeck(configs, userId);
    
    // Refresh the available decks list after creation
    await loadAvailableDecks();
  } catch (e) {
    print('Error in systemCreateDecks: $e');
    state = state.copyWith(error: e.toString());
  } finally {
    state = state.copyWith(isLoading: false);
  }
}



}

/// Provider for DeckNotifier that ties together DeckService and UserService
final deckProvider = StateNotifierProvider<DeckNotifier, DeckState>((ref) {
  final deckService = ref.watch(deckServiceProvider);
  final userService = ref.watch(userProvider);
 
  return DeckNotifier(deckService, userService,ref);
});
