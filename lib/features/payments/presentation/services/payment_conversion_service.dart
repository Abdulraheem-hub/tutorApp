/// @context7:feature:payments
/// @context7:dependencies:payment_entity,cloud_firestore
/// @context7:pattern:conversion_service
///
/// Service to convert between Firestore payment data and PaymentEntity
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/payment_entity.dart';

/// Service to handle conversion between Firestore payment documents and PaymentEntity
class PaymentConversionService {
  /// Convert Firestore payment document to PaymentEntity
  static PaymentEntity fromFirestoreDocument(
    String paymentId,
    Map<String, dynamic> data,
  ) {
    // Parse payment date from various formats
    DateTime paymentDate = DateTime.now();
    final paymentDateField = data['paymentDate'] ?? data['date'];
    if (paymentDateField != null) {
      if (paymentDateField is Timestamp) {
        paymentDate = paymentDateField.toDate();
      } else if (paymentDateField is String) {
        paymentDate = DateTime.tryParse(paymentDateField) ?? DateTime.now();
      }
    }

    // Parse created date
    DateTime createdAt = DateTime.now();
    final createdAtField = data['createdAt'];
    if (createdAtField != null) {
      if (createdAtField is Timestamp) {
        createdAt = createdAtField.toDate();
      } else if (createdAtField is String) {
        createdAt = DateTime.tryParse(createdAtField) ?? DateTime.now();
      }
    }

    // Parse payment method
    PaymentMethod method = PaymentMethod.cash;
    final methodString = data['method'] as String?;
    if (methodString != null) {
      switch (methodString.toLowerCase()) {
        case 'cash':
          method = PaymentMethod.cash;
          break;
        case 'digitalwallet':
        case 'upi':
          method = PaymentMethod.paypal; // Using paypal as digital wallet
          break;
        case 'banktransfer':
        case 'bank_transfer':
          method = PaymentMethod.bankTransfer;
          break;
        case 'card':
        case 'creditcard':
        case 'credit_card':
          method = PaymentMethod.creditCard;
          break;
        default:
          method = PaymentMethod.other;
      }
    }

    // Calculate payment flow information based on available data
    final amount = (data['amount'] as num?)?.toDouble() ?? 0.0;

    // Determine monthly fee - use explicit value if available, otherwise estimate based on amount patterns
    double monthlyFee;
    final explicitMonthlyFee =
        (data['monthlyFee'] as num?)?.toDouble() ??
        (data['monthlyFeeAtPayment'] as num?)?.toDouble();

    if (explicitMonthlyFee != null) {
      monthlyFee = explicitMonthlyFee;
    } else {
      // If no explicit monthly fee, try to determine from the payment scenario
      // Look for clues in the data to determine if this is a partial payment
      final hasExplicitPartialFlag = data.containsKey('isPartialPayment');
      final explicitPartialPayment = data['isPartialPayment'] as bool?;

      if (hasExplicitPartialFlag && explicitPartialPayment == true) {
        // If explicitly marked as partial, estimate the full fee
        // Common tutoring fee patterns: round up to nearest 50 or 100
        if (amount < 500) {
          monthlyFee = ((amount / 50).ceil() * 50 + 50).toDouble();
        } else {
          monthlyFee = ((amount / 100).ceil() * 100 + 100).toDouble();
        }
      } else {
        // Default case: treat amount as the expected fee
        monthlyFee = amount;
      }
    }

    // Determine if this is a partial payment
    final isPartialPayment =
        data['isPartialPayment'] as bool? ?? (amount < monthlyFee);

    // Calculate payment flow details
    final shortfallAmount =
        (data['shortfallAmount'] as num?)?.toDouble() ??
        (isPartialPayment ? monthlyFee - amount : 0.0);

    final excessAmount =
        (data['excessAmount'] as num?)?.toDouble() ??
        (amount > monthlyFee ? amount - monthlyFee : 0.0);

    // Parse payment status and calculate based on payment details
    PaymentStatus status = PaymentStatus.completed;
    final statusString = data['status'] as String?;
    if (statusString != null) {
      switch (statusString.toLowerCase()) {
        case 'pending':
          status = PaymentStatus.pending;
          break;
        case 'failed':
          status = PaymentStatus.failed;
          break;
        case 'cancelled':
          status = PaymentStatus.cancelled;
          break;
        case 'refunded':
          status = PaymentStatus.refunded;
          break;
        case 'completed':
        case 'paid':
        default:
          // For completed payments, keep status as completed
          // The UI will determine if it's partial based on isPartialPayment
          status = PaymentStatus.completed;
      }
    } else {
      // No explicit status, calculate based on payment amount
      if (amount <= 0) {
        status = PaymentStatus.pending;
      } else {
        // All completed payments use completed status
        // The UI determines partial vs full based on isPartialPayment
        status = PaymentStatus.completed;
      }
    }

    // Parse payment period
    DateTime paymentPeriod = paymentDate;
    final paymentPeriodField = data['paymentPeriod'];
    if (paymentPeriodField != null) {
      if (paymentPeriodField is Timestamp) {
        paymentPeriod = paymentPeriodField.toDate();
      } else if (paymentPeriodField is String) {
        paymentPeriod = DateTime.tryParse(paymentPeriodField) ?? paymentDate;
      }
    }

    return PaymentEntity(
      id: paymentId,
      studentId: data['studentId'] as String? ?? '',
      studentName: data['studentName'] as String? ?? 'Unknown Student',
      amount: amount,
      hours: (data['hours'] as num?)?.toDouble() ?? 0.0,
      hourlyRate: (data['hourlyRate'] as num?)?.toDouble() ?? 0.0,
      method: method,
      status: status,
      date: paymentDate,
      description: data['description'] as String?,
      notes: data['notes'] as String?,
      createdAt: createdAt,
      updatedAt: null, // Can be parsed if needed
      receiptUrl: data['receiptUrl'] as String?,
      transactionId: data['transactionId'] as String?,
      // Payment flow specific fields
      monthlyFeeAtPayment: monthlyFee,
      paymentPeriod: paymentPeriod,
      shortfallAmount: shortfallAmount,
      excessAmount: excessAmount,
      outstandingBalanceBefore:
          (data['outstandingBalanceBefore'] as num?)?.toDouble() ?? 0.0,
      outstandingBalanceAfter:
          (data['outstandingBalanceAfter'] as num?)?.toDouble() ?? 0.0,
      isPartialPayment: isPartialPayment,
    );
  }

  /// Convert PaymentEntity back to Firestore document format
  static Map<String, dynamic> toFirestoreDocument(PaymentEntity payment) {
    return {
      'studentId': payment.studentId,
      'studentName': payment.studentName,
      'amount': payment.amount,
      'hours': payment.hours,
      'hourlyRate': payment.hourlyRate,
      'method': payment.method.name,
      'status': payment.status.name,
      'paymentDate': payment.date.toIso8601String(),
      'date': payment.date.toIso8601String(), // For compatibility
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

  /// Get display text for payment status
  static String getPaymentStatusDisplayText(PaymentEntity payment) {
    if (payment.isPartialPayment && payment.shortfallAmount > 0) {
      return 'Partial Payment';
    } else if (payment.excessAmount > 0) {
      return 'Overpayment';
    } else if (payment.status == PaymentStatus.completed) {
      return 'Paid';
    } else {
      return payment.status.name.toUpperCase();
    }
  }

  /// Get due amount for next month (shortfall from current payment)
  static double getDueAmountNextMonth(PaymentEntity payment) {
    return payment.shortfallAmount;
  }

  /// Check if payment has outstanding balance
  static bool hasOutstandingBalance(PaymentEntity payment) {
    return payment.outstandingBalanceAfter > 0;
  }

  /// Get readable payment method name
  static String getPaymentMethodDisplayName(PaymentMethod method) {
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
        return 'Digital Wallet';
      case PaymentMethod.venmo:
        return 'Venmo';
      case PaymentMethod.other:
        return 'Other';
    }
  }
}
