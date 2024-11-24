// lib/core/services/cache/i_cache_service.dart

abstract class ICacheService {
  Future<void> saveString(String key, String value);
  Future<String?> getString(String key);
  Future<void> remove(String key);
  Future<void> clearAll();
}
