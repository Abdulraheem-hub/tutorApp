/// Integration test to reproduce the exact "add student" error scenario
/// This simulates the complete user flow from adding a student to viewing the list

import 'package:flutter/material.dart';
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
import 'package:tutor_pay/features/students/presentation/pages/students_page_new.dart';
import 'package:tutor_pay/features/students/presentation/widgets/students_list.dart';
import 'package:tutor_pay/core/theme/app_theme.dart';

// Generate mocks
@GenerateMocks([StudentsRepository])
import 'add_student_issue_test.mocks.dart';

void main() {
  group('Student List Error Integration Tests', () {
    late MockStudentsRepository mockRepository;

    setUp(() {
      mockRepository = MockStudentsRepository();
    });

    testWidgets('should handle add student flow and display list correctly', (WidgetTester tester) async {
      // Create test student
      final testStudentEntity = StudentEntity(
        id: 'test-student-1',
        name: 'Test Student',
        subject: 'Mathematics',
        monthlyFee: 50.0,
        email: 'test@example.com',
        phone: '+1234567890',
        address: 'Test Address',
        isActive: true,
        createdAt: DateTime.now(),
        totalHours: 0.0,
        totalEarnings: 0.0,
        outstandingBalance: 0.0,
        currentMonthPaid: false,
      );

      // Mock repository responses
      when(mockRepository.getAllStudents())
          .thenAnswer((_) async => [testStudentEntity]);

      // Build the app widget
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: BlocProvider(
            create: (context) => StudentsBloc(studentsRepository: mockRepository),
            child: const StudentsPage(),
          ),
        ),
      );

      // Trigger loading
      final bloc = tester.element(find.byType(StudentsPage)).read<StudentsBloc>();
      bloc.add(const LoadStudents());

      // Wait for the async operations
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Verify that the student list is displayed
      expect(find.byType(StudentsList), findsOneWidget);
      
      // Verify student data is displayed
      expect(find.text('Test Student'), findsOneWidget);
      
      verify(mockRepository.getAllStudents()).called(1);
    });

    testWidgets('should handle empty student list correctly', (WidgetTester tester) async {
      // Mock empty response
      when(mockRepository.getAllStudents())
          .thenAnswer((_) async => []);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: BlocProvider(
            create: (context) => StudentsBloc(studentsRepository: mockRepository),
            child: const StudentsPage(),
          ),
        ),
      );

      final bloc = tester.element(find.byType(StudentsPage)).read<StudentsBloc>();
      bloc.add(const LoadStudents());

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Should show empty state
      expect(find.text('No students found'), findsOneWidget);
      expect(find.text('Add your first student to get started'), findsOneWidget);
    });

    testWidgets('should handle student loading error correctly', (WidgetTester tester) async {
      // Mock error response
      when(mockRepository.getAllStudents())
          .thenThrow(Exception('Database connection failed'));

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: BlocProvider(
            create: (context) => StudentsBloc(studentsRepository: mockRepository),
            child: const StudentsPage(),
          ),
        ),
      );

      final bloc = tester.element(find.byType(StudentsPage)).read<StudentsBloc>();
      bloc.add(const LoadStudents());

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Should show error state
      expect(find.text('Error loading students'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('should simulate complete add student flow with navigation back', (WidgetTester tester) async {
      // This test simulates the exact scenario described in the issue
      final newStudentEntity = StudentEntity(
        id: '',
        name: 'New Student',
        subject: 'Physics',
        monthlyFee: 75.0,
        isActive: true,
        createdAt: DateTime.now(),
        totalHours: 0.0,
        totalEarnings: 0.0,
      );

      final addedStudentEntity = newStudentEntity.copyWith(id: 'new-student-id');
      final studentsAfterAdd = [addedStudentEntity];

      // Mock the complete flow
      when(mockRepository.addStudent(any))
          .thenAnswer((_) async => addedStudentEntity);
      when(mockRepository.getAllStudents())
          .thenAnswer((_) async => studentsAfterAdd);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: BlocProvider(
            create: (context) => StudentsBloc(studentsRepository: mockRepository),
            child: const StudentsPage(),
          ),
        ),
      );

      final bloc = tester.element(find.byType(StudentsPage)).read<StudentsBloc>();

      // Simulate add student operation
      bloc.add(AddStudent(newStudentEntity));

      // Wait for all state transitions
      await tester.pump(); // StudentOperationInProgress
      await tester.pump(const Duration(milliseconds: 50)); // StudentOperationSuccess
      await tester.pump(const Duration(milliseconds: 50)); // StudentsLoading
      await tester.pump(const Duration(milliseconds: 50)); // StudentsLoaded

      // Should show the newly added student
      expect(find.text('New Student'), findsOneWidget);
      
      // Verify both operations were called
      verify(mockRepository.addStudent(any)).called(1);
      verify(mockRepository.getAllStudents()).called(1);
    });
  });
}