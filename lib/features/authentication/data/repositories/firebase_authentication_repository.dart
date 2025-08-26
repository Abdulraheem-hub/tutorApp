/// @context7:feature:authentication
/// @context7:dependencies:firebase_auth,authentication_repository,user_model,exceptions
/// @context7:pattern:repository_implementation
///
/// Firebase implementation of AuthenticationRepository
library;

import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/authentication_repository.dart';
import '../models/user_model.dart';
import '../../../../core/exceptions/exceptions.dart';
import '../../../../core/services/firebase_service.dart';

/// Firebase implementation of the authentication repository
/// Handles all Firebase Auth operations and error mapping
class FirebaseAuthenticationRepository implements AuthenticationRepository {
  FirebaseAuthenticationRepository({FirebaseAuth? firebaseAuth})
    : _firebaseAuth = firebaseAuth ?? FirebaseService.instance.auth;

  final FirebaseAuth _firebaseAuth;

  @override
  Future<UserEntity?> getCurrentUser() async {
    try {
      final User? firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser != null) {
        return UserModel.fromFirebaseUser(firebaseUser).toEntity();
      }
      return null;
    } catch (e) {
      throw AuthenticationException(
        message: 'Failed to get current user',
        details: e,
      );
    }
  }

  @override
  Stream<UserEntity?> get authStateChanges {
    return _firebaseAuth.authStateChanges().map((User? firebaseUser) {
      if (firebaseUser != null) {
        return UserModel.fromFirebaseUser(firebaseUser).toEntity();
      }
      return null;
    });
  }

  @override
  Future<UserEntity> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential credential = await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);

      if (credential.user == null) {
        throw const AuthenticationException(
          message: 'Failed to sign in - no user returned',
          code: 'no-user',
        );
      }

      return UserModel.fromFirebaseUser(credential.user!).toEntity();
    } on FirebaseAuthException catch (e) {
      throw AuthenticationException(
        message: _mapFirebaseAuthErrorMessage(e.code),
        code: e.code,
        details: e,
      );
    } catch (e) {
      throw AuthenticationException(
        message: 'An unexpected error occurred during sign in',
        details: e,
      );
    }
  }

  @override
  Future<UserEntity> registerWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final UserCredential credential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      if (credential.user == null) {
        throw const AuthenticationException(
          message: 'Failed to register - no user returned',
          code: 'no-user',
        );
      }

      // Update display name if provided
      if (displayName != null && displayName.isNotEmpty) {
        await credential.user!.updateDisplayName(displayName);
        await credential.user!.reload();
      }

      return UserModel.fromFirebaseUser(credential.user!).toEntity();
    } on FirebaseAuthException catch (e) {
      throw AuthenticationException(
        message: _mapFirebaseAuthErrorMessage(e.code),
        code: e.code,
        details: e,
      );
    } catch (e) {
      throw AuthenticationException(
        message: 'An unexpected error occurred during registration',
        details: e,
      );
    }
  }

  @override
  Future<UserEntity> signInWithGoogle() async {
    try {
      // This would require google_sign_in package
      // For now, throw unsupported operation
      throw const AuthenticationException(
        message: 'Google sign in not yet implemented',
        code: 'unsupported-operation',
      );
    } catch (e) {
      throw AuthenticationException(
        message: 'Failed to sign in with Google',
        details: e,
      );
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } on FirebaseAuthException catch (e) {
      throw AuthenticationException(
        message: _mapFirebaseAuthErrorMessage(e.code),
        code: e.code,
        details: e,
      );
    } catch (e) {
      throw AuthenticationException(
        message: 'An unexpected error occurred during sign out',
        details: e,
      );
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw AuthenticationException(
        message: _mapFirebaseAuthErrorMessage(e.code),
        code: e.code,
        details: e,
      );
    } catch (e) {
      throw AuthenticationException(
        message: 'Failed to send password reset email',
        details: e,
      );
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    try {
      final User? user = _firebaseAuth.currentUser;
      if (user == null) {
        throw const AuthenticationException(
          message: 'No authenticated user found',
          code: 'no-user',
        );
      }

      await user.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      throw AuthenticationException(
        message: _mapFirebaseAuthErrorMessage(e.code),
        code: e.code,
        details: e,
      );
    } catch (e) {
      throw AuthenticationException(
        message: 'Failed to send email verification',
        details: e,
      );
    }
  }

  @override
  Future<UserEntity> updateUserProfile({
    String? displayName,
    String? photoUrl,
  }) async {
    try {
      final User? user = _firebaseAuth.currentUser;
      if (user == null) {
        throw const AuthenticationException(
          message: 'No authenticated user found',
          code: 'no-user',
        );
      }

      if (displayName != null) {
        await user.updateDisplayName(displayName);
      }

      if (photoUrl != null) {
        await user.updatePhotoURL(photoUrl);
      }

      await user.reload();
      return UserModel.fromFirebaseUser(_firebaseAuth.currentUser!).toEntity();
    } on FirebaseAuthException catch (e) {
      throw AuthenticationException(
        message: _mapFirebaseAuthErrorMessage(e.code),
        code: e.code,
        details: e,
      );
    } catch (e) {
      throw AuthenticationException(
        message: 'Failed to update user profile',
        details: e,
      );
    }
  }

  @override
  Future<void> deleteAccount() async {
    try {
      final User? user = _firebaseAuth.currentUser;
      if (user == null) {
        throw const AuthenticationException(
          message: 'No authenticated user found',
          code: 'no-user',
        );
      }

      await user.delete();
    } on FirebaseAuthException catch (e) {
      throw AuthenticationException(
        message: _mapFirebaseAuthErrorMessage(e.code),
        code: e.code,
        details: e,
      );
    } catch (e) {
      throw AuthenticationException(
        message: 'Failed to delete account',
        details: e,
      );
    }
  }

  @override
  Future<void> reauthenticateWithPassword(String password) async {
    try {
      final User? user = _firebaseAuth.currentUser;
      if (user == null) {
        throw const AuthenticationException(
          message: 'No authenticated user found',
          code: 'no-user',
        );
      }

      final String email = user.email ?? '';
      if (email.isEmpty) {
        throw const AuthenticationException(
          message: 'User email not available for reauthentication',
          code: 'no-email',
        );
      }

      final AuthCredential credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );

      await user.reauthenticateWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw AuthenticationException(
        message: _mapFirebaseAuthErrorMessage(e.code),
        code: e.code,
        details: e,
      );
    } catch (e) {
      throw AuthenticationException(
        message: 'Failed to reauthenticate user',
        details: e,
      );
    }
  }

  @override
  Future<void> changePassword(String newPassword) async {
    try {
      final User? user = _firebaseAuth.currentUser;
      if (user == null) {
        throw const AuthenticationException(
          message: 'No authenticated user found',
          code: 'no-user',
        );
      }

      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw AuthenticationException(
        message: _mapFirebaseAuthErrorMessage(e.code),
        code: e.code,
        details: e,
      );
    } catch (e) {
      throw AuthenticationException(
        message: 'Failed to change password',
        details: e,
      );
    }
  }

  /// Map Firebase Auth error codes to user-friendly messages
  String _mapFirebaseAuthErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'weak-password':
        return 'Password is too weak. Please choose a stronger password.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'This operation is not allowed.';
      case 'requires-recent-login':
        return 'Please sign in again to perform this action.';
      case 'invalid-credential':
        return 'Invalid credentials provided.';
      default:
        return 'An authentication error occurred. Please try again.';
    }
  }
}
