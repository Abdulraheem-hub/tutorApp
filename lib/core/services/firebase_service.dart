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

  /// Comprehensive method to populate test data for all payment scenarios
  Future<void> populateSampleData() async {
    try {
      print('🧪 Starting comprehensive payment test data creation...');

      final userId = currentUserId;
      final studentsRef = firestore
          .collection('users')
          .doc(userId)
          .collection('students');
      final paymentsRef = firestore
          .collection('users')
          .doc(userId)
          .collection('payments');

      // First, clear all existing data to avoid conflicts
      print('🧹 Clearing existing data...');
      await _clearExistingData(studentsRef, paymentsRef);

      final now = DateTime.now();

      // Define comprehensive test scenarios that match our payment card designs
      final testScenarios = [
        {
          'name': 'Alice Johnson',
          'scenario': 'Partial Payment - \$75 paid of \$150 monthly fee',
          'monthlyFee': 150.0,
          'currentMonthPaid': true,
          'outstandingBalance': 75.0,
          'paymentStatus': 'paid',
          'lastPaymentAmount': 75.0,
          'grade': 'grade10',
          'subjects': ['Mathematics', 'Science'],
          'phone': '+1234567890',
          'email': 'alice.johnson@email.com',
          'address': '123 Main Street, New York',
        },
        {
          'name': 'Bob Smith',
          'scenario': 'Overdue Payment - \$200 monthly fee, no payment made',
          'monthlyFee': 200.0,
          'currentMonthPaid': false,
          'outstandingBalance': 200.0,
          'paymentStatus': 'pending',
          'lastPaymentAmount': 0.0,
          'grade': 'grade11',
          'subjects': ['Mathematics', 'Physics'],
          'phone': '+1234567891',
          'email': 'bob.smith@email.com',
          'address': '456 Oak Avenue, Los Angeles',
        },
        {
          'name': 'Carol Davis',
          'scenario': 'Overpayment - \$180 paid of \$120 monthly fee',
          'monthlyFee': 120.0,
          'currentMonthPaid': true,
          'outstandingBalance': -60.0, // Credit balance
          'paymentStatus': 'paid',
          'lastPaymentAmount': 180.0,
          'grade': 'grade9',
          'subjects': ['Mathematics', 'English'],
          'phone': '+1234567892',
          'email': 'carol.davis@email.com',
          'address': '789 Pine Road, Chicago',
        },
        {
          'name': 'David Wilson',
          'scenario': 'Full Payment - \$175 paid of \$175 monthly fee',
          'monthlyFee': 175.0,
          'currentMonthPaid': true,
          'outstandingBalance': 0.0,
          'paymentStatus': 'paid',
          'lastPaymentAmount': 175.0,
          'grade': 'grade12',
          'subjects': ['Physics', 'Chemistry', 'Mathematics'],
          'phone': '+1234567893',
          'email': 'david.wilson@email.com',
          'address': '321 Elm Street, Houston',
        },
        {
          'name': 'Eva Brown',
          'scenario': 'Failed Payment - Card declined, \$160 monthly fee',
          'monthlyFee': 160.0,
          'currentMonthPaid': false,
          'outstandingBalance': 160.0,
          'paymentStatus': 'failed',
          'lastPaymentAmount': 0.0,
          'grade': 'grade10',
          'subjects': ['Mathematics', 'Science'],
          'phone': '+1234567894',
          'email': 'eva.brown@email.com',
          'address': '654 Maple Avenue, Phoenix',
        },
        {
          'name': 'Frank Miller',
          'scenario':
              'Cancelled Payment - Student discontinued, \$140 monthly fee',
          'monthlyFee': 140.0,
          'currentMonthPaid': false,
          'outstandingBalance': 140.0,
          'paymentStatus': 'cancelled',
          'lastPaymentAmount': 0.0,
          'grade': 'grade11',
          'subjects': ['Mathematics', 'Physics'],
          'phone': '+1234567895',
          'email': 'frank.miller@email.com',
          'address': '987 Cedar Lane, Philadelphia',
        },
        {
          'name': 'Grace Taylor',
          'scenario':
              'Refunded Payment - \$190 refunded due to schedule conflict',
          'monthlyFee': 190.0,
          'currentMonthPaid': true,
          'outstandingBalance': 190.0, // Refunded amount becomes outstanding
          'paymentStatus': 'refunded',
          'lastPaymentAmount': 190.0,
          'grade': 'grade12',
          'subjects': ['Biology', 'Chemistry', 'Physics'],
          'phone': '+1234567896',
          'email': 'grace.taylor@email.com',
          'address': '147 Birch Street, San Antonio',
        },
        {
          'name': 'Henry Anderson',
          'scenario': 'Multiple Months Overdue - 3 months unpaid',
          'monthlyFee': 180.0,
          'currentMonthPaid': false,
          'outstandingBalance': 540.0, // 3 months worth
          'paymentStatus': 'overdue',
          'lastPaymentAmount': 0.0,
          'grade': 'grade9',
          'subjects': ['Mathematics', 'English'],
          'phone': '+1234567897',
          'email': 'henry.anderson@email.com',
          'address': '258 Spruce Road, San Diego',
        },
        {
          'name': 'Ivy Chen',
          'scenario': 'Advance Payment - 3 months paid in advance',
          'monthlyFee': 160.0,
          'currentMonthPaid': true,
          'outstandingBalance': -320.0, // 2 months credit
          'paymentStatus': 'paid',
          'lastPaymentAmount': 480.0, // 3 months worth
          'grade': 'grade11',
          'subjects': ['Mathematics', 'Computer Science'],
          'phone': '+1234567898',
          'email': 'ivy.chen@email.com',
          'address': '369 Willow Avenue, Dallas',
        },
        {
          'name': 'Jack Robinson',
          'scenario': 'Irregular Payment History - Mixed payment patterns',
          'monthlyFee': 200.0,
          'currentMonthPaid': true,
          'outstandingBalance': 100.0, // Some unpaid amount
          'paymentStatus': 'paid',
          'lastPaymentAmount': 100.0, // Partial payment
          'grade': 'grade10',
          'subjects': ['Mathematics', 'Science', 'History'],
          'phone': '+1234567899',
          'email': 'jack.robinson@email.com',
          'address': '741 Aspen Lane, San Jose',
        },
      ];

      final batch = firestore.batch();
      final studentIds = <String>[];

      print('📝 Creating students with comprehensive test scenarios...');
      for (int i = 0; i < testScenarios.length; i++) {
        final scenario = testScenarios[i];
        final studentDoc = studentsRef.doc();
        studentIds.add(studentDoc.id);

        // Create student document
        batch.set(studentDoc, {
          'id': studentDoc.id,
          'name': scenario['name'],
          'grade': scenario['grade'],
          'monthlyFee': scenario['monthlyFee'],
          'paymentStatus': scenario['paymentStatus'],
          'currentMonthPaid': scenario['currentMonthPaid'],
          'outstandingBalance': scenario['outstandingBalance'],
          'lastPaymentAmount': scenario['lastPaymentAmount'],
          'admissionNumber': 'TST${(i + 1).toString().padLeft(3, '0')}',
          'joinDate': Timestamp.fromDate(
            now.subtract(Duration(days: 90 + i * 5)),
          ),
          'isActive': true,
          'subjects': scenario['subjects'],
          'phone': scenario['phone'],
          'email': scenario['email'],
          'address': scenario['address'],
          'notes': scenario['scenario'],
          'testScenario': scenario['scenario'],
          'createdAt': Timestamp.fromDate(now),
          'updatedAt': Timestamp.fromDate(now),
          'totalHours':
              (scenario['lastPaymentAmount'] as double) / 100, // Sample hours
          'totalEarnings': scenario['lastPaymentAmount'],
          'paymentPeriod': Timestamp.fromDate(DateTime(now.year, now.month)),
          'lastPaymentDate':
              (scenario['currentMonthPaid'] as bool) &&
                  (scenario['lastPaymentAmount'] as double) > 0
              ? Timestamp.fromDate(DateTime(now.year, now.month, 5))
              : null,
        });
      }

      print('💾 Committing students batch write...');
      await batch.commit();

      print('💰 Creating payment histories for test scenarios...');
      // Create payment histories in separate batches to avoid size limits
      for (int i = 0; i < testScenarios.length; i++) {
        await _createPaymentHistory(
          paymentsRef,
          studentIds[i],
          testScenarios[i],
          now,
        );
      }

      print('✅ Comprehensive test data created successfully!');
      print(
        '📊 Created ${testScenarios.length} test scenarios covering all payment cases',
      );
      print(
        '🔍 Check the app to verify all payment scenarios are working correctly',
      );
    } catch (e) {
      print('❌ Error populating comprehensive test data: $e');
      rethrow;
    }
  }

  Future<void> _clearExistingData(
    CollectionReference studentsRef,
    CollectionReference paymentsRef,
  ) async {
    final batch1 = firestore.batch();

    // Clear students
    final studentsSnapshot = await studentsRef.get();
    for (final doc in studentsSnapshot.docs) {
      batch1.delete(doc.reference);
    }
    await batch1.commit();

    // Clear payments
    final paymentsSnapshot = await paymentsRef.get();
    final batch2 = firestore.batch();
    for (final doc in paymentsSnapshot.docs) {
      batch2.delete(doc.reference);
    }
    await batch2.commit();
  }

  Future<void> _createPaymentHistory(
    CollectionReference paymentsRef,
    String studentId,
    Map<String, dynamic> scenario,
    DateTime now,
  ) async {
    final studentName = scenario['name'] as String;
    final monthlyFee = scenario['monthlyFee'] as double;
    final lastPaymentAmount = scenario['lastPaymentAmount'] as double;

    final batch = firestore.batch();

    // Create different payment histories based on scenario
    if (studentName.contains('Alice')) {
      // Partial payment this month
      final paymentDoc = paymentsRef.doc();
      batch.set(paymentDoc, {
        'id': paymentDoc.id,
        'studentId': studentId,
        'studentName': studentName,
        'amount': lastPaymentAmount,
        'monthlyFee': monthlyFee,
        'paymentDate': Timestamp.fromDate(now),
        'method': 'credit_card',
        'description':
            'Partial Monthly Fee - ${_getMonthName(now.month)} ${now.year}',
        'type': 'monthlyFee',
        'status': 'paid',
        'createdAt': Timestamp.fromDate(now),
      });
    } else if (studentName.contains('Bob')) {
      // No payment - overdue
      // No payment record created for overdue status
    } else if (studentName.contains('Carol')) {
      // Overpayment this month
      final paymentDoc = paymentsRef.doc();
      batch.set(paymentDoc, {
        'id': paymentDoc.id,
        'studentId': studentId,
        'studentName': studentName,
        'amount': lastPaymentAmount,
        'monthlyFee': monthlyFee,
        'paymentDate': Timestamp.fromDate(now),
        'method': 'bank_transfer',
        'description':
            'Monthly Fee + Advance - ${_getMonthName(now.month)} ${now.year}',
        'type': 'monthlyFee',
        'status': 'paid',
        'createdAt': Timestamp.fromDate(now),
      });
    } else if (studentName.contains('David')) {
      // Full payment this month
      final paymentDoc = paymentsRef.doc();
      batch.set(paymentDoc, {
        'id': paymentDoc.id,
        'studentId': studentId,
        'studentName': studentName,
        'amount': lastPaymentAmount,
        'monthlyFee': monthlyFee,
        'paymentDate': Timestamp.fromDate(now),
        'method': 'cash',
        'description': 'Monthly Fee - ${_getMonthName(now.month)} ${now.year}',
        'type': 'monthlyFee',
        'status': 'paid',
        'createdAt': Timestamp.fromDate(now),
      });
    } else if (studentName.contains('Eva')) {
      // Failed payment attempt
      final paymentDoc = paymentsRef.doc();
      batch.set(paymentDoc, {
        'id': paymentDoc.id,
        'studentId': studentId,
        'studentName': studentName,
        'amount': 0.0,
        'monthlyFee': monthlyFee,
        'paymentDate': null,
        'method': 'credit_card',
        'description': 'Failed Payment - Card Declined',
        'type': 'monthlyFee',
        'status': 'failed',
        'failureReason': 'Insufficient funds',
        'createdAt': Timestamp.fromDate(now),
      });
    } else if (studentName.contains('Frank')) {
      // Cancelled payment
      final paymentDoc = paymentsRef.doc();
      batch.set(paymentDoc, {
        'id': paymentDoc.id,
        'studentId': studentId,
        'studentName': studentName,
        'amount': 0.0,
        'monthlyFee': monthlyFee,
        'paymentDate': null,
        'method': 'cancelled',
        'description': 'Cancelled - Student Discontinued',
        'type': 'monthlyFee',
        'status': 'cancelled',
        'cancellationReason': 'Student left program',
        'createdAt': Timestamp.fromDate(now),
      });
    } else if (studentName.contains('Grace')) {
      // Refunded payment
      final paymentDoc = paymentsRef.doc();
      batch.set(paymentDoc, {
        'id': paymentDoc.id,
        'studentId': studentId,
        'studentName': studentName,
        'amount': lastPaymentAmount,
        'monthlyFee': monthlyFee,
        'paymentDate': Timestamp.fromDate(now.subtract(Duration(days: 5))),
        'refundDate': Timestamp.fromDate(now),
        'method': 'bank_transfer',
        'description': 'Refunded Payment - Schedule Conflict',
        'type': 'monthlyFee',
        'status': 'refunded',
        'refundReason': 'Schedule conflict, refund requested',
        'createdAt': Timestamp.fromDate(now.subtract(Duration(days: 5))),
      });
    } else if (studentName.contains('Henry')) {
      // Multiple months overdue - no payments
      // No payment records created for overdue student
    } else if (studentName.contains('Ivy')) {
      // Advance payment for multiple months
      final paymentDoc = paymentsRef.doc();
      batch.set(paymentDoc, {
        'id': paymentDoc.id,
        'studentId': studentId,
        'studentName': studentName,
        'amount': lastPaymentAmount,
        'monthlyFee': monthlyFee,
        'paymentDate': Timestamp.fromDate(now),
        'method': 'digitalWallet',
        'description': 'Advance Payment for 3 Months',
        'type': 'monthlyFee',
        'status': 'paid',
        'createdAt': Timestamp.fromDate(now),
      });
    } else if (studentName.contains('Jack')) {
      // Irregular payment pattern - partial payment this month
      final paymentDoc = paymentsRef.doc();
      batch.set(paymentDoc, {
        'id': paymentDoc.id,
        'studentId': studentId,
        'studentName': studentName,
        'amount': lastPaymentAmount,
        'monthlyFee': monthlyFee,
        'paymentDate': Timestamp.fromDate(now),
        'method': 'cash',
        'description': 'Partial Payment - Irregular Pattern',
        'type': 'monthlyFee',
        'status': 'paid',
        'createdAt': Timestamp.fromDate(now),
      });

      // Add some previous irregular payments
      final lastMonthPayment = paymentsRef.doc();
      batch.set(lastMonthPayment, {
        'id': lastMonthPayment.id,
        'studentId': studentId,
        'studentName': studentName,
        'amount': 300.0,
        'monthlyFee': monthlyFee,
        'paymentDate': Timestamp.fromDate(
          DateTime(now.year, now.month - 1, 15),
        ),
        'method': 'bank_transfer',
        'description': 'Irregular Payment - Last Month',
        'type': 'monthlyFee',
        'status': 'paid',
        'createdAt': Timestamp.fromDate(DateTime(now.year, now.month - 1, 15)),
      });
    }

    await batch.commit();
  }

  String _getMonthName(int month) {
    const months = [
      '',
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month];
  }
}
