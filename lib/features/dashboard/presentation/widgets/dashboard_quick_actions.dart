/// @context7:feature:dashboard
/// @context7:pattern:widget_component
///
/// Quick actions section with modern Material Design 3 style buttons
library;

import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class DashboardQuickActions extends StatelessWidget {
  const DashboardQuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.textDark,
          ),
        ),

        const SizedBox(height: 16),

        // Row of action buttons
        Row(
          children: [
            Expanded(
              child: _ModernActionButton(
                icon: Icons.person_add_outlined,
                label: 'Add Student',
                color: AppTheme.successColor,
                backgroundColor: AppTheme.successColor.withValues(alpha: 0.1),
                onPressed: () {
                  Navigator.of(context).pushNamed('/add-student');
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ModernActionButton(
                icon: Icons.group_outlined,
                label: 'View Students',
                color: AppTheme.infoColor,
                backgroundColor: AppTheme.infoColor.withValues(alpha: 0.1),
                onPressed: () {
                  Navigator.of(context).pushNamed('/students');
                },
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Second row for payments
        Row(
          children: [
            Expanded(
              child: _ModernActionButton(
                icon: Icons.payment_outlined,
                label: 'View Payments',
                color: AppTheme.primaryPurple,
                backgroundColor: AppTheme.primaryPurple.withValues(alpha: 0.1),
                onPressed: () {
                  Navigator.of(context).pushNamed('/payments');
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ModernActionButton(
                icon: Icons.analytics_outlined,
                label: 'Analytics',
                color: AppTheme.warningColor,
                backgroundColor: AppTheme.warningColor.withValues(alpha: 0.1),
                onPressed: () {
                  _showComingSoonDialog(context, 'Analytics');
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showComingSoonDialog(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(feature),
        content: Text('$feature feature is coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class _ModernActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color backgroundColor;
  final VoidCallback onPressed;

  const _ModernActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.backgroundColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textDark,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
