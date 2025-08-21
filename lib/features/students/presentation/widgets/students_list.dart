/**
 * @context7:feature:students
 * @context7:pattern:widget_component
 * 
 * Students list with individual student cards
 */

import 'package:flutter/material.dart';
import '../../domain/entities/student_entities.dart';
import 'student_card.dart';
import '../../../../core/constants/app_constants.dart';

class StudentsList extends StatelessWidget {
  final List<Student> students;

  const StudentsList({
    super.key,
    required this.students,
  });

  @override
  Widget build(BuildContext context) {
    if (students.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No students found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Try adjusting your search or filters',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: students.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return StudentCard(
          student: students[index],
          onTap: () {
            Navigator.pushNamed(
              context,
              AppRoutes.studentDetail,
              arguments: students[index],
            );
          },
        );
      },
    );
  }
}