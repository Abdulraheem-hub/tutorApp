/// @context7:feature:payments
/// @context7:dependencies:flutter,payment_entity,app_theme
/// @context7:pattern:widget_component
///
/// Comprehensive payment card widget that displays detailed payment information
/// including payment status, amounts, due dates, and various payment scenarios
library;

import 'package:flutter/material.dart';
import '../../domain/entities/payment_entity.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_utils.dart';

class ComprehensivePaymentCard extends StatelessWidget {
  final PaymentEntity payment;
  final VoidCallback? onTap;
  final bool showDetailedInfo;
  final bool showStudentInfo;

  const ComprehensivePaymentCard({
    super.key,
    required this.payment,
    this.onTap,
    this.showDetailedInfo = true,
    this.showStudentInfo = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getStatusBorderColor(), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCompactHeader(),
              const SizedBox(height: 8),
              _buildCompactBody(),
              if (showDetailedInfo &&
                  (payment.isPartialPayment ||
                      payment.excessAmount > 0 ||
                      payment.outstandingBalanceBefore > 0)) ...[
                const SizedBox(height: 8),
                _buildCompactBreakdown(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompactHeader() {
    return Row(
      children: [
        // Payment method icon
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: _getMethodColor().withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(_getMethodIcon(), color: _getMethodColor(), size: 18),
        ),
        const SizedBox(width: 10),

        // Student name and amount
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showStudentInfo) ...[
                Text(
                  payment.studentName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 2),
              ],
              Row(
                children: [
                  Text(
                    payment.formattedAmount,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _getAmountColor(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (payment.isPartialPayment || payment.excessAmount > 0)
                    _buildCompactStatusBadge(),
                ],
              ),
            ],
          ),
        ),

        // Payment status
        _buildMainStatusBadge(),
      ],
    );
  }

  Widget _buildCompactStatusBadge() {
    String text;
    Color color;
    IconData icon;

    if (payment.isPartialPayment) {
      text = 'Partial';
      color = AppTheme.warningColor;
      icon = Icons.warning_rounded;
    } else if (payment.excessAmount > 0) {
      text = 'Excess';
      color = AppTheme.infoColor;
      icon = Icons.trending_up;
    } else {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 2),
          Text(
            text,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainStatusBadge() {
    final statusData = _getPaymentStatusData();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: statusData['color'].withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        statusData['text'],
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: statusData['color'],
        ),
      ),
    );
  }

  Widget _buildCompactBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date and method in one line
        Row(
          children: [
            Icon(Icons.calendar_today, size: 12, color: AppTheme.textLight),
            const SizedBox(width: 4),
            Text(
              AppUtils.formatDate(payment.date),
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textLight,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 12),
            Icon(Icons.payment, size: 12, color: AppTheme.textLight),
            const SizedBox(width: 4),
            Text(
              payment.methodDisplayName,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textLight,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Text(
              AppUtils.formatMonthYear(payment.paymentPeriod),
              style: const TextStyle(
                fontSize: 11,
                color: AppTheme.textLight,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),

        // Status description
        Text(
          _getPaymentStatusDescription(),
          style: TextStyle(
            fontSize: 12,
            color: _getStatusBorderColor(),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildCompactBreakdown() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Breakdown',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
              if (payment.outstandingBalanceAfter > 0)
                Text(
                  'Due: ${AppUtils.formatCurrency(payment.outstandingBalanceAfter)}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.warningColor,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),

          // Compact breakdown rows
          if (payment.monthlyFeeAtPayment > 0)
            _buildCompactBreakdownRow(
              'Monthly Fee',
              AppUtils.formatCurrency(payment.monthlyFeeAtPayment),
              Colors.blue.shade600,
            ),

          if (payment.outstandingBalanceBefore > 0)
            _buildCompactBreakdownRow(
              'Previous Due',
              AppUtils.formatCurrency(payment.outstandingBalanceBefore),
              AppTheme.errorColor,
            ),

          if (payment.isPartialPayment)
            _buildCompactBreakdownRow(
              'Short',
              AppUtils.formatCurrency(payment.shortfallAmount),
              AppTheme.warningColor,
            ),

          if (payment.excessAmount > 0)
            _buildCompactBreakdownRow(
              'Credit',
              AppUtils.formatCurrency(payment.excessAmount),
              AppTheme.infoColor,
            ),
        ],
      ),
    );
  }

  Widget _buildCompactBreakdownRow(String label, String amount, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppTheme.textDark,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods for styling
  Color _getAmountColor() {
    if (payment.isPartialPayment) {
      return AppTheme.warningColor;
    } else if (payment.excessAmount > 0) {
      return AppTheme.infoColor;
    } else {
      return AppTheme.successColor;
    }
  }

  Color _getMethodColor() {
    switch (payment.method) {
      case PaymentMethod.cash:
        return AppTheme.successColor;
      case PaymentMethod.creditCard:
      case PaymentMethod.check:
        return AppTheme.warningColor;
      case PaymentMethod.bankTransfer:
        return AppTheme.infoColor;
      case PaymentMethod.paypal:
      case PaymentMethod.venmo:
        return AppTheme.primaryPurple;
      default:
        return Colors.grey.shade600;
    }
  }

  IconData _getMethodIcon() {
    switch (payment.method) {
      case PaymentMethod.cash:
        return Icons.money;
      case PaymentMethod.creditCard:
        return Icons.credit_card;
      case PaymentMethod.bankTransfer:
        return Icons.account_balance;
      case PaymentMethod.check:
        return Icons.receipt_long;
      case PaymentMethod.paypal:
        return Icons.account_balance_wallet;
      case PaymentMethod.venmo:
        return Icons.mobile_friendly;
      default:
        return Icons.payment;
    }
  }

  Map<String, dynamic> _getPaymentStatusData() {
    if (payment.isPartialPayment) {
      return {
        'text': 'Partial Payment',
        'icon': Icons.warning_rounded,
        'color': AppTheme.warningColor,
      };
    } else if (payment.excessAmount > 0) {
      return {
        'text': 'Overpayment',
        'icon': Icons.trending_up,
        'color': AppTheme.infoColor,
      };
    } else if (payment.outstandingBalanceAfter > 0) {
      return {
        'text': 'Balance Due',
        'icon': Icons.schedule,
        'color': AppTheme.warningColor,
      };
    } else {
      return {
        'text': 'Completed',
        'icon': Icons.check_circle,
        'color': AppTheme.successColor,
      };
    }
  }

  Color _getStatusBorderColor() {
    final statusData = _getPaymentStatusData();
    return statusData['color'];
  }

  String _getPaymentStatusDescription() {
    if (payment.isPartialPayment) {
      return 'Paid ${payment.formattedAmount} • ${AppUtils.formatCurrency(payment.shortfallAmount)} due next month';
    } else if (payment.excessAmount > 0) {
      return 'Full payment + ${AppUtils.formatCurrency(payment.excessAmount)} credit applied';
    } else if (payment.outstandingBalanceAfter > 0) {
      return 'Paid but ${AppUtils.formatCurrency(payment.outstandingBalanceAfter)} still outstanding';
    } else {
      return 'Payment completed successfully';
    }
  }
}
