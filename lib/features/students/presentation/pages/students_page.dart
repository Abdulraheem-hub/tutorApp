/**
 * @context7:feature:students
 * @context7:dependencies:flutter,student_entities
 * @context7:pattern:page_widget
 * 
 * Students page with search, filters, and student list
 */

import 'package:flutter/material.dart';
import '../../domain/entities/student_entities.dart';
import '../widgets/students_header.dart';
import '../widgets/students_search.dart';
import '../widgets/students_filters.dart';
import '../widgets/students_list.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';

class StudentsPage extends StatefulWidget {
  const StudentsPage({super.key});

  @override
  State<StudentsPage> createState() => _StudentsPageState();
}

class _StudentsPageState extends State<StudentsPage> {
  String _searchQuery = '';
  String _selectedFilter = 'All';
  List<Student> _filteredStudents = [];

  // Mock data based on the image
  final List<Student> _allStudents = [
    Student(
      id: '1',
      name: 'Ahmed Hassan',
      grade: Grade.grade8,
      subjects: [const Subject(id: '1', name: 'Mathematics', shortName: 'Math')],
      monthlyFee: 80.0,
      paymentStatus: PaymentStatus.paid,
      nextPaymentDate: DateTime(2024, 1, 15),
      joinDate: DateTime(2023, 9, 1),
      admissionNumber: '#204001',
      admissionDate: DateTime(2024, 1, 15),
      address: 'House 123, Street 5, Gulshan-e-Iqbal, Karachi',
      phoneNumber: '+92 300 1234567',
      email: 'ahmed.hassan@email.com',
    ),
    Student(
      id: '2',
      name: 'Mike Chen',
      grade: Grade.grade10,
      subjects: [
        const Subject(id: '2', name: 'Physics', shortName: 'Physics'),
        const Subject(id: '3', name: 'Chemistry', shortName: 'Chemistry'),
      ],
      monthlyFee: 120.0,
      paymentStatus: PaymentStatus.pending,
      nextPaymentDate: DateTime(2024, 1, 10),
      joinDate: DateTime(2023, 8, 15),
      admissionNumber: '#204002',
      admissionDate: DateTime(2023, 8, 15),
      address: 'Apartment 45, Block B, DHA Phase 2, Karachi',
      phoneNumber: '+92 321 9876543',
      email: 'mike.chen@email.com',
    ),
    Student(
      id: '3',
      name: 'Emma Davis',
      grade: Grade.grade9,
      subjects: [
        const Subject(id: '4', name: 'English', shortName: 'English'),
        const Subject(id: '5', name: 'Math', shortName: 'Math'),
      ],
      monthlyFee: 60.0,
      paymentStatus: PaymentStatus.overdue,
      nextPaymentDate: DateTime(2023, 12, 25),
      joinDate: DateTime(2023, 7, 20),
    ),
    Student(
      id: '4',
      name: 'Alex Rodriguez',
      grade: Grade.grade12,
      subjects: [const Subject(id: '6', name: 'Calculus', shortName: 'Calculus')],
      monthlyFee: 100.0,
      paymentStatus: PaymentStatus.paid,
      nextPaymentDate: DateTime(2024, 1, 20),
      joinDate: DateTime(2023, 6, 10),
    ),
    Student(
      id: '5',
      name: 'Lily Wang',
      grade: Grade.grade9,
      subjects: [const Subject(id: '7', name: 'Biology', shortName: 'Biology')],
      monthlyFee: 90.0,
      paymentStatus: PaymentStatus.newStudent,
      nextPaymentDate: DateTime(2024, 1, 25),
      joinDate: DateTime(2024, 1, 1),
    ),
    Student(
      id: '6',
      name: 'James Wilson',
      grade: Grade.grade7,
      subjects: [const Subject(id: '8', name: 'Science', shortName: 'Science')],
      monthlyFee: 70.0,
      paymentStatus: PaymentStatus.paid,
      nextPaymentDate: DateTime(2024, 1, 18),
      joinDate: DateTime(2023, 5, 5),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _filteredStudents = _allStudents;
  }

  void _updateSearch(String query) {
    setState(() {
      _searchQuery = query;
      _applyFilters();
    });
  }

  void _updateFilter(String filter) {
    setState(() {
      _selectedFilter = filter;
      _applyFilters();
    });
  }

  void _applyFilters() {
    _filteredStudents = _allStudents.where((student) {
      // Apply search filter
      bool matchesSearch = _searchQuery.isEmpty ||
          student.name.toLowerCase().contains(_searchQuery.toLowerCase());

      // Apply category filter
      bool matchesFilter = _selectedFilter == 'All' ||
          student.grade.category == _selectedFilter;

      return matchesSearch && matchesFilter;
    }).toList();
  }

  StudentsData get _studentsData {
    final statusCounts = <PaymentStatus, int>{};
    for (final status in PaymentStatus.values) {
      statusCounts[status] = _allStudents
          .where((student) => student.paymentStatus == status)
          .length;
    }

    return StudentsData(
      students: _filteredStudents,
      statusCounts: statusCounts,
    );
  }

  @override
  Widget build(BuildContext context) {
    final studentsData = _studentsData;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header with title and add button
            StudentsHeader(
              onAddPressed: () {
                Navigator.pushNamed(context, AppRoutes.addStudent);
              },
            ),

            // Search bar
            StudentsSearch(
              onSearchChanged: _updateSearch,
            ),

            // Filter tabs
            StudentsFilters(
              selectedFilter: _selectedFilter,
              onFilterChanged: _updateFilter,
            ),

            // Students list
            Expanded(
              child: StudentsList(
                students: studentsData.students,
              ),
            ),
          ],
        ),
      ),
    );
  }
}