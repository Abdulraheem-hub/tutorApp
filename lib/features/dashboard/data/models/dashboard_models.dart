/// @context7:feature:dashboard
/// @context7:dependencies:dashboard_entities
/// @context7:pattern:data_model
/// 
/// Data models for dashboard feature with JSON serialization
library;

import '../../domain/entities/dashboard_entities.dart';
import '../../../../core/utils/app_utils.dart';

class DashboardDataModel extends DashboardData {
  const DashboardDataModel({
    required super.totalEarnings,
    required super.earningsChange,
    required super.activeStudents,
    required super.studentsChange,
    required super.pendingAmount,
    required super.pendingCount,
    required super.monthlyGoal,
    required super.goalProgress,
    required super.recentActivity,
  });

  factory DashboardDataModel.fromJson(Map<String, dynamic> json) {
    return DashboardDataModel(
      totalEarnings: (json['totalEarnings'] as num).toDouble(),
      earningsChange: (json['earningsChange'] as num).toDouble(),
      activeStudents: json['activeStudents'] as int,
      studentsChange: json['studentsChange'] as int,
      pendingAmount: (json['pendingAmount'] as num).toDouble(),
      pendingCount: json['pendingCount'] as int,
      monthlyGoal: (json['monthlyGoal'] as num).toDouble(),
      goalProgress: (json['goalProgress'] as num).toDouble(),
      recentActivity: (json['recentActivity'] as List)
          .map((activity) => StudentActivityModel.fromJson(activity))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalEarnings': totalEarnings,
      'earningsChange': earningsChange,
      'activeStudents': activeStudents,
      'studentsChange': studentsChange,
      'pendingAmount': pendingAmount,
      'pendingCount': pendingCount,
      'monthlyGoal': monthlyGoal,
      'goalProgress': goalProgress,
      'recentActivity': recentActivity
          .map((activity) => (activity as StudentActivityModel).toJson())
          .toList(),
    };
  }

  // Factory method to create from dummy data
  factory DashboardDataModel.fromDummyData() {
    final dummyData = AppUtils.generateDummyDashboardData();
    final activities = (dummyData['recentActivity'] as List)
        .map((activity) => StudentActivityModel.fromMap(activity))
        .toList();

    return DashboardDataModel(
      totalEarnings: dummyData['totalEarnings'],
      earningsChange: dummyData['earningsChange'],
      activeStudents: dummyData['activeStudents'],
      studentsChange: dummyData['studentsChange'],
      pendingAmount: dummyData['pendingAmount'],
      pendingCount: dummyData['pendingCount'],
      monthlyGoal: dummyData['monthlyGoal'],
      goalProgress: dummyData['goalProgress'],
      recentActivity: activities,
    );
  }
}

class StudentActivityModel extends StudentActivity {
  const StudentActivityModel({
    required super.id,
    required super.name,
    super.profileImage,
    required super.lastActivity,
    required super.amount,
    required super.status,
  });

  factory StudentActivityModel.fromJson(Map<String, dynamic> json) {
    return StudentActivityModel(
      id: json['id'] as String,
      name: json['name'] as String,
      profileImage: json['profileImage'] as String?,
      lastActivity: DateTime.parse(json['lastActivity'] as String),
      amount: (json['amount'] as num).toDouble(),
      status: ActivityStatus.values.firstWhere(
        (status) => status.name == json['status'],
        orElse: () => ActivityStatus.newStudent,
      ),
    );
  }

  factory StudentActivityModel.fromMap(Map<String, dynamic> map) {
    ActivityStatus status;
    switch (map['status'] as String) {
      case 'paid':
        status = ActivityStatus.paid;
        break;
      case 'pending':
        status = ActivityStatus.pending;
        break;
      case 'overdue':
        status = ActivityStatus.overdue;
        break;
      case 'new':
        status = ActivityStatus.newStudent;
        break;
      default:
        status = ActivityStatus.newStudent;
    }

    return StudentActivityModel(
      id: map['id'] as String,
      name: map['name'] as String,
      profileImage: map['profileImage'] as String?,
      lastActivity: map['lastPayment'] as DateTime,
      amount: (map['amount'] as num).toDouble(),
      status: status,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'profileImage': profileImage,
      'lastActivity': lastActivity.toIso8601String(),
      'amount': amount,
      'status': status.name,
    };
  }
}
