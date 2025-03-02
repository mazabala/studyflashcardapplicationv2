import 'dart:convert';
import 'dart:html' as html;
import 'dart:async';

class FileImportUtils {
  /// Opens a file picker dialog for JSON files and returns the file content
  static Future<String?> pickJsonFile() async {
    final completer = Completer<String?>();

    // Create file input element
    final html.FileUploadInputElement input = html.FileUploadInputElement();
    input.accept = '.json';
    input.click();

    // Listen for file selection
    input.onChange.listen((event) {
      final files = input.files;
      if (files != null && files.isNotEmpty) {
        final file = files[0];
        final reader = html.FileReader();

        reader.onLoad.listen((event) {
          completer.complete(reader.result as String);
        });

        reader.onError.listen((event) {
          completer.complete(null);
        });

        reader.readAsText(file);
      } else {
        completer.complete(null);
      }
    });

    return completer.future;
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
  static void downloadSampleTemplate() {
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

    final jsonString = const JsonEncoder.withIndent('  ').convert(sampleJson);
    final blob = html.Blob([jsonString], 'application/json');
    final url = html.Url.createObjectUrlFromBlob(blob);

    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', 'deck_import_template.json')
      ..click();

    html.Url.revokeObjectUrl(url);
  }
}
