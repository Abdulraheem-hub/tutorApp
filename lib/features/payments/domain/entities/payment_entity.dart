/// @context7:feature:payments
/// @context7:dependencies:equatable
/// @context7:pattern:domain_entity
///
/// Payment entity representing payment data in the domain layer
library;

import 'package:equatable/equatable.dart';

/// Enum representing different payment statuses
enum PaymentStatus { pending, completed, failed, cancelled, refunded }

/// Enum representing different payment methods
enum PaymentMethod {
  cash,
  check,
  bankTransfer,
  creditCard,
  paypal,
  venmo,
  other,
}

/// Domain entity representing a payment transaction
/// Contains all payment-related business logic and data for monthly fee payments
class PaymentEntity extends Equatable {
  const PaymentEntity({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.amount,
    this.hours = 0.0,
    this.hourlyRate = 0.0,
    required this.method,
    this.status = PaymentStatus.pending,
    required this.date,
    this.description,
    this.notes,
    required this.createdAt,
    this.updatedAt,
    this.receiptUrl,
    this.transactionId,
    // New fields for monthly payment flow
    required this.monthlyFeeAtPayment,
    required this.paymentPeriod,
    this.shortfallAmount = 0.0,
    this.excessAmount = 0.0,
    this.outstandingBalanceBefore = 0.0,
    this.outstandingBalanceAfter = 0.0,
    this.isPartialPayment = false,
  });

  /// Unique identifier for the payment
  final String id;

  /// ID of the student this payment is for
  final String studentId;

  /// Name of the student (for easy display)
  final String studentName;

  /// Payment amount
  final double amount;

  /// Number of hours this payment covers
  final double hours;

  /// Hourly rate at the time of payment
  final double hourlyRate;

  /// Payment method used
  final PaymentMethod method;

  /// Current status of the payment
  final PaymentStatus status;

  /// Date when the payment was made/received
  final DateTime date;

  /// Description of what the payment is for
  final String? description;

  /// Additional notes about the payment
  final String? notes;

  /// When the payment record was created
  final DateTime createdAt;

  /// When the payment record was last updated
  final DateTime? updatedAt;

  /// URL to receipt or proof of payment
  final String? receiptUrl;

  /// External transaction ID (for digital payments)
  final String? transactionId;

  // Monthly payment flow fields
  /// Monthly fee amount at the time of payment
  final double monthlyFeeAtPayment;

  /// The period (month/year) this payment covers
  final DateTime paymentPeriod;

  /// Amount short of the expected payment
  final double shortfallAmount;

  /// Amount in excess of the expected payment
  final double excessAmount;

  /// Outstanding balance before this payment
  final double outstandingBalanceBefore;

  /// Outstanding balance after this payment
  final double outstandingBalanceAfter;

  /// Whether this is a partial payment (less than expected)
  final bool isPartialPayment;

  @override
  List<Object?> get props => [
    id,
    studentId,
    studentName,
    amount,
    hours,
    hourlyRate,
    method,
    status,
    date,
    description,
    notes,
    createdAt,
    updatedAt,
    receiptUrl,
    transactionId,
    monthlyFeeAtPayment,
    paymentPeriod,
    shortfallAmount,
    excessAmount,
    outstandingBalanceBefore,
    outstandingBalanceAfter,
    isPartialPayment,
  ];

  /// Create a copy of this payment with some properties updated
  PaymentEntity copyWith({
    String? id,
    String? studentId,
    String? studentName,
    double? amount,
    double? hours,
    double? hourlyRate,
    PaymentMethod? method,
    PaymentStatus? status,
    DateTime? date,
    String? description,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? receiptUrl,
    String? transactionId,
    double? monthlyFeeAtPayment,
    DateTime? paymentPeriod,
    double? shortfallAmount,
    double? excessAmount,
    double? outstandingBalanceBefore,
    double? outstandingBalanceAfter,
    bool? isPartialPayment,
  }) {
    return PaymentEntity(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      amount: amount ?? this.amount,
      hours: hours ?? this.hours,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      method: method ?? this.method,
      status: status ?? this.status,
      date: date ?? this.date,
      description: description ?? this.description,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      receiptUrl: receiptUrl ?? this.receiptUrl,
      transactionId: transactionId ?? this.transactionId,
      monthlyFeeAtPayment: monthlyFeeAtPayment ?? this.monthlyFeeAtPayment,
      paymentPeriod: paymentPeriod ?? this.paymentPeriod,
      shortfallAmount: shortfallAmount ?? this.shortfallAmount,
      excessAmount: excessAmount ?? this.excessAmount,
      outstandingBalanceBefore:
          outstandingBalanceBefore ?? this.outstandingBalanceBefore,
      outstandingBalanceAfter:
          outstandingBalanceAfter ?? this.outstandingBalanceAfter,
      isPartialPayment: isPartialPayment ?? this.isPartialPayment,
    );
  }

  /// Check if payment is completed
  bool get isCompleted => status == PaymentStatus.completed;

  /// Check if payment is pending
  bool get isPending => status == PaymentStatus.pending;

  /// Check if payment failed
  bool get isFailed => status == PaymentStatus.failed;

  /// Check if payment was cancelled
  bool get isCancelled => status == PaymentStatus.cancelled;

  /// Check if payment was refunded
  bool get isRefunded => status == PaymentStatus.refunded;

  /// Get formatted amount as string
  String get formattedAmount => '\$${amount.toStringAsFixed(2)}';

  /// Get formatted hourly rate as string
  String get formattedHourlyRate => '\$${hourlyRate.toStringAsFixed(2)}/hr';

  /// Get payment method display name
  String get methodDisplayName {
    switch (method) {
      case PaymentMethod.cash:
        return 'Cash';
      case PaymentMethod.check:
        return 'Check';
      case PaymentMethod.bankTransfer:
        return 'Bank Transfer';
      case PaymentMethod.creditCard:
        return 'Credit Card';
      case PaymentMethod.paypal:
        return 'PayPal';
      case PaymentMethod.venmo:
        return 'Venmo';
      case PaymentMethod.other:
        return 'Other';
    }
  }

  /// Get payment status display name
  String get statusDisplayName {
    switch (status) {
      case PaymentStatus.pending:
        return 'Pending';
      case PaymentStatus.completed:
        return 'Completed';
      case PaymentStatus.failed:
        return 'Failed';
      case PaymentStatus.cancelled:
        return 'Cancelled';
      case PaymentStatus.refunded:
        return 'Refunded';
    }
  }

  /// Validate if the calculated amount matches hours * hourlyRate
  bool get isAmountValid {
    final calculatedAmount = hours * hourlyRate;
    const tolerance = 0.01; // Allow for small floating point differences
    return (amount - calculatedAmount).abs() < tolerance;
  }

  /// Get formatted shortfall amount as string
  String get formattedShortfallAmount =>
      '\$${shortfallAmount.toStringAsFixed(2)}';

  /// Get formatted excess amount as string
  String get formattedExcessAmount => '\$${excessAmount.toStringAsFixed(2)}';

  /// Check if this payment covers the full monthly fee
  bool get coversFullMonthlyFee => amount >= monthlyFeeAtPayment;

  /// Get the effective amount that goes toward the monthly fee
  double get effectiveMonthlyAmount {
    final totalRequired = monthlyFeeAtPayment + outstandingBalanceBefore;
    return amount > totalRequired
        ? monthlyFeeAtPayment
        : (amount - outstandingBalanceBefore).clamp(0.0, monthlyFeeAtPayment);
  }

  /// Get payment coverage summary as string
  String get paymentCoverageSummary {
    if (isPartialPayment) {
      return 'Partial payment: \$${shortfallAmount.toStringAsFixed(2)} due';
    } else if (excessAmount > 0) {
      return 'Overpayment: \$${excessAmount.toStringAsFixed(2)} credit';
    } else {
      return 'Full payment';
    }
  }

  @override
  String toString() {
    return 'PaymentEntity(id: $id, studentName: $studentName, amount: $formattedAmount, status: $statusDisplayName)';
  }
}
