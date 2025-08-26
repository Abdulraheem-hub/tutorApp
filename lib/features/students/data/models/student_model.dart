/// @context7:feature:students
/// @context7:dependencies:cloud_firestore,student_entity
/// @context7:pattern:firestore_model
///
/// Firestore model for Student data with cloud sync capabilities
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/student_entity.dart';

/// Firestore model for Student with cloud synchronization
/// Handles conversion between Firestore documents and Student entities
class StudentModel extends StudentEntity {
  const StudentModel({
    required super.id,
    required super.name,
    required super.subject,
    required super.monthlyFee,
    super.email,
    super.phone,
    super.address,
    super.notes,
    required super.isActive,
    required super.createdAt,
    super.updatedAt,
    super.lastPaymentDate,
    super.totalHours,
    super.totalEarnings,
    super.outstandingBalance,
    super.currentMonthPaid,
    super.paymentPeriod,
    super.lastPaymentAmount,
  });

  /// Create StudentModel from Firestore DocumentSnapshot
  factory StudentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Handle both 'subject' (string) and 'subjects' (array) formats
    String subjectValue;
    if (data['subjects'] != null && data['subjects'] is List) {
      // Convert subjects array to string
      final subjectsList = data['subjects'] as List;
      subjectValue = subjectsList.join(' & ');
    } else {
      // Use existing subject field, with null safety
      subjectValue = data['subject'] as String? ?? '';
    }

    return StudentModel(
      id: doc.id,
      name: data['name'] as String? ?? 'Unknown Student',
      subject: subjectValue,
      monthlyFee:
          (data['monthlyFee'] as num?)?.toDouble() ??
          (data['hourlyRate'] as num?)?.toDouble() ??
          0.0,
      email: data['email'] as String?,
      phone: data['phone'] as String?,
      address: data['address'] as String?,
      notes: data['notes'] as String?,
      isActive: data['isActive'] as bool? ?? true,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
      lastPaymentDate: data['lastPaymentDate'] != null
          ? (data['lastPaymentDate'] as Timestamp).toDate()
          : null,
      totalHours: (data['totalHours'] as num?)?.toDouble() ?? 0.0,
      totalEarnings: (data['totalEarnings'] as num?)?.toDouble() ?? 0.0,
      outstandingBalance:
          (data['outstandingBalance'] as num?)?.toDouble() ?? 0.0,
      currentMonthPaid: data['currentMonthPaid'] as bool? ?? false,
      paymentPeriod: data['paymentPeriod'] != null
          ? (data['paymentPeriod'] as Timestamp).toDate()
          : null,
      lastPaymentAmount: (data['lastPaymentAmount'] as num?)?.toDouble(),
    );
  }

  /// Create StudentModel from JSON map
  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      id: json['id'] as String,
      name: json['name'] as String,
      subject: json['subject'] as String,
      monthlyFee:
          (json['monthlyFee'] as num?)?.toDouble() ??
          (json['hourlyRate'] as num?)?.toDouble() ??
          0.0,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      notes: json['notes'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      lastPaymentDate: json['lastPaymentDate'] != null
          ? DateTime.parse(json['lastPaymentDate'] as String)
          : null,
      totalHours: (json['totalHours'] as num?)?.toDouble() ?? 0.0,
      totalEarnings: (json['totalEarnings'] as num?)?.toDouble() ?? 0.0,
      outstandingBalance:
          (json['outstandingBalance'] as num?)?.toDouble() ?? 0.0,
      currentMonthPaid: json['currentMonthPaid'] as bool? ?? false,
      paymentPeriod: json['paymentPeriod'] != null
          ? DateTime.parse(json['paymentPeriod'] as String)
          : null,
      lastPaymentAmount: (json['lastPaymentAmount'] as num?)?.toDouble(),
    );
  }

  /// Convert StudentModel to Firestore-compatible map
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'subject': subject,
      'monthlyFee': monthlyFee,
      'email': email,
      'phone': phone,
      'address': address,
      'notes': notes,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'lastPaymentDate': lastPaymentDate != null
          ? Timestamp.fromDate(lastPaymentDate!)
          : null,
      'totalHours': totalHours,
      'totalEarnings': totalEarnings,
      'outstandingBalance': outstandingBalance,
      'currentMonthPaid': currentMonthPaid,
      'paymentPeriod': paymentPeriod != null
          ? Timestamp.fromDate(paymentPeriod!)
          : null,
      'lastPaymentAmount': lastPaymentAmount,
    };
  }

  /// Convert StudentModel to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'subject': subject,
      'monthlyFee': monthlyFee,
      'email': email,
      'phone': phone,
      'address': address,
      'notes': notes,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'lastPaymentDate': lastPaymentDate?.toIso8601String(),
      'totalHours': totalHours,
      'totalEarnings': totalEarnings,
      'outstandingBalance': outstandingBalance,
      'currentMonthPaid': currentMonthPaid,
      'paymentPeriod': paymentPeriod?.toIso8601String(),
      'lastPaymentAmount': lastPaymentAmount,
    };
  }

  /// Convert to StudentEntity
  StudentEntity toEntity() {
    return StudentEntity(
      id: id,
      name: name,
      subject: subject,
      monthlyFee: monthlyFee,
      email: email,
      phone: phone,
      address: address,
      notes: notes,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
      lastPaymentDate: lastPaymentDate,
      totalHours: totalHours,
      totalEarnings: totalEarnings,
      outstandingBalance: outstandingBalance,
      currentMonthPaid: currentMonthPaid,
      paymentPeriod: paymentPeriod,
      lastPaymentAmount: lastPaymentAmount,
    );
  }

  /// Create StudentModel from StudentEntity
  factory StudentModel.fromEntity(StudentEntity entity) {
    return StudentModel(
      id: entity.id,
      name: entity.name,
      subject: entity.subject,
      monthlyFee: entity.monthlyFee,
      email: entity.email,
      phone: entity.phone,
      address: entity.address,
      notes: entity.notes,
      isActive: entity.isActive,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      lastPaymentDate: entity.lastPaymentDate,
      totalHours: entity.totalHours,
      totalEarnings: entity.totalEarnings,
      outstandingBalance: entity.outstandingBalance,
      currentMonthPaid: entity.currentMonthPaid,
      paymentPeriod: entity.paymentPeriod,
      lastPaymentAmount: entity.lastPaymentAmount,
    );
  }

  @override
  StudentModel copyWith({
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
    return StudentModel(
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
}
