import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flashcardstudyapplication/core/services/spaced_repetition/spaced_repetition_service.dart';

final spacedRepetitionProvider = StateNotifierProvider<SpacedRepetitionNotifier, bool>((ref) {
  return SpacedRepetitionNotifier();
});

class SpacedRepetitionNotifier extends StateNotifier<bool> {
  late final SpacedRepetitionService _service;
  
  SpacedRepetitionNotifier() : super(true) {
    _service = SpacedRepetitionService();
  }

  void toggleSpacedRepetition() {
    state = !state;
    _service.toggleSpacedRepetition(state);
  }

  bool get isEnabled => state;
} 