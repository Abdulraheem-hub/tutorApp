/// @context7:feature:payments
/// @context7:dependencies:cloud_firestore,payment_entity,student_entity,firebase_service
/// @context7:pattern:repository_implementation
///
/// Firebase repository implementation for payment operations with payment flow logic
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/payment_entity.dart';
import '../../domain/usecases/process_payment_usecase.dart';
import '../../../students/domain/entities/student_entity.dart';
import '../../../../core/exceptions/exceptions.dart';
import '../../../../core/services/firebase_service.dart';

/// Firebase repository for payment operations including payment flow logic
class FirebasePaymentRepository {
  FirebasePaymentRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseService.instance.firestore;

  final FirebaseFirestore _firestore;

  /// Get current user ID from Firebase service
  String get _currentUserId => FirebaseService.instance.currentUserId;

  /// Process a payment with payment flow logic and store in Firebase
  Future<PaymentProcessingResult> processAndStorePayment({
    required StudentEntity student,
    required double paymentAmount,
    required PaymentMethod paymentMethod,
    required DateTime paymentDate,
    String? description,
    String? notes,
  }) async {
    try {
      // Use the payment processing logic
      final processPaymentUseCase = ProcessPaymentUseCase();
      final result = processPaymentUseCase.processPayment(
        student: student,
        paymentAmount: paymentAmount,
        paymentMethod: paymentMethod,
        paymentDate: paymentDate,
        description: description,
        notes: notes,
      );

      // Store payment and update student in Firebase using a batch operation
      final batch = _firestore.batch();

      // Add payment to payments collection
      final paymentRef = _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('payments')
          .doc(result.payment.id);

      batch.set(paymentRef, _paymentToFirestore(result.payment));

      // Update student document with new payment status and outstanding balance
      final studentRef = _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('students')
          .doc(student.id);

      batch.update(
        studentRef,
        _studentPaymentUpdateToFirestore(result.updatedStudent),
      );

      // Commit the batch operation
      await batch.commit();

      return result;
    } catch (e) {
      throw DataException(message: 'Failed to process and store payment: $e');
    }
  }

  /// Get payment history for a student
  Stream<List<PaymentEntity>> getStudentPayments(String studentId) {
    try {
      return _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('payments')
          .where('studentId', isEqualTo: studentId)
          .orderBy('date', descending: true)
          .snapshots()
          .map(
            (snapshot) => snapshot.docs
                .map((doc) => _paymentFromFirestore(doc.id, doc.data()))
                .toList(),
          );
    } catch (e) {
      throw DataException(message: 'Failed to get student payments: $e');
    }
  }

  /// Get all payments for the current user
  Stream<List<PaymentEntity>> getAllPayments() {
    try {
      return _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('payments')
          .orderBy('date', descending: true)
          .snapshots()
          .map(
            (snapshot) => snapshot.docs
                .map((doc) => _paymentFromFirestore(doc.id, doc.data()))
                .toList(),
          );
    } catch (e) {
      throw DataException(message: 'Failed to get all payments: $e');
    }
  }

  /// Get payment statistics for dashboard
  Future<Map<String, dynamic>> getPaymentStatistics() async {
    try {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);

      final snapshot = await _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('payments')
          .where('date', isGreaterThanOrEqualTo: startOfMonth.toIso8601String())
          .get();

      double totalAmount = 0.0;
      int totalPayments = snapshot.docs.length;
      double totalOutstanding = 0.0;
      int partialPayments = 0;

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final amount = (data['amount'] as num?)?.toDouble() ?? 0.0;
        final shortfall = (data['shortfallAmount'] as num?)?.toDouble() ?? 0.0;
        final isPartial = data['isPartialPayment'] as bool? ?? false;

        totalAmount += amount;
        totalOutstanding += shortfall;
        if (isPartial) partialPayments++;
      }

      return {
        'totalAmount': totalAmount,
        'totalPayments': totalPayments,
        'totalOutstanding': totalOutstanding,
        'partialPayments': partialPayments,
        'averagePayment': totalPayments > 0 ? totalAmount / totalPayments : 0.0,
      };
    } catch (e) {
      throw DataException(message: 'Failed to get payment statistics: $e');
    }
  }

  /// Get students with outstanding balances
  Future<List<Map<String, dynamic>>>
  getStudentsWithOutstandingBalances() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('students')
          .where('outstandingBalance', isGreaterThan: 0.0)
          .orderBy('outstandingBalance', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'name': data['name'] ?? 'Unknown',
          'outstandingBalance':
              (data['outstandingBalance'] as num?)?.toDouble() ?? 0.0,
          'monthlyFee': (data['monthlyFee'] as num?)?.toDouble() ?? 0.0,
          'currentMonthPaid': data['currentMonthPaid'] as bool? ?? false,
        };
      }).toList();
    } catch (e) {
      throw DataException(
        message: 'Failed to get students with outstanding balances: $e',
      );
    }
  }

  /// Update student payment status (for month rollover, etc.)
  Future<void> updateStudentPaymentStatus(
    String studentId, {
    bool? currentMonthPaid,
    DateTime? paymentPeriod,
  }) async {
    try {
      final updates = <String, dynamic>{};

      if (currentMonthPaid != null) {
        updates['currentMonthPaid'] = currentMonthPaid;
      }

      if (paymentPeriod != null) {
        updates['paymentPeriod'] = paymentPeriod.toIso8601String();
      }

      updates['updatedAt'] = DateTime.now().toIso8601String();

      await _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('students')
          .doc(studentId)
          .update(updates);
    } catch (e) {
      throw DataException(
        message: 'Failed to update student payment status: $e',
      );
    }
  }

  /// Convert PaymentEntity to Firestore document
  Map<String, dynamic> _paymentToFirestore(PaymentEntity payment) {
    return {
      'studentId': payment.studentId,
      'studentName': payment.studentName,
      'amount': payment.amount,
      'hours': payment.hours,
      'hourlyRate': payment.hourlyRate,
      'method': payment.method.name,
      'status': payment.status.name,
      'date': payment.date.toIso8601String(),
      'description': payment.description,
      'notes': payment.notes,
      'createdAt': payment.createdAt.toIso8601String(),
      'updatedAt': payment.updatedAt?.toIso8601String(),
      'receiptUrl': payment.receiptUrl,
      'transactionId': payment.transactionId,
      // Payment flow specific fields
      'monthlyFeeAtPayment': payment.monthlyFeeAtPayment,
      'paymentPeriod': payment.paymentPeriod.toIso8601String(),
      'shortfallAmount': payment.shortfallAmount,
      'excessAmount': payment.excessAmount,
      'outstandingBalanceBefore': payment.outstandingBalanceBefore,
      'outstandingBalanceAfter': payment.outstandingBalanceAfter,
      'isPartialPayment': payment.isPartialPayment,
    };
  }

  /// Convert Firestore document to PaymentEntity
  PaymentEntity _paymentFromFirestore(String id, Map<String, dynamic> data) {
    return PaymentEntity(
      id: id,
      studentId: data['studentId'] ?? '',
      studentName: data['studentName'] ?? '',
      amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
      hours: (data['hours'] as num?)?.toDouble() ?? 0.0,
      hourlyRate: (data['hourlyRate'] as num?)?.toDouble() ?? 0.0,
      method: PaymentMethod.values.firstWhere(
        (method) => method.name == data['method'],
        orElse: () => PaymentMethod.cash,
      ),
      status: PaymentStatus.values.firstWhere(
        (status) => status.name == data['status'],
        orElse: () => PaymentStatus.completed,
      ),
      date: DateTime.tryParse(data['date'] ?? '') ?? DateTime.now(),
      description: data['description'],
      notes: data['notes'],
      createdAt: DateTime.tryParse(data['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: data['updatedAt'] != null
          ? DateTime.tryParse(data['updatedAt'])
          : null,
      receiptUrl: data['receiptUrl'],
      transactionId: data['transactionId'],
      // Payment flow specific fields
      monthlyFeeAtPayment:
          (data['monthlyFeeAtPayment'] as num?)?.toDouble() ?? 0.0,
      paymentPeriod:
          DateTime.tryParse(data['paymentPeriod'] ?? '') ?? DateTime.now(),
      shortfallAmount: (data['shortfallAmount'] as num?)?.toDouble() ?? 0.0,
      excessAmount: (data['excessAmount'] as num?)?.toDouble() ?? 0.0,
      outstandingBalanceBefore:
          (data['outstandingBalanceBefore'] as num?)?.toDouble() ?? 0.0,
      outstandingBalanceAfter:
          (data['outstandingBalanceAfter'] as num?)?.toDouble() ?? 0.0,
      isPartialPayment: data['isPartialPayment'] as bool? ?? false,
    );
  }

  /// Convert StudentEntity payment updates to Firestore updates
  Map<String, dynamic> _studentPaymentUpdateToFirestore(StudentEntity student) {
    return {
      'outstandingBalance': student.outstandingBalance,
      'currentMonthPaid': student.currentMonthPaid,
      'paymentPeriod': student.paymentPeriod?.toIso8601String(),
      'lastPaymentAmount': student.lastPaymentAmount,
      'lastPaymentDate': student.lastPaymentDate?.toIso8601String(),
      'totalEarnings': student.totalEarnings,
      'updatedAt':
          student.updatedAt?.toIso8601String() ??
          DateTime.now().toIso8601String(),
    };
  }
}
