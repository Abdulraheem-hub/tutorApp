/// @context7:feature:students
/// @context7:pattern:widget_component
///
/// Individual student card displaying student information
library;

import 'package:flutter/material.dart';
import '../../domain/entities/student_entities.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_utils.dart';

class StudentCard extends StatelessWidget {
  final Student student;
  final VoidCallback? onTap;

  const StudentCard({super.key, required this.student, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Profile Picture
            _buildProfilePicture(),

            const SizedBox(width: 12),

            // Student Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name and Status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          student.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textDark,
                          ),
                        ),
                      ),
                      _buildStatusBadge(),
                    ],
                  ),

                  const SizedBox(height: 4),

                  // Grade and Subjects
                  Text(
                    '${student.grade.displayName} • ${_getSubjectsText()}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textLight,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Fee and Payment Status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${AppUtils.formatCurrency(student.monthlyFee)}/month',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textDark,
                            ),
                          ),
                          if (student.outstandingBalance > 0)
                            Text(
                              'Due: ${AppUtils.formatCurrency(student.totalAmountDue)}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppTheme.errorColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (student.nextPaymentDate != null)
                            Text(
                              _getNextPaymentText(),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppTheme.textLight,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          _buildCurrentMonthStatus(),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfilePicture() {
    // Generate a color based on the student's name for consistent avatar colors
    final colors = [
      AppTheme.primaryPurple,
      AppTheme.greenPositive,
      AppTheme.orangePending,
      const Color(0xFF3B82F6),
      const Color(0xFFEC4899),
      const Color(0xFF06B6D4),
    ];
    final colorIndex = student.name.hashCode % colors.length;
    final avatarColor = colors[colorIndex.abs()];

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: avatarColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(24),
      ),
      child: student.profileImage != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.network(
                student.profileImage!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildInitialsAvatar(avatarColor);
                },
              ),
            )
          : _buildInitialsAvatar(avatarColor),
    );
  }

  Widget _buildInitialsAvatar(Color color) {
    final initials = student.name
        .split(' ')
        .map((name) => name.isNotEmpty ? name[0] : '')
        .join('')
        .toUpperCase();

    return Center(
      child: Text(
        initials,
        style: TextStyle(
          color: color,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color badgeColor;
    Color textColor;

    switch (student.paymentStatus) {
      case PaymentStatus.paid:
        badgeColor = AppTheme.greenPositive;
        textColor = Colors.white;
        break;
      case PaymentStatus.pending:
        badgeColor = AppTheme.orangePending;
        textColor = Colors.white;
        break;
      case PaymentStatus.overdue:
        badgeColor = AppTheme.errorColor;
        textColor = Colors.white;
        break;
      case PaymentStatus.newStudent:
        badgeColor = AppTheme.primaryPurple;
        textColor = Colors.white;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        student.paymentStatus.displayName,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildCurrentMonthStatus() {
    if (student.currentMonthPaid) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: AppTheme.greenPositive,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text(
          'Current Month Paid',
          style: TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: AppTheme.orangePending,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text(
          'Current Month Due',
          style: TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }
  }

  String _getSubjectsText() {
    if (student.subjects.isEmpty) return 'No subjects';
    if (student.subjects.length == 1) {
      return student.subjects.first.shortName ?? student.subjects.first.name;
    }
    return '${student.subjects.length} subjects';
  }

  String _getNextPaymentText() {
    if (student.nextPaymentDate == null) return '';

    final now = DateTime.now();
    final nextPayment = student.nextPaymentDate!;
    final difference = nextPayment.difference(now).inDays;

    if (difference < 0) {
      return 'Overdue ${difference.abs()} days';
    } else if (difference == 0) {
      return 'Due today';
    } else {
      return 'Next: ${AppUtils.formatDate(nextPayment)}';
    }
  }
}
