import 'package:flashcardstudyapplication/core/providers/auth_provider.dart';
import 'package:flashcardstudyapplication/core/providers/supabase_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flashcardstudyapplication/core/services/api/api_client.dart';
import 'package:flashcardstudyapplication/core/services/users/users_service.dart';

class UserState {
  final String? subscriptionPlan;
  final bool? isExpired;
  final String? errorMessage;
  final String? userId;
  final String? firstName;
  final String? lastName;
  final String? userStatus;
  final String? role;
  final bool? isAdmin;
  late final String? subscriptionPlanID;

  UserState({this.subscriptionPlan, this.isExpired, this.errorMessage, this.userId, this.firstName, this.lastName, this.userStatus, this.role, this.isAdmin, this.subscriptionPlanID});

  // Create a new state with updated values
  UserState copyWith({
    String? subscriptionPlan,
    bool? isExpired,
    String? errorMessage,
    String? userId,
    String? firstName,
    String? lastName,
    String? userStatus,
    String? role,
    bool? isAdmin,
    String? subscriptionPlanID,
    }) {
    return UserState(
      subscriptionPlan: subscriptionPlan ?? this.subscriptionPlan,
      isExpired: isExpired ?? this.isExpired,
      errorMessage: errorMessage ?? this.errorMessage,
      userId: userId ?? this.userId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      userStatus: userStatus ?? this.userStatus,
      role: role ?? this.role,
      isAdmin: isAdmin ?? this.isAdmin,
      subscriptionPlanID: subscriptionPlanID ?? this.subscriptionPlanID,
    );
  }
}


// UserNotifier to manage user-related state
class UserNotifier extends StateNotifier<UserState> {
  final UserService userService;
  final Ref ref;  // Add Ref to access other providers

  UserNotifier(this.userService, this.ref) : super(UserState()) {
    // Initialize user details when UserNotifier is created
    initializeUser();
  }

  Future<void> initializeUser() async {
    final authState = ref.read(authProvider);
    if (authState.isAuthenticated) {
      await fetchUserDetails();
    }
  }

  // Update fetchUserDetails to handle cases where user isn't authenticated
  Future<void> fetchUserDetails() async {
    try {
      final user = await userService.getCurrentUserInfo();
      if (user == null) {
        state = UserState(); // Reset state if no user
        return;
      }

      final subscriptionPlan = user['subscription_plan'];
      final expiryDate = user['subscription_expiry_date'];
      final isExpired = user['subscription_name'];

      state = state.copyWith(
        subscriptionPlan: subscriptionPlan,
        isExpired: isExpired,
        errorMessage: null,
        userId: user['id'],
        firstName: user['first_name'],
        lastName: user['last_name'],
        userStatus: user['user_status'],
        role: user['role'],
        isAdmin: user['is_admin'], 
        subscriptionPlanID: user['subscription_planID'],
      );
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  // Function to update user profile
  Future<void> updateUserProfile(String firstname, String lastname) async {
    try {
      await userService.updateUserProfile(firstname, lastname);
      // After updating, you may want to refetch or update the user state
      state = state.copyWith(errorMessage: null);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  // Function to upgrade user subscription
  Future<void> upgradeSubscription(String planType) async {
    try {
      await userService.upgradeSubscription(planType);
      // After upgrading, you may want to refetch or update the user state
      await fetchUserDetails(); // Refresh user data after upgrade
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  // Function to downgrade user subscription
  Future<void> downgradeSubscription(String planType) async {
    try {
      await userService.downgradeSubscription(planType);
      // After downgrading, you may want to refetch or update the user state
      await fetchUserDetails(); // Refresh user data after downgrade
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }





}

// Define the Riverpod provider for the user
final userProvider = StateNotifierProvider<UserNotifier, UserState>((ref) {
  final userService = ref.read(userServiceProvider);
  return UserNotifier(userService, ref);
});



// Define a provider for UserService
final userServiceProvider = Provider<UserService>((ref) {
  final supabaseClient = ref.read(supabaseServiceProvider);
  final apiService = ref.read(apiClientProvider); // This assumes you have an apiClientProvider
  return UserService(supabaseClient.client, apiService);
});
