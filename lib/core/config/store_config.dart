
enum Stores { appleStore, googlePlay }

class StoreConfig {
    final Stores revenueCatStore;
    final String apiKey;
    static StoreConfig? _instance;

    factory StoreConfig({required Stores store, required String apiKey}) {
        _instance ??= StoreConfig._internal(store, apiKey);
        return _instance!;
    }

    StoreConfig._internal(this.revenueCatStore, this.apiKey);

    static StoreConfig get instance {
        if (_instance == null) {
            throw StateError('StoreConfig must be initialized first');
        }
        return _instance!;
    }

    static bool isForAppleStore() => instance.revenueCatStore == Stores.appleStore;

    static bool isForGooglePlay() => instance.revenueCatStore == Stores.googlePlay;
}