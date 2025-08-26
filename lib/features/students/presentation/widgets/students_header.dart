/// @context7:feature:students
/// @context7:pattern:widget_component
/// 
/// Students page header with title and add button
library;

import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class StudentsHeader extends StatelessWidget {
  final VoidCallback onAddPressed;

  const StudentsHeader({
    super.key,
    required this.onAddPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Title
          Text(
            'Students',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),

          // Add button
          Container(
            decoration: BoxDecoration(
              color: AppTheme.primaryPurple,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: onAddPressed,
              icon: const Icon(
                Icons.add,
                color: Colors.white,
                size: 24,
              ),
              tooltip: 'Add Student',
            ),
          ),
        ],
      ),
    );
  }
}