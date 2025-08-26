/// @context7:feature:database_utilities
/// @context7:dependencies:firebase_core,cloud_firestore
/// @context7:pattern:utility_service
///
/// Database utility for populating sample data within the app
library;

import '../services/firebase_service.dart';

class DatabaseSeeder {
  static final FirebaseService _firebaseService = FirebaseService.instance;

  /// Populate comprehensive sample data for testing all payment scenarios
  static Future<void> populateAllSampleData() async {
    print('🚀 Starting sample data population...');

    try {
      await populateStudents();
      await populatePayments();
      await populateAnalyticsData();

      print('🎉 Sample data population completed successfully!');
    } catch (e) {
      print('❌ Error populating sample data: $e');
      rethrow;
    }
  }

  /// Clear all existing data before populating (use with caution!)
  static Future<void> clearAllData() async {
    print('🗑️ Clearing existing data...');

    final userId = _firebaseService.currentUserId;
    final firestore = _firebaseService.firestore;

    // Clear students
    final studentsSnapshot = await firestore
        .collection('users')
        .doc(userId)
        .collection('students')
        .get();

    final studentsBatch = firestore.batch();
    for (final doc in studentsSnapshot.docs) {
      studentsBatch.delete(doc.reference);
    }
    await studentsBatch.commit();

    // Clear payments
    final paymentsSnapshot = await firestore
        .collection('users')
        .doc(userId)
        .collection('payments')
        .get();

    final paymentsBatch = firestore.batch();
    for (final doc in paymentsSnapshot.docs) {
      paymentsBatch.delete(doc.reference);
    }
    await paymentsBatch.commit();

    // Clear analytics
    final analyticsSnapshot = await firestore
        .collection('users')
        .doc(userId)
        .collection('analytics')
        .get();

    final analyticsBatch = firestore.batch();
    for (final doc in analyticsSnapshot.docs) {
      analyticsBatch.delete(doc.reference);
    }
    await analyticsBatch.commit();

    print('✅ All data cleared successfully');
  }

  /// Populate comprehensive student data covering all payment scenarios
  static Future<void> populateStudents() async {
    print('📚 Populating sample students...');

    final firestore = _firebaseService.firestore;
    final userId = _firebaseService.currentUserId;
    final studentsRef = firestore
        .collection('users')
        .doc(userId)
        .collection('students');

    // Define subjects for different grades
    final primarySubjects = [
      {'id': 'math-primary', 'name': 'Mathematics', 'shortName': 'Math'},
      {'id': 'english-primary', 'name': 'English', 'shortName': 'Eng'},
      {
        'id': 'science-primary',
        'name': 'General Science',
        'shortName': 'Science',
      },
      {'id': 'social-primary', 'name': 'Social Studies', 'shortName': 'Social'},
    ];

    final middleSubjects = [
      {'id': 'math-middle', 'name': 'Mathematics', 'shortName': 'Math'},
      {'id': 'english-middle', 'name': 'English', 'shortName': 'Eng'},
      {'id': 'science-middle', 'name': 'Science', 'shortName': 'Science'},
      {'id': 'social-middle', 'name': 'Social Science', 'shortName': 'Social'},
      {'id': 'hindi-middle', 'name': 'Hindi', 'shortName': 'Hindi'},
    ];

    final highSchoolSubjects = [
      {'id': 'math-high', 'name': 'Mathematics', 'shortName': 'Math'},
      {'id': 'physics', 'name': 'Physics', 'shortName': 'Phy'},
      {'id': 'chemistry', 'name': 'Chemistry', 'shortName': 'Chem'},
      {'id': 'biology', 'name': 'Biology', 'shortName': 'Bio'},
      {'id': 'english-high', 'name': 'English', 'shortName': 'Eng'},
      {'id': 'computer-science', 'name': 'Computer Science', 'shortName': 'CS'},
    ];

    final sampleStudents = [
      // Scenario 1: Current students (paid up)
      {
        'name': 'Aarav Sharma',
        'grade': 'grade10',
        'subjects': middleSubjects.take(4).toList(),
        'monthlyFee': 3500.0,
        'paymentStatus': 'paid',
        'currentMonthPaid': true,
        'outstandingBalance': 0.0,
        'admissionNumber': 'TUT001',
        'phoneNumber': '+91 98765 43210',
        'email': 'aarav.sharma@email.com',
        'address': '123 MG Road, Bangalore, Karnataka 560001',
      },

      // Scenario 2: New student (first month)
      {
        'name': 'Diya Patel',
        'grade': 'grade8',
        'subjects': middleSubjects.take(5).toList(),
        'monthlyFee': 3000.0,
        'paymentStatus': 'newStudent',
        'currentMonthPaid': false,
        'outstandingBalance': 0.0,
        'admissionNumber': 'TUT002',
        'phoneNumber': '+91 99887 76554',
        'email': 'diya.patel@email.com',
        'address': '456 Brigade Road, Bangalore, Karnataka 560025',
      },

      // Scenario 3: Current month pending
      {
        'name': 'Arjun Kumar',
        'grade': 'grade12',
        'subjects': highSchoolSubjects.take(4).toList(),
        'monthlyFee': 4500.0,
        'paymentStatus': 'pending',
        'currentMonthPaid': false,
        'outstandingBalance': 0.0,
        'admissionNumber': 'TUT003',
        'phoneNumber': '+91 98123 45678',
        'email': 'arjun.kumar@email.com',
        'address': '789 Indiranagar, Bangalore, Karnataka 560038',
      },

      // Scenario 4: Multiple months overdue
      {
        'name': 'Ananya Singh',
        'grade': 'grade9',
        'subjects': middleSubjects,
        'monthlyFee': 3200.0,
        'paymentStatus': 'overdue',
        'currentMonthPaid': false,
        'outstandingBalance': 9600.0, // 3 months outstanding
        'admissionNumber': 'TUT004',
        'phoneNumber': '+91 97654 32109',
        'email': 'ananya.singh@email.com',
        'address': '321 Koramangala, Bangalore, Karnataka 560034',
      },

      // Scenario 5: Partial payment (current month paid, previous dues)
      {
        'name': 'Ishaan Gupta',
        'grade': 'grade11',
        'subjects': highSchoolSubjects.take(5).toList(),
        'monthlyFee': 4000.0,
        'paymentStatus': 'pending',
        'currentMonthPaid': true,
        'outstandingBalance': 8000.0, // 2 months previous dues
        'admissionNumber': 'TUT005',
        'phoneNumber': '+91 95432 16780',
        'email': 'ishaan.gupta@email.com',
        'address': '654 Whitefield, Bangalore, Karnataka 560066',
      },

      // Scenario 6: High-value student (multiple subjects)
      {
        'name': 'Kavya Reddy',
        'grade': 'grade12',
        'subjects': highSchoolSubjects,
        'monthlyFee': 6000.0,
        'paymentStatus': 'paid',
        'currentMonthPaid': true,
        'outstandingBalance': 0.0,
        'admissionNumber': 'TUT006',
        'phoneNumber': '+91 94321 87650',
        'email': 'kavya.reddy@email.com',
        'address': '987 Electronic City, Bangalore, Karnataka 560100',
      },

      // Scenario 7: Low-grade student
      {
        'name': 'Ravi Mishra',
        'grade': 'grade3',
        'subjects': primarySubjects.take(3).toList(),
        'monthlyFee': 2000.0,
        'paymentStatus': 'paid',
        'currentMonthPaid': true,
        'outstandingBalance': 0.0,
        'admissionNumber': 'TUT007',
        'phoneNumber': '+91 93210 98765',
        'email': 'ravi.mishra@email.com',
        'address': '147 HSR Layout, Bangalore, Karnataka 560102',
      },

      // Scenario 8: Irregular payment pattern
      {
        'name': 'Priya Joshi',
        'grade': 'grade7',
        'subjects': middleSubjects.take(4).toList(),
        'monthlyFee': 2800.0,
        'paymentStatus': 'overdue',
        'currentMonthPaid': false,
        'outstandingBalance': 5600.0, // 2 months overdue
        'admissionNumber': 'TUT008',
        'phoneNumber': '+91 92109 87654',
        'email': 'priya.joshi@email.com',
        'address': '258 JP Nagar, Bangalore, Karnataka 560078',
      },

      // Scenario 9: Recently joined, first payment done
      {
        'name': 'Aditya Malhotra',
        'grade': 'grade6',
        'subjects': middleSubjects.take(4).toList(),
        'monthlyFee': 2700.0,
        'paymentStatus': 'paid',
        'currentMonthPaid': true,
        'outstandingBalance': 0.0,
        'admissionNumber': 'TUT009',
        'phoneNumber': '+91 91098 76543',
        'email': 'aditya.malhotra@email.com',
        'address': '369 Bannerghatta Road, Bangalore, Karnataka 560076',
      },

      // Scenario 10: Student with varying payment amounts
      {
        'name': 'Siya Agarwal',
        'grade': 'grade5',
        'subjects': primarySubjects,
        'monthlyFee': 2500.0,
        'paymentStatus': 'pending',
        'currentMonthPaid': false,
        'outstandingBalance': 2500.0, // 1 month overdue
        'admissionNumber': 'TUT010',
        'phoneNumber': '+91 90987 65432',
        'email': 'siya.agarwal@email.com',
        'address': '741 Marathahalli, Bangalore, Karnataka 560037',
      },

      // Additional scenarios for comprehensive testing

      // Scenario 11: Multiple subjects, high achiever
      {
        'name': 'Rohan Kapoor',
        'grade': 'grade11',
        'subjects': [...highSchoolSubjects],
        'monthlyFee': 5500.0,
        'paymentStatus': 'paid',
        'currentMonthPaid': true,
        'outstandingBalance': 0.0,
        'admissionNumber': 'TUT011',
        'phoneNumber': '+91 89876 54321',
        'email': 'rohan.kapoor@email.com',
        'address': '852 Bellandur, Bangalore, Karnataka 560103',
      },

      // Scenario 12: New admission, no payments yet
      {
        'name': 'Neha Verma',
        'grade': 'grade4',
        'subjects': primarySubjects.take(3).toList(),
        'monthlyFee': 2200.0,
        'paymentStatus': 'newStudent',
        'currentMonthPaid': false,
        'outstandingBalance': 0.0,
        'admissionNumber': 'TUT012',
        'phoneNumber': '+91 88765 43210',
        'email': 'neha.verma@email.com',
        'address': '963 Sarjapur Road, Bangalore, Karnataka 560035',
      },
    ];

    // Add students to Firestore
    final batch = firestore.batch();

    for (int i = 0; i < sampleStudents.length; i++) {
      final student = sampleStudents[i];
      final docRef = studentsRef.doc();

      final now = DateTime.now();
      final joinDate = now.subtract(
        Duration(days: 30 + (i * 15)),
      ); // Staggered join dates

      batch.set(docRef, {
        ...student,
        'id': docRef.id,
        'joinDate': joinDate.toIso8601String(),
        'admissionDate': joinDate.toIso8601String(),
        'isActive': true,
        'nextPaymentDate': _calculateNextPaymentDate(
          now,
          student['currentMonthPaid'] as bool,
        ),
        'paymentPeriod': DateTime(now.year, now.month).toIso8601String(),
        'lastPaymentAmount': student['currentMonthPaid'] as bool
            ? student['monthlyFee']
            : null,
        'createdAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
      });

      print('  ✓ Added student: ${student['name']} (${student['grade']})');
    }

    await batch.commit();
    print('📚 Successfully added ${sampleStudents.length} students');
  }

  /// Populate comprehensive payment history for testing
  static Future<void> populatePayments() async {
    print('💰 Populating sample payments...');

    final firestore = _firebaseService.firestore;
    final userId = _firebaseService.currentUserId;
    final paymentsRef = firestore
        .collection('users')
        .doc(userId)
        .collection('payments');
    final studentsRef = firestore
        .collection('users')
        .doc(userId)
        .collection('students');

    // Get all students
    final studentsSnapshot = await studentsRef.get();
    final students = studentsSnapshot.docs;

    final batch = firestore.batch();
    final now = DateTime.now();

    // Payment methods distribution
    final paymentMethods = ['cash', 'digitalWallet', 'bankTransfer', 'card'];

    int paymentCount = 0;

    for (final studentDoc in students) {
      final student = studentDoc.data();
      final studentId = student['id'] as String;
      final studentName = student['name'] as String;
      final monthlyFee = student['monthlyFee'] as double;
      final currentMonthPaid = student['currentMonthPaid'] as bool;
      final outstandingBalance = student['outstandingBalance'] as double;

      // Create payment history based on student's payment status

      // 1. Historical monthly payments (3-6 months back)
      final monthsBack =
          (studentName.hashCode % 6) + 3; // 3-8 months of history
      for (int i = 1; i <= monthsBack; i++) {
        final paymentDate = DateTime(now.year, now.month - i, 15 + (i % 10));

        // Skip some payments for overdue students to create realistic scenarios
        if (outstandingBalance > 0 &&
            i <= (outstandingBalance / monthlyFee).ceil()) {
          continue; // Skip these payments to create overdue scenario
        }

        final paymentDoc = paymentsRef.doc();
        batch.set(paymentDoc, {
          'id': paymentDoc.id,
          'studentId': studentId,
          'studentName': studentName,
          'amount': monthlyFee,
          'paymentDate': paymentDate.toIso8601String(),
          'method': paymentMethods[i % paymentMethods.length],
          'description':
              'Monthly Fee - ${_getMonthName(paymentDate.month)} ${paymentDate.year}',
          'type': 'monthlyFee',
          'status': 'completed',
          'createdAt': paymentDate.toIso8601String(),
        });
        paymentCount++;
      }

      // 2. Current month payment (if paid)
      if (currentMonthPaid) {
        final currentPaymentDate = DateTime(
          now.year,
          now.month,
          10 + (studentName.hashCode % 15),
        );
        final paymentDoc = paymentsRef.doc();
        batch.set(paymentDoc, {
          'id': paymentDoc.id,
          'studentId': studentId,
          'studentName': studentName,
          'amount': monthlyFee,
          'paymentDate': currentPaymentDate.toIso8601String(),
          'method': paymentMethods[paymentCount % paymentMethods.length],
          'description':
              'Monthly Fee - ${_getMonthName(now.month)} ${now.year}',
          'type': 'monthlyFee',
          'status': 'completed',
          'createdAt': currentPaymentDate.toIso8601String(),
        });
        paymentCount++;
      }

      // 3. Registration fee (for all students)
      final registrationDate = DateTime.parse(student['joinDate'] as String);
      final registrationDoc = paymentsRef.doc();
      final registrationFee = monthlyFee * 0.5; // 50% of monthly fee
      batch.set(registrationDoc, {
        'id': registrationDoc.id,
        'studentId': studentId,
        'studentName': studentName,
        'amount': registrationFee,
        'paymentDate': registrationDate.toIso8601String(),
        'method': paymentMethods[0], // Usually cash for registration
        'description': 'Registration Fee',
        'type': 'registrationFee',
        'status': 'completed',
        'createdAt': registrationDate.toIso8601String(),
      });
      paymentCount++;

      // 4. Additional payments (exam fees, extra classes) for some students
      if (paymentCount % 3 == 0) {
        // Every 3rd student gets exam fee
        final examDate = now.subtract(Duration(days: 45));
        final examDoc = paymentsRef.doc();
        batch.set(examDoc, {
          'id': examDoc.id,
          'studentId': studentId,
          'studentName': studentName,
          'amount': 500.0,
          'paymentDate': examDate.toIso8601String(),
          'method': paymentMethods[1],
          'description': 'Mid-term Examination Fee',
          'type': 'examFee',
          'status': 'completed',
          'createdAt': examDate.toIso8601String(),
        });
        paymentCount++;
      }

      if (paymentCount % 4 == 0) {
        // Every 4th student gets extra class
        final extraClassDate = now.subtract(Duration(days: 20));
        final extraDoc = paymentsRef.doc();
        batch.set(extraDoc, {
          'id': extraDoc.id,
          'studentId': studentId,
          'studentName': studentName,
          'amount': 800.0,
          'paymentDate': extraClassDate.toIso8601String(),
          'method': paymentMethods[2],
          'description': 'Extra Mathematics Class',
          'type': 'extraClass',
          'status': 'completed',
          'createdAt': extraClassDate.toIso8601String(),
        });
        paymentCount++;
      }

      // 5. Partial payments for some overdue students
      if (outstandingBalance > 0 && paymentCount % 5 == 0) {
        final partialDate = now.subtract(Duration(days: 10));
        final partialDoc = paymentsRef.doc();
        final partialAmount = monthlyFee * 0.7; // 70% payment
        batch.set(partialDoc, {
          'id': partialDoc.id,
          'studentId': studentId,
          'studentName': studentName,
          'amount': partialAmount,
          'paymentDate': partialDate.toIso8601String(),
          'method': paymentMethods[3],
          'description': 'Partial Payment - Monthly Fee',
          'type': 'monthlyFee',
          'status': 'completed',
          'createdAt': partialDate.toIso8601String(),
        });
        paymentCount++;
      }

      print('  ✓ Added payment history for: $studentName');
    }

    await batch.commit();
    print('💰 Successfully added $paymentCount payment records');
  }

  /// Populate analytics and summary data
  static Future<void> populateAnalyticsData() async {
    print('📊 Populating analytics data...');

    final firestore = _firebaseService.firestore;
    final userId = _firebaseService.currentUserId;
    final analyticsRef = firestore
        .collection('users')
        .doc(userId)
        .collection('analytics');

    final now = DateTime.now();

    // Monthly revenue data for the last 6 months
    final batch = firestore.batch();

    for (int i = 0; i < 6; i++) {
      final month = DateTime(now.year, now.month - i);
      final monthDoc = analyticsRef.doc(
        'revenue-${month.year}-${month.month.toString().padLeft(2, '0')}',
      );

      // Calculate realistic revenue numbers
      final baseRevenue = 25000.0 + (i * 2000); // Growing revenue trend
      final variations = (month.hashCode % 5000).toDouble(); // Some variation
      final totalRevenue = baseRevenue + variations;

      batch.set(monthDoc, {
        'month': month.toIso8601String(),
        'totalRevenue': totalRevenue,
        'totalPayments': (totalRevenue / 3200)
            .round(), // Average fee assumption
        'averagePayment': totalRevenue / (totalRevenue / 3200).round(),
        'paymentMethods': {
          'cash': (totalRevenue * 0.4).round(),
          'digitalWallet': (totalRevenue * 0.35).round(),
          'bankTransfer': (totalRevenue * 0.15).round(),
          'card': (totalRevenue * 0.1).round(),
        },
        'paymentTypes': {
          'monthlyFee': (totalRevenue * 0.85).round(),
          'registrationFee': (totalRevenue * 0.08).round(),
          'examFee': (totalRevenue * 0.04).round(),
          'extraClass': (totalRevenue * 0.03).round(),
        },
        'createdAt': now.toIso8601String(),
      });

      print(
        '  ✓ Added analytics for: ${_getMonthName(month.month)} ${month.year}',
      );
    }

    await batch.commit();
    print('📊 Successfully added analytics data for 6 months');
  }

  /// Helper function to calculate next payment date
  static String? _calculateNextPaymentDate(
    DateTime now,
    bool currentMonthPaid,
  ) {
    if (currentMonthPaid) {
      // Next month
      final nextMonth = DateTime(now.year, now.month + 1, 10);
      return nextMonth.toIso8601String();
    } else {
      // Current month (overdue)
      final thisMonth = DateTime(now.year, now.month, 10);
      return thisMonth.toIso8601String();
    }
  }

  /// Helper function to get month name
  static String _getMonthName(int month) {
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
