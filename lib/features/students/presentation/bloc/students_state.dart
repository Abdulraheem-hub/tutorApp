/// @context7:feature:students
/// @context7:dependencies:equatable,student_entity
/// @context7:pattern:bloc_states
///
/// States for the Students BLoC
library;

import 'package:equatable/equatable.dart';
import '../../domain/entities/student_entity.dart';

/// Base class for all Students BLoC states
abstract class StudentsState extends Equatable {
  const StudentsState();

  @override
  List<Object?> get props => [];
}

/// Initial state when BLoC is first created
class StudentsInitial extends StudentsState {
  const StudentsInitial();
}

/// State when students are being loaded
class StudentsLoading extends StudentsState {
  const StudentsLoading();
}

/// State when students are successfully loaded
class StudentsLoaded extends StudentsState {
  final List<StudentEntity> students;
  final List<StudentEntity> filteredStudents;
  final String currentFilter;
  final String searchQuery;

  const StudentsLoaded({
    required this.students,
    required this.filteredStudents,
    this.currentFilter = 'all',
    this.searchQuery = '',
  });

  @override
  List<Object?> get props => [
    students,
    filteredStudents,
    currentFilter,
    searchQuery,
  ];

  /// Create a copy of this state with updated properties
  StudentsLoaded copyWith({
    List<StudentEntity>? students,
    List<StudentEntity>? filteredStudents,
    String? currentFilter,
    String? searchQuery,
  }) {
    return StudentsLoaded(
      students: students ?? this.students,
      filteredStudents: filteredStudents ?? this.filteredStudents,
      currentFilter: currentFilter ?? this.currentFilter,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

/// State when loading fails
class StudentsError extends StudentsState {
  final String message;
  final String? errorCode;

  const StudentsError({required this.message, this.errorCode});

  @override
  List<Object?> get props => [message, errorCode];
}

/// State when a student operation is in progress
class StudentOperationInProgress extends StudentsState {
  final String operation; // 'adding', 'updating', 'deleting', etc.

  const StudentOperationInProgress(this.operation);

  @override
  List<Object?> get props => [operation];
}

/// State when a student operation succeeds
class StudentOperationSuccess extends StudentsState {
  final String operation;
  final String message;
  final StudentEntity? student; // For operations that return a student

  const StudentOperationSuccess({
    required this.operation,
    required this.message,
    this.student,
  });

  @override
  List<Object?> get props => [operation, message, student];
}

/// State when a student operation fails
class StudentOperationFailure extends StudentsState {
  final String operation;
  final String message;
  final String? errorCode;

  const StudentOperationFailure({
    required this.operation,
    required this.message,
    this.errorCode,
  });

  @override
  List<Object?> get props => [operation, message, errorCode];
}

/// State when a specific student is loaded
class StudentLoaded extends StudentsState {
  final StudentEntity student;

  const StudentLoaded(this.student);

  @override
  List<Object?> get props => [student];
}

/// State when no students are found
class StudentsEmpty extends StudentsState {
  const StudentsEmpty();
}
