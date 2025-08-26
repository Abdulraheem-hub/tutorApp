/// @context7:feature:students
/// @context7:pattern:widget_component
/// 
/// Students filter tabs
library;

import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class StudentsFilters extends StatelessWidget {
  final String selectedFilter;
  final ValueChanged<String> onFilterChanged;

  const StudentsFilters({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  static const List<String> filters = [
    'All',
    'Grade 1-5',
    'Grade 6-10',
    'High School',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      margin: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: filters.map((filter) {
          final isSelected = filter == selectedFilter;
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => onFilterChanged(filter),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? AppTheme.primaryPurple 
                      : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected 
                        ? AppTheme.primaryPurple 
                        : AppTheme.textLight.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  filter,
                  style: TextStyle(
                    color: isSelected 
                        ? Colors.white 
                        : AppTheme.textLight,
                    fontSize: 14,
                    fontWeight: isSelected 
                        ? FontWeight.w600 
                        : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}