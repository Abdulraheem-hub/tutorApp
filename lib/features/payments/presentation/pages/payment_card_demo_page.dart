/// @context7:feature:payments
/// @context7:dependencies:flutter,payment_entity,payment_cards
/// @context7:pattern:demo_page
///
/// Demo page showcasing different payment card designs with various payment scenarios
/// Demonstrates all payment cases: partial, full, overpayment, with/without outstanding
library;

import 'package:flutter/material.dart';
import '../widgets/payment_cards.dart';
import '../../domain/entities/payment_entity.dart';
import '../../../../core/theme/app_theme.dart';
import '../services/payment_conversion_service.dart';

class PaymentCardDemoPage extends StatefulWidget {
  const PaymentCardDemoPage({super.key});

  @override
  State<PaymentCardDemoPage> createState() => _PaymentCardDemoPageState();
}

class _PaymentCardDemoPageState extends State<PaymentCardDemoPage> {
  bool _showComprehensive = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Payment Card Designs',
          style: TextStyle(
            color: AppTheme.textDark,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.textDark),
        actions: [
          Switch(
            value: _showComprehensive,
            onChanged: (value) {
              setState(() {
                _showComprehensive = value;
              });
            },
            activeColor: AppTheme.primaryPurple,
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          // Header with switch
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _showComprehensive
                            ? 'Comprehensive Cards'
                            : 'Compact Cards',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _showComprehensive
                            ? 'Detailed payment information with breakdown'
                            : 'Compact view with all essential information',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.textLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Payment cards list
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildSectionHeader('Partial Payment Scenario'),
                _buildPaymentCard(_createPartialPayment()),

                const SizedBox(height: 24),
                _buildSectionHeader('Full Payment Scenario'),
                _buildPaymentCard(_createFullPayment()),

                const SizedBox(height: 24),
                _buildSectionHeader('Overpayment Scenario'),
                _buildPaymentCard(_createOverpayment()),

                const SizedBox(height: 24),
                _buildSectionHeader('Payment with Outstanding Balance'),
                _buildPaymentCard(_createPaymentWithOutstanding()),

                const SizedBox(height: 24),
                _buildSectionHeader('Payment Clearing Outstanding'),
                _buildPaymentCard(_createPaymentClearingOutstanding()),

                const SizedBox(height: 24),
                _buildSectionHeader('Different Payment Methods'),
                _buildPaymentCard(_createCashPayment()),
                const SizedBox(height: 12),
                _buildPaymentCard(_createCardPayment()),
                const SizedBox(height: 12),
                _buildPaymentCard(_createBankTransferPayment()),
                const SizedBox(height: 20),
                _buildSectionHeader('Status Testing'),
                _buildPaymentCard(_createPendingPayment()),
                const SizedBox(height: 12),
                _buildPaymentCard(_createFailedPayment()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppTheme.textDark,
        ),
      ),
    );
  }

  Widget _buildPaymentCard(PaymentEntity payment) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Display calculated status info for debugging
        Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Status Debug Info:',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Status: ${payment.status.name}',
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              ),
              Text(
                'Display Text: ${PaymentConversionService.getPaymentStatusDisplayText(payment)}',
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              ),
              Text(
                'Is Partial: ${payment.isPartialPayment}',
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              ),
              Text(
                'Amount: \$${payment.amount} / Monthly: \$${payment.monthlyFeeAtPayment}',
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              ),
              Text(
                'Shortfall: \$${payment.shortfallAmount} / Excess: \$${payment.excessAmount}',
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
        // The actual payment card
        _showComprehensive
            ? ComprehensivePaymentCard(
                payment: payment,
                onTap: () => _showPaymentDetails(payment),
              )
            : CompactPaymentCard(
                payment: payment,
                onTap: () => _showPaymentDetails(payment),
              ),
      ],
    );
  }

  void _showPaymentDetails(PaymentEntity payment) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryPurple.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.receipt_long,
                        color: AppTheme.primaryPurple,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Payment Details',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ComprehensivePaymentCard(
                    payment: payment,
                    showDetailedInfo: true,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Sample payment scenarios
  PaymentEntity _createPartialPayment() {
    return PaymentEntity(
      id: 'pay_partial_001',
      studentId: 'student_001',
      studentName: 'Sarah Johnson',
      amount: 80.0,
      method: PaymentMethod.cash,
      status: PaymentStatus.completed,
      date: DateTime.now().subtract(const Duration(hours: 2)),
      description: 'Monthly Fee Payment - Partial',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      monthlyFeeAtPayment: 120.0,
      paymentPeriod: DateTime(DateTime.now().year, DateTime.now().month, 1),
      shortfallAmount: 40.0,
      excessAmount: 0.0,
      outstandingBalanceBefore: 0.0,
      outstandingBalanceAfter: 40.0,
      isPartialPayment: true,
    );
  }

  PaymentEntity _createFullPayment() {
    return PaymentEntity(
      id: 'pay_full_002',
      studentId: 'student_002',
      studentName: 'Mike Chen',
      amount: 120.0,
      method: PaymentMethod.bankTransfer,
      status: PaymentStatus.completed,
      date: DateTime.now().subtract(const Duration(hours: 6)),
      description: 'Monthly Fee Payment - Full',
      createdAt: DateTime.now().subtract(const Duration(hours: 6)),
      monthlyFeeAtPayment: 120.0,
      paymentPeriod: DateTime(DateTime.now().year, DateTime.now().month, 1),
      shortfallAmount: 0.0,
      excessAmount: 0.0,
      outstandingBalanceBefore: 0.0,
      outstandingBalanceAfter: 0.0,
      isPartialPayment: false,
    );
  }

  PaymentEntity _createOverpayment() {
    return PaymentEntity(
      id: 'pay_over_003',
      studentId: 'student_003',
      studentName: 'Emma Davis',
      amount: 200.0,
      method: PaymentMethod.creditCard,
      status: PaymentStatus.completed,
      date: DateTime.now().subtract(const Duration(hours: 12)),
      description: 'Monthly Fee Payment - Overpayment',
      createdAt: DateTime.now().subtract(const Duration(hours: 12)),
      monthlyFeeAtPayment: 120.0,
      paymentPeriod: DateTime(DateTime.now().year, DateTime.now().month, 1),
      shortfallAmount: 0.0,
      excessAmount: 80.0,
      outstandingBalanceBefore: 0.0,
      outstandingBalanceAfter: 0.0,
      isPartialPayment: false,
    );
  }

  PaymentEntity _createPaymentWithOutstanding() {
    return PaymentEntity(
      id: 'pay_outstanding_004',
      studentId: 'student_004',
      studentName: 'Alex Rodriguez',
      amount: 100.0,
      method: PaymentMethod.paypal,
      status: PaymentStatus.completed,
      date: DateTime.now().subtract(const Duration(days: 1)),
      description: 'Partial Payment with Outstanding',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      monthlyFeeAtPayment: 120.0,
      paymentPeriod: DateTime(DateTime.now().year, DateTime.now().month, 1),
      shortfallAmount: 0.0,
      excessAmount: 0.0,
      outstandingBalanceBefore: 50.0,
      outstandingBalanceAfter: 70.0,
      isPartialPayment: true,
    );
  }

  PaymentEntity _createPaymentClearingOutstanding() {
    return PaymentEntity(
      id: 'pay_clearing_005',
      studentId: 'student_005',
      studentName: 'Lisa Wang',
      amount: 180.0,
      method: PaymentMethod.venmo,
      status: PaymentStatus.completed,
      date: DateTime.now().subtract(const Duration(days: 2)),
      description: 'Payment Clearing Outstanding',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      monthlyFeeAtPayment: 120.0,
      paymentPeriod: DateTime(DateTime.now().year, DateTime.now().month, 1),
      shortfallAmount: 0.0,
      excessAmount: 10.0,
      outstandingBalanceBefore: 50.0,
      outstandingBalanceAfter: 0.0,
      isPartialPayment: false,
    );
  }

  PaymentEntity _createCashPayment() {
    return PaymentEntity(
      id: 'pay_cash_006',
      studentId: 'student_006',
      studentName: 'James Wilson',
      amount: 120.0,
      method: PaymentMethod.cash,
      status: PaymentStatus.completed,
      date: DateTime.now().subtract(const Duration(days: 3)),
      description: 'Cash Payment',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      monthlyFeeAtPayment: 120.0,
      paymentPeriod: DateTime(DateTime.now().year, DateTime.now().month, 1),
      shortfallAmount: 0.0,
      excessAmount: 0.0,
      outstandingBalanceBefore: 0.0,
      outstandingBalanceAfter: 0.0,
      isPartialPayment: false,
    );
  }

  PaymentEntity _createCardPayment() {
    return PaymentEntity(
      id: 'pay_card_007',
      studentId: 'student_007',
      studentName: 'Sofia Martinez',
      amount: 150.0,
      method: PaymentMethod.creditCard,
      status: PaymentStatus.completed,
      date: DateTime.now().subtract(const Duration(days: 4)),
      description: 'Credit Card Payment',
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
      monthlyFeeAtPayment: 120.0,
      paymentPeriod: DateTime(DateTime.now().year, DateTime.now().month, 1),
      shortfallAmount: 0.0,
      excessAmount: 30.0,
      outstandingBalanceBefore: 0.0,
      outstandingBalanceAfter: 0.0,
      isPartialPayment: false,
    );
  }

  PaymentEntity _createBankTransferPayment() {
    return PaymentEntity(
      id: 'pay_bank_008',
      studentId: 'student_008',
      studentName: 'David Thompson',
      amount: 90.0,
      method: PaymentMethod.bankTransfer,
      status: PaymentStatus.completed,
      date: DateTime.now().subtract(const Duration(days: 5)),
      description: 'Bank Transfer Payment',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      monthlyFeeAtPayment: 120.0,
      paymentPeriod: DateTime(DateTime.now().year, DateTime.now().month, 1),
      shortfallAmount: 30.0,
      excessAmount: 0.0,
      outstandingBalanceBefore: 0.0,
      outstandingBalanceAfter: 30.0,
      isPartialPayment: true,
    );
  }

  PaymentEntity _createPendingPayment() {
    return PaymentEntity(
      id: 'pay_pending_001',
      studentId: 'student_pending',
      studentName: 'John Pending',
      amount: 0.0,
      method: PaymentMethod.cash,
      status: PaymentStatus.pending,
      date: DateTime.now(),
      description: 'Pending Payment - No amount received yet',
      createdAt: DateTime.now(),
      monthlyFeeAtPayment: 120.0,
      paymentPeriod: DateTime(DateTime.now().year, DateTime.now().month, 1),
      shortfallAmount: 120.0,
      excessAmount: 0.0,
      outstandingBalanceBefore: 0.0,
      outstandingBalanceAfter: 120.0,
      isPartialPayment: true,
    );
  }

  PaymentEntity _createFailedPayment() {
    return PaymentEntity(
      id: 'pay_failed_001',
      studentId: 'student_failed',
      studentName: 'Jane Failed',
      amount: 0.0,
      method: PaymentMethod.creditCard,
      status: PaymentStatus.failed,
      date: DateTime.now().subtract(const Duration(hours: 1)),
      description: 'Failed Payment - Credit card declined',
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      monthlyFeeAtPayment: 120.0,
      paymentPeriod: DateTime(DateTime.now().year, DateTime.now().month, 1),
      shortfallAmount: 120.0,
      excessAmount: 0.0,
      outstandingBalanceBefore: 0.0,
      outstandingBalanceAfter: 120.0,
      isPartialPayment: true,
    );
  }
}
