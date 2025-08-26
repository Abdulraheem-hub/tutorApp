/// @context7:feature:payment_settings
/// @context7:pattern:widget_component
/// 
/// Payment method card widget for displaying individual payment methods
library;

import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../pages/payment_settings_page.dart';

class PaymentMethodCard extends StatelessWidget {
  final PaymentMethod paymentMethod;
  final VoidCallback onTap;
  final VoidCallback onSetAsDefault;
  final VoidCallback onDelete;

  const PaymentMethodCard({
    super.key,
    required this.paymentMethod,
    required this.onTap,
    required this.onSetAsDefault,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: paymentMethod.isDefault
              ? AppTheme.primaryPurple.withValues(alpha: 0.3)
              : AppTheme.textLight.withValues(alpha: 0.2),
          width: paymentMethod.isDefault ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Payment method icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _getIconBackgroundColor(),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getPaymentMethodIcon(),
                  color: _getIconColor(),
                  size: 24,
                ),
              ),

              const SizedBox(width: 16),

              // Payment method details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            paymentMethod.title,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textDark,
                            ),
                          ),
                        ),
                        if (paymentMethod.isDefault)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryPurple.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Default',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppTheme.primaryPurple,
                                fontWeight: FontWeight.w500,
                                fontSize: 11,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      paymentMethod.subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textLight,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // More options icon
              Icon(Icons.more_vert, color: AppTheme.textLight, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getPaymentMethodIcon() {
    switch (paymentMethod.type) {
      case PaymentMethodType.upi:
        return Icons.account_balance_wallet;
      case PaymentMethodType.cash:
        return Icons.payments;
      case PaymentMethodType.creditCard:
        return Icons.credit_card;
      case PaymentMethodType.debitCard:
        return Icons.credit_card;
      case PaymentMethodType.bankTransfer:
        return Icons.account_balance;
    }
  }

  Color _getIconColor() {
    switch (paymentMethod.type) {
      case PaymentMethodType.upi:
        return AppTheme.successColor;
      case PaymentMethodType.cash:
        return AppTheme.warningColor;
      case PaymentMethodType.creditCard:
        return AppTheme.primaryPurple;
      case PaymentMethodType.debitCard:
        return AppTheme.warningColor;
      case PaymentMethodType.bankTransfer:
        return AppTheme.infoColor;
    }
  }

  Color _getIconBackgroundColor() {
    switch (paymentMethod.type) {
      case PaymentMethodType.upi:
        return AppTheme.successColor.withValues(alpha: 0.1);
      case PaymentMethodType.cash:
        return AppTheme.warningColor.withValues(alpha: 0.1);
      case PaymentMethodType.creditCard:
        return AppTheme.primaryPurple.withValues(alpha: 0.1);
      case PaymentMethodType.debitCard:
        return AppTheme.warningColor.withValues(alpha: 0.1);
      case PaymentMethodType.bankTransfer:
        return AppTheme.infoColor.withValues(alpha: 0.1);
    }
  }
}
