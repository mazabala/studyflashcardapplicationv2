import 'package:flashcardstudyapplication/core/interfaces/i_user_service.dart';
import 'package:flashcardstudyapplication/core/providers/auth_provider.dart';
import 'package:flashcardstudyapplication/core/providers/provider_config.dart';
import 'package:flashcardstudyapplication/core/providers/supabase_provider.dart';
import 'package:flashcardstudyapplication/core/services/api/api_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  final String? email;
  final String? role;
  final bool? isAdmin;
  final String? subscriptionExpiryDate;
  late final String? subscriptionPlanID;

  UserState({this.subscriptionPlan, this.isExpired, this.errorMessage, this.userId, this.firstName, this.lastName, this.userStatus, this.email, this.role, this.isAdmin, this.subscriptionPlanID, this.subscriptionExpiryDate});

  // Create a new state with updated values
  UserState copyWith({
    String? subscriptionPlan,
    bool? isExpired,
    String? errorMessage,
    String? userId,
    String? firstName,
    String? lastName,
    String? userStatus,
    String? email,
    String? role,
    bool? isAdmin,
    String? subscriptionPlanID,
    String? subscriptionExpiryDate,
    }) {
    return UserState(
      subscriptionPlan: subscriptionPlan ?? this.subscriptionPlan,
      isExpired: isExpired ?? this.isExpired,
      errorMessage: errorMessage ?? this.errorMessage,
      userId: userId ?? this.userId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      userStatus: userStatus ?? this.userStatus,
      role: role ?? this.role,
      isAdmin: isAdmin ?? this.isAdmin,
      subscriptionPlanID: subscriptionPlanID ?? this.subscriptionPlanID,
      subscriptionExpiryDate: subscriptionExpiryDate ?? this.subscriptionExpiryDate,
    );
  }
}


// UserNotifier to manage user-related state
class UserNotifier extends StateNotifier<UserState> {
  final IUserService userService;
  final Ref ref;

  UserNotifier(this.userService, this.ref) : super(UserState());

  Future<void> initializeUser() async {
    try {
      print('in the user provider, initialize');
      final authState = ref.read(authStateProvider);
      if (!authState.isAuthenticated) {
        print('user is not authenticated in the user provider');
        state = UserState(); // Reset state if not authenticated
        return;
      }

      await fetchUserDetails();
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  Future<void> deleteUser() async {
    await userService.deleteUser(state.userId??'');
    state = UserState();
  }

  // Update fetchUserDetails to handle cases where user isn't authenticated
  Future<void> fetchUserDetails() async {
    try {



      final user = await userService.getCurrentUserInfo();
      if (user == null) {
        
        state = UserState(); // Reset state if no user
        throw Exception('Unable to retrieve the user details from Auth Provider');
      }


      
      // Convert subscription_expiry_date to bool if it's a string
      final isExpired = DateTime.parse(user['subscription_expiry_date']).isBefore(DateTime.now());

      state = state.copyWith(
        subscriptionPlan: user['subscription_name']?.toString(),
        isExpired: isExpired,
        userId: user['id']?.toString(),
        firstName: user['firstname']?.toString(),
        lastName: user['lastname']?.toString(),
        userStatus: user['user_is_active']?.toString(),
        role: user['role']?.toString(),
        subscriptionPlanID: user['subscription_planID']?.toString(),
        subscriptionExpiryDate: user['subscription_expiry_date']?.toString(),
        isAdmin: user['role'] == 'superAdmin' ? true : false,

      );



    } catch (e) {
      print('Error in fetchUserDetails: $e');
      state = state.copyWith(errorMessage: e.toString());
      rethrow;
    }
  }

  // Function to update user profile
  Future<void> updateUserProfile(String firstname, String lastname, String userId) async {
    try {
      await userService.updateUserProfile(firstname, lastname, userId);
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



