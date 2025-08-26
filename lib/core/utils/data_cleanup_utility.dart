/// @context7:feature:data_cleanup
/// @context7:dependencies:firebase_core,cloud_firestore
/// @context7:pattern:utility_service
///
/// Utility to clean up Firebase database for production readiness
library;

import '../services/firebase_service.dart';

class DataCleanupUtility {
  static final FirebaseService _firebaseService = FirebaseService.instance;

  /// Clear all test and development data from Firebase
  static Future<void> clearAllDevelopmentData() async {
    print('🧹 Clearing all development and test data...');

    final userId = _firebaseService.currentUserId;
    final firestore = _firebaseService.firestore;

    try {
      // Clear students collection
      await _clearCollection(
        firestore.collection('users').doc(userId).collection('students'),
        'students',
      );

      // Clear payments collection
      await _clearCollection(
        firestore.collection('users').doc(userId).collection('payments'),
        'payments',
      );

      // Clear analytics collection
      await _clearCollection(
        firestore.collection('users').doc(userId).collection('analytics'),
        'analytics',
      );

      print('✅ All development data cleared successfully');
    } catch (e) {
      print('❌ Error clearing development data: $e');
      rethrow;
    }
  }

  /// Clear a specific collection
  static Future<void> _clearCollection(
    dynamic collectionRef,
    String collectionName,
  ) async {
    print('🗑️ Clearing $collectionName collection...');

    final snapshot = await collectionRef.get();
    if (snapshot.docs.isEmpty) {
      print('ℹ️ $collectionName collection is already empty');
      return;
    }

    final batch = _firebaseService.firestore.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();

    print('✅ Cleared ${snapshot.docs.length} documents from $collectionName');
  }

  /// Clear only test data (keeps real user data)
  static Future<void> clearTestDataOnly() async {
    print('🧪 Clearing test data only...');

    final userId = _firebaseService.currentUserId;
    final firestore = _firebaseService.firestore;

    try {
      // Clear test students (those with test names)
      final studentsRef = firestore
          .collection('users')
          .doc(userId)
          .collection('students');

      final studentsSnapshot = await studentsRef.get();
      final testStudentBatch = firestore.batch();
      int testStudentCount = 0;

      for (final doc in studentsSnapshot.docs) {
        final data = doc.data();
        final name = data['name'] as String? ?? '';
        
        // Identify test students by common test names
        if (_isTestStudent(name)) {
          testStudentBatch.delete(doc.reference);
          testStudentCount++;
        }
      }

      if (testStudentCount > 0) {
        await testStudentBatch.commit();
        print('✅ Cleared $testStudentCount test students');
      }

      // Clear test payments (those associated with test students)
      final paymentsRef = firestore
          .collection('users')
          .doc(userId)
          .collection('payments');

      final paymentsSnapshot = await paymentsRef.get();
      final testPaymentBatch = firestore.batch();
      int testPaymentCount = 0;

      for (final doc in paymentsSnapshot.docs) {
        final data = doc.data();
        final studentName = data['studentName'] as String? ?? '';
        
        if (_isTestStudent(studentName)) {
          testPaymentBatch.delete(doc.reference);
          testPaymentCount++;
        }
      }

      if (testPaymentCount > 0) {
        await testPaymentBatch.commit();
        print('✅ Cleared $testPaymentCount test payments');
      }

      print('✅ Test data cleanup completed');
    } catch (e) {
      print('❌ Error clearing test data: $e');
      rethrow;
    }
  }

  /// Check if a student name is a test student
  static bool _isTestStudent(String name) {
    final testNames = [
      'Alice Johnson',
      'Bob Smith', 
      'Carol Brown',
      'David Wilson',
      'Emma Davis',
      'Frank Miller',
      'Grace Taylor',
      'Test Student',
      'Sample Student',
      'Demo Student',
    ];

    return testNames.any((testName) => 
        name.toLowerCase().contains(testName.toLowerCase()));
  }
}