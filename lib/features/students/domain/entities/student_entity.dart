/// @context7:feature:students
/// @context7:dependencies:equatable
/// @context7:pattern:domain_entity
///
/// Student entity representing student data in the domain layer
library;

import 'package:equatable/equatable.dart';

/// Domain entity representing a student in the tutoring system
/// Contains all student-related business logic and data
class StudentEntity extends Equatable {
  const StudentEntity({
    required this.id,
    required this.name,
    required this.subject,
    required this.monthlyFee,
    this.email,
    this.phone,
    this.address,
    this.notes,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
    this.lastPaymentDate,
    this.totalHours = 0.0,
    this.totalEarnings = 0.0,
    this.outstandingBalance = 0.0,
    this.currentMonthPaid = false,
    this.paymentPeriod,
    this.lastPaymentAmount,
  });

  /// Unique identifier for the student
  final String id;

  /// Student's full name
  final String name;

  /// Subject being tutored
  final String subject;

  /// Monthly fee for tutoring sessions
  final double monthlyFee;

  /// Student's email address (optional)
  final String? email;

  /// Student's phone number (optional)
  final String? phone;

  /// Student's address (optional)
  final String? address;

  /// Additional notes about the student
  final String? notes;

  /// Whether the student is currently active
  final bool isActive;

  /// When the student record was created
  final DateTime createdAt;

  /// When the student record was last updated
  final DateTime? updatedAt;

  /// Date of the last payment received
  final DateTime? lastPaymentDate;

  /// Total hours tutored for this student
  final double totalHours;

  /// Total earnings from this student
  final double totalEarnings;

  /// Outstanding balance due to partial payments
  final double outstandingBalance;

  /// Whether the current month is considered paid
  final bool currentMonthPaid;

  /// The period (month/year) that the last payment covered
  final DateTime? paymentPeriod;

  /// Amount of the last payment received
  final double? lastPaymentAmount;

  @override
  List<Object?> get props => [
    id,
    name,
    subject,
    monthlyFee,
    email,
    phone,
    address,
    notes,
    isActive,
    createdAt,
    updatedAt,
    lastPaymentDate,
    totalHours,
    totalEarnings,
    outstandingBalance,
    currentMonthPaid,
    paymentPeriod,
    lastPaymentAmount,
  ];

  /// Create a copy of this student with some properties updated
  StudentEntity copyWith({
    String? id,
    String? name,
    String? subject,
    double? monthlyFee,
    String? email,
    String? phone,
    String? address,
    String? notes,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastPaymentDate,
    double? totalHours,
    double? totalEarnings,
    double? outstandingBalance,
    bool? currentMonthPaid,
    DateTime? paymentPeriod,
    double? lastPaymentAmount,
  }) {
    return StudentEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      subject: subject ?? this.subject,
      monthlyFee: monthlyFee ?? this.monthlyFee,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastPaymentDate: lastPaymentDate ?? this.lastPaymentDate,
      totalHours: totalHours ?? this.totalHours,
      totalEarnings: totalEarnings ?? this.totalEarnings,
      outstandingBalance: outstandingBalance ?? this.outstandingBalance,
      currentMonthPaid: currentMonthPaid ?? this.currentMonthPaid,
      paymentPeriod: paymentPeriod ?? this.paymentPeriod,
      lastPaymentAmount: lastPaymentAmount ?? this.lastPaymentAmount,
    );
  }

  /// Calculate potential earnings for given hours
  double calculateEarnings(double hours) {
    return hours * monthlyFee;
  }

  /// Check if student has recent activity (payment within last 30 days)
  bool get hasRecentActivity {
    if (lastPaymentDate == null) return false;
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    return lastPaymentDate!.isAfter(thirtyDaysAgo);
  }

  /// Get display name for the student
  String get displayName => name;

  /// Get formatted monthly fee as string
  String get formattedMonthlyFee => '\$${monthlyFee.toStringAsFixed(2)}/month';

  /// Get formatted total earnings as string
  String get formattedTotalEarnings => '\$${totalEarnings.toStringAsFixed(2)}';

  /// Get formatted outstanding balance as string
  String get formattedOutstandingBalance =>
      '\$${outstandingBalance.toStringAsFixed(2)}';

  /// Check if student has any outstanding balance
  bool get hasOutstandingBalance => outstandingBalance > 0;

  /// Get total amount due for current month (monthly fee + outstanding balance)
  double get totalAmountDue => monthlyFee + outstandingBalance;

  /// Get formatted total amount due as string
  String get formattedTotalAmountDue =>
      '\$${totalAmountDue.toStringAsFixed(2)}';

  /// Calculate payment status based on current month payment and outstanding balance
  String get calculatedPaymentStatus {
    if (currentMonthPaid && outstandingBalance == 0) return 'Paid';
    if (currentMonthPaid && outstandingBalance > 0) return 'Paid (Due Balance)';
    if (!currentMonthPaid && outstandingBalance > 0) return 'Overdue';
    return 'Pending';
  }

  /// Check if payment is overdue (considering next payment date)
  bool get isPaymentOverdue {
    if (paymentPeriod == null) return false;
    final now = DateTime.now();
    final nextDueDate = DateTime(
      paymentPeriod!.year,
      paymentPeriod!.month + 1,
      paymentPeriod!.day,
    );
    return now.isAfter(nextDueDate) && !currentMonthPaid;
  }

  @override
  String toString() {
    return 'StudentEntity(id: $id, name: $name, subject: $subject, monthlyFee: $monthlyFee, isActive: $isActive)';
  }
}
