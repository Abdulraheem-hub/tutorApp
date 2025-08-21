/**
 * @context7:feature:dashboard
 * @context7:dependencies:equatable
 * @context7:pattern:domain_entity
 * 
 * Domain entities for dashboard feature
 */

import 'package:equatable/equatable.dart';

class DashboardData extends Equatable {
  final double totalEarnings;
  final double earningsChange; // percentage
  final int activeStudents;
  final int studentsChange;
  final double pendingAmount;
  final int pendingCount;
  final double monthlyGoal;
  final double goalProgress; // 0.0 to 1.0
  final List<StudentActivity> recentActivity;

  const DashboardData({
    required this.totalEarnings,
    required this.earningsChange,
    required this.activeStudents,
    required this.studentsChange,
    required this.pendingAmount,
    required this.pendingCount,
    required this.monthlyGoal,
    required this.goalProgress,
    required this.recentActivity,
  });

  @override
  List<Object?> get props => [
        totalEarnings,
        earningsChange,
        activeStudents,
        studentsChange,
        pendingAmount,
        pendingCount,
        monthlyGoal,
        goalProgress,
        recentActivity,
      ];
}

class StudentActivity extends Equatable {
  final String id;
  final String name;
  final String? profileImage;
  final DateTime lastActivity;
  final double amount;
  final ActivityStatus status;

  const StudentActivity({
    required this.id,
    required this.name,
    this.profileImage,
    required this.lastActivity,
    required this.amount,
    required this.status,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        profileImage,
        lastActivity,
        amount,
        status,
      ];
}

enum ActivityStatus {
  paid,
  pending,
  overdue,
  newStudent,
}

extension ActivityStatusExtension on ActivityStatus {
  String get displayName {
    switch (this) {
      case ActivityStatus.paid:
        return 'Payment received';
      case ActivityStatus.pending:
        return 'Payment pending';
      case ActivityStatus.overdue:
        return 'Payment overdue';
      case ActivityStatus.newStudent:
        return 'New student added';
    }
  }
  
  String get colorKey {
    switch (this) {
      case ActivityStatus.paid:
        return 'success';
      case ActivityStatus.pending:
        return 'warning';
      case ActivityStatus.overdue:
        return 'error';
      case ActivityStatus.newStudent:
        return 'info';
    }
  }
}
