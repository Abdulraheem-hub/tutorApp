/// @context7:feature:students
/// @context7:dependencies:flutter_bloc,equatable,student_entity
/// @context7:pattern:bloc_events
///
/// Events for the Students BLoC
library;

import 'package:equatable/equatable.dart';
import '../../domain/entities/student_entity.dart';

/// Base class for all Students BLoC events
abstract class StudentsEvent extends Equatable {
  const StudentsEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load all students
class LoadStudents extends StudentsEvent {
  const LoadStudents();
}

/// Event to search students
class SearchStudents extends StudentsEvent {
  final String query;

  const SearchStudents(this.query);

  @override
  List<Object?> get props => [query];
}

/// Event to filter students
class FilterStudents extends StudentsEvent {
  final String filter; // 'all', 'active', 'inactive', 'archived'

  const FilterStudents(this.filter);

  @override
  List<Object?> get props => [filter];
}

/// Event to add a new student
class AddStudent extends StudentsEvent {
  final StudentEntity student;

  const AddStudent(this.student);

  @override
  List<Object?> get props => [student];
}

/// Event to update an existing student
class UpdateStudent extends StudentsEvent {
  final StudentEntity student;

  const UpdateStudent(this.student);

  @override
  List<Object?> get props => [student];
}

/// Event to delete a student
class DeleteStudent extends StudentsEvent {
  final String studentId;

  const DeleteStudent(this.studentId);

  @override
  List<Object?> get props => [studentId];
}

/// Event to load a student by ID
class LoadStudentById extends StudentsEvent {
  final String studentId;

  const LoadStudentById(this.studentId);

  @override
  List<Object?> get props => [studentId];
}

/// Event to refresh students list
class RefreshStudents extends StudentsEvent {
  const RefreshStudents();
}

/// Event to archive a student (soft delete)
class ArchiveStudent extends StudentsEvent {
  final String studentId;

  const ArchiveStudent(this.studentId);

  @override
  List<Object?> get props => [studentId];
}

/// Event to restore an archived student
class RestoreStudent extends StudentsEvent {
  final String studentId;

  const RestoreStudent(this.studentId);

  @override
  List<Object?> get props => [studentId];
}

/// Event to bulk delete students
class BulkDeleteStudents extends StudentsEvent {
  final List<String> studentIds;

  const BulkDeleteStudents(this.studentIds);

  @override
  List<Object?> get props => [studentIds];
}

/// Event to update student statistics
class UpdateStudentStats extends StudentsEvent {
  final String studentId;
  final double additionalHours;
  final double additionalEarnings;

  const UpdateStudentStats({
    required this.studentId,
    required this.additionalHours,
    required this.additionalEarnings,
  });

  @override
  List<Object?> get props => [studentId, additionalHours, additionalEarnings];
}
