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

    // Update cache
    state = AsyncData({
      ...currentState,
      collectionId: collection,
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

  void invalidateAll() {
    state = const AsyncData({});
  }
} 