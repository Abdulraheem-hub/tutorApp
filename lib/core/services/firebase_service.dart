/// @context7:feature:firebase_service
/// @context7:dependencies:firebase_core,firebase_auth,cloud_firestore,firebase_storage
/// @context7:pattern:service_layer
///
/// Core Firebase service providing centralized access to all Firebase services
library;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

/// Core Firebase service that provides access to all Firebase services
/// Follows singleton pattern to ensure single instance across the app
class FirebaseService {
  static FirebaseService? _instance;
  static FirebaseService get instance => _instance ??= FirebaseService._();

  FirebaseService._();

  /// Firebase Auth instance
  FirebaseAuth get auth => FirebaseAuth.instance;

  /// Firestore instance
  FirebaseFirestore get firestore => FirebaseFirestore.instance;

  /// Firebase Storage instance
  FirebaseStorage get storage => FirebaseStorage.instance;

  /// Firebase Messaging instance
  FirebaseMessaging get messaging => FirebaseMessaging.instance;

  /// Firebase Analytics instance
  FirebaseAnalytics get analytics => FirebaseAnalytics.instance;

  /// Firebase Crashlytics instance
  FirebaseCrashlytics get crashlytics => FirebaseCrashlytics.instance;

  /// Get current user ID (with fallback to test user for development)
  String get currentUserId {
    return auth.currentUser?.uid ?? 'test-user-123';
  }

  /// Initialize Firebase services
  Future<void> initialize() async {
    try {
      // Enable Firestore offline persistence
      await _enableFirestoreOfflinePersistence();

      // Initialize anonymous authentication for testing
      await _initializeAnonymousAuth();

      // Initialize Crashlytics
      await _initializeCrashlytics();

      // Request notification permissions
      await _requestNotificationPermissions();
    } catch (e) {
      // Log error but don't throw to avoid app crash
      await crashlytics.recordError(
        e,
        StackTrace.current,
        reason: 'Failed to initialize Firebase services',
      );
    }
  }

  /// Enable Firestore offline persistence
  Future<void> _enableFirestoreOfflinePersistence() async {
    try {
      firestore.settings = const Settings(persistenceEnabled: true);
    } catch (e) {
      // Persistence might already be enabled or not supported
    }
  }

  /// Initialize anonymous authentication for testing
  Future<void> _initializeAnonymousAuth() async {
    try {
      // Check if user is already signed in
      if (auth.currentUser == null) {
        // Sign in anonymously for testing purposes
        await auth.signInAnonymously();
      } else {}
    } catch (e) {}
  }

  /// Initialize Crashlytics
  Future<void> _initializeCrashlytics() async {
    try {
      // Set up Crashlytics collection
      await crashlytics.setCrashlyticsCollectionEnabled(true);
    } catch (e) {}
  }

  /// Request notification permissions
  Future<void> _requestNotificationPermissions() async {
    try {
      await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
    } catch (e) {}
  }

  /// Get FCM token for push notifications
  Future<String?> getFCMToken() async {
    try {
      return await messaging.getToken();
    } catch (e) {
      await crashlytics.recordError(
        e,
        StackTrace.current,
        reason: 'Failed to get FCM token',
      );
      return null;
    }
  }

  /// Subscribe to FCM topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await messaging.subscribeToTopic(topic);
    } catch (e) {
      await crashlytics.recordError(
        e,
        StackTrace.current,
        reason: 'Failed to subscribe to topic: $topic',
      );
    }
  }

  /// Unsubscribe from FCM topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await messaging.unsubscribeFromTopic(topic);
    } catch (e) {
      await crashlytics.recordError(
        e,
        StackTrace.current,
        reason: 'Failed to unsubscribe from topic: $topic',
      );
    }
  }

}
