/**
 * @context7:feature:students
 * @context7:dependencies:flutter,student_entities,payment,pdf
 * @context7:pattern:page_widget
 * 
 * Payment confirmation page with receipt functionality
 */

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../domain/entities/student_entities.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_utils.dart';
import '../../../../core/constants/app_constants.dart';

class PaymentConfirmationPage extends StatefulWidget {
  final Payment? payment;
  final Student? student;

  const PaymentConfirmationPage({super.key, this.payment, this.student});

  @override
  State<PaymentConfirmationPage> createState() =>
      _PaymentConfirmationPageState();
}

class _PaymentConfirmationPageState extends State<PaymentConfirmationPage>
    with TickerProviderStateMixin {
  late AnimationController _checkmarkController;
  late AnimationController _contentController;
  late Animation<double> _checkmarkAnimation;
  late Animation<double> _contentAnimation;

  Payment? _payment;
  Student? _student;
  String _transactionId = '';

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _generateTransactionId();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_payment == null || _student == null) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null) {
        _payment = args['payment'] as Payment?;
        _student = args['student'] as Student?;
      }
    }
  }

  void _initializeAnimations() {
    _checkmarkController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _contentController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _checkmarkAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _checkmarkController, curve: Curves.elasticOut),
    );

    _contentAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _contentController, curve: Curves.easeOutBack),
    );

    // Start animations
    _checkmarkController.forward().then((_) {
      _contentController.forward();
    });
  }

  void _generateTransactionId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    _transactionId = 'TXN${timestamp.toString().substring(7)}';
  }

  @override
  void dispose() {
    _checkmarkController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_payment == null || _student == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Payment Confirmation')),
        body: const Center(child: Text('Payment details not found')),
      );
    }

    return WillPopScope(
      onWillPop: () async {
        _navigateToStudents();
        return false;
      },
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _buildSuccessCard(),
                      const SizedBox(height: 24),
                      _buildReceiptCard(),
                      const SizedBox(height: 24),
                      _buildActionButtons(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: _navigateToStudents,
            icon: const Icon(Icons.close, color: AppTheme.textDark),
          ),
          const SizedBox(width: 8),
          const Text(
            'Payment Confirmation',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.textDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessCard() {
    return AnimatedBuilder(
      animation: _checkmarkAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _checkmarkAnimation.value,
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF10B981), // Success green
                  Color(0xFF059669),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF10B981).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: const Icon(
                    Icons.check_circle_outline,
                    color: Colors.white,
                    size: 50,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Payment Successful!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Payment of ${AppUtils.formatCurrency(_payment!.amount)} has been recorded',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, color: Colors.white70),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Transaction ID: $_transactionId',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildReceiptCard() {
    return AnimatedBuilder(
      animation: _contentAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - _contentAnimation.value)),
          child: Opacity(
            opacity: _contentAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildReceiptHeader(),
                  const Divider(height: 1),
                  _buildReceiptDetails(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildReceiptHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.primaryPurple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.receipt_long,
              color: AppTheme.primaryPurple,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Payment Receipt',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppUtils.formatDateTime(DateTime.now()),
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
    );
  }

  Widget _buildReceiptDetails() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildReceiptRow('Student Name', _student!.name),
          _buildReceiptRow('Student ID', _student!.admissionNumber ?? 'N/A'),
          _buildReceiptRow('Grade', _student!.grade.displayName),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          _buildReceiptRow('Payment Type', _payment!.type.displayName),
          _buildReceiptRow('Payment Method', _payment!.method.displayName),
          _buildReceiptRow(
            'Payment Date',
            AppUtils.formatDate(_payment!.paymentDate),
          ),
          _buildReceiptRow('Description', _payment!.description),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          _buildReceiptRow(
            'Amount Paid',
            AppUtils.formatCurrency(_payment!.amount),
            isAmount: true,
          ),
          _buildReceiptRow('Transaction ID', _transactionId),
        ],
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value, {bool isAmount = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
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
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontSize: isAmount ? 16 : 14,
                color: isAmount ? AppTheme.primaryPurple : AppTheme.textDark,
                fontWeight: isAmount ? FontWeight.bold : FontWeight.w600,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return AnimatedBuilder(
      animation: _contentAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - _contentAnimation.value)),
          child: Opacity(
            opacity: _contentAnimation.value,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        icon: Icons.download,
                        label: 'Download Receipt',
                        onPressed: _downloadReceipt,
                        backgroundColor: AppTheme.primaryPurple,
                        textColor: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildActionButton(
                        icon: Icons.share,
                        label: 'Share Receipt',
                        onPressed: _shareReceipt,
                        backgroundColor: Colors.grey.shade100,
                        textColor: AppTheme.textDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: _buildActionButton(
                    icon: Icons.visibility,
                    label: 'View Receipt',
                    onPressed: _viewReceipt,
                    backgroundColor: Colors.white,
                    textColor: AppTheme.primaryPurple,
                    hasBorder: true,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _navigateToStudents,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Back to Students',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color backgroundColor,
    required Color textColor,
    bool hasBorder = false,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(
        label,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: hasBorder
              ? BorderSide(color: AppTheme.primaryPurple.withOpacity(0.3))
              : BorderSide.none,
        ),
        elevation: 0,
      ),
    );
  }

  void _downloadReceipt() async {
    try {
      // Show loading
      _showLoadingDialog('Generating receipt...');

      // Generate receipt content
      final receiptContent = _generateReceiptContent();

      // Get directory for saving
      final directory = await getApplicationDocumentsDirectory();
      final fileName =
          'Receipt_${_transactionId}_${DateTime.now().millisecondsSinceEpoch}.txt';
      final file = File('${directory.path}/$fileName');

      // Write receipt content
      await file.writeAsString(receiptContent);

      // Hide loading
      Navigator.pop(context);

      // Show success message
      _showSuccessSnackBar('Receipt downloaded to ${file.path}');

      // Copy path to clipboard
      await Clipboard.setData(ClipboardData(text: file.path));
    } catch (e) {
      Navigator.pop(context);
      _showErrorSnackBar('Failed to download receipt: $e');
    }
  }

  void _shareReceipt() async {
    try {
      final receiptContent = _generateReceiptContent();

      await Share.share(
        receiptContent,
        subject: 'Payment Receipt - ${_student!.name}',
      );
    } catch (e) {
      _showErrorSnackBar('Failed to share receipt: $e');
    }
  }

  void _viewReceipt() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          constraints: const BoxConstraints(maxHeight: 600),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: AppTheme.primaryPurple,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.receipt_long, color: Colors.white),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Payment Receipt',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    _generateReceiptContent(),
                    style: const TextStyle(
                      fontSize: 14,
                      fontFamily: 'monospace',
                      height: 1.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _generateReceiptContent() {
    return '''
═══════════════════════════════════════
              PAYMENT RECEIPT
═══════════════════════════════════════

Date: ${AppUtils.formatDateTime(DateTime.now())}
Transaction ID: $_transactionId

STUDENT INFORMATION
───────────────────────────────────────
Name: ${_student!.name}
Student ID: ${_student!.admissionNumber ?? 'N/A'}
Grade: ${_student!.grade.displayName}
Subjects: ${_student!.subjects.map((s) => s.name).join(', ')}

PAYMENT DETAILS
───────────────────────────────────────
Payment Type: ${_payment!.type.displayName}
Payment Method: ${_payment!.method.displayName}
Payment Date: ${AppUtils.formatDate(_payment!.paymentDate)}
Description: ${_payment!.description}

AMOUNT BREAKDOWN
───────────────────────────────────────
Amount Paid: ${AppUtils.formatCurrency(_payment!.amount)}
Transaction Fee: ${AppUtils.formatCurrency(0.0)}
───────────────────────────────────────
Total: ${AppUtils.formatCurrency(_payment!.amount)}

═══════════════════════════════════════
         Thank you for your payment!
═══════════════════════════════════════

This is a computer-generated receipt.
For queries, please contact support.

Generated by ${AppConstants.appName} v${AppConstants.appVersion}
''';
  }

  void _showLoadingDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Text(message),
          ],
        ),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _navigateToStudents() {
    // Navigate back to the main screen (which includes students page)
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }
}
