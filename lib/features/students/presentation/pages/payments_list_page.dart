/// @context7:feature:students
/// @context7:dependencies:flutter,cloud_firestore,payment_entities,payment_cards
/// @context7:pattern:page_widget
///
/// Payments list page to view all recorded payments from Firestore with compact payment cards
library;

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_utils.dart';
import '../../../../core/services/firebase_service.dart';
import '../../../payments/domain/entities/payment_entity.dart';
import '../../../payments/presentation/services/payment_conversion_service.dart';
import '../../../payments/presentation/widgets/payment_cards.dart';

class PaymentsListPage extends StatefulWidget {
  const PaymentsListPage({super.key});

  @override
  State<PaymentsListPage> createState() => _PaymentsListPageState();
}

class _PaymentsListPageState extends State<PaymentsListPage> {
  final FirebaseService _firebaseService = FirebaseService.instance;
  String _selectedFilter = 'All';
  String? _studentIdFilter; // For filtering by specific student

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Check if student ID was passed as argument for filtering
    final studentId = ModalRoute.of(context)?.settings.arguments as String?;
    if (studentId != null) {
      _studentIdFilter = studentId;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          _studentIdFilter != null ? 'Student Payments' : 'Payment History',
          style: const TextStyle(
            color: AppTheme.textDark,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.textDark),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() {
                _selectedFilter = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'All', child: Text('All Payments')),
              const PopupMenuItem(value: 'cash', child: Text('Cash Only')),
              const PopupMenuItem(
                value: 'digitalWallet',
                child: Text('UPI Only'),
              ),
              const PopupMenuItem(
                value: 'bankTransfer',
                child: Text('Bank Transfer Only'),
              ),
              const PopupMenuItem(value: 'card', child: Text('Card Only')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSummaryCard(),
          Expanded(child: _buildPaymentsList()),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firebaseService.firestore
          .collection('users')
          .doc(_firebaseService.currentUserId)
          .collection('payments')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final payments = snapshot.data!.docs;
        final totalAmount = payments.fold<double>(
          0.0,
          (total, doc) =>
              total + (doc.data() as Map<String, dynamic>)['amount'],
        );

        return Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppTheme.primaryPurple, Color(0xFF8B5CF6)],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryPurple.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Collected',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppUtils.formatCurrency(totalAmount),
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.receipt_long,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${payments.length}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Text(
                      'Payments',
                      style: TextStyle(fontSize: 10, color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPaymentsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _getFilteredPaymentsStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                const SizedBox(height: 16),
                Text('Error loading payments: ${snapshot.error}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => setState(() {}),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final payments = snapshot.data?.docs ?? [];

        if (payments.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.payment_outlined, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  _selectedFilter == 'All'
                      ? 'No payments recorded yet'
                      : 'No payments found for $_selectedFilter',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Payments will appear here once recorded',
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: payments.length,
          itemBuilder: (context, index) {
            final paymentDoc = payments[index];
            final paymentData = paymentDoc.data() as Map<String, dynamic>;

            // Convert to PaymentEntity for use with compact cards
            final paymentEntity =
                PaymentConversionService.fromFirestoreDocument(
                  paymentDoc.id,
                  paymentData,
                );

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: CompactPaymentCard(
                payment: paymentEntity,
                onTap: () => _showPaymentDetails(paymentEntity),
              ),
            );
          },
        );
      },
    );
  }

  Stream<QuerySnapshot> _getFilteredPaymentsStream() {
    Query query = _firebaseService.firestore
        .collection('users')
        .doc(_firebaseService.currentUserId)
        .collection('payments')
        .orderBy('createdAt', descending: true);

    // Filter by student ID if specified
    if (_studentIdFilter != null) {
      query = query.where('studentId', isEqualTo: _studentIdFilter);
    }

    // Filter by payment method if not "All"
    if (_selectedFilter != 'All') {
      query = query.where('method', isEqualTo: _selectedFilter);
    }

    return query.snapshots();
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
        maxChildSize: 0.9,
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
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Column(
                      children: [
                        // Use the comprehensive payment card for detailed view
                        ComprehensivePaymentCard(payment: payment),
                        const SizedBox(height: 20),

                        // Additional technical details
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Technical Details',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textDark,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                _buildDetailRow('Payment ID', payment.id),
                                _buildDetailRow(
                                  'Student ID',
                                  payment.studentId,
                                ),
                                _buildDetailRow(
                                  'Payment Date',
                                  AppUtils.formatDate(payment.date),
                                ),
                                _buildDetailRow(
                                  'Payment Period',
                                  AppUtils.formatDate(payment.paymentPeriod),
                                ),
                                _buildDetailRow(
                                  'Created At',
                                  AppUtils.formatDateTime(payment.createdAt),
                                ),
                                if (payment.transactionId != null)
                                  _buildDetailRow(
                                    'Transaction ID',
                                    payment.transactionId!,
                                  ),
                                if (payment.receiptUrl != null)
                                  _buildDetailRow(
                                    'Receipt URL',
                                    payment.receiptUrl!,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textLight,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textDark,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
