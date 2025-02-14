import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../interfaces/i_posthog_service.dart';
import 'provider_config.dart';

class AnalyticsNotifier extends StateNotifier<void> {
  final IPostHogService _posthogService;
  final Ref _ref;

  AnalyticsNotifier(this._posthogService, this._ref) : super(null);

  void trackScreenView(String screenName, {Map<String, dynamic>? properties}) {
    _posthogService.screen(
      screenName: screenName,
      properties: {
        'source': 'navigation',
        ...?properties,
      },
    );
  }

  void trackEvent(String eventName, {Map<String, dynamic>? properties}) {
    _posthogService.capture(
      eventName: eventName,
      properties: properties,
    );
  }

  // Auth Events
  void trackLogin({required String method}) {
    trackEvent('user_login', properties: {'method': method});
  }

  void trackLogout() {
    trackEvent('user_logout');
  }

  void trackSignUp({required String method}) {
    trackEvent('user_signup', properties: {'method': method});
  }

  // Deck Events
  void trackDeckCreated({required String deckId, required String deckName}) {
    trackEvent('deck_created', properties: {
      'deck_id': deckId,
      'deck_name': deckName,
    });
  }

  void trackDeckDeleted({required String deckId, required String deckName}) {
    trackEvent('deck_deleted', properties: {
      'deck_id': deckId,
      'deck_name': deckName,
    });
  }

  void trackDeckStudyStarted({required String deckId, required String deckName}) {
    trackEvent('deck_study_started', properties: {
      'deck_id': deckId,
      'deck_name': deckName,
    });
  }

  void trackDeckStudyCompleted({
    required String deckId, 
    required String deckName,
    required int cardsStudied,
    required int correctAnswers,
  }) {
    trackEvent('deck_study_completed', properties: {
      'deck_id': deckId,
      'deck_name': deckName,
      'cards_studied': cardsStudied,
      'correct_answers': correctAnswers,
      'accuracy': cardsStudied > 0 ? (correctAnswers / cardsStudied) * 100 : 0,
    });
  }

  // Flashcard Events
  void trackFlashcardCreated({required String deckId, required String flashcardId}) {
    trackEvent('flashcard_created', properties: {
      'deck_id': deckId,
      'flashcard_id': flashcardId,
    });
  }

  void trackFlashcardAnswered({
    required String deckId,
    required String flashcardId,
    required bool isCorrect,
  }) {
    trackEvent('flashcard_answered', properties: {
      'deck_id': deckId,
      'flashcard_id': flashcardId,
      'is_correct': isCorrect,
    });
  }

  // Subscription Events
  void trackSubscriptionStarted({required String plan}) {
    trackEvent('subscription_started', properties: {'plan': plan});
  }

  void trackSubscriptionCancelled({required String plan}) {
    trackEvent('subscription_cancelled', properties: {'plan': plan});
  }

  void identifyUser(String userId, {Map<String, dynamic>? userProperties}) {
    _posthogService.identify(
      userId: userId,
      userProperties: userProperties,
    );
  }

  void reset() {
    _posthogService.reset();
  }
}

