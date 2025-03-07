// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;

// Conditionally import for web platform
// This is the proper way to handle conditional imports in Flutter
import 'web_file_utils.dart' if (dart.library.html) 'web_file_utils_web.dart';

/// Utility class for file import operations
/// Web-specific functionality is guarded by platform checks
class FileImportUtils {
  /// Opens a file picker dialog for JSON files and returns the file content
  /// This only works on web platforms, returns null on other platforms
  static Future<String?> pickJsonFile() async {
    // Skip on non-web platforms
    if (!kIsWeb) {
      print('File picking is not supported on this platform');
      return null;
    }

    return WebFileUtils.pickJsonFile();
  }

  /// Validates the basic structure of the JSON content
  static bool isValidJsonStructure(String jsonContent) {
    try {
      final jsonData = jsonDecode(jsonContent);

      if (jsonData is! Map<String, dynamic>) {
        return false;
      }

      // Check for collections structure
      if (jsonData.containsKey('collections') &&
          jsonData['collections'] is List) {
        // Valid collections format
        return true;
      }

      // Check for legacy decks structure
      if (jsonData.containsKey('decks') && jsonData['decks'] is List) {
        return true;
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  /// Downloads a sample JSON template
  /// This only works on web platforms, does nothing on other platforms
  static void downloadSampleTemplate() {
    // Skip on non-web platforms
    if (!kIsWeb) {
      print('File download is not supported on this platform');
      return;
    }

    WebFileUtils.downloadSampleTemplate(getSampleTemplate());
  }

  /// Returns a sample JSON template as a string
  static String getSampleTemplate() {
    final sampleJson = {
      "collections": [
        {
          "name": "Basic Principles of Pharmacology",
          "subject": "Pharmacology",
          "description":
              "Fundamental concepts of pharmacokinetics and pharmacodynamics",
          "isPublic": true,
          "decks": [
            {
              "topic": "Pharmacokinetics",
              "focus": "Absorption",
              "category": "Medicine",
              "difficultyLevel": "Beginner",
              "cardCount": 10
            },
            {
              "topic": "Pharmacokinetics",
              "focus": "Distribution",
              "category": "Medicine",
              "difficultyLevel": "Beginner",
              "cardCount": 10
            },
            {
              "topic": "Pharmacokinetics",
              "focus": "Metabolism",
              "category": "Medicine",
              "difficultyLevel": "Intermediate",
              "cardCount": 15
            },
          ]
        },
        {
          "name": "Clinical Pharmacology",
          "subject": "Pharmacology",
          "description": "Application of pharmacology in clinical settings",
          "isPublic": true,
          "decks": [
            {
              "topic": "Antibiotics",
              "focus": "Penicillins",
              "category": "Medicine",
              "difficultyLevel": "Intermediate",
              "cardCount": 20
            },
            {
              "topic": "Antibiotics",
              "focus": "Cephalosporins",
              "category": "Medicine",
              "difficultyLevel": "Advanced",
              "cardCount": 15
            }
          ]
        },
        {
          "name": "Cardiovascular Pharmacology",
          "subject": "Cardiology",
          "description": "Drugs affecting the cardiovascular system",
          "isPublic": false,
          "decks": [
            {
              "topic": "Antihypertensives",
              "focus": "ACE Inhibitors",
              "category": "Medicine",
              "difficultyLevel": "Intermediate",
              "cardCount": 12
            },
            {
              "topic": "Antihypertensives",
              "focus": "Beta Blockers",
              "category": "Medicine",
              "difficultyLevel": "Intermediate",
              "cardCount": 12
            },
            {
              "topic": "Antiarrhythmics",
              "focus": "Classification and Mechanisms",
              "category": "Medicine",
              "difficultyLevel": "Advanced",
              "cardCount": 18
            }
          ]
        }
      ]
    };

    return const JsonEncoder.withIndent('  ').convert(sampleJson);
  }
}
