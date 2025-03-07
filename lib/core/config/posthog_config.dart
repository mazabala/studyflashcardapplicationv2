class AppPostHogConfig {
  static const String host = 'https://app.posthog.com';
  static const bool debug = true; // Set to false in production

  static Map<String, dynamic> getOptions() {
    return {
      'host': host,
      'enable': true,
      'debug': debug,
      'captureApplicationLifecycleEvents': true,
      'captureScreenViews': true,
    };
  }
}
