/// @context7:feature:students
/// @context7:dependencies:flutter,student_entities,flutter_bloc
/// @context7:pattern:page_widget
///
/// Students page with search, filters, and student list using BLoC
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../widgets/students_header.dart';
import '../widgets/students_search.dart';
import '../widgets/students_filters.dart';
import '../widgets/students_list.dart';
import '../bloc/students_bloc.dart';
import '../bloc/students_event.dart';
import '../bloc/students_state.dart';
import '../utils/student_mapper.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';

class StudentsPage extends StatefulWidget {
  const StudentsPage({super.key});

  @override
  State<StudentsPage> createState() => _StudentsPageState();
}

class _StudentsPageState extends State<StudentsPage> {
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    // Load students when the page is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StudentsBloc>().add(const LoadStudents());
    });
  }

  @override
  Widget build(BuildContext context) {
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
              onSearchChanged: (query) {
                context.read<StudentsBloc>().add(SearchStudents(query));
              },
            ),

            // Filter tabs
            StudentsFilters(
              selectedFilter: _selectedFilter,
              onFilterChanged: (filter) {
                setState(() {
                  _selectedFilter = filter;
                });
                String blocFilter = 'all';
                switch (filter) {
                  case 'Grade 1-5':
                  case 'Grade 6-10':
                  case 'High School':
                    blocFilter = 'active'; // For now, map to active
                    break;
                  default:
                    blocFilter = 'all';
                }
                context.read<StudentsBloc>().add(FilterStudents(blocFilter));
              },
            ),

            // Students list with BLoC state management
            Expanded(
              child: BlocBuilder<StudentsBloc, StudentsState>(
                builder: (context, state) {
                  if (state is StudentsLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.primaryPurple,
                      ),
                    );
                  } else if (state is StudentsLoaded) {
                    // Convert StudentEntity to Student for UI
                    final students = state.filteredStudents
                        .map((entity) => StudentMapper.fromEntity(entity))
                        .toList();

                    return StudentsList(students: students);
                  } else if (state is StudentsEmpty) {
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
                            'Add your first student to get started',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  } else if (state is StudentsError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.red,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Error loading students',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.red,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            state.message,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.red,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              context.read<StudentsBloc>().add(
                                const LoadStudents(),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryPurple,
                            ),
                            child: const Text(
                              'Retry',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // Default fallback
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.primaryPurple,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
