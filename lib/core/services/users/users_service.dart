import 'package:flashcardstudyapplication/core/error/error_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flashcardstudyapplication/core/interfaces/i_user_service.dart';
import 'package:flashcardstudyapplication/core/interfaces/i_api_service.dart';

class UserService implements IUserService {
  final SupabaseClient _supabaseClient;
  final IApiService _apiService;

  UserService(this._supabaseClient, this._apiService);

@override
Future<Map<String, dynamic>?> getCurrentUserInfo() async {

  
  try {
  final user =  _supabaseClient.auth.currentUser;
  

  if (user != null) {
    // Get the user info from our users table
    final userInfo = await _fetchUser(user.id);
    
      print('userInfo: ${userInfo}');
    if (userInfo != null) {
      // Create a new map that combines auth user data and our custom user data
      return {
        'id': user.id,
        'email': user.email,
        'created_at': userInfo['created_at'],
        'firstname': userInfo['firstname'],
        'lastname': userInfo['lastname'],
        'subscription_name': userInfo['subscriptiontype_name'],
        'subscription_status': userInfo['subscription_status'],
        'subscription_expiry_date': userInfo['subscription_expiry_date'],
        'subscription_planID': userInfo['subscriptionid'],
        'user_is_active': userInfo['user_is_active'],
        'role': userInfo['role']
      };
    }
  }} on Exception catch (e) {
  print('service user error: $e');
}
  
  return null; // Return null if no user is logged in or if user data isn't found
}

@override
Future<Map<String, dynamic>?> _fetchUser(String userid) async {
  final user = await _supabaseClient
      .from('users_view')
      .select('*')
      .eq('id', userid)
      .maybeSingle();
  return user;
}

@override
Future<void> deleteUser(String userid) async {

  try {

    if (userid == null || userid == '') {
      throw Exception('User ID is required');
    }

    final userSubscription = await _supabaseClient
      .from('user_subscriptions')
      .delete()
      .eq('user_id', userid);


await _supabaseClient.rpc('deleteUser');
  //  await _supabaseClient
  //     .auth.admin.deleteUser(userid);


} catch (e) {
  throw ErrorHandler.handle(e, 
        message: 'Failed to delete user: $e',
        specificType: ErrorType.userProfile
      );
}
}


  @override
  Future<String?> getCurrentUserEmail() async {
    final user = _supabaseClient.auth.currentUser;
    return user?.email;
  }

  @override
  Future<void> updateUserProfile(String firstname, String ?lastname, String userId) async {
    final user = _supabaseClient.auth.currentUser;
    if (user == null) {
      throw ErrorHandler.handleUserNotFound();
    }

    try {
      final result = await _supabaseClient.from('users').update({
        'first_name': firstname,
        'last_name': lastname,
      })
      .eq('id', userId)
      .select();

      if (result == null) {
        print('result: $result');
        throw ErrorHandler.handleProfileUpdateError(
          null,
          'Failed to update profile. Error: $result'
        );
      }
    } on PostgrestException catch (e) {
      throw ErrorHandler.handleDatabaseError(e, specificType: ErrorType.userProfile);
    } on AuthException catch (e) {
      throw ErrorHandler.handleAuthError(e);
    } catch (e) {
      throw ErrorHandler.handle(e, 
        message: 'Failed to update profile',
        specificType: ErrorType.userProfile
      );
    }
  }

  @override
  Future<void> upgradeSubscription(String planType) async {
    final user = _supabaseClient.auth.currentUser;
    if (user == null) {
      throw ErrorHandler.handleUserNotFound();
    }

    try {
      final result = await _supabaseClient.from('user_subscriptions').upsert({
        'user_id': user.id,
        'sub': planType,
        'status': 'active',
        'expiry_date': _getExpiryDateForPlan(planType),
      });

      if (result == null) {
        throw ErrorHandler.handleSubscriptionError(
          null,
          'Failed to upgrade subscription'
        );
      }
    } on PostgrestException catch (e) {
      throw ErrorHandler.handleDatabaseError(e, specificType: ErrorType.subscription);
    } on AuthException catch (e) {
      throw ErrorHandler.handleAuthError(e);
    } catch (e) {
      throw ErrorHandler.handle(e, 
        message: 'Failed to upgrade subscription',
        specificType: ErrorType.subscription
      );
    }
  }

DateTime _getExpiryDateForPlan(String planType) {
    final now = DateTime.now();
    switch (planType.toLowerCase()) {
      case 'basic':
        return now.add(const Duration(days: 30));
      case 'advanced':
        return now.add(const Duration(days: 30));
      default:
        return now.add(const Duration(days: 3));
    }
  }

  @override
  Future<void> downgradeSubscription(String planType) async {
    final user = _supabaseClient.auth.currentUser;
    if (user == null) {
      throw ErrorHandler.handleUserNotFound();
    }

    try {
      final result = await _supabaseClient.from('subscriptions').upsert({
        'user_id': user.id,
        'plan_type': planType,
        'status': 'active',
        'expiry_date': _getExpiryDateForPlan(planType),
      });

      if (result == null) {
        throw ErrorHandler.handleSubscriptionError(
          null,
          'Failed to downgrade subscription'
        );
      }
    } on PostgrestException catch (e) {
      throw ErrorHandler.handleDatabaseError(e, specificType: ErrorType.subscription);
    } on AuthException catch (e) {
      throw ErrorHandler.handleAuthError(e);
    } catch (e) {
      throw ErrorHandler.handle(e, 
        message: 'Failed to downgrade subscription',
        specificType: ErrorType.subscription
      );
    }
  }

  

  

}