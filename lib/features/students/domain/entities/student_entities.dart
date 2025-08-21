/**
 * @context7:feature:students
 * @context7:dependencies:equatable
 * @context7:pattern:domain_entity
 * 
 * Domain entities for students feature
 */

import 'package:equatable/equatable.dart';

class Student extends Equatable {
  final String id;
  final String name;
  final String? profileImage;
  final Grade grade;
  final List<Subject> subjects;
  final double monthlyFee;
  final PaymentStatus paymentStatus;
  final DateTime? nextPaymentDate;
  final DateTime joinDate;
  final bool isActive;

  const Student({
    required this.id,
    required this.name,
    this.profileImage,
    required this.grade,
    required this.subjects,
    required this.monthlyFee,
    required this.paymentStatus,
    this.nextPaymentDate,
    required this.joinDate,
    this.isActive = true,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        profileImage,
        grade,
        subjects,
        monthlyFee,
        paymentStatus,
        nextPaymentDate,
        joinDate,
        isActive,
      ];
}

class Subject extends Equatable {
  final String id;
  final String name;
  final String? shortName;

  const Subject({
    required this.id,
    required this.name,
    this.shortName,
  });

  @override
  List<Object?> get props => [id, name, shortName];
}

enum Grade {
  grade1,
  grade2,
  grade3,
  grade4,
  grade5,
  grade6,
  grade7,
  grade8,
  grade9,
  grade10,
  grade11,
  grade12,
}

enum PaymentStatus {
  paid,
  pending,
  overdue,
  newStudent,
}

extension GradeExtension on Grade {
  String get displayName {
    switch (this) {
      case Grade.grade1:
        return 'Grade 1';
      case Grade.grade2:
        return 'Grade 2';
      case Grade.grade3:
        return 'Grade 3';
      case Grade.grade4:
        return 'Grade 4';
      case Grade.grade5:
        return 'Grade 5';
      case Grade.grade6:
        return 'Grade 6';
      case Grade.grade7:
        return 'Grade 7';
      case Grade.grade8:
        return 'Grade 8';
      case Grade.grade9:
        return 'Grade 9';
      case Grade.grade10:
        return 'Grade 10';
      case Grade.grade11:
        return 'Grade 11';
      case Grade.grade12:
        return 'Grade 12';
    }
  }

  String get category {
    switch (this) {
      case Grade.grade1:
      case Grade.grade2:
      case Grade.grade3:
      case Grade.grade4:
      case Grade.grade5:
        return 'Grade 1-5';
      case Grade.grade6:
      case Grade.grade7:
      case Grade.grade8:
      case Grade.grade9:
      case Grade.grade10:
        return 'Grade 6-10';
      case Grade.grade11:
      case Grade.grade12:
        return 'High School';
    }
  }
}

extension PaymentStatusExtension on PaymentStatus {
  String get displayName {
    switch (this) {
      case PaymentStatus.paid:
        return 'Paid';
      case PaymentStatus.pending:
        return 'Pending';
      case PaymentStatus.overdue:
        return 'Overdue';
      case PaymentStatus.newStudent:
        return 'New';
    }
  }

  String get colorKey {
    switch (this) {
      case PaymentStatus.paid:
        return 'success';
      case PaymentStatus.pending:
        return 'warning';
      case PaymentStatus.overdue:
        return 'error';
      case PaymentStatus.newStudent:
        return 'info';
    }
  }
}

class StudentsData extends Equatable {
  final List<Student> students;
  final int totalStudents;
  final double monthlyRevenue;
  final Map<PaymentStatus, int> statusCounts;

  const StudentsData({
    required this.students,
    required this.totalStudents,
    required this.monthlyRevenue,
    required this.statusCounts,
  });

  @override
  List<Object?> get props => [
        students,
        totalStudents,
        monthlyRevenue,
        statusCounts,
      ];
}