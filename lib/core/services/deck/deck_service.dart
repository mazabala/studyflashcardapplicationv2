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
  final _uuid = const Uuid();

  DeckService(this._supabaseClient, this._apiService);



@override
  Future<List<Flashcard>> getFlashcards(String deckid) async{

// Fetch associated flashcards for the deck (list result)
    
    try{  final PostgrestList flashcardsResponse = await _supabaseClient
          .from('flashcards')
          .select()
          .eq('deck_id', deckid);



            if (flashcardsResponse.isEmpty) {
        throw ErrorHandler.handle('No flashcards found');
      }

      final flashcards = (flashcardsResponse as List)         //this needs to be into a different method so we can access flashcards on the UI/
          .map((flashcardData) => Flashcard.fromjson(flashcardData))
          .toList();
          
         return flashcards;
    }catch (e)

    {
      print(e);
      rethrow;}
}

  // Implement missing method getDeckDetails
  @override
  Future<List<Deck>> getDeckDetails(List<String> deckId) async {   
    try {
      // Fetch deck metadata (single result)
      final  deckResponse = await _supabaseClient
          .from('decks')
          .select()
          .inFilter('id', deckId);
          


      if (deckResponse.isEmpty) {
       return [];
      }
      else{


     final decks = (deckResponse )
          .map((deckData) => Deck.fromJson(deckData))
          .toList();
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
        .select('deck_id')  // This will return a list of deck_id
        .eq('user_id', userId);

    if (response.isEmpty) {
      print('No decks found for the user. returning');
      return [];
    }
  
    // Extract deck IDs from the response
    final deckIds = List<String>.from(response.map((item) => item['deck_id']));

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
Future<List<Deck>> loadDeckPool (String userId) async {

try {
    // Fetch deck IDs for the user (list result)

 
    final response = await _supabaseClient
        .from('available_decks')
        .select('deck_id') ;
        //.eq('user_id', userId);
        //inner join user_decks as ud on ud.userid?
        
        

  
    if (response.isEmpty) {
      print('No decks found from the loadDeckPool in servicess ');

    }

    // Extract deck IDs from the response
    final deckIds = List<String>.from(response.map((item) => item['deck_id']));

   log('deckIds: $deckIds');
    // Fetch details for all decks
    final decks = await getDeckDetails(deckIds);

    return decks;
}
catch (e)

{print (e);
rethrow;
}
}

Future <Map<String, dynamic>> _getModelConfig(String deckDifficultyIds) async {
  try {
    final deckDifficultyId = await _supabaseClient
      .from('api_model')
      .select()
      .single();
    



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

    final model = apiModel
      ..remove('cost_prompt')
      ..remove('cost_flashcard');

    late final num bodycards;

    final deckcost = _getDeckCost(
        cardCount, apiModel['cost_flashcard'], apiModel['cost_prompt']);



    final batches = _getbatches(deckcost, apiModel['max_tokens']);

    log('Batches: $batches');

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
            Return ONLY a JSON array in this exact format: [{\"front\":\"question text\", \"back\":\"answer text\"}]
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
Future<void>flagFlashcard (String flashcardId) async {
    try {
            final response = await _supabaseClient.from('flashcards')
            .update({'isFlagged':true})
            .eq('id',flashcardId);

            print('card flagged $response');

    }catch(e)
    {print (e);
    throw Exception ('There was a problem flagging the card.');}


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

      if (deckcost > maxTokens) {
        // Remove batch-related fields from body

        body.remove('deckcost');

        body.remove('batches');

        body.remove('max_tokens');



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

        allFlashcards =
            await _processApiResponse(response, deckid, difficultyLevel);
      }

      // Ensure we don't return more cards than requested

      return allFlashcards.take(cardCount).toList();
    } catch (e) {
      print('Error generating flashcards: $e');

      rethrow;
    }
  }

  Future<List<Flashcard>> _processApiResponse(Map<String, dynamic> response,
      String deckid, String difficultyLevel) async {
    final content = response['choices'][0]['message']['content'].trim();

    // Clean the content by removing markdown code block indicators

    final cleanContent =
        content.replaceAll('```json', '').replaceAll('```', '').trim();

    log('Cleaned content: $cleanContent');

    if (cleanContent.length > 1) {
      List<dynamic> cards;

      try {
        cards = jsonDecode(cleanContent) as List;
      } catch (e) {
        log('JSON parsing error: $e');

        log('Problematic content: $cleanContent');

        throw Exception(
            'Failed to parse API response as JSON. Response was not a valid JSON array.');
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


  // Add a flashcard to a specific deck
  @override
  Future<void> decktoUser(String deckId, String userId) async {
    try {
      final  response = await _supabaseClient.from('user_decks').insert({
        'user_id': userId,
        'deck_id': deckId,
        'added_at': DateTime.now().toString(),
        'is_owner': 'false',
        'cards_mastered': 0,})
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
  Future<void> createDeck(String topic, String focus ,String category, String difficultyLevel, String userid, int cardCount) async {
    try {
      bool isPublic = false;
      final deckId = _uuid.v4();
      List<Flashcard> flashcards = const [];


      final categoryid = await _getDeckCategoryID(category);


      if(categoryid == null)
      {print ('categoryid is empty $categoryid');}

      final PostgrestMap response = await _supabaseClient.from('decks').insert({
        'id': deckId,
        'title': ('$topic - $focus'),
        'subject': topic,
        'concept': focus,
        'description': '',
        'difficulty': difficultyLevel,
        'category_id': categoryid,     // Medicine, Law, etc.   
        'total_cards': flashcards.length,
        'is_public': isPublic,
        'creator_id': userid,
        'created_at': DateTime.now().toIso8601String(),
        'modified_by': userid,
        'difficulty_level':difficultyLevel,
      }).select().single();


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

      final aiFlashcards = await _generateFlashcards(topic: topic,focus: focus, deckid: deckId, category: category, difficultyLevel: difficultyLevel, cardCount: cardCount); 
      
      
      // If there are flashcards, create them with their own UUIDs
      if (aiFlashcards.isNotEmpty) {
        final flashcardsData = aiFlashcards.map((card) => {
          'id': _uuid.v4(),  // Generate UUID for each flashcard
          'deck_id': deckId, // Link to the deck's UUID
          'front': card.front,
          'back': card.back,
          'difficulty': difficultyLevel,
          'created_at': DateTime.now().toIso8601String(),
          'last_reviewed': DateTime.now().toIso8601String(),
        }).toList();

        // Insert all flashcards
        await _supabaseClient
            .from('flashcards')
            .insert(flashcardsData);

        await _supabaseClient
        .from('decks')
        .update({'total_cards':flashcardsData.length})
        .eq('id', deckId);
      }
      print('Deck Created ${topic} - ${focus}');
    } catch (e) {
      throw ErrorHandler.handle(e);
    }

  }

  // Update a deck's metadata
  @override
  Future<void> updateDeck(String deckId, String title, String difficultyLevel, String userid) async {
    try {
      final PostgrestMap response = await _supabaseClient.from('decks').update({
        'title': title,
        'difficulty_level': difficultyLevel,
        'modified_by': userid,
      }).eq('id', deckId).select().single();

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


      final  deckResponse = await _supabaseClient
          .from('user_decks')
          .delete()
          .eq('deck_id', deckId);

    } catch (e) {
      print ('Error Removing Deck: $e');
      throw ErrorHandler.handle(e);
    }
  }


@override
Future<List<String>> getDeckDifficulty (String? subscriptionId) async {
 try{
   
   if (subscriptionId == null) {
    throw Exception('Subscription ID is null');
   }
  final  subscriptionTypeID = await _supabaseClient
  .from('user_subscriptions')
  .select('subscriptionTypeID')
  .eq('subscriptionID',subscriptionId)
  .single();



  final PostgrestList deckDifficultyId = await _supabaseClient
  .from('decksubscription_difficulty')
  .select()
  .eq('subscriptionTypeID',subscriptionTypeID['subscriptionTypeID']);

  if (deckDifficultyId.isEmpty)
  {throw ErrorHandler.handle(deckDifficultyId);}


List<String> difficultyTypeIds= (deckDifficultyId as List)
    .map((deckDiff) => deckDiff['deckDifficultyTypeID'].toString())
    .toList();

final PostgrestList difficultyNamesResponse = await _supabaseClient
  .from('deck_difficulties')  // Assuming 'deck_difficulties' is your table
  .select('name')
  .inFilter('difficultyType_id', difficultyTypeIds);


 
  // Check if there was an error or if no data was found
if (difficultyNamesResponse== null || difficultyNamesResponse.isEmpty) {
  throw ErrorHandler.handle('No difficulty names found');
}

// Convert response data to a list of Deck objects
      return (difficultyNamesResponse as List)
          .map((deckDiffName) => deckDiffName['name'].toString())
          .toList();
    } catch (e) {
      print (e);
      throw ErrorHandler.handle(e);
    }
 
 
  
  }


Future<String>_getDifficultyPrompt (String difficultyTypeid) async
{
  try{

  final  deckmodelReader= await _supabaseClient
  .from('deck_difficulties')
  .select('prompt')
  .eq('difficultyType_id',difficultyTypeid)
  .single();


  return deckmodelReader['prompt'];
  }catch (e)
  {
  print('prompt: $e');
   rethrow;}

}
Future<List> _getModel () async
{
  try{
  final PostgrestList deckmodelReader= await _supabaseClient
  .from('api_model')
  .select('model');


  return (deckmodelReader as List)
          .map((decktoken) => decktoken['model'])
          .toList();
  }catch (e)
  {
  print('MaxTokens: $e');
   rethrow;}

}

Future<int> _getDeckMaxTokens (String difficultyTypeid) async
{
  try{
  final  deckTokenReader= await _supabaseClient
  .from('deck_difficulties')
  .select('max_tokens')
  .eq('difficultyType_id',difficultyTypeid)

  .single();
 
  return deckTokenReader['max_tokens'];
  }catch (e)
  {
  print('MaxTokens: $e');
   rethrow;}

}
Future<double> _getDeckTemp (String difficultyTypeid) async
{
  try{
  final  deckTempReader = await _supabaseClient
  .from('deck_difficulties')
  .select('temperature')
  .eq('difficultyType_id',difficultyTypeid)
  .single();

  return deckTempReader['temperature'];
  }catch (e)
  {
  print('temperature: $e');
   throw (e);}

}
@override
Future<List<String>> getDeckCategory() async
{
    try{
     
   final PostgrestList deckCategory = await _supabaseClient
   .from('categories')
   .select();
  

   return (deckCategory as List)
   .map((deckCat) => deckCat['name'].toString())
   .toList();
   
    }catch (e)
    {print (e);
      throw ErrorHandler.handle(e);}



}



Future<String> _getDeckDifficultyID(String deckDifficultyName) async
{
    try{
     print('Looking for difficulty: $deckDifficultyName');
   final  deckDifficulty = await _supabaseClient
   .from('deck_difficulties')
   .select('difficultyType_id')
   .eq('name',deckDifficultyName)
   .single();

    print('DeckDifficultyID: ${deckDifficulty['difficultyType_id']}');

    if (deckDifficulty.isEmpty) {
        throw Exception('DeckDifficultyID not found');
                              }
   return deckDifficulty['difficultyType_id'];

    }catch (e)
    { print('error on _DeckDifficultyID: $e');
      rethrow ;}


}
Future<String> _getDeckCategoryID(String categoryName) async
{
    try{
     
   final  deckCategory = await _supabaseClient
   .from('categories')
   .select('id')
   .eq('name',categoryName)
   .single();

    print('DeckCategoryID: ${deckCategory['id']}');

    if (deckCategory.isEmpty) {
        throw Exception('Category not found');
                              }
   return deckCategory['id'];

    }catch (e)
    { print('error on _getdeckcatID: $e');
      rethrow ;}


}
@override
Future<void> addDeckCategory(String category) async {
  try{
  final PostgrestMap response = await _supabaseClient.from('categories').insert(

    {'name': category})
    .select()
    .single();
  }catch (e){throw ErrorHandler.handle(e);}
  

}



}