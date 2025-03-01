import 'dart:developer';

import 'package:flashcardstudyapplication/core/interfaces/i_deck_service.dart';
import 'package:flashcardstudyapplication/core/interfaces/i_user_service.dart';
import 'package:flashcardstudyapplication/core/models/flashcard.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flashcardstudyapplication/core/models/deck.dart';
import 'package:flashcardstudyapplication/core/services/deck/deck_service.dart';
import 'package:flashcardstudyapplication/core/services/api/api_client.dart';
import 'package:flashcardstudyapplication/core/services/users/users_service.dart';
import 'provider_config.dart';
import 'package:flashcardstudyapplication/core/services/collection/collection_service.dart';

/// DeckState class to hold the current state of the decks
class DeckState {
  final bool isLoading;
  final String error;
  final List<Deck> decks;
  final bool deckloaded;

  DeckState({
    this.isLoading = false,
    this.error = '',
    this.decks = const [],
    this.deckloaded = false,
  });

  DeckState copyWith({
    bool? isLoading,
    String? error,
    List<Deck>? decks,
    bool? deckloaded,
  }) {
    return DeckState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      decks: decks ?? this.decks,
      deckloaded: deckloaded ?? this.deckloaded,
    );
  }
}

/// DeckNotifier to manage the state of the deck
class DeckNotifier extends StateNotifier<DeckState> {
  final IDeckService _deckService;
  final IUserService _userService;
  final Ref _ref;

  DeckNotifier(this._deckService, this._userService, this._ref)
      : super(DeckState());

  Future<void> flagCard(String flashcardId) async {
    try {
      state = state.copyWith(isLoading: true, error: '');
      await _deckService.flagFlashcard(flashcardId);
    } catch (e) {
      rethrow;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<List<Flashcard>> getDeckFlashcards(String deckid) async {
    try {
      state = state.copyWith(isLoading: true, error: '');
      final deckFlashcards = _deckService.getFlashcards(deckid);
      return deckFlashcards;
    } catch (e) {
      print(e);
      rethrow;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> createDeck(String subject, String concept, String category,
      String difficultyLevel, String userid, int cardCount) async {
    state = state.copyWith(isLoading: true, error: '');
    try {
      final userId = _userService.getCurrentUserInfo();
      if (userId == null) {
        throw Exception("User is not logged in");
      }

      final userSubscription = _userService.getCurrentUserInfo();
      final deck = await _deckService.createDeck(
          subject, concept, category, difficultyLevel, userid, cardCount);

      _ref.read(analyticsProvider.notifier).trackEvent(
        'deck_created',
        properties: {
          'subject': subject,
          'concept': concept,
          'category': category,
          'difficulty_level': difficultyLevel,
          'card_count': cardCount,
        },
      );
    } catch (e) {
      print(e);
      state = state.copyWith(error: e.toString());
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<List<Deck>> loadAvailableDecks() async {
    state = state.copyWith(isLoading: true, error: '', decks: []);

    try {
      final userId = await _userService.getCurrentUserInfo();
      if (userId == null) {
        throw Exception("User is not logged in");
      }

      final decks = await _deckService.loadDeckPool(userId['id']);
      log('decks: $decks');

      if (decks != null) {
        state = state.copyWith(decks: decks);
        return decks;
      } else
        return [];
// Return the list of decks
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return []; // Return an empty list in case of error
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> addDecktoUser(String deckId) async {
    try {
      state = state.copyWith(isLoading: true, error: '');

      final userId = await _userService.getCurrentUserInfo();
      if (userId == null) {
        throw Exception("User is not logged in");
      }

      await _deckService.decktoUser(deckId, userId['id']);

      // First update user decks
      await loadUserDecks(userId['id']);

      // Then load available decks to get fresh data
      await loadAvailableDecks();
    } catch (e) {
      print(e);
      rethrow;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<List<Deck>> loadUserDecks(String? userId) async {
    try {
      //state = state.copyWith(isLoading: true);

      String userIdToUse;
      if (userId == null) {
        final userInfo = await _userService.getCurrentUserInfo();
        if (userInfo == null) {
          state =
              state.copyWith(error: "User is not logged in", isLoading: false);
          return [];
        }
        userIdToUse = userInfo['id'];
      } else {
        userIdToUse = userId;
      }

      final decks = await _deckService.getUserDecks(userIdToUse);
      // Always update state with the decks, even if empty
      print('decks: $decks');

      state = state.copyWith(decks: decks, isLoading: false, deckloaded: true);

      return decks;
    } catch (e) {
      print('error in the catch block of Deck Provider loadUserDecks: $e');
      final errorMsg = e.toString();
      state = state.copyWith(error: errorMsg, isLoading: false, decks: []);
      rethrow;
    }
  }

  Future<void> updateDeck(
      String deckId, String title, String difficultyLevel) async {
    state = state.copyWith(isLoading: true, error: '');
    try {
      final userId = await _userService.getCurrentUserInfo();
      if (userId == null) {
        throw Exception("User is not logged in");
      }

      await _deckService.updateDeck(
          deckId, title, difficultyLevel, userId['id']);
      final decks = await _deckService.getUserDecks(userId['id']);
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
      final userId = await _userService.getCurrentUserInfo();
      if (userId == null) {
        throw Exception("User is not logged in");
      }

      await _deckService.removeDeck(deckId);
      final decks = await _deckService.getUserDecks(userId['id']);
      state = state.copyWith(decks: decks);

      _ref.read(analyticsProvider.notifier).trackEvent(
        'deck_deleted',
        properties: {
          'deck_id': deckId,
        },
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<List<String>> getDeckDifficulty(String subcriptionID) async {
    final deckDifficulty = _deckService.getDeckDifficulty(subcriptionID);

    return deckDifficulty;
  }

  Future<List<String>> getDeckCategory() async {
    try {
      final deckCategory = await _deckService.getDeckCategory();
      return deckCategory;
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<void> addDeckCategory(String category) async {
    try {
      final deckinsert = _deckService.addDeckCategory(category);
    } catch (e) {
      print('unable to add category - Error: $e');
      throw e;
    }
  }

// Future<void> systemCreateDecks(List<SystemDeckConfig> configs) async {
//   state = state.copyWith(isLoading: true, error: '');
//   try {
//     final userId = _userService.userId;
//     if (userId == null) {
//       throw Exception("System user is not logged in");
//     }

//     await _deckService.systemCreateDeck(configs, userId);

//     // Refresh the available decks list after creation
//     await loadAvailableDecks();
//   } catch (e) {
//     print('Error in systemCreateDecks: $e');
//     state = state.copyWith(error: e.toString());
//   } finally {
//     state = state.copyWith(isLoading: false);
//   }
// }

  Future<List<Deck>> getDecksForCollection(String collectionId) async {
    try {
      state = state.copyWith(isLoading: true);

      // First, get the collection to access its deck IDs
      final collectionService = _ref.read(collectionServiceProvider);
      final collection = await collectionService.getCollection(collectionId);

      if (collection.deckIds.isEmpty) {
        state = state.copyWith(
          isLoading: false,
          decks: [],
          deckloaded: true,
        );
        return [];
      }

      // Now get the decks using the collection's deck IDs
      final decks = await _deckService.getDeckDetails(collection.deckIds);

      state = state.copyWith(
        isLoading: false,
        decks: decks,
        deckloaded: true,
      );
      return decks;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }
}
