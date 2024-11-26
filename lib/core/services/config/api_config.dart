//// lib/core/services/api_config.dart
//
//import 'dart:io';
//import 'package:yaml/yaml.dart';
//import 'package:flashcardstudyapplication/core/error/error_handler.dart';
//
//class ApiConfig {
//  static late final Map<String, dynamic> _config;
//
//  // Initialize the config by loading from the api.config file
//  static Future<void> initialize() async {
//    try {
//      final configFile = File('config/api.config'); // Adjust the path if needed
//      final yamlString = await configFile.readAsString();
//      _config = loadYaml(yamlString);
//    } catch (e) {
//      throw ErrorHandler.handle(e, message: 'Failed to load API configuration');
//    }
//  }
//
//  // OpenAI API Key and endpoint
//  static String get openAiKey => _config['openai']['api_key'];
//  static String get openAiEndpoint => _config['openai']['base_url'];
//
//  // Default OpenAI configuration
//  static Map<String, dynamic> get openAiConfig => Map<String, dynamic>.from(_config['openai']['config']);
//
//  // Difficulty configuration for OpenAI based on the level
//  static Map<String, dynamic> getDifficultyConfig(String level) {
//    final difficultySettings = _config['openai']['difficulty_settings'] as Map;
//    return Map<String, dynamic>.from(difficultySettings[level] ?? {});
//  }
//}
