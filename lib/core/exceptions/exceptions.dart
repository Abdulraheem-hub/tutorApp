/// @context7:feature:core_exceptions
/// @context7:dependencies:equatable
/// @context7:pattern:exception_handling
///
/// Core exceptions for the TutorPay application
library;

import 'package:equatable/equatable.dart';

/// Base exception class for all application exceptions
abstract class AppException extends Equatable implements Exception {
  const AppException({required this.message, this.code, this.details});

  /// Human-readable error message
  final String message;

  /// Error code for programmatic handling
  final String? code;

  /// Additional error details
  final dynamic details;

  @override
  List<Object?> get props => [message, code, details];

  @override
  String toString() => 'AppException(message: $message, code: $code)';
}

/// Exception thrown during authentication operations
class AuthenticationException extends AppException {
  const AuthenticationException({
    required super.message,
    super.code,
    super.details,
  });

  @override
  String toString() =>
      'AuthenticationException(message: $message, code: $code)';
}

/// Exception thrown during network operations
class NetworkException extends AppException {
  const NetworkException({required super.message, super.code, super.details});

  @override
  String toString() => 'NetworkException(message: $message, code: $code)';
}

/// Exception thrown during data operations
class DataException extends AppException {
  const DataException({required super.message, super.code, super.details});

  @override
  String toString() => 'DataException(message: $message, code: $code)';
}

/// Exception thrown during validation operations
class ValidationException extends AppException {
  const ValidationException({
    required super.message,
    super.code,
    super.details,
  });

  @override
  String toString() => 'ValidationException(message: $message, code: $code)';
}

/// Exception thrown for server-related errors
class ServerException extends AppException {
  const ServerException({required super.message, super.code, super.details});

  @override
  String toString() => 'ServerException(message: $message, code: $code)';
}

/// Exception thrown for cache-related errors
class CacheException extends AppException {
  const CacheException({required super.message, super.code, super.details});

  @override
  String toString() => 'CacheException(message: $message, code: $code)';
}
