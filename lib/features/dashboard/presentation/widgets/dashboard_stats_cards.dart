/**
 * @context7:feature:dashboard
 * @context7:dependencies:dashboard_entities,app_utils
 * @context7:pattern:widget_component
 * 
 * Dashboard stats cards showing earnings, students, pending payments, and monthly goal
 */

import 'package:flutter/material.dart';
import '../../domain/entities/dashboard_entities.dart';
import '../../../../core/utils/app_utils.dart';
import '../../../../core/theme/app_theme.dart';

class DashboardStatsCards extends StatelessWidget {
  final DashboardData dashboardData;
  final bool isRefreshing;

  const DashboardStatsCards({
    super.key,
    required this.dashboardData,
    this.isRefreshing = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Only two cards: Expected Income and Received Income
        Row(
          children: [
            Expanded(
              child: _StatsCard(
                title: 'Expected Income',
                subtitle: 'This month',
                value: AppUtils.formatCurrency(dashboardData.monthlyGoal),
                change: 0.0,
                changeLabel: '',
                icon: Icons.trending_up,
                backgroundColor: const Color(0xFFEEF2FF), // Light purple background
                iconColor: const Color(0xFF6366F1),
                isRefreshing: isRefreshing,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _StatsCard(
                title: 'Received Income',
                subtitle: 'Till now',
                value: AppUtils.formatCurrency(dashboardData.totalEarnings),
                change: dashboardData.earningsChange,
                changeLabel: '+${dashboardData.earningsChange.toInt()}%',
                icon: Icons.account_balance_wallet_outlined,
                backgroundColor: const Color(0xFFECFDF5), // Light green background
                iconColor: AppTheme.successColor,
                isRefreshing: isRefreshing,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatsCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String value;
  final double change;
  final String changeLabel;
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
  final bool isRefreshing;

  const _StatsCard({
    required this.title,
    this.subtitle,
    required this.value,
    required this.change,
    required this.changeLabel,
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
    this.isRefreshing = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AnimatedOpacity(
      opacity: isRefreshing ? 0.6 : 1.0,
      duration: const Duration(milliseconds: 300),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon and change indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 20,
                  ),
                ),
                if (change > 0 && changeLabel.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.successColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.trending_up,
                          color: AppTheme.successColor,
                          size: 12,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          changeLabel,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.successColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Value
            Text(
              value,
              style: theme.textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
                fontSize: 28,
              ),
            ),
            
            const SizedBox(height: 4),
            
            // Title and subtitle
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.textLight,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  final String title;
  final double current;
  final double target;
  final double progress;
  final bool isRefreshing;

  const _GoalCard({
    required this.title,
    required this.current,
    required this.target,
    required this.progress,
    this.isRefreshing = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AnimatedOpacity(
      opacity: isRefreshing ? 0.6 : 1.0,
      duration: const Duration(milliseconds: 300),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6), // Light purple background
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon and progress text
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.flag_outlined,
                    color: AppTheme.purpleGoal,
                    size: 20,
                  ),
                ),
                Text(
                  'This month',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.textLight,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Target amount
            Text(
              AppUtils.formatCurrency(target),
              style: theme.textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
                fontSize: 28,
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
            
            const SizedBox(height: 12),
            
            // Progress bar
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        '${(progress * 100).toInt()}% complete',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.textLight,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      AppUtils.formatCurrency(current),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.purpleGoal,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppTheme.purpleGoal,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
