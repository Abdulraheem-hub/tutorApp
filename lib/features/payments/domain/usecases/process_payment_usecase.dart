/// @context7:feature:payments
/// @context7:dependencies:payment_entity,student_entity
/// @context7:pattern:usecase
///
/// Use case for processing monthly payments with partial payment logic
library;

import 'package:equatable/equatable.dart';
import '../entities/payment_entity.dart';
import '../../../students/domain/entities/student_entity.dart';

/// Use case for processing a payment with proper monthly fee logic
class ProcessPaymentUseCase {
  /// Process a payment and calculate the resulting balances and status
  PaymentProcessingResult processPayment({
    required StudentEntity student,
    required double paymentAmount,
    required PaymentMethod paymentMethod,
    required DateTime paymentDate,
    String? description,
    String? notes,
  }) {
    final now = DateTime.now();
    final paymentPeriod = DateTime(paymentDate.year, paymentDate.month, 1);

    // Calculate payment breakdown
    final outstandingBefore = student.outstandingBalance;
    final monthlyFee = student.monthlyFee;
    final totalRequired = monthlyFee + outstandingBefore;

    // Determine payment distribution
    double amountForOutstanding = 0.0;
    double amountForMonthlyFee = 0.0;
    double excessAmount = 0.0;
    double shortfallAmount = 0.0;
    bool isPartialPayment = false;
    bool currentMonthPaid = false;

    if (paymentAmount == 0.0) {
      // Zero payment - current month not paid, full monthly fee becomes outstanding
      shortfallAmount = monthlyFee;
      isPartialPayment = true;
      currentMonthPaid = false;
    } else if (paymentAmount < monthlyFee && outstandingBefore == 0.0) {
      // Partial payment with no outstanding - current month is paid, shortfall goes to next month
      amountForMonthlyFee = paymentAmount;
      shortfallAmount = monthlyFee - paymentAmount;
      isPartialPayment = true;
      currentMonthPaid =
          true; // As per requirement: current month is paid even if partial
    } else if (paymentAmount < monthlyFee && outstandingBefore > 0.0) {
      // Partial payment with outstanding - payment reduces outstanding, current month not paid
      amountForOutstanding = paymentAmount;
      shortfallAmount = monthlyFee; // Full monthly fee becomes outstanding
      isPartialPayment = true;
      currentMonthPaid = false;
    } else if (paymentAmount >= monthlyFee && paymentAmount < totalRequired) {
      // Payment covers monthly fee but not full outstanding balance
      // Apply to outstanding first, then to monthly fee
      amountForOutstanding = outstandingBefore;
      amountForMonthlyFee = paymentAmount - outstandingBefore;
      shortfallAmount = monthlyFee - amountForMonthlyFee;
      isPartialPayment = true;
      currentMonthPaid =
          amountForMonthlyFee >=
          monthlyFee; // Only if full monthly fee is covered
    } else if (paymentAmount == totalRequired) {
      // Exact payment for outstanding + monthly fee
      amountForOutstanding = outstandingBefore;
      amountForMonthlyFee = monthlyFee;
      currentMonthPaid = true;
    } else {
      // Overpayment
      amountForOutstanding = outstandingBefore;
      amountForMonthlyFee = monthlyFee;
      excessAmount = paymentAmount - totalRequired;
      currentMonthPaid = true;
    }

    // Calculate new outstanding balance
    // Outstanding = previous outstanding - amount applied to outstanding + any shortfall from monthly fee
    final newOutstandingBalance =
        (outstandingBefore - amountForOutstanding + shortfallAmount).clamp(
          0.0,
          double.infinity,
        );

    // Create payment entity
    final payment = PaymentEntity(
      id: _generatePaymentId(),
      studentId: student.id,
      studentName: student.name,
      amount: paymentAmount,
      hours: 0.0, // Not used for monthly payments
      hourlyRate: 0.0, // Not used for monthly payments
      method: paymentMethod,
      status: PaymentStatus.completed,
      date: paymentDate,
      description: description ?? 'Monthly Fee Payment',
      notes: notes,
      createdAt: now,
      monthlyFeeAtPayment: monthlyFee,
      paymentPeriod: paymentPeriod,
      shortfallAmount: shortfallAmount,
      excessAmount: excessAmount,
      outstandingBalanceBefore: outstandingBefore,
      outstandingBalanceAfter: newOutstandingBalance,
      isPartialPayment: isPartialPayment,
    );

    // Create updated student entity
    final updatedStudent = student.copyWith(
      outstandingBalance: newOutstandingBalance,
      currentMonthPaid: currentMonthPaid,
      paymentPeriod: paymentPeriod,
      lastPaymentAmount: paymentAmount,
      lastPaymentDate: paymentDate,
      totalEarnings: student.totalEarnings + paymentAmount,
      updatedAt: now,
    );

    return PaymentProcessingResult(
      payment: payment,
      updatedStudent: updatedStudent,
      amountForOutstanding: amountForOutstanding,
      amountForMonthlyFee: amountForMonthlyFee,
      isCurrentMonthPaid: currentMonthPaid,
    );
  }

  String _generatePaymentId() {
    return 'pay_${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecond}';
  }
}

/// Result of payment processing
class PaymentProcessingResult extends Equatable {
  final PaymentEntity payment;
  final StudentEntity updatedStudent;
  final double amountForOutstanding;
  final double amountForMonthlyFee;
  final bool isCurrentMonthPaid;

  const PaymentProcessingResult({
    required this.payment,
    required this.updatedStudent,
    required this.amountForOutstanding,
    required this.amountForMonthlyFee,
    required this.isCurrentMonthPaid,
  });

  @override
  List<Object?> get props => [
    payment,
    updatedStudent,
    amountForOutstanding,
    amountForMonthlyFee,
    isCurrentMonthPaid,
  ];

  /// Get summary of payment processing
  String get processingSummary {
    if (payment.isPartialPayment) {
      return 'Partial payment of ${payment.formattedAmount}. '
          '${payment.formattedShortfallAmount} will be added to next month.';
    } else if (payment.excessAmount > 0) {
      return 'Payment of ${payment.formattedAmount} received. '
          '${payment.formattedExcessAmount} credit applied to outstanding balance.';
    } else {
      return 'Full payment of ${payment.formattedAmount} received for current month.';
    }
  }
}
