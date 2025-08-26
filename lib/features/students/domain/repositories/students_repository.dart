/// @context7:feature:students
/// @context7:dependencies:student_entity
/// @context7:pattern:repository_interface
///
/// Students repository contract defining all student operations
library;

import '../entities/student_entity.dart';

/// Abstract repository defining student operations
/// This contract will be implemented by the data layer
abstract class StudentsRepository {
  /// Get all students for the current user
  /// Returns empty list if no students found
  Future<List<StudentEntity>> getAllStudents();

  /// Stream of all students for real-time updates
  Stream<List<StudentEntity>> get studentsStream;

  /// Get a specific student by ID
  /// Returns null if student not found
  Future<StudentEntity?> getStudentById(String id);

  /// Create a new student
  /// Returns the created student with generated ID
  Future<StudentEntity> addStudent(StudentEntity student);

  /// Update an existing student
  /// Returns the updated student
  Future<StudentEntity> updateStudent(StudentEntity student);

  /// Delete a student by ID
  /// This should also handle cleanup of related data
  Future<void> deleteStudent(String id);

  /// Search students by name or subject
  Future<List<StudentEntity>> searchStudents(String query);

  /// Get active students only
  Future<List<StudentEntity>> getActiveStudents();

  /// Get inactive students only
  Future<List<StudentEntity>> getInactiveStudents();

  /// Update student's total hours and earnings
  Future<void> updateStudentStats(
    String studentId,
    double additionalHours,
    double additionalEarnings,
  );

  /// Update student payment status after payment processing
  Future<void> updateStudentPaymentStatus(StudentEntity student);

  /// Soft delete - mark student as archived instead of deleting
  Future<void> archiveStudent(String id);

  /// Restore archived student
  Future<void> restoreStudent(String id);

  /// Bulk delete students
  Future<void> bulkDeleteStudents(List<String> studentIds);
}
