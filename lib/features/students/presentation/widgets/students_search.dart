/**
 * @context7:feature:students
 * @context7:pattern:widget_component
 * 
 * Students search bar
 */

import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class StudentsSearch extends StatelessWidget {
  final ValueChanged<String> onSearchChanged;

  const StudentsSearch({
    super.key,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      margin: const EdgeInsets.only(bottom: 16),
      child: TextField(
        onChanged: onSearchChanged,
        decoration: InputDecoration(
          hintText: 'Search students...',
          hintStyle: TextStyle(
            color: AppTheme.textLight,
            fontSize: 16,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: AppTheme.textLight,
            size: 20,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        style: TextStyle(
          color: AppTheme.textDark,
          fontSize: 16,
        ),
      ),
    );
  }
}