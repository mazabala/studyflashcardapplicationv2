// lib/core/services/deck/deck_service.dart

import 'dart:convert';
import 'dart:developer';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flashcardstudyapplication/core/models/deck.dart';
import 'package:flashcardstudyapplication/core/models/flashcard.dart';
import 'package:flashcardstudyapplication/core/interfaces/i_deck_service.dart';
import 'package:flashcardstudyapplication/core/error/error_handler.dart';
import 'package:flashcardstudyapplication/core/interfaces/i_api_service.dart';
import 'package:flashcardstudyapplication/core/services/api/api_client.dart';
import 'package:uuid/uuid.dart';
import 'package:posthog_flutter/posthog_flutter.dart';
import 'package:flashcardstudyapplication/core/models/deck_import.dart';
import 'package:flashcardstudyapplication/core/interfaces/i_collection_service.dart';

class SystemDeckConfig {
  final String category;
  final String description;
  final String difficultyLevel;
  final int cardCount;

  SystemDeckConfig({
    required this.category,
    required this.description,
    required this.difficultyLevel,
    required this.cardCount,
  });
}

class DeckService implements IDeckService {
  final SupabaseClient _supabaseClient;
  final IApiService _apiService;
  final ICollectionService _collectionService;
  final _uuid = const Uuid();

  DeckService(this._supabaseClient, this._apiService, this._collectionService);

  @override
  Future<List<Flashcard>> getFlashcards(String deckid) async {
// Fetch associated flashcards for the deck (list result)

    try {
      final PostgrestList flashcardsResponse = await _supabaseClient
          .from('flashcards')
          .select()
          .eq('deck_id', deckid);

      if (flashcardsResponse.isEmpty) {
        throw ErrorHandler.handle('No flashcards found');
      }

      final flashcards = (flashcardsResponse
              as List) //this needs to be into a different method so we can access flashcards on the UI/
          .map((flashcardData) => Flashcard.fromjson(flashcardData))
          .toList();

      return flashcards;
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  // Implement missing method getDeckDetails
  @override
  Future<List<Deck>> getDeckDetails(List<String> deckId) async {
    try {
      // Fetch deck metadata (single result)
      final deckResponse =
          await _supabaseClient.from('decks').select().inFilter('id', deckId);

      if (deckResponse.isEmpty) {
        return [];
      } else {
        final decks =
            (deckResponse).map((deckData) => Deck.fromJson(deckData)).toList();
        return decks;
      }

      // Return the deck with its flashcards
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  // Implement getUserDecks to return List<Deck>
  @override
  Future<List<Deck>> getUserDecks(String userId) async {
    try {
      // Fetch deck IDs for the user (list result)
      final response = await _supabaseClient
          .from('user_decks')
          .select('deck_id') // This will return a list of deck_id
          .eq('user_id', userId);

      if (response.isEmpty) {
        print('No decks found for the user. returning');
        return [];
      }

      // Extract deck IDs from the response
      final deckIds =
          List<String>.from(response.map((item) => item['deck_id']));

      // Fetch details for all decks
      final decks = await getDeckDetails(deckIds);

      // Return the list of Deck objects
      return decks;
    } catch (e) {
      print('get users deck: $e');
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<List<Deck>> loadDeckPool(String userId) async {
    try {
      // Fetch deck IDs for the user (list result)

      final response =
          await _supabaseClient.from('available_decks').select('deck_id');
      //.eq('user_id', userId);
      //inner join user_decks as ud on ud.userid?

      if (response.isEmpty) {
        print('No decks found from the loadDeckPool in servicess ');
      }

      // Extract deck IDs from the response
      final deckIds =
          List<String>.from(response.map((item) => item['deck_id']));

      log('deckIds: $deckIds');
      // Fetch details for all decks
      final decks = await getDeckDetails(deckIds);

      return decks;
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> _getModelConfig(String deckDifficultyIds) async {
    try {
      final deckDifficultyId =
          await _supabaseClient.from('api_model').select().single();

      final config = {
        'model': deckDifficultyId['model'],
        'top_p': deckDifficultyId['top_p'],
        'temperature': await _getDeckTemp(deckDifficultyIds),
        'max_tokens': await _getDeckMaxTokens(deckDifficultyIds),
        'cost_prompt': deckDifficultyId['cost_prompt'],
        'cost_flashcard': deckDifficultyId['cost_flashcard']
      };

      log('Final config: $config');
      return config;
    } catch (e) {
      print('Error setting modelconfig: $e');
      rethrow;
    }
  }

  int _getDeckCost(int cardCount, int flashcardcost, int promptcost) {
    int totalTokens = (cardCount * flashcardcost) + promptcost;

    return totalTokens;
  }

  int _getbatches(int deckcost, int maxTokens) {
    int batches = (deckcost / maxTokens).ceil();

    return batches;
  }

  Future<Map<String, dynamic>> _generateBody(String difficultyLevel,
      int cardCount, String topic, String focus, String category) async {
    // 1. Get the system prompt and API model configuration based on difficulty level

    final deckdifficulty = await _getDeckDifficultyID(difficultyLevel);

    final systemPrompt = await _getDifficultyPrompt(deckdifficulty);

    final apiModel = await _getModelConfig(deckdifficulty);

    late final num bodycards;

    final deckcost = _getDeckCost(
        cardCount, apiModel['cost_flashcard'], apiModel['cost_prompt']);

    final model = apiModel
      ..remove('cost_prompt')
      ..remove('cost_flashcard');

    final batches = _getbatches(deckcost, apiModel['max_tokens']);

    if (deckcost > apiModel['max_tokens']) {
      bodycards = cardCount / batches;
    } else {
      bodycards = cardCount;
    }

// 2. Construct the request body

    final body = {
      ...model,
      'deckcost': [deckcost],
      'batches': [batches],
      'max_tokens': [apiModel['max_tokens']],
      'messages': [
        {
          'role': 'system',
          'content': systemPrompt,
        },
        {
          'role': 'user',
          'content':
              '''Create exactly $bodycards $difficultyLevel-level questions and answers based on $topic with focus on $focus. 
            The flashcards should include clinical applications, disease mechanisms, pathophysiology, and differential diagnoses based on reliable, evidence-based medical knowledge from trusted sources such as textbooks, clinical guidelines, and peer-reviewed literature. 
            Ensure the content is challenging yet relevant to a clinical student at this level. 
            Category: $category
            Return ONLY a JSON array in this exact format: [{"front":"question text", "back":"answer text"}]
            Rule: Do not break the strings into multiple lines. If needed, use the \n character to break the string into multiple lines.
            Note: If a concept cannot be verified through academic sources, exclude it.'''
        }
      ],
    };

    return body;
  }

  Future<Map<String, dynamic>> _apiPost(Map<String, dynamic> body) async {
    try {
      final response = await _apiService.post('', body: jsonEncode(body));

      return response;
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<void> flagFlashcard(String flashcardId) async {
    try {
      final response = await _supabaseClient
          .from('flashcards')
          .update({'isFlagged': true}).eq('id', flashcardId);

      print('card flagged $response');
    } catch (e) {
      print(e);
      throw Exception('There was a problem flagging the card.');
    }
  }

  Future<List<Flashcard>> _generateFlashcards({
    required String topic,
    required String focus,
    required String category,
    required String difficultyLevel,
    required int cardCount,
    required String deckid,
  }) async {
    try {
      // 1. Generate the body

      final body = await _generateBody(
          difficultyLevel, cardCount, topic, focus, category);

      // 2. Make the POST request to generate flashcards

      final deckcost = body['deckcost'][0];

      final batches = body['batches'][0];

      final maxTokens = body['max_tokens'][0];

      List<Flashcard> allFlashcards = [];
      body.remove('deckcost');

      body.remove('batches');

      body.remove('max_tokens');
      if (deckcost > maxTokens) {
        // Remove batch-related fields from body

        // Generate flashcards in batches

        for (var i = 0; i < batches; i++) {
          final response = await _apiPost(body);

          final batchFlashcards =
              await _processApiResponse(response, deckid, difficultyLevel);

          allFlashcards.addAll(batchFlashcards);

          // If we've generated enough cards, break

          if (allFlashcards.length >= cardCount) break;
        }
      } else {
        final response = await _apiPost(body);
        print('apiresponse: $response');
        allFlashcards =
            await _processApiResponse(response, deckid, difficultyLevel);
        print('allFlashcards: $allFlashcards');
      }

      // Ensure we don't return more cards than requested
      allFlashcards = allFlashcards.take(cardCount).toList();

      // // 3. Verify and improve flashcards with AI
      // allFlashcards = await _verifyFlashcardsWithAI(
      //     allFlashcards, topic, focus, category, difficultyLevel);

      return allFlashcards;
    } catch (e) {
      print('Error generating flashcards: $e');

      rethrow;
    }
  }

  Future<List<Flashcard>> _processApiResponse(Map<String, dynamic> response,
      String deckid, String difficultyLevel) async {
    final content = response['choices'][0]['message']['content'].trim();

    final cleanContent =
        content.replaceAll('```json', '').replaceAll('```', '').trim();

    log('Cleaned content: $cleanContent');

    if (cleanContent.length > 1) {
      List<dynamic> cards;

      try {
        // Parse the JSON content
        cards = jsonDecode(cleanContent) as List;
      } catch (e) {
        // Fix the json format if needed
        log('JSON parsing error: $e');
        log('Problematic content: $cleanContent');

        try {
          // Request AI to fix the JSON format
          final request = await _verifyFlashcardsWithAI(content);
          final verifiedContent = await _apiPost(request);
          final newContent =
              verifiedContent['choices'][0]['message']['content'].trim();

          // Clean the fixed content
          final cleanNewContent =
              newContent.replaceAll('```json', '').replaceAll('```', '').trim();
          log('AI fixed content: $cleanNewContent');

          // Try to parse the fixed JSON
          cards = jsonDecode(cleanNewContent) as List;
          log('Successfully parsed fixed JSON');
        } catch (fixError) {
          log('Failed to fix JSON: $fixError');
          throw Exception(
              'Failed to parse API response as JSON, even after attempting to fix it: ${fixError.toString()}');
        }
      }

      // Validate and convert cards
      return cards.map((card) {
        if (!card.containsKey('front') || !card.containsKey('back')) {
          throw Exception('Invalid card format: Missing front or back field');
        }

        return Flashcard(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            deckid: deckid,
            front: card['front'].toString(),
            back: card['back'].toString(),
            difficultyLevel: difficultyLevel,
            created_at: DateTime.now().millisecondsSinceEpoch.toString(),
            last_reviewed: DateTime.now().millisecondsSinceEpoch.toString());
      }).toList();
    } else {
      throw Exception('Failed to generate flashcards');
    }
  }

  // New method to verify flashcards with AI
  Future<Map<String, dynamic>> _verifyFlashcardsWithAI(String content) async {
    try {
      // Create verification prompt
      final verificationBody = {
        'model': await _getModel().then((models) => models.first),
        'temperature': 0.7,
        'top_p': 0.95,
        'max_tokens': 4000,
        'messages': [
          {
            'role': 'system',
            'content':
                '''You are the last resource for verifying flashcards. Your task is to fix JSON arrays containing flashcards. Always return a valid JSON array, never a JSON object.'''
          },
          {
            'role': 'user',
            'content':
                '''You are an AI designed to analyze and correct JSON files. Your goal is to ensure the JSON is valid, properly structured, and formatted correctly. Follow these rules when processing JSON:

Rules for JSON Fixing:
1. Validate the JSON syntax – Ensure it is correctly formatted and parsable.
2. Fix structural errors – Repair missing commas, brackets, or incorrect data types.
3. Ensure uniform formatting – Maintain consistent spacing and indentation.
4. Preserve all data accurately – Do not alter any information or meaning.
5. Ensure strings are properly formatted – Remove unintended line breaks within values.
6. Check for missing or extra brackets – Close any unclosed arrays or objects.
7. Output a corrected JSON file – Return the fixed JSON in a properly formatted structure.
8. IMPORTANT: Always return a JSON ARRAY, not a JSON object. The output should be a direct array of flashcard objects, not wrapped in any outer object.

Example Input (Incorrect JSON):
[
    {"front":"What is the most common cause of tricuspid regurgitation?","back":"Secondary to left-sided heart disease, such as
    mitral valve disease or left ventricular failure."},
    {"front":"What is the classic physical exam finding in severe tricuspid regurgitation?","back":"Giant 'v' waves in the jugular 
    venous pulse."},
    {"front":"What is the most common cause of pulmonic stenosis in adults?","back":"Rheumatic heart disease."},
]

Expected Fixed JSON Output:
[
    {
        "front": "What is the most common cause of tricuspid regurgitation?",
        "back": "Secondary to left-sided heart disease, such as mitral valve disease or left ventricular failure."
    },
    {
        "front": "What is the classic physical exam finding in severe tricuspid regurgitation?",
        "back": "Giant 'v' waves in the jugular venous pulse."
    },
    {
        "front": "What is the most common cause of pulmonic stenosis in adults?",
        "back": "Rheumatic heart disease."
    }
]

INCORRECT Output Format (DO NOT USE):
{
    "cards": [
        {"front": "Question", "back": "Answer"},
        {"front": "Question", "back": "Answer"}
    ]
}

Instructions for AI:
- Identify and correct all syntax errors.
- Ensure all objects are properly enclosed and formatted.
- Remove unnecessary line breaks within strings.
- Return ONLY the fixed JSON array directly, not wrapped in any object.
- Do not include any explanations or text outside the JSON array.

Now, fix the following JSON content:
${content}
'''
          }
        ]
      };

      return verificationBody;
    } catch (e) {
      log('Error verifying flashcards: $e');
      // Return a fallback verification body with the original content
      return {
        'model': 'gpt-3.5-turbo', // Fallback model
        'temperature': 0.5,
        'top_p': 0.9,
        'max_tokens': 2000,
        'messages': [
          {
            'role': 'system',
            'content':
                '''You are the last resource for verifying flashcards. Your task is to fix JSON arrays containing flashcards. Always return a valid JSON array, never a JSON object.'''
          },
          {
            'role': 'user',
            'content':
                '''You are an AI designed to analyze and correct JSON files. Your goal is to ensure the JSON is valid, properly structured, and formatted correctly. Follow these rules when processing JSON:

Rules for JSON Fixing:
1. Validate the JSON syntax – Ensure it is correctly formatted and parsable.
2. Fix structural errors – Repair missing commas, brackets, or incorrect data types.
3. Ensure uniform formatting – Maintain consistent spacing and indentation.
4. Preserve all data accurately – Do not alter any information or meaning.
5. Ensure strings are properly formatted – Remove unintended line breaks within values.
6. Check for missing or extra brackets – Close any unclosed arrays or objects.
7. Output a corrected JSON file – Return the fixed JSON in a properly formatted structure.
8. IMPORTANT: Always return a JSON ARRAY, not a JSON object. The output should be a direct array of flashcard objects, not wrapped in any outer object.

Example Input (Incorrect JSON):
[
    {"front":"What is the most common cause of tricuspid regurgitation?","back":"Secondary to left-sided heart disease, such as
    mitral valve disease or left ventricular failure."},
    {"front":"What is the classic physical exam finding in severe tricuspid regurgitation?","back":"Giant 'v' waves in the jugular 
    venous pulse."},
    {"front":"What is the most common cause of pulmonic stenosis in adults?","back":"Rheumatic heart disease."},
]

Expected Fixed JSON Output:
[
    {
        "front": "What is the most common cause of tricuspid regurgitation?",
        "back": "Secondary to left-sided heart disease, such as mitral valve disease or left ventricular failure."
    },
    {
        "front": "What is the classic physical exam finding in severe tricuspid regurgitation?",
        "back": "Giant 'v' waves in the jugular venous pulse."
    },
    {
        "front": "What is the most common cause of pulmonic stenosis in adults?",
        "back": "Rheumatic heart disease."
    }
]

INCORRECT Output Format (DO NOT USE):
{
    "cards": [
        {"front": "Question", "back": "Answer"},
        {"front": "Question", "back": "Answer"}
    ]
}

Instructions for AI:
- Identify and correct all syntax errors.
- Ensure all objects are properly enclosed and formatted.
- Remove unnecessary line breaks within strings.
- Return ONLY the fixed JSON array directly, not wrapped in any object.
- Do not include any explanations or text outside the JSON array.

Now, fix the following JSON content:
${content}
'''
          }
        ],
      };
    }
  }

  // Add a flashcard to a specific deck
  @override
  Future<void> decktoUser(String deckId, String userId) async {
    try {
      final response = await _supabaseClient
          .from('user_decks')
          .insert({
            'user_id': userId,
            'deck_id': deckId,
            'added_at': DateTime.now().toString(),
            'is_owner': 'false',
            'cards_mastered': 0,
          })
          .select()
          .single();

      if (response['error'] != null) {
        throw ErrorHandler.handle(response['error']);
      }
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  // Create a new deck
  @override
  Future<void> createDeck(String topic, String focus, String category,
      String difficultyLevel, String userid, int cardCount) async {
    try {
      bool isPublic = false;
      final deckId = _uuid.v4();
      List<Flashcard> flashcards = const [];

      final categoryid = await _getDeckCategoryID(category);

      if (categoryid == null) {
        print('categoryid is empty $categoryid');
      }

      final PostgrestMap response = await _supabaseClient
          .from('decks')
          .insert({
            'id': deckId,
            'title': ('$topic - $focus'),
            'subject': topic,
            'concept': focus,
            'description': '',
            'difficulty': difficultyLevel,
            'category_id': categoryid, // Medicine, Law, etc.
            'total_cards': flashcards.length,
            'is_public': isPublic,
            'creator_id': userid,
            'created_at': DateTime.now().toIso8601String(),
            'modified_by': userid,
            'difficulty_level': difficultyLevel,
          })
          .select()
          .single();

      if (response['error'] != null) {
        throw ErrorHandler.handle(response);
      }

      // Create user-deck relationship
      await _supabaseClient.from('user_decks').insert({
        'user_id': userid,
        'deck_id': deckId,
        'is_owner': true,
      });

      //Generation Flashcards now

      final aiFlashcards = await _generateFlashcards(
          topic: topic,
          focus: focus,
          deckid: deckId,
          category: category,
          difficultyLevel: difficultyLevel,
          cardCount: cardCount);

      // If there are flashcards, create them with their own UUIDs
      if (aiFlashcards.isNotEmpty) {
        final flashcardsData = aiFlashcards
            .map((card) => {
                  'id': _uuid.v4(), // Generate UUID for each flashcard
                  'deck_id': deckId, // Link to the deck's UUID
                  'front': card.front,
                  'back': card.back,
                  'difficulty': difficultyLevel,
                  'created_at': DateTime.now().toIso8601String(),
                  'last_reviewed': DateTime.now().toIso8601String(),
                })
            .toList();

        // Insert all flashcards
        await _supabaseClient.from('flashcards').insert(flashcardsData);

        await _supabaseClient
            .from('decks')
            .update({'total_cards': flashcardsData.length}).eq('id', deckId);
      }
      print('Deck Created ${topic} - ${focus}');
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  // Update a deck's metadata
  @override
  Future<void> updateDeck(String deckId, String title, String difficultyLevel,
      String userid) async {
    try {
      final PostgrestMap response = await _supabaseClient
          .from('decks')
          .update({
            'title': title,
            'difficulty_level': difficultyLevel,
            'modified_by': userid,
          })
          .eq('id', deckId)
          .select()
          .single();

      if (response['error'] != null) {
        throw ErrorHandler.handle(response['error']);
      }
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  // Delete a deck T
  @override
  Future<void> removeDeck(String deckId) async {
    try {
      final deckResponse = await _supabaseClient
          .from('user_decks')
          .delete()
          .eq('deck_id', deckId);
    } catch (e) {
      print('Error Removing Deck: $e');
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<List<String>> getDeckDifficulty(String? subscriptionId) async {
    try {
      if (subscriptionId == null) {
        throw Exception('Subscription ID is null');
      }
      final subscriptionTypeID = await _supabaseClient
          .from('user_subscriptions')
          .select('subscriptionTypeID')
          .eq('id', subscriptionId)
          .single();

      final PostgrestList deckDifficultyId = await _supabaseClient
          .from('decksubscription_difficulty')
          .select()
          .eq('subscriptionTypeID', subscriptionTypeID['subscriptionTypeID']);

      if (deckDifficultyId.isEmpty) {
        throw ErrorHandler.handle(deckDifficultyId);
      }

      List<String> difficultyTypeIds = (deckDifficultyId as List)
          .map((deckDiff) => deckDiff['deckDifficultyTypeID'].toString())
          .toList();

      final PostgrestList difficultyNamesResponse = await _supabaseClient
          .from(
              'deck_difficulties') // Assuming 'deck_difficulties' is your table
          .select('name')
          .inFilter('id', difficultyTypeIds);

      // Check if there was an error or if no data was found
      if (difficultyNamesResponse == null || difficultyNamesResponse.isEmpty) {
        throw ErrorHandler.handle('No difficulty names found');
      }

// Convert response data to a list of Deck objects
      return (difficultyNamesResponse as List)
          .map((deckDiffName) => deckDiffName['name'].toString())
          .toList();
    } catch (e) {
      print(e);
      throw ErrorHandler.handle(e);
    }
  }

  Future<String> _getDifficultyPrompt(String difficultyTypeid) async {
    try {
      final deckmodelReader = await _supabaseClient
          .from('deck_difficulties')
          .select('prompt')
          .eq('id', difficultyTypeid)
          .single();

      return deckmodelReader['prompt'];
    } catch (e) {
      print('prompt: $e');
      rethrow;
    }
  }

  Future<List> _getModel() async {
    try {
      final PostgrestList deckmodelReader =
          await _supabaseClient.from('api_model').select('model');

      return (deckmodelReader as List)
          .map((decktoken) => decktoken['model'])
          .toList();
    } catch (e) {
      print('MaxTokens: $e');
      rethrow;
    }
  }

  Future<int> _getDeckMaxTokens(String difficultyTypeid) async {
    try {
      final deckTokenReader = await _supabaseClient
          .from('deck_difficulties')
          .select('max_tokens')
          .eq('id', difficultyTypeid)
          .single();

      return deckTokenReader['max_tokens'];
    } catch (e) {
      print('MaxTokens: $e');
      rethrow;
    }
  }

  Future<double> _getDeckTemp(String difficultyTypeid) async {
    try {
      final deckTempReader = await _supabaseClient
          .from('deck_difficulties')
          .select('temperature')
          .eq('id', difficultyTypeid)
          .single();

      return deckTempReader['temperature'];
    } catch (e) {
      print('temperature: $e');
      throw (e);
    }
  }

  @override
  Future<List<String>> getDeckCategory() async {
    try {
      final PostgrestList deckCategory = await _supabaseClient
          .from('categories')
          .select()
          .eq('is_active', true);

      return (deckCategory as List)
          .map((deckCat) => deckCat['name'].toString())
          .toList();
    } catch (e) {
      print(e);
      throw ErrorHandler.handle(e);
    }
  }

  Future<String> _getDeckDifficultyID(String deckDifficultyName) async {
    try {
      print('fetching deckDifficultyName: $deckDifficultyName.toLowerCase()');

      final deckDifficulty = await _supabaseClient
          .from('deck_difficulties')
          .select('id')
          .eq('name', deckDifficultyName.toLowerCase())
          .single();

      if (deckDifficulty.isEmpty) {
        throw Exception('DeckDifficultyID not found');
      }
      return deckDifficulty['id'];
    } catch (e) {
      print('error on _DeckDifficultyID: $e');
      rethrow;
    }
  }

  Future<String> _getDeckCategoryID(String categoryName) async {
    try {
      final deckCategory = await _supabaseClient
          .from('categories')
          .select('id')
          .eq('name', categoryName)
          .eq('is_active', true)
          .single();

      if (deckCategory.isEmpty) {
        throw Exception('Category not found');
      }
      return deckCategory['id'];
    } catch (e) {
      print('error on _getdeckcatID: $e');
      rethrow;
    }
  }

  @override
  Future<void> addDeckCategory(String category) async {
    try {
      final PostgrestMap response = await _supabaseClient
          .from('categories')
          .insert({'name': category})
          .select()
          .single();
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  // Import decks from JSON file (admin only)
  @override
  Future<DeckImportResult> importDecksFromJson(
      String jsonContent, String userId) async {
    try {
      // Parse and validate the JSON content
      Map<String, dynamic> jsonMap;
      try {
        jsonMap = jsonDecode(jsonContent) as Map<String, dynamic>;
        print(jsonMap);
      } catch (e) {
        print(e);
        return DeckImportResult(
          success: false,
          message: 'Invalid JSON format',
          totalDecks: 0,
          successfulDecks: 0,
          errors: ['Failed to parse JSON: ${e.toString()}'],
        );
      }

      // Check if the JSON has the new 'collections' format
      if (jsonMap.containsKey('collections') &&
          jsonMap['collections'] is List) {
        // Handle the new collections format
        return await _importCollectionsFromJson(jsonMap, userId);
      }

      // Handle the old format with 'decks' and 'collection'
      // Validate the JSON structure
      if (!jsonMap.containsKey('decks') || jsonMap['decks'] is! List) {
        return DeckImportResult(
          success: false,
          message: 'Invalid JSON structure',
          totalDecks: 0,
          successfulDecks: 0,
          errors: [
            'JSON must contain a "decks" array or a "collections" array'
          ],
        );
      }

      // Create DeckImport object
      DeckImport deckImport;
      try {
        // For backward compatibility, create a collection with the decks
        final List<dynamic> decksList = jsonMap['decks'] as List;
        final CollectionInfo collection = jsonMap.containsKey('collection')
            ? CollectionInfo.fromJson(
                jsonMap['collection'] as Map<String, dynamic>)
            : CollectionInfo(
                name: 'Imported Collection',
                subject: 'Imported',
                description: 'Imported from JSON',
                isPublic: false,
                decks: [],
              );

        // Convert old format to new format
        final List<DeckImportItem> decks = decksList
            .map((deckJson) =>
                DeckImportItem.fromJson(deckJson as Map<String, dynamic>))
            .toList();

        // Create a collection with the decks
        final CollectionInfo collectionWithDecks = CollectionInfo(
          name: collection.name,
          subject: collection.subject,
          description: collection.description,
          isPublic: collection.isPublic,
          decks: decks,
        );

        deckImport = DeckImport(collections: [collectionWithDecks]);
      } catch (e) {
        return DeckImportResult(
          success: false,
          message: 'Invalid deck data format',
          totalDecks: 0,
          successfulDecks: 0,
          errors: ['Failed to parse deck data: ${e.toString()}'],
        );
      }

      // Process the collection
      if (deckImport.collections.isEmpty ||
          deckImport.collections[0].decks.isEmpty) {
        return DeckImportResult(
          success: false,
          message: 'No decks found in import data',
          totalDecks: 0,
          successfulDecks: 0,
          errors: ['No decks found in import data'],
        );
      }

      final CollectionInfo collection = deckImport.collections[0];
      final List<DeckImportItem> decks = collection.decks;

      // Validate each deck's data
      final List<String> validationErrors =
          await _validateDeckImport(deckImport);
      if (validationErrors.isNotEmpty) {
        return DeckImportResult(
          success: false,
          message: 'Validation failed',
          totalDecks: decks.length,
          successfulDecks: 0,
          errors: validationErrors,
        );
      }

      // Process each deck
      final List<String> errors = [];
      int successCount = 0;
      final List<String> createdDeckIds = [];

      for (final deck in decks) {
        try {
          final deckId = _uuid.v4();
          await createDeck(
            deck.topic,
            deck.focus,
            deck.category,
            deck.difficultyLevel,
            userId,
            deck.cardCount,
          );

          // Get the deck ID from the created deck
          final deckDetails = await _supabaseClient
              .from('decks')
              .select('id')
              .eq('title', '${deck.topic} - ${deck.focus}')
              .eq('creator_id', userId)
              .order('created_at', ascending: false)
              .limit(1)
              .single();

          final createdDeckId = deckDetails['id'] as String;
          createdDeckIds.add(createdDeckId);

          successCount++;
          log('Successfully created deck: ${deck.topic} - ${deck.focus}');
        } catch (e) {
          final errorMsg =
              'Failed to create deck "${deck.topic} - ${deck.focus}": ${e.toString()}';
          log(errorMsg);
          errors.add(errorMsg);
        }
      }

      // Create collection if specified
      String? collectionId;
      if (createdDeckIds.isNotEmpty) {
        print('Creating collections now.');
        try {
          final createdCollection = await _collectionService.createCollection(
            name: collection.name,
            subject: collection.subject,
            description: collection.description,
            deckIds: createdDeckIds,
            isPublic: collection.isPublic,
          );
          collectionId = createdCollection.id;
          log('Successfully created collection: ${collection.name}');
          print('Successfully created collection: ${collection.name}');
        } catch (e) {
          final errorMsg = 'Failed to create collection: ${e.toString()}';
          log(errorMsg);
          errors.add(errorMsg);
        }
      }

      // Return result
      final collectionCreated = collectionId != null;

      return DeckImportResult(
        success: errors.isEmpty,
        message: errors.isEmpty
            ? collectionCreated
                ? 'Successfully imported all decks and created collection'
                : 'Imported decks but failed to create collection'
            : 'Imported $successCount out of ${decks.length} decks',
        totalDecks: decks.length,
        successfulDecks: successCount,
        errors: errors,
        collectionIds: collectionId != null ? [collectionId] : null,
      );
    } catch (e) {
      log('Error importing decks: $e');
      return DeckImportResult(
        success: false,
        message: 'Import failed',
        totalDecks: 0,
        successfulDecks: 0,
        errors: ['Unexpected error: ${e.toString()}'],
      );
    }
  }

  // Import collections from the new JSON format
  Future<DeckImportResult> _importCollectionsFromJson(
      Map<String, dynamic> jsonMap, String userId) async {
    try {
      print(jsonMap);
      final List<dynamic> collectionsList = jsonMap['collections'] as List;

      int totalDecks = 0;
      int successfulDecks = 0;
      final List<String> errors = [];
      final List<String> createdCollectionIds = [];

      // Process each collection
      for (final collectionData in collectionsList) {
        if (collectionData is! Map<String, dynamic>) {
          errors.add('Invalid collection format: Collection must be an object');
          continue;
        }

        if (!collectionData.containsKey('decks') ||
            collectionData['decks'] is! List) {
          errors.add(
              'Invalid collection format: Collection must contain a "decks" array');
          continue;
        }

        final String collectionName =
            collectionData['name'] as String? ?? 'Unnamed Collection';
        final String subject = collectionData['subject'] as String? ?? '';
        final String description =
            collectionData['description'] as String? ?? '';
        final bool isPublic = collectionData['isPublic'] as bool? ?? false;

        final List<dynamic> decksList = collectionData['decks'] as List;
        totalDecks += decksList.length;

        // Create decks for this collection
        final List<String> createdDeckIds = [];

        for (final deckData in decksList) {
          if (deckData is! Map<String, dynamic>) {
            errors.add('Invalid deck format in collection "$collectionName"');
            continue;
          }

          try {
            final deckImportItem = DeckImportItem(
              topic: deckData['topic'] as String? ?? '',
              focus: deckData['focus'] as String? ?? '',
              category: deckData['category'] as String? ?? '',
              difficultyLevel: deckData['difficultyLevel'] as String? ?? '',
              cardCount: deckData['cardCount'] as int? ?? 0,
            );

            // Validate deck data
            final List<String> deckErrors =
                await _validateDeckImportItem(deckImportItem);
            if (deckErrors.isNotEmpty) {
              errors.addAll(
                  deckErrors.map((e) => 'In collection "$collectionName": $e'));
              continue;
            }

            // Create the deck
            await createDeck(
              deckImportItem.topic,
              deckImportItem.focus,
              deckImportItem.category,
              deckImportItem.difficultyLevel,
              userId,
              deckImportItem.cardCount,
            );

            // Get the deck ID
            final deckDetails = await _supabaseClient
                .from('decks')
                .select('id')
                .eq('title',
                    '${deckImportItem.topic} - ${deckImportItem.focus}')
                .eq('creator_id', userId)
                .order('created_at', ascending: false)
                .limit(1)
                .single();

            final createdDeckId = deckDetails['id'] as String;
            createdDeckIds.add(createdDeckId);
            successfulDecks++;

            log('Successfully created deck: ${deckImportItem.topic} - ${deckImportItem.focus}');
          } catch (e) {
            final errorMsg =
                'Failed to create deck in collection "$collectionName": ${e.toString()}';
            log(errorMsg);
            errors.add(errorMsg);
          }
        }

        // Create the collection if we have decks
        if (createdDeckIds.isNotEmpty) {
          try {
            final collection = await _collectionService.createCollection(
              name: collectionName,
              subject: subject,
              description: description,
              deckIds: createdDeckIds,
              isPublic: isPublic,
            );
            createdCollectionIds.add(collection.id);
            log('Successfully created collection: $collectionName');
          } catch (e) {
            final errorMsg =
                'Failed to create collection "$collectionName": ${e.toString()}';
            log(errorMsg);
            errors.add(errorMsg);
          }
        }
      }

      // Return result
      return DeckImportResult(
        success: errors.isEmpty && successfulDecks > 0,
        message: errors.isEmpty
            ? 'Successfully imported $successfulDecks decks across ${createdCollectionIds.length} collections'
            : 'Imported $successfulDecks out of $totalDecks decks with errors',
        totalDecks: totalDecks,
        successfulDecks: successfulDecks,
        errors: errors,
        collectionIds:
            createdCollectionIds.isNotEmpty ? createdCollectionIds : null,
      );
    } catch (e) {
      log('Error importing collections: $e');
      return DeckImportResult(
        success: false,
        message: 'Import failed',
        totalDecks: 0,
        successfulDecks: 0,
        errors: ['Unexpected error: ${e.toString()}'],
      );
    }
  }

  // Validate a single deck import item
  Future<List<String>> _validateDeckImportItem(DeckImportItem deck) async {
    final List<String> errors = [];

    // Get available categories and difficulty levels for validation
    final List<String> availableCategories = await getDeckCategory();
    final List<String> availableDifficulties =
        await getDeckDifficulty('default');

    // Validate topic and focus
    if (deck.topic.isEmpty) {
      errors.add('Topic cannot be empty');
    }
    if (deck.focus.isEmpty) {
      errors.add('Focus cannot be empty');
    }

    // Validate category
    if (deck.category.isEmpty) {
      errors.add('Category cannot be empty');
    } else if (!availableCategories.contains(deck.category)) {
      errors.add(
          'Invalid category "${deck.category}". Available categories: ${availableCategories.join(", ")}');
    }

    // Validate difficulty level
    if (deck.difficultyLevel.isEmpty) {
      errors.add('Difficulty level cannot be empty');
    } else if (!availableDifficulties.contains(deck.difficultyLevel)) {
      errors.add(
          'Invalid difficulty level "${deck.difficultyLevel}". Available difficulty levels: ${availableDifficulties.join(", ")}');
    }

    // Validate card count
    if (deck.cardCount <= 0) {
      errors.add('Card count must be greater than 0');
    } else if (deck.cardCount > 100) {
      errors.add('Card count cannot exceed 100');
    }

    return errors;
  }

  // Validate deck import data
  Future<List<String>> _validateDeckImport(DeckImport deckImport) async {
    final List<String> errors = [];
    final Set<String> deckTitles = {};

    // Get available categories and difficulty levels for validation
    final List<String> availableCategories = await getDeckCategory();
    final List<String> availableDifficulties =
        await getDeckDifficulty('default');

    // Validate each collection and its decks
    for (final collection in deckImport.collections) {
      for (int i = 0; i < collection.decks.length; i++) {
        final deck = collection.decks[i];
        final deckIndex = i + 1;
        final deckTitle = '${deck.topic} - ${deck.focus}';

        // Check for duplicate deck titles
        if (deckTitles.contains(deckTitle)) {
          errors.add('Deck $deckIndex: Duplicate deck title "$deckTitle"');
        } else {
          deckTitles.add(deckTitle);
        }

        // Validate the deck using the common validation method
        final deckErrors = await _validateDeckImportItem(deck);
        if (deckErrors.isNotEmpty) {
          errors.addAll(deckErrors.map((e) => 'Deck $deckIndex: $e'));
        }
      }
    }

    return errors;
  }
}
