/**
 * @context7:feature:payment_settings
 * @context7:pattern:modal_sheet
 * 
 * Bottom sheet for adding new payment options that students can use
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_theme.dart';
import '../pages/payment_settings_page.dart';

class AddPaymentMethodSheet extends StatefulWidget {
  final Function(PaymentMethod) onPaymentMethodAdded;

  const AddPaymentMethodSheet({super.key, required this.onPaymentMethodAdded});

  @override
  State<AddPaymentMethodSheet> createState() => _AddPaymentMethodSheetState();
}

class _AddPaymentMethodSheetState extends State<AddPaymentMethodSheet> {
  PaymentMethodType selectedType = PaymentMethodType.upi;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _detailsController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _titleController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.9,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppTheme.textLight.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Title
                  Text(
                    'Add Payment Method',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textDark,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Payment method type selection
                  Text(
                    'Payment Method Type',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textDark,
                    ),
                  ),

                  const SizedBox(height: 12),

                  _buildPaymentTypeSelector(),

                  const SizedBox(height: 24),

                  // Title field
                  Text(
                    _getTitleLabel(),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textDark,
                    ),
                  ),

                  const SizedBox(height: 8),

                  TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      hintText: _getTitleHint(),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppTheme.textLight.withOpacity(0.3),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppTheme.textLight.withOpacity(0.3),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppTheme.primaryPurple,
                          width: 2,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter ${_getTitleLabel().toLowerCase()}';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  // Details field
                  Text(
                    _getDetailsLabel(),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textDark,
                    ),
                  ),

                  const SizedBox(height: 8),

                  TextFormField(
                    controller: _detailsController,
                    decoration: InputDecoration(
                      hintText: _getDetailsHint(),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppTheme.textLight.withOpacity(0.3),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppTheme.textLight.withOpacity(0.3),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppTheme.primaryPurple,
                          width: 2,
                        ),
                      ),
                    ),
                    keyboardType: _getKeyboardType(),
                    inputFormatters: _getInputFormatters(),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter ${_getDetailsLabel().toLowerCase()}';
                      }
                      return _validateDetails(value);
                    },
                  ),

                  const SizedBox(height: 32),

                  // Add button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _addPaymentMethod,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryPurple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Add Payment Method',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPaymentTypeSelector() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.textLight.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: PaymentMethodType.values.map((type) {
          final isSelected = selectedType == type;
          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => setState(() => selectedType = type),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.primaryPurple.withOpacity(0.1)
                      : null,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _getTypeIconBackgroundColor(type),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        _getTypeIcon(type),
                        color: _getTypeIconColor(type),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        _getTypeTitle(type),
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: isSelected
                              ? AppTheme.primaryPurple
                              : AppTheme.textDark,
                        ),
                      ),
                    ),
                    Radio<PaymentMethodType>(
                      value: type,
                      groupValue: selectedType,
                      onChanged: (value) =>
                          setState(() => selectedType = value!),
                      activeColor: AppTheme.primaryPurple,
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _getTypeTitle(PaymentMethodType type) {
    switch (type) {
      case PaymentMethodType.upi:
        return 'UPI Payment';
      case PaymentMethodType.cash:
        return 'Cash Payment';
      case PaymentMethodType.creditCard:
        return 'Credit Card';
      case PaymentMethodType.debitCard:
        return 'Debit Card';
      case PaymentMethodType.bankTransfer:
        return 'Bank Transfer';
    }
  }

  IconData _getTypeIcon(PaymentMethodType type) {
    switch (type) {
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

  Color _getTypeIconColor(PaymentMethodType type) {
    switch (type) {
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

  Color _getTypeIconBackgroundColor(PaymentMethodType type) {
    switch (type) {
      case PaymentMethodType.upi:
        return AppTheme.successColor.withOpacity(0.1);
      case PaymentMethodType.cash:
        return AppTheme.warningColor.withOpacity(0.1);
      case PaymentMethodType.creditCard:
        return AppTheme.primaryPurple.withOpacity(0.1);
      case PaymentMethodType.debitCard:
        return AppTheme.warningColor.withOpacity(0.1);
      case PaymentMethodType.bankTransfer:
        return AppTheme.infoColor.withOpacity(0.1);
    }
  }

  String _getTitleLabel() {
    switch (selectedType) {
      case PaymentMethodType.upi:
        return 'App/Service Name';
      case PaymentMethodType.cash:
        return 'Cash Payment Label';
      case PaymentMethodType.creditCard:
      case PaymentMethodType.debitCard:
        return 'Card Type';
      case PaymentMethodType.bankTransfer:
        return 'Transfer Type';
    }
  }

  String _getTitleHint() {
    switch (selectedType) {
      case PaymentMethodType.upi:
        return 'e.g., Google Pay, PhonePe, Paytm';
      case PaymentMethodType.cash:
        return 'e.g., Cash Payment';
      case PaymentMethodType.creditCard:
        return 'e.g., Credit Card';
      case PaymentMethodType.debitCard:
        return 'e.g., Debit Card';
      case PaymentMethodType.bankTransfer:
        return 'e.g., Bank Transfer, NEFT, RTGS';
    }
  }

  String _getDetailsLabel() {
    switch (selectedType) {
      case PaymentMethodType.upi:
        return 'Description (Optional)';
      case PaymentMethodType.cash:
        return 'Description (Optional)';
      case PaymentMethodType.creditCard:
      case PaymentMethodType.debitCard:
        return 'Description (Optional)';
      case PaymentMethodType.bankTransfer:
        return 'Description (Optional)';
    }
  }

  String _getDetailsHint() {
    switch (selectedType) {
      case PaymentMethodType.upi:
        return 'Additional details about UPI payment';
      case PaymentMethodType.cash:
        return 'Additional details about cash payment';
      case PaymentMethodType.creditCard:
      case PaymentMethodType.debitCard:
        return 'Additional details about card payment';
      case PaymentMethodType.bankTransfer:
        return 'Additional details about bank transfer';
    }
  }

  TextInputType _getKeyboardType() {
    switch (selectedType) {
      case PaymentMethodType.upi:
      case PaymentMethodType.cash:
      case PaymentMethodType.creditCard:
      case PaymentMethodType.debitCard:
      case PaymentMethodType.bankTransfer:
        return TextInputType.text;
    }
  }

  List<TextInputFormatter> _getInputFormatters() {
    // For this use case, we don't need special formatting
    // as these are just labels/descriptions, not actual payment details
    return [];
  }

  String? _validateDetails(String value) {
    // Details are optional for payment options
    return null;
  }

  void _addPaymentMethod() {
    if (_formKey.currentState!.validate()) {
      final newMethod = PaymentMethod(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: selectedType,
        title: _titleController.text.trim(),
        subtitle: _formatSubtitle(_detailsController.text.trim()),
        isDefault: false,
      );

      widget.onPaymentMethodAdded(newMethod);
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${newMethod.title} added successfully'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    }
  }

  String _formatSubtitle(String details) {
    switch (selectedType) {
      case PaymentMethodType.upi:
      case PaymentMethodType.cash:
      case PaymentMethodType.creditCard:
      case PaymentMethodType.debitCard:
      case PaymentMethodType.bankTransfer:
        return details.isEmpty ? 'No additional details' : details;
    }
  }
}
