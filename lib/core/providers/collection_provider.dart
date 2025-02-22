import 'package:flashcardstudyapplication/core/models/collection.dart';
import 'package:flashcardstudyapplication/core/providers/provider_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final collectionDetailsProvider = AsyncNotifierProvider<CollectionDetailsNotifier, Map<String, Collection>>(() {
  return CollectionDetailsNotifier();
});

class CollectionDetailsNotifier extends AsyncNotifier<Map<String, Collection>> {
  @override
  Future<Map<String, Collection>> build() async {
    return {};
  }

  Future<Collection> getCollectionDetails(String collectionId) async {
    final currentState = await future;
    
    // Return cached collection if available
    if (currentState.containsKey(collectionId)) {
      return currentState[collectionId]!;
    }

    // Fetch collection details
    final collectionService = ref.read(collectionServiceProvider);
    final collection = await collectionService.getCollection(collectionId);

    // Update cache with proper ID mapping
    state = AsyncData({
      ...currentState,
      collection.id: collection,  // Use the collection's ID as the key
    });

    return collection;
  }

  void invalidateCollection(String collectionId) {
    state.whenData((collections) {
      state = AsyncData({
        ...collections,
      }..remove(collectionId));
    });
  }

  // Add method to update collection in cache
  void updateCollection(Collection collection) {
    state.whenData((collections) {
      state = AsyncData({
        ...collections,
        collection.id: collection,
      });
    });
  }

  void invalidateAll() {
    state = const AsyncData({});
  }
} 