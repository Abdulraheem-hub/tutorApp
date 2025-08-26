/// @context7:feature:authentication
/// @context7:dependencies:firebase_auth,user_entity
/// @context7:pattern:data_model
///
/// User model for converting between Firebase User and UserEntity
library;

import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/user_entity.dart';

/// Data model that extends UserEntity with Firebase-specific functionality
/// Handles conversion between Firebase User and domain UserEntity
class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    super.displayName,
    super.photoUrl,
    super.phoneNumber,
    required super.isEmailVerified,
    super.createdAt,
    super.lastSignInAt,
  });

  /// Create UserModel from Firebase User
  factory UserModel.fromFirebaseUser(User user) {
    return UserModel(
      id: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
      photoUrl: user.photoURL,
      phoneNumber: user.phoneNumber,
      isEmailVerified: user.emailVerified,
      createdAt: user.metadata.creationTime,
      lastSignInAt: user.metadata.lastSignInTime,
    );
  }

  /// Create UserModel from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String?,
      photoUrl: json['photoUrl'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      isEmailVerified: json['isEmailVerified'] as bool,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      lastSignInAt: json['lastSignInAt'] != null
          ? DateTime.parse(json['lastSignInAt'] as String)
          : null,
    );
  }

  /// Convert UserModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'phoneNumber': phoneNumber,
      'isEmailVerified': isEmailVerified,
      'createdAt': createdAt?.toIso8601String(),
      'lastSignInAt': lastSignInAt?.toIso8601String(),
    };
  }

  /// Convert to UserEntity
  UserEntity toEntity() {
    return UserEntity(
      id: id,
      email: email,
      displayName: displayName,
      photoUrl: photoUrl,
      phoneNumber: phoneNumber,
      isEmailVerified: isEmailVerified,
      createdAt: createdAt,
      lastSignInAt: lastSignInAt,
    );
  }

  /// Create UserModel from UserEntity
  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      email: entity.email,
      displayName: entity.displayName,
      photoUrl: entity.photoUrl,
      phoneNumber: entity.phoneNumber,
      isEmailVerified: entity.isEmailVerified,
      createdAt: entity.createdAt,
      lastSignInAt: entity.lastSignInAt,
    );
  }

  @override
  UserModel copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    String? phoneNumber,
    bool? isEmailVerified,
    DateTime? createdAt,
    DateTime? lastSignInAt,
  }) {
    return UserModel(
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
}
