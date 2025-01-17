import 'package:flutter/foundation.dart';

enum Stores { appleStore, googlePlay }

class StoreConfig {
    final Stores RevenueCatStore;
    final String apiKey;
    static StoreConfig? _instance;

    factory StoreConfig({required Stores store, required String apiKey}) {
        _instance ??= StoreConfig._internal(store, apiKey);
        return _instance!;
    }

    StoreConfig._internal(this.RevenueCatStore, this.apiKey);

    static StoreConfig get instance {
        if (_instance == null) {
            throw StateError('StoreConfig must be initialized first');
        }
        return _instance!;
    }

    static bool isForAppleStore() => instance.RevenueCatStore == Stores.appleStore;

    static bool isForGooglePlay() => instance.RevenueCatStore == Stores.googlePlay;
}