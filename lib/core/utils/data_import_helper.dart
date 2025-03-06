import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

/// A utility class to help with importing flashcard data from the data directory
class DataImportHelper {
  /// Loads a JSON file from the data directory
  ///
  /// [fileName] is the name of the file without the path
  /// Returns a Map<String, dynamic> representing the JSON data
  static Future<Map<String, dynamic>> loadJsonFromDataDir(
      String fileName) async {
    try {
      // For files bundled with the app
      final String jsonString = await rootBundle.loadString('data/$fileName');
      return json.decode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      // For files in the app's documents directory
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/data/$fileName');

      if (await file.exists()) {
        final jsonString = await file.readAsString();
        return json.decode(jsonString) as Map<String, dynamic>;
      }

      throw Exception('File not found: $fileName');
    }
  }

  /// Saves a JSON file to the app's documents directory
  ///
  /// [fileName] is the name of the file without the path
  /// [data] is the data to save
  static Future<void> saveJsonToDataDir(
      String fileName, Map<String, dynamic> data) async {
    final directory = await getApplicationDocumentsDirectory();
    final dataDir = Directory('${directory.path}/data');

    // Create the data directory if it doesn't exist
    if (!await dataDir.exists()) {
      await dataDir.create(recursive: true);
    }

    final file = File('${dataDir.path}/$fileName');
    await file.writeAsString(json.encode(data));
  }

  /// Lists all JSON files in the data directory
  ///
  /// Returns a list of file names
  static Future<List<String>> listJsonFilesInDataDir() async {
    final directory = await getApplicationDocumentsDirectory();
    final dataDir = Directory('${directory.path}/data');

    if (!await dataDir.exists()) {
      return [];
    }

    final files = await dataDir.list().toList();
    return files
        .where((file) => file.path.endsWith('.json'))
        .map((file) => file.path.split('/').last)
        .toList();
  }
}
