/// @context7:feature:students
/// @context7:dependencies:firebase,flutter_test
/// @context7:pattern:integration_test
///
/// Test Firebase integration for students feature
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:tutor_pay/core/di/dependency_injection.dart';
import 'package:tutor_pay/features/students/domain/entities/student_entity.dart';
import 'package:tutor_pay/features/students/data/repositories/firestore_students_repository.dart';

void main() {
  group('Firebase Students Integration Tests', () {
    late FirestoreStudentsRepository repository;

    setUpAll(() async {
      // Initialize dependencies
      await initializeDependencies();
      repository = FirestoreStudentsRepository();
    });

    test('should create a test student in Firestore', () async {
      // Create test student
      final testStudent = StudentEntity(
        id: '',
        name: 'Test Student',
        subject: 'Mathematics',
        monthlyFee: 25.0,
        email: 'test@example.com',
        phone: '+1234567890',
        address: 'Test Address',
        notes: 'Test notes',
        isActive: true,
        createdAt: DateTime.now(),
        totalHours: 0.0,
        totalEarnings: 0.0,
      );

      // Add student
      final addedStudent = await repository.addStudent(testStudent);

      // Verify student was added
      expect(addedStudent.id, isNotEmpty);
      expect(addedStudent.name, equals('Test Student'));
      expect(addedStudent.subject, equals('Mathematics'));
      expect(addedStudent.monthlyFee, equals(25.0));

      // Clean up - delete the test student
      await repository.deleteStudent(addedStudent.id);
    });

    test('should retrieve students from Firestore', () async {
      // Get all students
      final students = await repository.getAllStudents();

      // Should return a list (may be empty)
      expect(students, isA<List<StudentEntity>>());
    });
  });
}
