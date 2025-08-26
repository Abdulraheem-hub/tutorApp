/// Test to reproduce and fix the "add student" issue
/// This test checks the complete flow from adding a student to displaying in the list

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:tutor_pay/features/students/domain/entities/student_entity.dart';
import 'package:tutor_pay/features/students/domain/entities/student_entities.dart';
import 'package:tutor_pay/features/students/domain/repositories/students_repository.dart';
import 'package:tutor_pay/features/students/presentation/bloc/students_bloc.dart';
import 'package:tutor_pay/features/students/presentation/bloc/students_event.dart';
import 'package:tutor_pay/features/students/presentation/bloc/students_state.dart';
import 'package:tutor_pay/features/students/presentation/utils/student_mapper.dart';

// Generate mocks
@GenerateMocks([StudentsRepository])
import 'add_student_issue_test.mocks.dart';

void main() {
  group('Add Student Issue Tests', () {
    late StudentsBloc studentsBloc;
    late MockStudentsRepository mockRepository;

    setUp(() {
      mockRepository = MockStudentsRepository();
      studentsBloc = StudentsBloc(studentsRepository: mockRepository);
    });

    tearDown(() {
      studentsBloc.close();
    });

    test('should handle state transitions correctly when adding student', () async {
      // This reproduces the exact issue: state management during add student flow
      final testStudentEntity = StudentEntity(
        id: '',
        name: 'John Doe',
        subject: 'Mathematics',
        monthlyFee: 50.0,
        isActive: true,
        createdAt: DateTime.now(),
        totalHours: 0.0,
        totalEarnings: 0.0,
      );

      final addedStudentEntity = testStudentEntity.copyWith(id: 'generated-id-123');
      final studentsListAfterAdd = [addedStudentEntity];

      // Mock repository responses
      when(mockRepository.addStudent(any))
          .thenAnswer((_) async => addedStudentEntity);
      when(mockRepository.getAllStudents())
          .thenAnswer((_) async => studentsListAfterAdd);

      // Track state changes
      final states = <StudentsState>[];
      studentsBloc.stream.listen((state) => states.add(state));

      // Add the student
      studentsBloc.add(AddStudent(testStudentEntity));

      // Wait for all async operations to complete
      await Future.delayed(const Duration(milliseconds: 200));

      // Verify the state sequence
      expect(states.length, greaterThanOrEqualTo(4));
      expect(states[0], isA<StudentOperationInProgress>());
      expect(states[1], isA<StudentOperationSuccess>());
      expect(states[2], isA<StudentsLoading>());
      expect(states[3], isA<StudentsLoaded>());

      // Verify the final state has the student
      final finalState = states[3] as StudentsLoaded;
      expect(finalState.students, hasLength(1));
      expect(finalState.students.first.id, equals('generated-id-123'));
    });

    test('should successfully add student and reload list', () async {
      // Arrange
      final testStudentEntity = StudentEntity(
        id: 'test-id-123',
        name: 'John Doe',
        subject: 'Mathematics',
        monthlyFee: 50.0,
        email: 'john@example.com',
        phone: '+1234567890',
        address: '123 Test St',
        notes: 'Test student',
        isActive: true,
        createdAt: DateTime.now(),
        totalHours: 0.0,
        totalEarnings: 0.0,
      );

      final studentsListAfterAdd = [testStudentEntity];

      // Mock repository responses
      when(mockRepository.addStudent(any))
          .thenAnswer((_) async => testStudentEntity);
      when(mockRepository.getAllStudents())
          .thenAnswer((_) async => studentsListAfterAdd);

      // Act & Assert
      expectLater(
        studentsBloc.stream,
        emitsInOrder([
          isA<StudentOperationInProgress>(),
          isA<StudentOperationSuccess>(),
          isA<StudentsLoading>(),
          isA<StudentsLoaded>(),
        ]),
      );

      // Add the student
      studentsBloc.add(AddStudent(testStudentEntity));

      await Future.delayed(const Duration(milliseconds: 100));

      // Verify repository calls
      verify(mockRepository.addStudent(any)).called(1);
      verify(mockRepository.getAllStudents()).called(1);
    });

    test('should convert StudentEntity to Student for UI display', () {
      // Arrange
      final studentEntity = StudentEntity(
        id: 'test-id-123',
        name: 'Jane Doe',
        subject: 'Physics',
        monthlyFee: 75.0,
        email: 'jane@example.com',
        phone: '+9876543210',
        address: '456 Test Ave',
        isActive: true,
        createdAt: DateTime.now(),
        totalHours: 10.0,
        totalEarnings: 750.0,
        outstandingBalance: 25.0,
        currentMonthPaid: false,
      );

      // Act
      final student = StudentMapper.fromEntity(studentEntity);

      // Assert
      expect(student.id, equals(studentEntity.id));
      expect(student.name, equals(studentEntity.name));
      expect(student.monthlyFee, equals(studentEntity.monthlyFee));
      expect(student.email, equals(studentEntity.email));
      expect(student.phoneNumber, equals(studentEntity.phone));
      expect(student.address, equals(studentEntity.address));
      expect(student.isActive, equals(studentEntity.isActive));
      expect(student.joinDate, equals(studentEntity.createdAt));
      expect(student.outstandingBalance, equals(studentEntity.outstandingBalance));
      expect(student.currentMonthPaid, equals(studentEntity.currentMonthPaid));
      
      // Check that subjects list is properly created
      expect(student.subjects, isNotEmpty);
      expect(student.subjects.first.name, equals(studentEntity.subject));
      
      // Check that default values are set appropriately
      expect(student.grade, equals(Grade.grade8));
      // Payment status should be calculated based on currentMonthPaid and outstanding balance
      expect(student.paymentStatus, equals(PaymentStatus.pending));
    });

    test('should handle multiple subjects in StudentEntity', () {
      // Test case for when subject contains multiple subjects
      final studentEntity = StudentEntity(
        id: 'test-id-456',
        name: 'Multi Subject Student',
        subject: 'Math & Physics & Chemistry',
        monthlyFee: 100.0,
        isActive: true,
        createdAt: DateTime.now(),
        totalHours: 0.0,
        totalEarnings: 0.0,
      );

      // Act
      final student = StudentMapper.fromEntity(studentEntity);

      // Assert
      expect(student.subjects, isNotEmpty);
      expect(student.subjects.first.name, equals('Math & Physics & Chemistry'));
    });

    test('should calculate payment status correctly', () {
      // Test different payment status scenarios
      
      // Scenario 1: Paid and no outstanding balance
      final paidStudent = StudentEntity(
        id: 'paid-student',
        name: 'Paid Student',
        subject: 'Math',
        monthlyFee: 50.0,
        isActive: true,
        createdAt: DateTime.now(),
        totalHours: 0.0,
        totalEarnings: 0.0,
        currentMonthPaid: true,
        outstandingBalance: 0.0,
      );
      
      final mappedPaidStudent = StudentMapper.fromEntity(paidStudent);
      expect(mappedPaidStudent.paymentStatus, equals(PaymentStatus.paid));
      
      // Scenario 2: Paid but has outstanding balance
      final partialPaidStudent = paidStudent.copyWith(
        outstandingBalance: 25.0,
      );
      
      final mappedPartialPaid = StudentMapper.fromEntity(partialPaidStudent);
      expect(mappedPartialPaid.paymentStatus, equals(PaymentStatus.pending));
      
      // Scenario 3: Not paid current month
      final unpaidStudent = paidStudent.copyWith(
        currentMonthPaid: false,
        outstandingBalance: 0.0,
      );
      
      final mappedUnpaid = StudentMapper.fromEntity(unpaidStudent);
      expect(mappedUnpaid.paymentStatus, equals(PaymentStatus.pending));
    });

    test('should handle repository errors gracefully', () async {
      // Arrange
      final testStudentEntity = StudentEntity(
        id: '',
        name: 'Test Student',
        subject: 'Math',
        monthlyFee: 50.0,
        isActive: true,
        createdAt: DateTime.now(),
        totalHours: 0.0,
        totalEarnings: 0.0,
      );

      // Mock repository to throw an error
      when(mockRepository.addStudent(any))
          .thenThrow(Exception('Network error'));

      // Act & Assert
      expectLater(
        studentsBloc.stream,
        emitsInOrder([
          isA<StudentOperationInProgress>(),
          isA<StudentOperationFailure>(),
        ]),
      );

      studentsBloc.add(AddStudent(testStudentEntity));

      await Future.delayed(const Duration(milliseconds: 100));

      // Verify error is handled
      verify(mockRepository.addStudent(any)).called(1);
      // LoadStudents should not be called if add fails
      verifyNever(mockRepository.getAllStudents());
    });
  });
}