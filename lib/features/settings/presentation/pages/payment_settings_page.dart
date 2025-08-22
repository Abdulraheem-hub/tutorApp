/**
 * @context7:feature:payment_settings
 * @context7:pattern:page_widget
 * 
 * Payment method settings page for managing available payment options
 * that tutors can select when recording student fee payments
 */

import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../widgets/payment_method_card.dart';
import '../widgets/add_payment_method_sheet.dart';

class PaymentSettingsPage extends StatefulWidget {
  const PaymentSettingsPage({super.key});

  @override
  State<PaymentSettingsPage> createState() => _PaymentSettingsPageState();
}

class _PaymentSettingsPageState extends State<PaymentSettingsPage> {
  // Available payment method options for students
  List<PaymentMethod> paymentMethods = [
    PaymentMethod(
      id: '1',
      type: PaymentMethodType.upi,
      title: 'UPI Payment',
      subtitle: 'Google Pay, PhonePe, Paytm, etc.',
      isDefault: true,
    ),
    PaymentMethod(
      id: '2',
      type: PaymentMethodType.cash,
      title: 'Cash Payment',
      subtitle: 'Direct cash payment',
      isDefault: false,
    ),
    PaymentMethod(
      id: '3',
      type: PaymentMethodType.bankTransfer,
      title: 'Bank Transfer',
      subtitle: 'NEFT, RTGS, IMPS',
      isDefault: false,
    ),
    PaymentMethod(
      id: '4',
      type: PaymentMethodType.creditCard,
      title: 'Card Payment',
      subtitle: 'Credit/Debit card payment',
      isDefault: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
        ),
        title: Text(
          'Payment Methods',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header text
            Text(
              'Add payment method labels to categorize how students pay their fees',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textLight,
              ),
            ),

            const SizedBox(height: 24),

            // Payment methods list
            if (paymentMethods.isEmpty)
              _buildEmptyState(context)
            else
              _buildPaymentMethodsList(),

            const SizedBox(height: 24),

            // Add payment method button
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _showAddPaymentMethodSheet,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.add, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Add Payment Method',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.textLight.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.lightPurple,
              borderRadius: BorderRadius.circular(40),
            ),
            child: const Icon(
              Icons.credit_card_outlined,
              size: 40,
              color: AppTheme.primaryPurple,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No Payment Methods Added',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add payment method labels to categorize student payments',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.textLight,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodsList() {
    return Column(
      children: paymentMethods.map((method) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: PaymentMethodCard(
            paymentMethod: method,
            onTap: () => _showPaymentMethodOptions(method),
            onSetAsDefault: () => _setAsDefault(method),
            onDelete: () => _deletePaymentMethod(method),
          ),
        );
      }).toList(),
    );
  }

  void _showAddPaymentMethodSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddPaymentMethodSheet(
        onPaymentMethodAdded: (PaymentMethod newMethod) {
          setState(() {
            paymentMethods.add(newMethod);
          });
        },
      ),
    );
  }

  void _showPaymentMethodOptions(PaymentMethod method) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.textLight.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              method.title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              method.subtitle,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppTheme.textLight),
            ),
            const SizedBox(height: 24),
            if (!method.isDefault)
              ListTile(
                leading: const Icon(Icons.star_outline),
                title: const Text('Set as Default'),
                onTap: () {
                  Navigator.pop(context);
                  _setAsDefault(method);
                },
              ),
            ListTile(
              leading: Icon(Icons.edit_outlined, color: AppTheme.primaryPurple),
              title: const Text('Edit'),
              onTap: () {
                Navigator.pop(context);
                _editPaymentMethod(method);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete_outline, color: AppTheme.errorColor),
              title: Text(
                'Delete',
                style: TextStyle(color: AppTheme.errorColor),
              ),
              onTap: () {
                Navigator.pop(context);
                _deletePaymentMethod(method);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _setAsDefault(PaymentMethod method) {
    setState(() {
      for (var pm in paymentMethods) {
        pm.isDefault = pm.id == method.id;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${method.title} set as default payment method'),
        backgroundColor: AppTheme.successColor,
      ),
    );
  }

  void _editPaymentMethod(PaymentMethod method) {
    // TODO: Implement edit functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Edit payment method functionality coming soon!'),
      ),
    );
  }

  void _deletePaymentMethod(PaymentMethod method) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Payment Method'),
        content: Text('Are you sure you want to delete ${method.title}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                paymentMethods.removeWhere((pm) => pm.id == method.id);
                // If deleted method was default, set first method as default
                if (method.isDefault && paymentMethods.isNotEmpty) {
                  paymentMethods.first.isDefault = true;
                }
              });

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${method.title} deleted'),
                  backgroundColor: AppTheme.errorColor,
                ),
              );
            },
            child: Text('Delete', style: TextStyle(color: AppTheme.errorColor)),
          ),
        ],
      ),
    );
  }
}

// Payment method model
class PaymentMethod {
  final String id;
  final PaymentMethodType type;
  final String title;
  final String subtitle;
  bool isDefault;

  PaymentMethod({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.isDefault,
  });
}

enum PaymentMethodType { upi, cash, creditCard, debitCard, bankTransfer }
