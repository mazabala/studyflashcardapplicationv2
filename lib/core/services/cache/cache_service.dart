// lib/core/services/cache/cache_service.dart

import 'package:shared_preferences/shared_preferences.dart';
import 'package:flashcardstudyapplication/core/interfaces/i_cache_service.dart';

class CacheService implements ICacheService {
  late SharedPreferences _preferences;

  CacheService() {
    _init();
  }

  Future<void> _init() async {
    _preferences = await SharedPreferences.getInstance();
  }

   Future<void> initialize() async {
    await _init();
  }

  @override
  Future<void> saveString(String key, String value) async {
    await _preferences.setString(key, value);
  }

  @override
  Future<String?> getString(String key) async {
    return _preferences.getString(key);
  }

  @override
  Future<void> remove(String key) async {
    await _preferences.remove(key);
  }

  @override
  Future<void> clearAll() async {
    await _preferences.clear();
  }
}
