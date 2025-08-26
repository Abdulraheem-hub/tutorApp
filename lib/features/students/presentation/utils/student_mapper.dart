/// @context7:feature:students
/// @context7:dependencies:student_entity,student_entities
/// @context7:pattern:mapper_utility
///
/// Utility to convert between different student representations
library;

import '../../domain/entities/student_entity.dart';
import '../../domain/entities/student_entities.dart';

/// Utility class to convert between StudentEntity and Student models
class StudentMapper {
  /// Convert from Firebase StudentEntity to UI Student model
  static Student fromEntity(StudentEntity entity) {
    try {
      print('🔄 StudentMapper: Converting entity ${entity.id} - ${entity.name}');
      
      final student = Student(
        id: entity.id,
        name: entity.name,
        grade: Grade.grade8, // Default grade, should be properly mapped
        subjects: [
          Subject(id: '1', name: entity.subject, shortName: entity.subject),
        ],
        monthlyFee: entity.monthlyFee,
        paymentStatus: _calculatePaymentStatus(entity),
        nextPaymentDate: _calculateNextPaymentDate(entity),
        joinDate: entity.createdAt,
        isActive: entity.isActive,
        admissionNumber: null, // Not available in StudentEntity
        admissionDate: entity.createdAt, // Use creation date as admission date
        email: entity.email,
        phoneNumber: entity.phone,
        address: entity.address,
        outstandingBalance: entity.outstandingBalance,
        currentMonthPaid: entity.currentMonthPaid,
        paymentPeriod: entity.paymentPeriod,
        lastPaymentAmount: entity.lastPaymentAmount,
      );
      
      print('✅ StudentMapper: Successfully converted entity ${entity.id}');
      return student;
    } catch (e) {
      print('❌ StudentMapper: Error converting entity ${entity.id}: $e');
      rethrow;
    }
  }

  /// Calculate payment status based on StudentEntity data
  static PaymentStatus _calculatePaymentStatus(StudentEntity entity) {
    if (entity.currentMonthPaid && entity.outstandingBalance == 0) {
      return PaymentStatus.paid;
    } else if (entity.currentMonthPaid && entity.outstandingBalance > 0) {
      return PaymentStatus.pending; // Has outstanding balance
    } else if (entity.isPaymentOverdue) {
      return PaymentStatus.overdue;
    } else {
      return PaymentStatus.pending;
    }
  }

  /// Calculate next payment date based on payment period
  static DateTime? _calculateNextPaymentDate(StudentEntity entity) {
    if (entity.paymentPeriod == null) {
      // If no payment period set, assume next month from creation
      final now = DateTime.now();
      return DateTime(now.year, now.month + 1, entity.createdAt.day);
    }
    
    // Calculate next month from payment period
    final paymentPeriod = entity.paymentPeriod!;
    return DateTime(paymentPeriod.year, paymentPeriod.month + 1, paymentPeriod.day);
  }

  /// Convert from UI Student model to Firebase StudentEntity
  static StudentEntity toEntity(Student student) {
    return StudentEntity(
      id: student.id,
      name: student.name,
      subject: student.subjects.isNotEmpty ? student.subjects.first.name : '',
      monthlyFee: student.monthlyFee,
      email: student.email,
      phone: student.phoneNumber,
      address: student.address,
      notes: null,
      isActive: student.isActive,
      createdAt: student.joinDate,
      updatedAt: DateTime.now(),
      lastPaymentDate: null, // Will be set when payments are recorded
      totalHours: 0.0, // Will be calculated from tutoring sessions
      totalEarnings: 0.0, // Will be calculated from payments
      outstandingBalance: student.outstandingBalance,
      currentMonthPaid: student.currentMonthPaid,
      paymentPeriod: student.paymentPeriod,
      lastPaymentAmount: student.lastPaymentAmount,
    );
  }
}
