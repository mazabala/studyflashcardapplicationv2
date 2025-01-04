import 'package:flashcardstudyapplication/core/error/error_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flashcardstudyapplication/core/interfaces/i_user_service.dart';
import 'package:flashcardstudyapplication/core/interfaces/i_api_service.dart';

class UserService implements IUserService {
  final SupabaseClient _supabaseClient;
  final IApiService _apiService;

  UserService(this._supabaseClient, this._apiService);

  String? getCurrentUserId() {
    final user = _supabaseClient.auth.currentUser;
    return user?.id;
  }

Future<bool> isSystemAdmin() async{
    try{
      final userid = getCurrentUserId();
      if(userid == null)
      {
        return false;
      }

      final userRole = await _supabaseClient  
          .from('user_roles')
          .select('role')
          .eq('user_id', userid)
          .maybeSingle();


      if(userRole?['role'] == 'superAdmin')
      {return true;}
      else return false;
      
    }
    catch (e){

          print(e);
          rethrow;
           }

}

@override
Future<bool> isUserExpired(DateTime expiryDate) async {
  try {
    // Parse the expiryDate string into a DateTime object
    print("=====Expiry date: $expiryDate======"); //TODO: Is this working?

    // Compare with the current date and time
    if (expiryDate.isBefore(DateTime.now())) {
      return true; // Expired
    } else {
      return false; // Not expired
    }
  } catch (e) {
    // Handle parsing errors
    print("Error parsing expiry date: $e");
    return false; // Return false or handle the error appropriately
  }
}

  @override
  Future<String?> getCurrentUserEmail() async {
    final user = _supabaseClient.auth.currentUser;
    return user?.email;
  }

  @override
  Future<void> updateUserProfile(String name, String email) async {
    final user = _supabaseClient.auth.currentUser;
    if (user == null) {
      throw ErrorHandler.handleUserNotFound();
    }

    try {
      final result = await _supabaseClient.from('users').upsert({
        'id': user.id,
        'name': name,
        'email': email,
      });

      if (result == null) {
        throw ErrorHandler.handleProfileUpdateError(
          null,
          'Failed to update profile'
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

  @override
  Future<String> getUserSubscriptionPlan() async {
    final user = _supabaseClient.auth.currentUser;
    if (user == null) {
      throw ErrorHandler.handleUserNotFound();
    }
    else {
          print(user.id);}

    try {
      final result = await _supabaseClient  
          .from('user_subscriptions')
          .select('subscriptionID')
          .eq('user_id', user.id)
          .maybeSingle();


      if (result == null) {
        throw ErrorHandler.handleSubscriptionError(
          null,
          'No subscription found'
        );
      }

      return result['subscriptionID'] as String;
    } on PostgrestException catch (e) {
      throw ErrorHandler.handleDatabaseError(e, specificType: ErrorType.subscription);
    } on AuthException catch (e) {
      throw ErrorHandler.handleAuthError(e);
    } catch (e) {
      throw ErrorHandler.handle(e, 
        message: 'Failed to retrieve subscription plan',
        specificType: ErrorType.subscription
      );
    }
  }

  @override
  Future<DateTime?> getSubscriptionExpiry() async {
    final user = _supabaseClient.auth.currentUser;
    if (user == null) {
      throw ErrorHandler.handleUserNotFound();
    }

    try {
      final result = await _supabaseClient
          .from('user_subscriptions')
          .select('end_date')
          .eq('user_id', user.id)
          .single();

      if (result == null) {
        throw ErrorHandler.handleSubscriptionError(
          null,
          'No subscription found'
        );
      }
      
      final expiryDate = result['end_date'] as String?;
      return expiryDate != null ? DateTime.tryParse(expiryDate) : null;
    } on PostgrestException catch (e) {
      throw ErrorHandler.handleDatabaseError(e, specificType: ErrorType.subscription);
    } on AuthException catch (e) {
      throw ErrorHandler.handleAuthError(e);
    } catch (e) {
      throw ErrorHandler.handle(e, 
        message: 'Failed to retrieve subscription expiry',
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
}