// lib/core/services/interfaces/i_database_service.dart

import 'dart:async';

abstract class IDatabaseService {
  // Initialize the database service (e.g., connection setup, authentication, etc.)
  Future<void> initialize();

  // Create a new record in the specified table
  Future<Map<String, dynamic>> create(String table, Map<String, dynamic> data);

  // Read a record or list of records from the specified table
  Future<Map<String, dynamic>> read(String table, {Map<String, dynamic>? queryParams});

  // Update an existing record in the specified table
  Future<Map<String, dynamic>> update(String table, String id, Map<String, dynamic> data);

  // Delete a record from the specified table
  Future<Map<String, dynamic>> delete(String table, String id);
}
