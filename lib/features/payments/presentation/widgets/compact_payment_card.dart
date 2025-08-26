/// @context7:feature:payments
/// @context7:dependencies:flutter,payment_entity,app_theme
/// @context7:pattern:widget_component
///
/// Compact payment card widget for quick overview of payment information
/// Used in payment lists where space is limited
library;

import 'package:flutter/material.dart';
import '../../domain/entities/payment_entity.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_utils.dart';

class CompactPaymentCard extends StatelessWidget {
  final PaymentEntity payment;
  final VoidCallback? onTap;
  final bool showStudentName;

  const CompactPaymentCard({
    super.key,
    required this.payment,
    this.onTap,
    this.showStudentName = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: _getStatusColor().withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              // Payment method icon
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: _getMethodColor().withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getMethodIcon(),
                  color: _getMethodColor(),
                  size: 16,
                ),
              ),
              const SizedBox(width: 10),

              // Payment info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (showStudentName) ...[
                      Text(
                        payment.studentName,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                    ],
                    Row(
                      children: [
                        Text(
                          AppUtils.formatDate(payment.date),
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.textLight,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Text(
                          ' • ',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppTheme.textLight,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            payment.methodDisplayName,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppTheme.textLight,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    _buildStatusIndicator(),
                  ],
                ),
              ),

              // Amount and status
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    payment.formattedAmount,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: _getAmountColor(),
                    ),
                  ),
                  const SizedBox(height: 2),
                  if (payment.isPartialPayment || payment.excessAmount > 0)
                    _buildAmountBadge(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIndicator() {
    String statusText;
    Color statusColor;

    if (payment.isPartialPayment) {
      statusText = '${AppUtils.formatCurrency(payment.shortfallAmount)} due';
      statusColor = AppTheme.warningColor;
    } else if (payment.excessAmount > 0) {
      statusText = '${AppUtils.formatCurrency(payment.excessAmount)} credit';
      statusColor = AppTheme.infoColor;
    } else if (payment.outstandingBalanceAfter > 0) {
      statusText =
          '${AppUtils.formatCurrency(payment.outstandingBalanceAfter)} outstanding';
      statusColor = AppTheme.warningColor;
    } else {
      statusText = 'Completed';
      statusColor = AppTheme.successColor;
    }

    return Text(
      statusText,
      style: TextStyle(
        fontSize: 10,
        color: statusColor,
        fontWeight: FontWeight.w600,
      ),
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildAmountBadge() {
    String text;
    Color color;

    if (payment.isPartialPayment) {
      text = 'Partial';
      color = AppTheme.warningColor;
    } else if (payment.excessAmount > 0) {
      text = 'Credit';
      color = AppTheme.infoColor;
    } else {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 0.5),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 8,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
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

  Color _getStatusColor() {
    if (payment.isPartialPayment) {
      return AppTheme.warningColor;
    } else if (payment.excessAmount > 0) {
      return AppTheme.infoColor;
    } else if (payment.outstandingBalanceAfter > 0) {
      return AppTheme.warningColor;
    } else {
      return AppTheme.successColor;
    }
  }

  Color _getAmountColor() {
    if (payment.isPartialPayment) {
      return AppTheme.warningColor;
    } else if (payment.excessAmount > 0) {
      return AppTheme.infoColor;
    } else {
      return AppTheme.successColor;
    }
  }
}
