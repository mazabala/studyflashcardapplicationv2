// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:async';
import 'dart:html' as html;

/// Web implementation for file utilities
/// This file is used when the app is running on web platforms
class WebFileUtils {
  /// Opens a file picker dialog for JSON files and returns the file content
  static Future<String?> pickJsonFile() async {
    final completer = Completer<String?>();

    // Create file input element
    final input = html.FileUploadInputElement();
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

  /// Downloads a sample JSON template
  static void downloadSampleTemplate(String jsonContent) {
    final blob = html.Blob([jsonContent], 'application/json');
    final url = html.Url.createObjectUrlFromBlob(blob);

    // Use the anchor element directly without storing it in a variable
    html.AnchorElement(href: url)
      ..setAttribute('download', 'deck_import_template.json')
      ..click();

    html.Url.revokeObjectUrl(url);
  }
}
