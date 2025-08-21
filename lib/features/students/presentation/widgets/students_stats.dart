/**
 * @context7:feature:students
 * @context7:pattern:widget_component
 * 
 * Students statistics cards
 */

import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_utils.dart';

class StudentsStats extends StatelessWidget {
  final int totalStudents;
  final double monthlyRevenue;

  const StudentsStats({
    super.key,
    required this.totalStudents,
    required this.monthlyRevenue,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      margin: const EdgeInsets.only(bottom: 24),
      child: Row(
        children: [
          // Total Students Card
          Expanded(
            child: _StatCard(
              title: 'Total Students',
              value: totalStudents.toString(),
              color: AppTheme.textDark,
              backgroundColor: Colors.white,
            ),
          ),

          const SizedBox(width: 16),

          // Monthly Revenue Card
          Expanded(
            child: _StatCard(
              title: 'Monthly Revenue',
              value: AppUtils.formatCurrency(monthlyRevenue),
              color: AppTheme.greenPositive,
              backgroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final Color backgroundColor;

  const _StatCard({
    required this.title,
    required this.value,
    required this.color,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Value
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),

          const SizedBox(height: 4),

          // Title
          Text(
            title,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.textLight,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}