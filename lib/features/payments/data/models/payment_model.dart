/// @context7:feature:payments
/// @context7:dependencies:cloud_firestore,payment_entity
/// @context7:pattern:firestore_model
///
/// Firestore model for Payment data with cloud sync capabilities
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/payment_entity.dart';

/// Extension to convert PaymentStatus enum to/from string
extension PaymentStatusExtension on PaymentStatus {
  String toFirestoreString() {
    return toString().split('.').last;
  }

  static PaymentStatus fromFirestoreString(String value) {
    return PaymentStatus.values.firstWhere(
      (status) => status.toString().split('.').last == value,
      orElse: () => PaymentStatus.pending,
    );
  }
}

/// Extension to convert PaymentMethod enum to/from string
extension PaymentMethodExtension on PaymentMethod {
  String toFirestoreString() {
    return toString().split('.').last;
  }

  static PaymentMethod fromFirestoreString(String value) {
    return PaymentMethod.values.firstWhere(
      (method) => method.toString().split('.').last == value,
      orElse: () => PaymentMethod.cash,
    );
  }
}

/// Firestore model for Payment with cloud synchronization
/// Handles conversion between Firestore documents and Payment entities
class PaymentModel extends PaymentEntity {
  const PaymentModel({
    required super.id,
    required super.studentId,
    required super.studentName,
    required super.amount,
    super.hours = 0.0,
    super.hourlyRate = 0.0,
    required super.method,
    super.status = PaymentStatus.pending,
    required super.date,
    super.description,
    super.notes,
    required super.createdAt,
    super.updatedAt,
    super.receiptUrl,
    super.transactionId,
    // New monthly payment flow fields
    required super.monthlyFeeAtPayment,
    required super.paymentPeriod,
    super.shortfallAmount = 0.0,
    super.excessAmount = 0.0,
    super.outstandingBalanceBefore = 0.0,
    super.outstandingBalanceAfter = 0.0,
    super.isPartialPayment = false,
  });

  /// Create PaymentModel from Firestore DocumentSnapshot
  factory PaymentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return PaymentModel(
      id: doc.id,
      studentId: data['studentId'] as String,
      studentName: data['studentName'] as String,
      amount: (data['amount'] as num).toDouble(),
      hours: (data['hours'] as num?)?.toDouble() ?? 0.0,
      hourlyRate: (data['hourlyRate'] as num?)?.toDouble() ?? 0.0,
      method: PaymentMethodExtension.fromFirestoreString(
        data['method'] as String,
      ),
      status: PaymentStatusExtension.fromFirestoreString(
        data['status'] as String,
      ),
      date: (data['date'] as Timestamp).toDate(),
      description: data['description'] as String?,
      notes: data['notes'] as String?,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
      receiptUrl: data['receiptUrl'] as String?,
      transactionId: data['transactionId'] as String?,
      // New monthly payment flow fields
      monthlyFeeAtPayment:
          (data['monthlyFeeAtPayment'] as num?)?.toDouble() ?? 0.0,
      paymentPeriod: data['paymentPeriod'] != null
          ? (data['paymentPeriod'] as Timestamp).toDate()
          : DateTime.now(),
      shortfallAmount: (data['shortfallAmount'] as num?)?.toDouble() ?? 0.0,
      excessAmount: (data['excessAmount'] as num?)?.toDouble() ?? 0.0,
      outstandingBalanceBefore:
          (data['outstandingBalanceBefore'] as num?)?.toDouble() ?? 0.0,
      outstandingBalanceAfter:
          (data['outstandingBalanceAfter'] as num?)?.toDouble() ?? 0.0,
      isPartialPayment: data['isPartialPayment'] as bool? ?? false,
    );
  }

  /// Create PaymentModel from JSON map
  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'] as String,
      studentId: json['studentId'] as String,
      studentName: json['studentName'] as String,
      amount: (json['amount'] as num).toDouble(),
      hours: (json['hours'] as num?)?.toDouble() ?? 0.0,
      hourlyRate: (json['hourlyRate'] as num?)?.toDouble() ?? 0.0,
      method: PaymentMethodExtension.fromFirestoreString(
        json['method'] as String,
      ),
      status: PaymentStatusExtension.fromFirestoreString(
        json['status'] as String,
      ),
      date: DateTime.parse(json['date'] as String),
      description: json['description'] as String?,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      receiptUrl: json['receiptUrl'] as String?,
      transactionId: json['transactionId'] as String?,
      // New monthly payment flow fields
      monthlyFeeAtPayment:
          (json['monthlyFeeAtPayment'] as num?)?.toDouble() ?? 0.0,
      paymentPeriod: json['paymentPeriod'] != null
          ? DateTime.parse(json['paymentPeriod'] as String)
          : DateTime.now(),
      shortfallAmount: (json['shortfallAmount'] as num?)?.toDouble() ?? 0.0,
      excessAmount: (json['excessAmount'] as num?)?.toDouble() ?? 0.0,
      outstandingBalanceBefore:
          (json['outstandingBalanceBefore'] as num?)?.toDouble() ?? 0.0,
      outstandingBalanceAfter:
          (json['outstandingBalanceAfter'] as num?)?.toDouble() ?? 0.0,
      isPartialPayment: json['isPartialPayment'] as bool? ?? false,
    );
  }

  /// Convert PaymentModel to Firestore-compatible map
  Map<String, dynamic> toFirestore() {
    return {
      'studentId': studentId,
      'studentName': studentName,
      'amount': amount,
      'hours': hours,
      'hourlyRate': hourlyRate,
      'method': method.toFirestoreString(),
      'status': status.toFirestoreString(),
      'date': Timestamp.fromDate(date),
      'description': description,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'receiptUrl': receiptUrl,
      'transactionId': transactionId,
      // New monthly payment flow fields
      'monthlyFeeAtPayment': monthlyFeeAtPayment,
      'paymentPeriod': Timestamp.fromDate(paymentPeriod),
      'shortfallAmount': shortfallAmount,
      'excessAmount': excessAmount,
      'outstandingBalanceBefore': outstandingBalanceBefore,
      'outstandingBalanceAfter': outstandingBalanceAfter,
      'isPartialPayment': isPartialPayment,
    };
  }

  /// Convert PaymentModel to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studentId': studentId,
      'studentName': studentName,
      'amount': amount,
      'hours': hours,
      'hourlyRate': hourlyRate,
      'method': method.toFirestoreString(),
      'status': status.toFirestoreString(),
      'date': date.toIso8601String(),
      'description': description,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'receiptUrl': receiptUrl,
      'transactionId': transactionId,
      // New monthly payment flow fields
      'monthlyFeeAtPayment': monthlyFeeAtPayment,
      'paymentPeriod': paymentPeriod.toIso8601String(),
      'shortfallAmount': shortfallAmount,
      'excessAmount': excessAmount,
      'outstandingBalanceBefore': outstandingBalanceBefore,
      'outstandingBalanceAfter': outstandingBalanceAfter,
      'isPartialPayment': isPartialPayment,
    };
  }

  /// Convert to PaymentEntity
  PaymentEntity toEntity() {
    return PaymentEntity(
      id: id,
      studentId: studentId,
      studentName: studentName,
      amount: amount,
      hours: hours,
      hourlyRate: hourlyRate,
      method: method,
      status: status,
      date: date,
      description: description,
      notes: notes,
      createdAt: createdAt,
      updatedAt: updatedAt,
      receiptUrl: receiptUrl,
      transactionId: transactionId,
      // New monthly payment flow fields
      monthlyFeeAtPayment: monthlyFeeAtPayment,
      paymentPeriod: paymentPeriod,
      shortfallAmount: shortfallAmount,
      excessAmount: excessAmount,
      outstandingBalanceBefore: outstandingBalanceBefore,
      outstandingBalanceAfter: outstandingBalanceAfter,
      isPartialPayment: isPartialPayment,
    );
  }

  /// Create PaymentModel from PaymentEntity
  factory PaymentModel.fromEntity(PaymentEntity entity) {
    return PaymentModel(
      id: entity.id,
      studentId: entity.studentId,
      studentName: entity.studentName,
      amount: entity.amount,
      hours: entity.hours,
      hourlyRate: entity.hourlyRate,
      method: entity.method,
      status: entity.status,
      date: entity.date,
      description: entity.description,
      notes: entity.notes,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      receiptUrl: entity.receiptUrl,
      transactionId: entity.transactionId,
      // New monthly payment flow fields
      monthlyFeeAtPayment: entity.monthlyFeeAtPayment,
      paymentPeriod: entity.paymentPeriod,
      shortfallAmount: entity.shortfallAmount,
      excessAmount: entity.excessAmount,
      outstandingBalanceBefore: entity.outstandingBalanceBefore,
      outstandingBalanceAfter: entity.outstandingBalanceAfter,
      isPartialPayment: entity.isPartialPayment,
    );
  }

  @override
  PaymentModel copyWith({
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
    // New monthly payment flow fields
    double? monthlyFeeAtPayment,
    DateTime? paymentPeriod,
    double? shortfallAmount,
    double? excessAmount,
    double? outstandingBalanceBefore,
    double? outstandingBalanceAfter,
    bool? isPartialPayment,
  }) {
    return PaymentModel(
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
      // New monthly payment flow fields
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
}
