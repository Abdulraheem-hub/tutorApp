/// @context7:feature:authentication
/// @context7:dependencies:user_entity
/// @context7:pattern:repository_interface
///
/// Authentication repository contract defining all auth operations
library;

import '../entities/user_entity.dart';

/// Abstract repository defining authentication operations
/// This contract will be implemented by the data layer
abstract class AuthenticationRepository {
  /// Get current authenticated user
  /// Returns null if no user is authenticated
  Future<UserEntity?> getCurrentUser();

  /// Stream of authentication state changes
  /// Emits UserEntity when user signs in, null when user signs out
  Stream<UserEntity?> get authStateChanges;

  /// Sign in with email and password
  /// Returns UserEntity on success
  /// Throws AuthenticationException on failure
  Future<UserEntity> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// Register new user with email and password
  /// Returns UserEntity on success
  /// Throws AuthenticationException on failure
  Future<UserEntity> registerWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  });

  /// Sign in with Google
  /// Returns UserEntity on success
  /// Throws AuthenticationException on failure
  Future<UserEntity> signInWithGoogle();

  /// Sign out current user
  /// Throws AuthenticationException on failure
  Future<void> signOut();

  /// Send password reset email
  /// Throws AuthenticationException on failure
  Future<void> sendPasswordResetEmail(String email);

  /// Send email verification
  /// Throws AuthenticationException on failure
  Future<void> sendEmailVerification();

  /// Update user profile
  /// Throws AuthenticationException on failure
  Future<UserEntity> updateUserProfile({String? displayName, String? photoUrl});

  /// Delete user account
  /// Throws AuthenticationException on failure
  Future<void> deleteAccount();

  /// Re-authenticate user before sensitive operations
  /// Throws AuthenticationException on failure
  Future<void> reauthenticateWithPassword(String password);

  /// Change user password
  /// Requires recent authentication
  /// Throws AuthenticationException on failure
  Future<void> changePassword(String newPassword);
}
