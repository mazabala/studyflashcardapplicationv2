abstract class IPostHogService {
  Future<void> initialize();
  void capture({required String eventName, Map<String, dynamic>? properties});
  void identify({required String userId, Map<String, dynamic>? userProperties});
  void screen({required String screenName, Map<String, dynamic>? properties});
  void reset();
} 