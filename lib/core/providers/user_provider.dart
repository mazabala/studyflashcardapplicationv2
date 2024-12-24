import 'package:flashcardstudyapplication/core/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flashcardstudyapplication/core/services/api/api_client.dart';
import 'package:flashcardstudyapplication/core/services/users/users_service.dart';

class UserState {
  final String? subscriptionPlan;
  final bool? isExpired;
  final String? errorMessage;
  final String? userId;

  UserState({this.subscriptionPlan, this.isExpired, this.errorMessage, this.userId});

  // Create a new state with updated values
  UserState copyWith({
    String? subscriptionPlan,
    bool? isExpired,
    String? errorMessage,
    String? userId,
  }) {
    return UserState(
      subscriptionPlan: subscriptionPlan ?? this.subscriptionPlan,
      isExpired: isExpired ?? this.isExpired,
      errorMessage: errorMessage ?? this.errorMessage,
      userId: userId ?? this.userId,
    );
  }
}


// UserNotifier to manage user-related state
class UserNotifier extends StateNotifier<UserState> {
  final UserService userService;

  UserNotifier(this.userService) : super(UserState());

  // Fetch user details including subscription and expiry status
  Future<void> fetchUserDetails() async {
    try {
      // Fetch subscription plan
      final subscriptionPlan = await userService.getUserSubscriptionPlan();
      
      // Fetch subscription expiry date
      final expiryDate = await userService.getSubscriptionExpiry();

      final isExpired = expiryDate != null 
        ? await userService.isUserExpired(expiryDate) 
        : false;
        
      final userId = userService.getCurrentUserId();
      // Update the state with the fetched data
      state = state.copyWith(
        subscriptionPlan: subscriptionPlan,
        isExpired: isExpired,
        errorMessage: null,
        userId: userId,
      );
    } catch (e) {
      // Handle any errors that occur during fetching
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  // Function to update user profile
  Future<void> updateUserProfile(String name, String email) async {
    try {
      await userService.updateUserProfile(name, email);
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

Future<bool> isUserAdmin () async{

  try{
    final userRole =  await userService.isSystemAdmin();
      return userRole;
  }
  catch (e)
  {
    print (e);
    throw e;
  } 
}



}

// Define the Riverpod provider for the user
final userProvider = StateNotifierProvider<UserNotifier, UserState>((ref) {
  final userService = ref.read(userServiceProvider);
  return UserNotifier(userService);
});



// Define a provider for UserService
final userServiceProvider = Provider<UserService>((ref) {
  final supabaseClient = ref.read(supabaseClientProvider);
  final apiService = ref.read(apiClientProvider); // This assumes you have an apiClientProvider
  return UserService(supabaseClient, apiService);
});
