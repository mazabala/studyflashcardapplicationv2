// lib/core/services/billing/billing_service.dart

import 'package:flashcardstudyapplication/core/interfaces/i_api_service.dart';
import 'package:flashcardstudyapplication/core/interfaces/i_billing_service.dart';
import 'package:flashcardstudyapplication/core/error/error_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BillingService implements IBillingService {
  final SupabaseClient _supabaseClient;
  final IApiService _apiService;

  BillingService(this._supabaseClient, this._apiService);

  @override
  Future<void> initiatePayment(String userId, double amount, String plan) async {
    try {
      // Create a payment link or initiate the payment process
      // Using Supabase (or integrated payment processor like Stripe)
      // Example placeholder logic:
      final response = await _supabaseClient.from('payments').insert({
        'user_id': userId,
        'amount': amount,
        'plan': plan,
        'status': 'initiated',
      });

      if (response.error != null) {
        throw ServiceError(message: 'Failed to initiate payment');
      }

      // You might return a payment URL here for the user to complete the payment
      // For example, create a link with Stripe or another processor

    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<void> checkPaymentStatus(String userId) async {
    try {
      // Check the payment status (using the payment processor or Supabase)
      final response = await _supabaseClient
          .from('payments')
          .select('status')
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(1)
          .single();

      if (response == null ) {
        throw ServiceError(message: 'Failed to check payment status');
      }

      final status = response['status']; //todo maybe?
      if (status != 'paid') {
        throw ServiceError(message: 'Payment is not successful');
      }

    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<void> handlePaymentSuccess(String userId, String plan) async {
    try {
      // Update the user subscription status in Supabase
      final response = await _supabaseClient.from('users').update({
        'subscription': plan, // Update to the correct plan
        'subscription_status': 'active',
        'subscription_date': DateTime.now().toIso8601String(),
      }).eq('id', userId);

      if (response.error != null) {
        throw ServiceError(message: 'Failed to handle payment success');
      }

    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<void> handlePaymentFailure(String userId) async {
    try {
      // Mark the user as inactive if payment fails
      final response = await _supabaseClient.from('users').update({
        'subscription_status': 'inactive',
        'subscription': null,
      }).eq('id', userId);

      if (response.error != null) {
        throw ServiceError(message: 'Failed to handle payment failure');
      }

    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<void> renewSubscription(String userId) async {
    try {
      // Attempt to renew the subscription (usually done after a successful payment)
      final response = await _supabaseClient.from('users').update({
        'subscription_date': DateTime.now().toIso8601String(),
      }).eq('id', userId);

      if (response.error != null) {
        throw ServiceError(message: 'Failed to renew subscription');
      }

    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }
}
