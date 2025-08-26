/// @context7:feature:students
/// @context7:dependencies:student_entity,student_entities
/// @context7:pattern:mapper_utility
///
/// Utility to convert between different student representations
library;

import '../../domain/entities/student_entity.dart';
import '../../domain/entities/student_entities.dart';

/// Utility class to convert between StudentEntity and Student models
class StudentMapper {
  /// Convert from Firebase StudentEntity to UI Student model
  static Student fromEntity(StudentEntity entity) {
    return Student(
      id: entity.id,
      name: entity.name,
      grade: Grade.grade8, // Default grade, should be properly mapped
      subjects: [
        Subject(id: '1', name: entity.subject, shortName: entity.subject),
      ],
      monthlyFee: entity.monthlyFee,
      paymentStatus: PaymentStatus.paid, // Default status
      joinDate: entity.createdAt,
      isActive: entity.isActive,
      email: entity.email,
      phoneNumber: entity.phone,
      address: entity.address,
    );
  }

  /// Convert from UI Student model to Firebase StudentEntity
  static StudentEntity toEntity(Student student) {
    return StudentEntity(
      id: student.id,
      name: student.name,
      subject: student.subjects.isNotEmpty ? student.subjects.first.name : '',
      monthlyFee: student.monthlyFee,
      email: student.email,
      phone: student.phoneNumber,
      address: student.address,
      notes: null,
      isActive: student.isActive,
      createdAt: student.joinDate,
      updatedAt: DateTime.now(),
      lastPaymentDate: null,
      totalHours: 0.0,
      totalEarnings: 0.0,
    );
  }
}
