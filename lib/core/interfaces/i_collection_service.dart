import 'package:flashcardstudyapplication/core/models/collection.dart';
import 'package:flashcardstudyapplication/core/models/user_collection.dart';

abstract class ICollectionService {
  // Collection management
  Future<Collection> createCollection({
    required String name,
    required String subject,
    required String description,
    required List<String> deckIds,
    required bool isPublic,
  });

  Future<Collection> updateCollection(Collection collection);
  Future<void> deleteCollection(String collectionId);
  Future<Collection> getCollection(String collectionId);
  Future<List<Collection>> searchCollections(String query);
  Future<List<Collection>> getCollectionPool({int page = 0, int pageSize = 20});

  // User collection management
  Future<UserCollection> addCollectionToUser(String collectionId);
  Future<void> removeCollectionFromUser(String userCollectionId);
  Future<List<UserCollection>> getUserCollections(
      {int page = 0, int pageSize = 20});
  Future<void> updateUserCollection(UserCollection userCollection);

  // Collection deck management
  Future<void> addDeckToCollection(String collectionId, String deckId);
  Future<void> removeDeckFromCollection(String collectionId, String deckId);
  Future<void> addDeckToUserCollection(String userCollectionId, String deckId);
  Future<void> removeDeckFromUserCollection(
      String userCollectionId, String deckId);

  // Collection stats
  Future<double> getCollectionCompletionRate(String collectionId);
  Future<double> getUserCollectionCompletionRate(String userCollectionId);
}
