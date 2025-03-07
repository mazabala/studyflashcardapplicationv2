/// Stub implementation for non-web platforms
/// This file is used when the app is running on non-web platforms
class WebFileUtils {
  /// Stub implementation for picking a JSON file
  static Future<String?> pickJsonFile() async {
    return null;
  }

  /// Stub implementation for downloading a sample template
  static void downloadSampleTemplate(String jsonContent) {
    // Do nothing on non-web platforms
  }
}
