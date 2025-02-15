import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flashcardstudyapplication/core/models/flashcard_progress.dart';
import 'package:flashcardstudyapplication/core/models/study_session.dart';
import 'package:flashcardstudyapplication/core/error/error_handler.dart';

class ProgressService {
  final SupabaseClient _supabaseClient;

  ProgressService(this._supabaseClient);

  // Flashcard Progress Methods
  Future<FlashcardProgress> updateFlashcardProgress({
    required String userId,
    required String flashcardId,
    required String confidenceLevel,
    required bool isMarkedForLater,
  }) async {
    try {
      final response = await _supabaseClient
          .from('flashcard_progress')
          .upsert({
            'user_id': userId,
            'flashcard_id': flashcardId,
            'confidence_level': confidenceLevel,
            'is_marked_for_later': isMarkedForLater,
            'last_reviewed_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      return FlashcardProgress.fromJson(response);
    } catch (e) {
      throw ErrorHandler.handle('Failed to update flashcard progress: $e');
    }
  }

  Future<List<FlashcardProgress>> getFlashcardProgress(String userId, String deckId) async {
    try {
      final response = await _supabaseClient
          .from('flashcard_progress')
          .select('*, flashcards!inner(*)')
          .eq('user_id', userId)
          .eq('flashcards.deck_id', deckId);

      return (response as List)
          .map((json) => FlashcardProgress.fromJson(json))
          .toList();
    } catch (e) {
      throw ErrorHandler.handle('Failed to get flashcard progress: $e');
    }
  }

  // Study Session Methods
  Future<StudySession> startStudySession(String userId, String deckId) async {
    try {
      final response = await _supabaseClient
          .from('study_sessions')
          .insert({
            'user_id': userId,
            'deck_id': deckId,
            'started_at': DateTime.now().toIso8601String(),
            'cards_reviewed': 0,
          })
          .select()
          .single();

      return StudySession.fromJson(response);
    } catch (e) {
      throw ErrorHandler.handle('Failed to start study session: $e');
    }
  }

  Future<StudySession> updateStudySession(
    String sessionId, {
    DateTime? endedAt,
    int? cardsReviewed,
    DateTime? lastBreakAt,
  }) async {
    try {
      final updates = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (endedAt != null) updates['ended_at'] = endedAt.toIso8601String();
      if (cardsReviewed != null) updates['cards_reviewed'] = cardsReviewed;
      if (lastBreakAt != null) updates['last_break_at'] = lastBreakAt.toIso8601String();

      final response = await _supabaseClient
          .from('study_sessions')
          .update(updates)
          .eq('id', sessionId)
          .select()
          .single();

      return StudySession.fromJson(response);
    } catch (e) {
      throw ErrorHandler.handle('Failed to update study session: $e');
    }
  }

  Future<List<StudySession>> getUserStudySessions(String userId, String deckId) async {
    try {
      final response = await _supabaseClient
          .from('study_sessions')
          .select()
          .eq('user_id', userId)
          .eq('deck_id', deckId)
          .order('started_at', ascending: false);

      return (response as List)
          .map((json) => StudySession.fromJson(json))
          .toList();
    } catch (e) {
      throw ErrorHandler.handle('Failed to get study sessions: $e');
    }
  }

  // Analytics Methods
  Future<Map<String, dynamic>> getDeckProgress(String userId, String deckId) async {
    try {
      final progress = await getFlashcardProgress(userId, deckId);
      
      final totalCards = progress.length;
      final highConfidence = progress.where((p) => p.confidenceLevel == 'high').length;
      final mediumConfidence = progress.where((p) => p.confidenceLevel == 'medium').length;
      final markedForLater = progress.where((p) => p.isMarkedForLater).length;

      return {
        'total_cards': totalCards,
        'high_confidence': highConfidence,
        'medium_confidence': mediumConfidence,
        'low_confidence': totalCards - highConfidence - mediumConfidence,
        'marked_for_later': markedForLater,
        'completion_rate': totalCards > 0 ? (highConfidence / totalCards * 100).round() : 0,
      };
    } catch (e) {
      throw ErrorHandler.handle('Failed to get deck progress: $e');
    }
  }
} 