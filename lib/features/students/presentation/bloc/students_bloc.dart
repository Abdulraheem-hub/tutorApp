/// @context7:feature:students
/// @context7:dependencies:flutter_bloc,students_repository,firebase_service
/// @context7:pattern:bloc_implementation
///
/// BLoC implementation for Students feature
library;

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/student_entity.dart';
import '../../domain/repositories/students_repository.dart';
import '../../../../core/exceptions/exceptions.dart';
import 'students_event.dart';
import 'students_state.dart';

/// BLoC for managing students state and operations
class StudentsBloc extends Bloc<StudentsEvent, StudentsState> {
  final StudentsRepository _studentsRepository;

  StudentsBloc({required StudentsRepository studentsRepository})
    : _studentsRepository = studentsRepository,
      super(const StudentsInitial()) {
    // Register event handlers
    on<LoadStudents>(_onLoadStudents);
    on<AddStudent>(_onAddStudent);
    on<UpdateStudent>(_onUpdateStudent);
    on<DeleteStudent>(_onDeleteStudent);
    on<LoadStudentById>(_onLoadStudentById);
    on<FilterStudents>(_onFilterStudents);
    on<SearchStudents>(_onSearchStudents);
    on<RefreshStudents>(_onRefreshStudents);
    on<ArchiveStudent>(_onArchiveStudent);
    on<RestoreStudent>(_onRestoreStudent);
    on<BulkDeleteStudents>(_onBulkDeleteStudents);
  }

  /// Handle loading all students
  Future<void> _onLoadStudents(
    LoadStudents event,
    Emitter<StudentsState> emit,
  ) async {
    try {
      print('🔍 StudentsBloc: Starting _onLoadStudents');
      emit(const StudentsLoading());

      final students = await _studentsRepository.getAllStudents();
      print(
        '🔍 StudentsBloc: Received ${students.length} students from repository',
      );

      if (students.isEmpty) {
        print('🔍 StudentsBloc: No students found, emitting StudentsEmpty');
        emit(const StudentsEmpty());
      } else {
        print(
          '🔍 StudentsBloc: Emitting StudentsLoaded with ${students.length} students',
        );
        emit(StudentsLoaded(students: students, filteredStudents: students));
      }
    } on AppException catch (e) {
      print('❌ StudentsBloc: AppException caught - ${e.message}');
      // Provide more specific error message for authentication issues
      String userFriendlyMessage = e.message;
      if (e.code == 'USER_NOT_AUTHENTICATED') {
        userFriendlyMessage = 'Please sign in to view your students. The app will retry automatically.';
      }
      emit(StudentsError(message: userFriendlyMessage, errorCode: e.code));
    } catch (e) {
      print('❌ StudentsBloc: Unexpected error caught - $e');
      print('❌ StudentsBloc: Error type - ${e.runtimeType}');
      emit(StudentsError(message: 'An unexpected error occurred while fetching students. Please try again.'));
    }
  }

  /// Handle adding a new student
  Future<void> _onAddStudent(
    AddStudent event,
    Emitter<StudentsState> emit,
  ) async {
    try {
      emit(const StudentOperationInProgress('adding'));

      final newStudent = await _studentsRepository.addStudent(event.student);

      emit(
        StudentOperationSuccess(
          operation: 'adding',
          message: 'Student added successfully',
          student: newStudent,
        ),
      );

      // Refresh the students list
      add(const LoadStudents());
    } on AppException catch (e) {
      emit(
        StudentOperationFailure(
          operation: 'adding',
          message: e.message,
          errorCode: e.code,
        ),
      );
    } catch (e) {
      emit(
        StudentOperationFailure(
          operation: 'adding',
          message: 'Failed to add student: ${e.toString()}',
        ),
      );
    }
  }

  /// Handle updating an existing student
  Future<void> _onUpdateStudent(
    UpdateStudent event,
    Emitter<StudentsState> emit,
  ) async {
    try {
      emit(const StudentOperationInProgress('updating'));

      await _studentsRepository.updateStudent(event.student);

      emit(
        const StudentOperationSuccess(
          operation: 'updating',
          message: 'Student updated successfully',
        ),
      );

      // Refresh the students list
      add(const LoadStudents());
    } on AppException catch (e) {
      emit(
        StudentOperationFailure(
          operation: 'updating',
          message: e.message,
          errorCode: e.code,
        ),
      );
    } catch (e) {
      emit(
        StudentOperationFailure(
          operation: 'updating',
          message: 'Failed to update student: ${e.toString()}',
        ),
      );
    }
  }

  /// Handle deleting a student
  Future<void> _onDeleteStudent(
    DeleteStudent event,
    Emitter<StudentsState> emit,
  ) async {
    try {
      emit(const StudentOperationInProgress('deleting'));

      await _studentsRepository.deleteStudent(event.studentId);

      emit(
        const StudentOperationSuccess(
          operation: 'deleting',
          message: 'Student deleted successfully',
        ),
      );

      // Refresh the students list
      add(const LoadStudents());
    } on AppException catch (e) {
      emit(
        StudentOperationFailure(
          operation: 'deleting',
          message: e.message,
          errorCode: e.code,
        ),
      );
    } catch (e) {
      emit(
        StudentOperationFailure(
          operation: 'deleting',
          message: 'Failed to delete student: ${e.toString()}',
        ),
      );
    }
  }

  /// Handle loading a specific student by ID
  Future<void> _onLoadStudentById(
    LoadStudentById event,
    Emitter<StudentsState> emit,
  ) async {
    try {
      emit(const StudentsLoading());

      final student = await _studentsRepository.getStudentById(event.studentId);

      if (student != null) {
        emit(StudentLoaded(student));
      } else {
        emit(
          const StudentsError(
            message: 'Student not found',
            errorCode: 'STUDENT_NOT_FOUND',
          ),
        );
      }
    } on AppException catch (e) {
      emit(StudentsError(message: e.message, errorCode: e.code));
    } catch (e) {
      emit(StudentsError(message: 'Failed to load student: ${e.toString()}'));
    }
  }

  /// Handle filtering students
  void _onFilterStudents(FilterStudents event, Emitter<StudentsState> emit) {
    final currentState = state;
    if (currentState is StudentsLoaded) {
      List<StudentEntity> filteredStudents;

      switch (event.filter) {
        case 'active':
          filteredStudents = currentState.students
              .where((student) => student.isActive)
              .toList();
          break;
        case 'inactive':
          filteredStudents = currentState.students
              .where((student) => !student.isActive)
              .toList();
          break;
        case 'archived':
          filteredStudents = currentState.students
              .where((student) => !student.isActive)
              .toList();
          break;
        case 'all':
        default:
          filteredStudents = List.from(currentState.students);
          break;
      }

      // Apply existing search if any
      if (currentState.searchQuery.isNotEmpty) {
        filteredStudents = _applySearch(
          filteredStudents,
          currentState.searchQuery,
        );
      }

      emit(
        currentState.copyWith(
          filteredStudents: filteredStudents,
          currentFilter: event.filter,
        ),
      );
    }
  }

  /// Handle searching students
  void _onSearchStudents(SearchStudents event, Emitter<StudentsState> emit) {
    final currentState = state;
    if (currentState is StudentsLoaded) {
      List<StudentEntity> filteredStudents = List.from(currentState.students);

      // Apply current filter first
      if (currentState.currentFilter != 'all') {
        switch (currentState.currentFilter) {
          case 'active':
            filteredStudents = filteredStudents
                .where((student) => student.isActive)
                .toList();
            break;
          case 'inactive':
            filteredStudents = filteredStudents
                .where((student) => !student.isActive)
                .toList();
            break;
          case 'archived':
            filteredStudents = filteredStudents
                .where((student) => !student.isActive)
                .toList();
            break;
        }
      }

      // Apply search query
      if (event.query.isNotEmpty) {
        filteredStudents = _applySearch(filteredStudents, event.query);
      }

      emit(
        currentState.copyWith(
          filteredStudents: filteredStudents,
          searchQuery: event.query,
        ),
      );
    }
  }

  /// Apply search query to student list
  List<StudentEntity> _applySearch(List<StudentEntity> students, String query) {
    final lowercaseQuery = query.toLowerCase();
    return students.where((student) {
      return student.name.toLowerCase().contains(lowercaseQuery) ||
          (student.email?.toLowerCase().contains(lowercaseQuery) ?? false) ||
          (student.phone?.toLowerCase().contains(lowercaseQuery) ?? false) ||
          student.subject.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  /// Handle refreshing students
  Future<void> _onRefreshStudents(
    RefreshStudents event,
    Emitter<StudentsState> emit,
  ) async {
    // Simply reload all students
    add(const LoadStudents());
  }

  /// Handle archiving a student
  Future<void> _onArchiveStudent(
    ArchiveStudent event,
    Emitter<StudentsState> emit,
  ) async {
    try {
      emit(const StudentOperationInProgress('archiving'));

      await _studentsRepository.archiveStudent(event.studentId);

      emit(
        const StudentOperationSuccess(
          operation: 'archiving',
          message: 'Student archived successfully',
        ),
      );

      // Refresh the students list
      add(const LoadStudents());
    } on AppException catch (e) {
      emit(
        StudentOperationFailure(
          operation: 'archiving',
          message: e.message,
          errorCode: e.code,
        ),
      );
    } catch (e) {
      emit(
        StudentOperationFailure(
          operation: 'archiving',
          message: 'Failed to archive student: ${e.toString()}',
        ),
      );
    }
  }

  /// Handle restoring an archived student
  Future<void> _onRestoreStudent(
    RestoreStudent event,
    Emitter<StudentsState> emit,
  ) async {
    try {
      emit(const StudentOperationInProgress('restoring'));

      await _studentsRepository.restoreStudent(event.studentId);

      emit(
        const StudentOperationSuccess(
          operation: 'restoring',
          message: 'Student restored successfully',
        ),
      );

      // Refresh the students list
      add(const LoadStudents());
    } on AppException catch (e) {
      emit(
        StudentOperationFailure(
          operation: 'restoring',
          message: e.message,
          errorCode: e.code,
        ),
      );
    } catch (e) {
      emit(
        StudentOperationFailure(
          operation: 'restoring',
          message: 'Failed to restore student: ${e.toString()}',
        ),
      );
    }
  }

  /// Handle bulk deleting students
  Future<void> _onBulkDeleteStudents(
    BulkDeleteStudents event,
    Emitter<StudentsState> emit,
  ) async {
    try {
      emit(const StudentOperationInProgress('bulk_deleting'));

      await _studentsRepository.bulkDeleteStudents(event.studentIds);

      emit(
        StudentOperationSuccess(
          operation: 'bulk_deleting',
          message: 'Deleted ${event.studentIds.length} students successfully',
        ),
      );

      // Refresh the students list
      add(const LoadStudents());
    } on AppException catch (e) {
      emit(
        StudentOperationFailure(
          operation: 'bulk_deleting',
          message: e.message,
          errorCode: e.code,
        ),
      );
    } catch (e) {
      emit(
        StudentOperationFailure(
          operation: 'bulk_deleting',
          message: 'Failed to delete students: ${e.toString()}',
        ),
      );
    }
  }
}
