// lib/core/providers/cache_service_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flashcardstudyapplication/core/services/cache/cache_service.dart';

// Define a FutureProvider that waits for CacheService initialization
final cacheServiceProvider = FutureProvider<CacheService>((ref) async {
  final cacheService = CacheService();
  // Wait for initialization to complete
  await cacheService.initialize();
  return cacheService;
});
