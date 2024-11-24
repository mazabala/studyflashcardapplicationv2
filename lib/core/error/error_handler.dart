import 'package:supabase_flutter/supabase_flutter.dart';

enum ErrorType {
  authentication,
  database,
  network,
  validation,
  notFound,
  permission,
  configuration,
  api,
  unknown,
  subscription,  // Added for subscription-related errors
  userProfile    // Added for user profile-related errors
}

class ApiException implements Exception {
  final String message;
  final String? code;

  ApiException(this.message, [this.code]);

  @override
  String toString() => 'ApiException: $message (Code: $code)';
}

class ServiceError implements Exception {
  final String message;
  final ErrorType type;
  final String? code;
  final dynamic originalError;
  final StackTrace? stackTrace;

  ServiceError({
    required this.message,
    this.type = ErrorType.unknown,
    this.code,
    this.originalError,
    this.stackTrace,
  });

  @override
  String toString() => 'ServiceError: $message (Type: $type, Code: $code)';

  String get userMessage {
    switch (type) {
      case ErrorType.authentication:
        return 'Authentication error. Please sign in and try again.';
      case ErrorType.database:
        return 'Database error. Please try again later.';
      case ErrorType.network:
        return 'Network error. Please check your connection.';
      case ErrorType.validation:
        return 'Validation error: $message';
      case ErrorType.notFound:
        return 'The requested resource was not found.';
      case ErrorType.permission:
        return 'You don\'t have permission to perform this action.';
      case ErrorType.configuration:
        return 'System configuration error. Please contact support.';
      case ErrorType.api:
        return 'External service error. Please try again later.';
      case ErrorType.subscription:
        return 'Subscription error: $message';
      case ErrorType.userProfile:
        return 'Profile update error: $message';
      case ErrorType.unknown:
        return 'An unexpected error occurred. Please try again.';
    }
  }
}

class ErrorHandler {
  static ServiceError handleApiError(dynamic error, {String? message}) {
    // If the error is a known API error (e.g., from an API client or network failure)
    if (error is ApiException) {
      return ServiceError(
        message: message ?? error.message,
        type: ErrorType.api,
        code: error.code,
        originalError: error,
      );
    }

    // If it's not an ApiException, return a generic API error ServiceError
    return ServiceError(
      message: message ?? 'API error occurred.',
      type: ErrorType.api,
      originalError: error,
    );
  }

  static ServiceError handleAuthError(AuthException exception) {
    return ServiceError(
      message: exception.message ?? 'Unknown authentication error',
      type: ErrorType.authentication,
      code: exception.code ?? 'AUTH_ERROR',
      originalError: exception,
    );
  }

  static ServiceError handleDatabaseError(PostgrestException error, {ErrorType? specificType}) {
    final errorCode = error.code;

    // Handle specific database errors
    switch (errorCode) {
      case '23505': // Unique violation
        return ServiceError(
          message: 'This record already exists.',
          type: ErrorType.validation,
          code: errorCode,
          originalError: error,
        );
      case '42P01': // Undefined table
        return ServiceError(
          message: 'Database configuration error.',
          type: ErrorType.database,
          code: errorCode,
          originalError: error,
        );
      // Add specific error codes for subscription and user profile
      case '23503': // Foreign key violation
        return ServiceError(
          message: 'Referenced record does not exist.',
          type: specificType ?? ErrorType.database,
          code: errorCode,
          originalError: error,
        );
      default:
        return ServiceError(
          message: error.message,
          type: specificType ?? ErrorType.database,
          code: errorCode,
          originalError: error,
        );
    }
  }

  static ServiceError handleUserNotFound() {
    return ServiceError(
      message: 'User not logged in',
      type: ErrorType.authentication,
      code: 'USER_NOT_FOUND',
    );
  }

  static ServiceError handleSubscriptionError(dynamic error, String message) {
    return ServiceError(
      message: message,
      type: ErrorType.subscription,
      originalError: error,
    );
  }

  static ServiceError handleProfileUpdateError(dynamic error, String message) {
    return ServiceError(
      message: message,
      type: ErrorType.userProfile,
      originalError: error,
    );
  }

  // Handle all errors, including ApiException if needed
  static ServiceError handle(dynamic error, {
    String? message,
    StackTrace? stackTrace,
    ErrorType? specificType
  }) {
    if (error is ServiceError) {
      return error;
    }

    if (error is ApiException) {
      return handleApiError(error, message: message);
    }

    if (error is AuthException) {
      return handleAuthError(error);
    }

    if (error is PostgrestException) {
      return handleDatabaseError(error, specificType: specificType);
    }

    // Fallback: Return a generic ServiceError for any other errors
    return ServiceError(
      message: message ?? error?.toString() ?? 'An unknown error occurred',
      type: specificType ?? ErrorType.unknown,
      originalError: error,
      stackTrace: stackTrace,
    );
  }
}
