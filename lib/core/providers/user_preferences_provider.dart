import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flashcardstudyapplication/core/models/user_preferences.dart';
import 'package:flashcardstudyapplication/core/interfaces/i_user_service.dart';
import 'provider_config.dart';



class UserPreferencesNotifier extends StateNotifier<UserPreferences> {
  final IUserService _userService;

  UserPreferencesNotifier(this._userService) : super(UserPreferences(
    id: '',
    userId: '',
    lastUpdated: DateTime.now(),
  ));

  Future<void> loadPreferences() async {
    try {
      final userInfo = await _userService.getCurrentUserInfo();
      if (userInfo == null) {
        throw Exception('User not logged in');
      }

      final preferences = await _userService.getUserPreferences(userInfo['id']);
      state = preferences;
    } catch (e) {
      print('Error loading preferences: $e');
    }
  }

  Future<void> updatePreferences(UserPreferences preferences) async {
    try {
      final userInfo = await _userService.getCurrentUserInfo();
      if (userInfo == null) {
        throw Exception('User not logged in');
      }

      await _userService.updateUserPreferences(userInfo['id'], preferences);
      state = preferences;
    } catch (e) {
      print('Error updating preferences: $e');
    }
  }

  void toggleSpacedRepetition() {
    final newPreferences = state.copyWith(
      isSpacedRepetitionEnabled: !state.isSpacedRepetitionEnabled,
    );
    updatePreferences(newPreferences);
  }

  void updateCardsPerSession(int count) {
    final newPreferences = state.copyWith(cardsPerSession: count);
    updatePreferences(newPreferences);
  }

  void updateBreakInterval(int minutes) {
    final newPreferences = state.copyWith(breakInterval: minutes);
    updatePreferences(newPreferences);
  }

  void updateDefaultDifficulty(String difficulty) {
    final newPreferences = state.copyWith(defaultDifficulty: difficulty);
    updatePreferences(newPreferences);
  }
} 