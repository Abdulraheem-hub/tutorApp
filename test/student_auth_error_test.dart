/// @context7:feature:students
/// @context7:dependencies:flutter_test,mockito,firebase_auth
/// @context7:pattern:unit_test
///
/// Test authentication error handling in students feature
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tutor_pay/features/students/data/repositories/firestore_students_repository.dart';
import 'package:tutor_pay/features/students/presentation/bloc/students_bloc.dart';
import 'package:tutor_pay/features/students/presentation/bloc/students_event.dart';
import 'package:tutor_pay/features/students/presentation/bloc/students_state.dart';
import 'package:tutor_pay/core/exceptions/exceptions.dart';

// Generate mocks for testing
@GenerateMocks([FirebaseAuth, User, FirebaseFirestore])
import 'student_auth_error_test.mocks.dart';

void main() {
  group('Student Authentication Error Handling Tests', () {
    late FirestoreStudentsRepository repository;
    late StudentsBloc studentsBloc;
    late MockFirebaseAuth mockAuth;
    late MockFirebaseFirestore mockFirestore;

    setUp(() {
      mockAuth = MockFirebaseAuth();
      mockFirestore = MockFirebaseFirestore();
      repository = FirestoreStudentsRepository(firestore: mockFirestore);
      studentsBloc = StudentsBloc(studentsRepository: repository);
    });

    tearDown(() {
      studentsBloc.close();
    });

    test('should throw DataException when user is not authenticated', () async {
      // Arrange: Mock no authenticated user
      when(mockAuth.currentUser).thenReturn(null);

      // Act & Assert: Should throw DataException when accessing _currentUserId
      expect(
        () => repository.getAllStudents(),
        throwsA(isA<DataException>().having(
          (e) => e.code,
          'error code',
          'USER_NOT_AUTHENTICATED',
        )),
      );
    });

    test('should emit StudentsError when authentication fails in bloc', () async {
      // Arrange: Mock repository to throw authentication error
      final mockRepository = MockStudentsRepository();
      when(mockRepository.getAllStudents()).thenThrow(
        const DataException(
          message: 'User not authenticated. Please sign in to access student data.',
          code: 'USER_NOT_AUTHENTICATED',
        ),
      );

      final bloc = StudentsBloc(studentsRepository: mockRepository);

      // Act & Assert: Should emit StudentsError with friendly message
      expectLater(
        bloc.stream,
        emitsInOrder([
          isA<StudentsLoading>(),
          isA<StudentsError>().having(
            (state) => state.message,
            'error message',
            contains('Please sign in to view your students'),
          ),
        ]),
      );

      bloc.add(const LoadStudents());

      await Future.delayed(const Duration(milliseconds: 100));
      bloc.close();
    });

    test('should handle general exceptions with user-friendly message', () async {
      // Arrange: Mock repository to throw general exception
      final mockRepository = MockStudentsRepository();
      when(mockRepository.getAllStudents()).thenThrow(
        Exception('Network connection failed'),
      );

      final bloc = StudentsBloc(studentsRepository: mockRepository);

      // Act & Assert: Should emit StudentsError with friendly message
      expectLater(
        bloc.stream,
        emitsInOrder([
          isA<StudentsLoading>(),
          isA<StudentsError>().having(
            (state) => state.message,
            'error message',
            'An unexpected error occurred while fetching students. Please try again.',
          ),
        ]),
      );

      bloc.add(const LoadStudents());

      await Future.delayed(const Duration(milliseconds: 100));
      bloc.close();
    });
  });
}

// Mock class for StudentsRepository
class MockStudentsRepository extends Mock
    implements FirestoreStudentsRepository {}