// lib/core/services/interfaces/i_billing_service.dart

abstract class IBillingService {
  Future<void> initiatePayment(String userId, double amount, String plan);  // Initiates the payment
  Future<void> checkPaymentStatus(String userId);  // Checks if the payment was successful
  Future<void> handlePaymentSuccess(String userId, String plan);  // Handles successful payment
  Future<void> handlePaymentFailure(String userId);  // Handles failed payment
  Future<void> renewSubscription(String userId);  // Renews subscription on successful payment
}
