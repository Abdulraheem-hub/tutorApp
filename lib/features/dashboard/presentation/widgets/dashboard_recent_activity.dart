/**
 * @context7:feature:dashboard
 * @context7:dependencies:dashboard_entities,app_utils
 * @context7:pattern:widget_component
 * 
 * Recent activity section showing student payment activities
 */

import 'package:flutter/material.dart';
import '../../domain/entities/dashboard_entities.dart';
import '../../../../core/utils/app_utils.dart';
import '../../../../core/theme/app_theme.dart';

class DashboardRecentActivity extends StatelessWidget {
  final List<StudentActivity> activities;
  final bool isRefreshing;

  const DashboardRecentActivity({
    super.key,
    required this.activities,
    this.isRefreshing = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Activity',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            TextButton(
              onPressed: () {
                // TODO: Navigate to full activity list
                _showComingSoonDialog(context);
              },
              child: const Text('View All'),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Activity list
        AnimatedOpacity(
          opacity: isRefreshing ? 0.6 : 1.0,
          duration: const Duration(milliseconds: 300),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: activities.asMap().entries.map((entry) {
                final index = entry.key;
                final activity = entry.value;
                final isLast = index == activities.length - 1;
                
                return _ActivityItem(
                  activity: activity,
                  showDivider: !isLast,
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  void _showComingSoonDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('View All Activities'),
        content: const Text('Full activity list is coming soon!'),
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

class _ActivityItem extends StatelessWidget {
  final StudentActivity activity;
  final bool showDivider;

  const _ActivityItem({
    required this.activity,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Profile avatar
              _ProfileAvatar(
                name: activity.name,
                imageUrl: activity.profileImage,
                status: activity.status,
              ),
              
              const SizedBox(width: 12),
              
              // Activity details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      activity.status.displayName,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Amount and time
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (activity.amount > 0) ...[
                    Text(
                      _getAmountDisplay(activity),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: _getAmountColor(activity, theme),
                      ),
                    ),
                    const SizedBox(height: 2),
                  ],
                  Text(
                    AppUtils.timeAgo(activity.lastActivity),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        if (showDivider)
          Divider(
            height: 1,
            color: theme.colorScheme.outlineVariant,
          ),
      ],
    );
  }

  String _getAmountDisplay(StudentActivity activity) {
    switch (activity.status) {
      case ActivityStatus.paid:
        return '+${AppUtils.formatCurrency(activity.amount)}';
      case ActivityStatus.pending:
      case ActivityStatus.overdue:
        return AppUtils.formatCurrency(activity.amount);
      case ActivityStatus.newStudent:
        return 'New';
    }
  }

  Color _getAmountColor(StudentActivity activity, ThemeData theme) {
    switch (activity.status) {
      case ActivityStatus.paid:
        return const Color(0xFF10B981); // Green from image
      case ActivityStatus.pending:
        return const Color(0xFFE97B47); // Orange from image
      case ActivityStatus.overdue:
        return const Color(0xFFEF4444); // Red
      case ActivityStatus.newStudent:
        return const Color(0xFF6366F1); // Purple from image
    }
  }
}

class _ProfileAvatar extends StatelessWidget {
  final String name;
  final String? imageUrl;
  final ActivityStatus status;

  const _ProfileAvatar({
    required this.name,
    this.imageUrl,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Stack(
      children: [
        // Avatar
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(24),
          ),
          child: imageUrl != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.network(
                    imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildInitialsAvatar(theme);
                    },
                  ),
                )
              : _buildInitialsAvatar(theme),
        ),
        
        // Status indicator
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: _getStatusColor(theme),
              border: Border.all(
                color: theme.colorScheme.surface,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInitialsAvatar(ThemeData theme) {
    final initials = name
        .split(' ')
        .map((word) => word.isNotEmpty ? word[0].toUpperCase() : '')
        .take(2)
        .join();
    
    return Center(
      child: Text(
        initials,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }

  Color _getStatusColor(ThemeData theme) {
    switch (status) {
      case ActivityStatus.paid:
        return const Color(0xFF10B981); // Green from image
      case ActivityStatus.pending:
        return const Color(0xFFE97B47); // Orange from image
      case ActivityStatus.overdue:
        return const Color(0xFFEF4444); // Red
      case ActivityStatus.newStudent:
        return const Color(0xFF6366F1); // Purple from image
    }
  }
}
