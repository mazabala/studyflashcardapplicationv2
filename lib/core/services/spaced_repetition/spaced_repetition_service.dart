import 'dart:math';
import 'package:flashcardstudyapplication/core/models/flashcard.dart';
import 'package:flashcardstudyapplication/core/error/error_handler.dart';

class SpacedRepetitionService {
  // SM-2 algorithm parameters
  static const double _minEaseFactor = 1.3;
  static const int _maxInterval = 36500; // Max interval of 100 years
  
  // Default settings
  bool _isEnabled = true;
  
  bool get isEnabled => _isEnabled;
  
  void toggleSpacedRepetition(bool enabled) {
    _isEnabled = enabled;
  }

  // Calculate next review date using SM-2 algorithm
  DateTime calculateNextReview({
    required DateTime lastReview,
    required int repetitions,
    required double easeFactor,
    required int interval,
    required String confidenceLevel,
  }) {
    if (!_isEnabled) {
      // If spaced repetition is disabled, use a simple fixed interval (1 day)
      return DateTime.now().add(const Duration(days: 1));
    }

    try {
      // Convert confidence level to quality response (0-5)
      final quality = _convertConfidenceToQuality(confidenceLevel);
      
      // Calculate new ease factor
      final newEaseFactor = _calculateNewEaseFactor(easeFactor, quality);
      
      // Calculate new interval
      final newInterval = _calculateNewInterval(
        repetitions: repetitions,
        interval: interval,
        quality: quality,
        easeFactor: newEaseFactor,
      );

      // Calculate next review date
      return DateTime.now().add(Duration(days: newInterval));
    } catch (e) {
      throw ErrorHandler.handle('Failed to calculate next review: $e');
    }
  }

  // Convert confidence level to SM-2 quality response
  int _convertConfidenceToQuality(String confidenceLevel) {
    switch (confidenceLevel.toLowerCase()) {
      case 'low':
        return 2; // Hard to remember
      case 'medium':
        return 3; // Significant effort
      case 'high':
        return 5; // Perfect response
      default:
        return 3; // Default to medium
    }
  }

  // Calculate new ease factor based on quality of response
  double _calculateNewEaseFactor(double oldEaseFactor, int quality) {
    final newEaseFactor = oldEaseFactor + (0.1 - (5 - quality) * (0.08 + (5 - quality) * 0.02));
    return max(_minEaseFactor, newEaseFactor);
  }

  // Calculate new interval based on repetitions and ease factor
  int _calculateNewInterval({
    required int repetitions,
    required int interval,
    required int quality,
    required double easeFactor,
  }) {
    if (quality < 3) {
      // If quality is poor, reset repetitions
      return 1;
    }

    if (repetitions == 0) {
      return 1;
    } else if (repetitions == 1) {
      return 6;
    } else {
      final newInterval = (interval * easeFactor).round();
      return min(newInterval, _maxInterval);
    }
  }

  // Get review schedule for a deck
  List<DateTime> getReviewSchedule(List<Flashcard> flashcards) {
    if (!_isEnabled) {
      // If disabled, schedule all cards for tomorrow
      return List.generate(
        flashcards.length,
        (_) => DateTime.now().add(const Duration(days: 1)),
      );
    }

    return flashcards.map((card) {
      final lastReview = DateTime.parse(card.last_reviewed);
      final repetitions = _getRepetitionsFromHistory(card);
      final easeFactor = _getEaseFactorFromHistory(card);
      final interval = _getIntervalFromHistory(card);
      
      return calculateNextReview(
        lastReview: lastReview,
        repetitions: repetitions,
        easeFactor: easeFactor,
        interval: interval,
        confidenceLevel: _getLastConfidenceLevel(card),
      );
    }).toList();
  }

  // Helper methods to get card history
  int _getRepetitionsFromHistory(Flashcard card) {
    // Implementation needed: Get repetitions from card history
    return 0;
  }

  double _getEaseFactorFromHistory(Flashcard card) {
    // Implementation needed: Get ease factor from card history
    return 2.5; // Default ease factor
  }

  int _getIntervalFromHistory(Flashcard card) {
    // Implementation needed: Get interval from card history
    return 1;
  }

  String _getLastConfidenceLevel(Flashcard card) {
    // Implementation needed: Get last confidence level from card history
    return 'medium';
  }
} 