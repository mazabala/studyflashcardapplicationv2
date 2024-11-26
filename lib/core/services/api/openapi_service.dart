// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flashcardstudyapplication/core/services/api/api_client.dart';
// import 'package:flashcardstudyapplication/core/services/config/api_config.dart';

// class OpenAIService {
//   final ApiClient _apiClient;
//   final String apiKey;
//   final String baseUrl;

//   // Private constructor to prevent instantiation from outside
//   OpenAIService._({required this.apiKey, required this.baseUrl})
//       : _apiClient = ApiClient();

//   // Factory constructor to return the single instance of OpenAIService
//   factory OpenAIService(Ref ref) {
//     return OpenAIService._(
//       apiKey: ApiConfig.openAiKey, // Get the API key from the central config
//       baseUrl: ApiConfig.openAiEndpoint, // Get the endpoint from the central config
//     );
//   }

//   /// Method to retrieve the OpenAI configuration for a specific difficulty level.
//   Map<String, dynamic> getDifficultyConfig(String difficultyLevel) { // TODO: MOVE THIS OFF THE CONFIG AND ADD IT TO THE DATABASE.!!!
//     return ApiConfig.getDifficultyConfig(difficultyLevel);
//   }

//   /// Method to call OpenAI's API and generate flashcards based on the provided parameters.
//   Future<List<String>> createFlashcards({
//     required String prompt,
//     required String difficultyLevel,
//     required int cardCount,
//   }) async {
//     final config = getDifficultyConfig(difficultyLevel); // Get the difficulty config

//     // Prepare the payload for the POST request
//     final payload = {
//       'model': config['model'],
//       'prompt': prompt,
//       'temperature': config['temperature'],
//       'max_tokens': config['max_tokens'],
//     };

//     // Make the API call using your ApiClient
//     final response = await _apiClient.post('v1/flashcards', body: payload);

//     // Process the API response to extract the flashcards
//     final choices = response['choices'] as List;
//     return choices.map((choice) => choice['text'] as String).toList();
//   }
// }

// // Provider for OpenAIService
// final openAIServiceProvider = Provider<OpenAIService>((ref) {
//   return OpenAIService(ref);
// });
