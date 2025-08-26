/// @context7:feature:students
/// @context7:dependencies:cloud_firestore,students_repository,student_model,firebase_auth
/// @context7:pattern:repository_implementation
///
/// Firestore implementation of StudentsRepository
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/student_entity.dart';
import '../../domain/repositories/students_repository.dart';
import '../models/student_model.dart';
import '../../../../core/exceptions/exceptions.dart';
import '../../../../core/services/firebase_service.dart';

/// Firestore implementation of the students repository
/// Handles all Firestore operations for student data
class FirestoreStudentsRepository implements StudentsRepository {
  FirestoreStudentsRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseService.instance.firestore;

  final FirebaseFirestore _firestore;

  /// Get current user ID from Firebase Auth
  String get _currentUserId {
    final userId = FirebaseService.instance.auth.currentUser?.uid;
    if (userId == null) {
      print('❌ FirestoreStudentsRepository: No authenticated user found');
      // Throw a more specific error instead of falling back to test user
      throw DataException(
        message: 'User not authenticated. Please sign in to access student data.',
        code: 'USER_NOT_AUTHENTICATED',
      );
    }
    print('🔐 FirestoreStudentsRepository: Using authenticated user ID: $userId');
    return userId;
  }

  /// Get reference to user's students collection
  CollectionReference get _studentsCollection {
    return _firestore
        .collection('users')
        .doc(_currentUserId)
        .collection('students');
  }

  @override
  Future<List<StudentEntity>> getAllStudents() async {
    try {
      print('🔍 FirestoreStudentsRepository: Starting getAllStudents');
      print('🔍 Current User ID: $_currentUserId');
      print('🔍 Collection Path: users/$_currentUserId/students');

      final QuerySnapshot snapshot = await _studentsCollection
          .orderBy('createdAt', descending: true)
          .get();

      print('🔍 Query completed. Document count: ${snapshot.docs.length}');

      final students = snapshot.docs.map((doc) {
        print('🔍 Processing doc: ${doc.id}');
        print('🔍 Doc data: ${doc.data()}');
        return StudentModel.fromFirestore(doc).toEntity();
      }).toList();

      print('🔍 Converted ${students.length} students successfully');
      return students;
    } on FirebaseException catch (e) {
      print('❌ FirebaseException in getAllStudents: ${e.code} - ${e.message}');
      throw DataException(
        message: 'Failed to fetch students',
        code: e.code,
        details: e,
      );
    } catch (e) {
      print('❌ Unexpected error in getAllStudents: $e');
      print('❌ Error type: ${e.runtimeType}');
      throw DataException(
        message: 'An unexpected error occurred while fetching students',
        details: e,
      );
    }
  }

  @override
  Stream<List<StudentEntity>> get studentsStream {
    try {
      return _studentsCollection
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map(
            (snapshot) => snapshot.docs
                .map((doc) => StudentModel.fromFirestore(doc).toEntity())
                .toList(),
          );
    } catch (e) {
      throw DataException(
        message: 'Failed to create students stream',
        details: e,
      );
    }
  }

  @override
  Future<StudentEntity?> getStudentById(String id) async {
    try {
      final DocumentSnapshot doc = await _studentsCollection.doc(id).get();

      if (!doc.exists) {
        return null;
      }

      return StudentModel.fromFirestore(doc).toEntity();
    } on FirebaseException catch (e) {
      throw DataException(
        message: 'Failed to fetch student',
        code: e.code,
        details: e,
      );
    } catch (e) {
      throw DataException(
        message: 'An unexpected error occurred while fetching student',
        details: e,
      );
    }
  }

  @override
  Future<StudentEntity> addStudent(StudentEntity student) async {
    try {
      // Create student with auto-generated ID
      final DocumentReference docRef = await _studentsCollection.add(
        StudentModel.fromEntity(student).toFirestore(),
      );

      // Get the created document
      final DocumentSnapshot doc = await docRef.get();
      return StudentModel.fromFirestore(doc).toEntity();
    } on FirebaseException catch (e) {
      throw DataException(
        message: 'Failed to create student',
        code: e.code,
        details: e,
      );
    } catch (e) {
      throw DataException(
        message: 'An unexpected error occurred while creating student',
        details: e,
      );
    }
  }

  @override
  Future<StudentEntity> updateStudent(StudentEntity student) async {
    try {
      final updateData = StudentModel.fromEntity(student).toFirestore();
      updateData['updatedAt'] = Timestamp.now();

      await _studentsCollection.doc(student.id).update(updateData);

      // Get the updated document
      final DocumentSnapshot doc = await _studentsCollection
          .doc(student.id)
          .get();
      return StudentModel.fromFirestore(doc).toEntity();
    } on FirebaseException catch (e) {
      throw DataException(
        message: 'Failed to update student',
        code: e.code,
        details: e,
      );
    } catch (e) {
      throw DataException(
        message: 'An unexpected error occurred while updating student',
        details: e,
      );
    }
  }

  @override
  Future<void> deleteStudent(String id) async {
    try {
      await _studentsCollection.doc(id).delete();
    } on FirebaseException catch (e) {
      throw DataException(
        message: 'Failed to delete student',
        code: e.code,
        details: e,
      );
    } catch (e) {
      throw DataException(
        message: 'An unexpected error occurred while deleting student',
        details: e,
      );
    }
  }

  @override
  Future<List<StudentEntity>> searchStudents(String query) async {
    try {
      // Note: Firestore doesn't support full-text search natively
      // This is a simple implementation that searches by name prefix
      final QuerySnapshot snapshot = await _studentsCollection
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThanOrEqualTo: '$query\uf8ff')
          .get();

      final List<StudentEntity> nameMatches = snapshot.docs
          .map((doc) => StudentModel.fromFirestore(doc).toEntity())
          .toList();

      // Also search by subject
      final QuerySnapshot subjectSnapshot = await _studentsCollection
          .where('subject', isGreaterThanOrEqualTo: query)
          .where('subject', isLessThanOrEqualTo: '$query\uf8ff')
          .get();

      final List<StudentEntity> subjectMatches = subjectSnapshot.docs
          .map((doc) => StudentModel.fromFirestore(doc).toEntity())
          .toList();

      // Combine results and remove duplicates
      final Set<String> seenIds = <String>{};
      final List<StudentEntity> allMatches = [];

      for (final student in [...nameMatches, ...subjectMatches]) {
        if (!seenIds.contains(student.id)) {
          seenIds.add(student.id);
          allMatches.add(student);
        }
      }

      return allMatches;
    } on FirebaseException catch (e) {
      throw DataException(
        message: 'Failed to search students',
        code: e.code,
        details: e,
      );
    } catch (e) {
      throw DataException(
        message: 'An unexpected error occurred while searching students',
        details: e,
      );
    }
  }

  @override
  Future<List<StudentEntity>> getActiveStudents() async {
    try {
      final QuerySnapshot snapshot = await _studentsCollection
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => StudentModel.fromFirestore(doc).toEntity())
          .toList();
    } on FirebaseException catch (e) {
      throw DataException(
        message: 'Failed to fetch active students',
        code: e.code,
        details: e,
      );
    } catch (e) {
      throw DataException(
        message: 'An unexpected error occurred while fetching active students',
        details: e,
      );
    }
  }

  @override
  Future<List<StudentEntity>> getInactiveStudents() async {
    try {
      final QuerySnapshot snapshot = await _studentsCollection
          .where('isActive', isEqualTo: false)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => StudentModel.fromFirestore(doc).toEntity())
          .toList();
    } on FirebaseException catch (e) {
      throw DataException(
        message: 'Failed to fetch inactive students',
        code: e.code,
        details: e,
      );
    } catch (e) {
      throw DataException(
        message:
            'An unexpected error occurred while fetching inactive students',
        details: e,
      );
    }
  }

  @override
  Future<void> updateStudentStats(
    String studentId,
    double additionalHours,
    double additionalEarnings,
  ) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final DocumentReference studentRef = _studentsCollection.doc(studentId);
        final DocumentSnapshot studentDoc = await transaction.get(studentRef);

        if (!studentDoc.exists) {
          throw const DataException(
            message: 'Student not found',
            code: 'student-not-found',
          );
        }

        final studentData = studentDoc.data() as Map<String, dynamic>;
        final currentHours =
            (studentData['totalHours'] as num?)?.toDouble() ?? 0.0;
        final currentEarnings =
            (studentData['totalEarnings'] as num?)?.toDouble() ?? 0.0;

        transaction.update(studentRef, {
          'totalHours': currentHours + additionalHours,
          'totalEarnings': currentEarnings + additionalEarnings,
          'lastPaymentDate': Timestamp.now(),
          'updatedAt': Timestamp.now(),
        });
      });
    } on FirebaseException catch (e) {
      throw DataException(
        message: 'Failed to update student stats',
        code: e.code,
        details: e,
      );
    } catch (e) {
      throw DataException(
        message: 'An unexpected error occurred while updating student stats',
        details: e,
      );
    }
  }

  @override
  Future<void> archiveStudent(String id) async {
    try {
      await _studentsCollection.doc(id).update({
        'isArchived': true,
        'isActive': false,
        'updatedAt': Timestamp.now(),
      });
    } on FirebaseException catch (e) {
      throw DataException(
        message: 'Failed to archive student',
        code: e.code,
        details: e,
      );
    } catch (e) {
      throw DataException(
        message: 'An unexpected error occurred while archiving student',
        details: e,
      );
    }
  }

  @override
  Future<void> restoreStudent(String id) async {
    try {
      await _studentsCollection.doc(id).update({
        'isArchived': false,
        'isActive': true,
        'updatedAt': Timestamp.now(),
      });
    } on FirebaseException catch (e) {
      throw DataException(
        message: 'Failed to restore student',
        code: e.code,
        details: e,
      );
    } catch (e) {
      throw DataException(
        message: 'An unexpected error occurred while restoring student',
        details: e,
      );
    }
  }

  @override
  Future<void> updateStudentPaymentStatus(StudentEntity student) async {
    try {
      final StudentModel model = StudentModel.fromEntity(student);
      await _studentsCollection.doc(student.id).update(model.toFirestore());
    } on FirebaseException catch (e) {
      throw DataException(
        message: 'Failed to update student payment status',
        code: e.code,
        details: e,
      );
    } catch (e) {
      throw DataException(
        message:
            'An unexpected error occurred while updating student payment status',
        details: e,
      );
    }
  }

  @override
  Future<void> bulkDeleteStudents(List<String> studentIds) async {
    try {
      // Use batch write for bulk operations
      final WriteBatch batch = _firestore.batch();

      for (final studentId in studentIds) {
        batch.delete(_studentsCollection.doc(studentId));
      }

      await batch.commit();
    } on FirebaseException catch (e) {
      throw DataException(
        message: 'Failed to bulk delete students',
        code: e.code,
        details: e,
      );
    } catch (e) {
      throw DataException(
        message: 'An unexpected error occurred while bulk deleting students',
        details: e,
      );
    }
  }
}
