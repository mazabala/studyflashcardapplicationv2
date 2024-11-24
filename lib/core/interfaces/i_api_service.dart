// lib/core/services/interfaces/i_api_service.dart

import 'dart:async';

abstract class IApiService {
  // Initialize the API service (e.g., loading config, setting up connections)
  Future<void> initialize();

  // Send a GET request to the given endpoint with optional query parameters
  Future<Map<String, dynamic>> get(String endpoint, {Map<String, dynamic>? queryParams});

  // Send a POST request to the given endpoint with the provided body
  Future<Map<String, dynamic>> post(String endpoint, {dynamic body});

  // Send a PUT request to the given endpoint with the provided body
  Future<Map<String, dynamic>> put(String endpoint, {dynamic body});

  // Send a DELETE request to the given endpoint
  Future<Map<String, dynamic>> delete(String endpoint);

  String getSupabaseUrl();
  String getSupabaseAnonKey();

  

}
