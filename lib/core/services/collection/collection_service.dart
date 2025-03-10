import 'dart:developer';

import 'package:flashcardstudyapplication/core/error/error_handler.dart';
import 'package:flashcardstudyapplication/core/interfaces/i_collection_service.dart';
import 'package:flashcardstudyapplication/core/models/collection.dart';
import 'package:flashcardstudyapplication/core/models/user_collection.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CollectionService implements ICollectionService {
  final SupabaseClient _supabaseClient;

  CollectionService(this._supabaseClient);

  String get _userId {
    final userId = _supabaseClient.auth.currentUser?.id;
    if (userId == null) throw ErrorHandler.handleUnauthorized();
    return userId;
  }

  @override
  Future<Collection> createCollection({
    required String name,
    required String subject,
    required String description,
    required List<String> deckIds,
    required bool isPublic,
  }) async {
    try {
      final response = await _supabaseClient.rpc(
        'create_collection',
        params: {
          'p_name': name,
          'p_subject': subject,
          'p_description': description,
          'p_is_public': isPublic,
          'p_deck_ids': deckIds,
        },
      );
      return Collection.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<Collection> updateCollection(Collection collection) async {
    try {
      final response = await _supabaseClient.rpc(
        'update_collection',
        params: {
          'p_collection_id': collection.id,
          'p_name': collection.name,
          'p_subject': collection.subject,
          'p_description': collection.description,
          'p_is_public': collection.isPublic,
          'p_deck_ids': collection.deckIds.toList(),
        },
      );
      return Collection.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<void> deleteCollection(String collectionId) async {
    try {
      await _supabaseClient.rpc(
        'delete_collection',
        params: {
          'p_collection_id': collectionId,
        },
      );
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<Collection> getCollection(String collectionId) async {
    try {
      final response = await _supabaseClient.rpc(
        'get_collection',
        params: {
          'p_collection_id': collectionId,
        },
      );
      if (response == null) {
        throw ErrorHandler.handle('Collection not found');
      }
      return Collection.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      log(e.toString());
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<List<Collection>> searchCollections(String query) async {
    try {
      final response = await _supabaseClient.rpc(
        'search_collections',
        params: {
          'p_query': query,
        },
      );
      return (response as List)
          .map((json) => Collection.fromJson(json))
          .toList();
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<List<Collection>> getCollectionPool(
      {int page = 0, int pageSize = 20}) async {
    try {
      final start = page * pageSize;
      final response = await _supabaseClient
          .from('collections')
          .select()
          .eq('is_public', true)
          .range(start, start + pageSize - 1)
          .order('created_at', ascending: false);

      if (response == null) return [];
      return (response as List)
          .map((json) => Collection.fromJson(json))
          .toList();
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<UserCollection> addCollectionToUser(String collectionId) async {
    try {
      final response = await _supabaseClient.rpc(
        'add_collection_to_user',
        params: {
          'p_collection_id': collectionId,
        },
      );
      log('Collection: $collectionId added to user: $response');
      return UserCollection.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      log('Error adding collection to user: $e');
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<void> removeCollectionFromUser(String userCollectionId) async {
    try {
      await _supabaseClient.rpc(
        'remove_collection_from_user',
        params: {
          'p_user_collection_id': userCollectionId,
        },
      );
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<List<UserCollection>> getUserCollections(
      {int page = 0, int pageSize = 20}) async {
    try {
      final start = page * pageSize;
      final response = await _supabaseClient.from('user_collections').select('''
            *,
            user_collection_decks (
              deck_id,
              added_at,
              display_order
            )
          ''').order('added_at', ascending: false);

      if (response == null) return [];

      return (response as List).map((json) {
        // Transform user_collection_decks to decks format
        final decks = ((json['user_collection_decks'] as List?) ?? [])
            .map((deck) => <String, dynamic>{
                  'deck_id': deck['deck_id'] as String,
                  'added_at': deck['added_at'] as String,
                  'display_order': deck['display_order'] as int? ?? 0
                })
            .toList();

        // Create modified json with decks field
        final modifiedJson = <String, dynamic>{
          ...Map<String, dynamic>.from(json),
          'decks': decks,
        }..remove('user_collection_decks');

        return UserCollection.fromJson(modifiedJson);
      }).toList();
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<double> getCollectionCompletionRate(String collectionId) async {
    try {
      final response = await _supabaseClient.rpc(
        'get_collection_completion_rate',
        params: {
          'p_collection_id': collectionId,
        },
      );
      return (response as num).toDouble();
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<double> getUserCollectionCompletionRate(
      String userCollectionId) async {
    try {
      final response = await _supabaseClient.rpc(
        'get_user_collection_completion_rate',
        params: {
          'p_user_collection_id': userCollectionId,
        },
      );
      return (response as num).toDouble();
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<void> updateUserCollection(UserCollection userCollection) async {
    try {
      final deckEntries = userCollection.decks
          .map((deck) => {
                'deck_id': deck.deckId,
                'added_at': deck.addedAt.toIso8601String(),
                'display_order': deck.displayOrder,
              })
          .toList();

      await _supabaseClient.rpc(
        'update_user_collection',
        params: {
          'p_user_collection_id': userCollection.id,
          'p_completion_rate': userCollection.completionRate,
          'p_deck_entries': deckEntries,
        },
      );
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<void> addDeckToCollection(String collectionId, String deckId) async {
    try {
      await _supabaseClient.rpc(
        'add_deck_to_collection',
        params: {
          'p_collection_id': collectionId,
          'p_deck_id': deckId,
        },
      );
      log('Deck: $deckId added to collection: $collectionId');
    } catch (e) {
      log('Error adding deck to collection: $e');
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<void> removeDeckFromCollection(
      String collectionId, String deckId) async {
    try {
      await _supabaseClient.rpc(
        'remove_deck_from_collection',
        params: {
          'p_collection_id': collectionId,
          'p_deck_id': deckId,
        },
      );
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<void> addDeckToUserCollection(
      String userCollectionId, String deckId) async {
    try {
      await _supabaseClient.rpc(
        'add_deck_to_user_collection',
        params: {
          'p_user_collection_id': userCollectionId,
          'p_deck_id': deckId,
        },
      );
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<void> removeDeckFromUserCollection(
      String userCollectionId, String deckId) async {
    try {
      await _supabaseClient.rpc(
        'remove_deck_from_user_collection',
        params: {
          'p_user_collection_id': userCollectionId,
          'p_deck_id': deckId,
        },
      );
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }
}
