/// @context7:feature:authentication
/// @context7:dependencies:equatable
/// @context7:pattern:domain_entity
///
/// User entity representing authenticated user data
library;

import 'package:equatable/equatable.dart';

/// Domain entity representing a user in the system
/// This is platform-agnostic and contains only business logic relevant data
class UserEntity extends Equatable {
  const UserEntity({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.phoneNumber,
    required this.isEmailVerified,
    this.createdAt,
    this.lastSignInAt,
  });

  /// Unique identifier for the user
  final String id;

  /// User's email address
  final String email;

  /// User's display name (optional)
  final String? displayName;

  /// URL to user's profile photo (optional)
  final String? photoUrl;

  /// User's phone number (optional)
  final String? phoneNumber;

  /// Whether the user's email is verified
  final bool isEmailVerified;

  /// When the user account was created
  final DateTime? createdAt;

  /// Last sign-in time
  final DateTime? lastSignInAt;

  @override
  List<Object?> get props => [
    id,
    email,
    displayName,
    photoUrl,
    phoneNumber,
    isEmailVerified,
    createdAt,
    lastSignInAt,
  ];

  /// Create a copy of this user with some properties updated
  UserEntity copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    String? phoneNumber,
    bool? isEmailVerified,
    DateTime? createdAt,
    DateTime? lastSignInAt,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      createdAt: createdAt ?? this.createdAt,
      lastSignInAt: lastSignInAt ?? this.lastSignInAt,
    );
  }

  @override
  String toString() {
    return 'UserEntity(id: $id, email: $email, displayName: $displayName, isEmailVerified: $isEmailVerified)';
  }
}
