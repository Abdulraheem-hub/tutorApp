/// @context7:feature:students
/// @context7:dependencies:flutter,student_entities,payment
/// @context7:pattern:page_widget
///
/// Add payment page for recording student payments
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../domain/entities/student_entities.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_utils.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/firebase_service.dart';

class AddPaymentPage extends StatefulWidget {
  final Student? student;

  const AddPaymentPage({super.key, this.student});

  @override
  State<AddPaymentPage> createState() => _AddPaymentPageState();
}

class _AddPaymentPageState extends State<AddPaymentPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  Student? _student;
  DateTime _selectedDate = DateTime.now();
  PaymentMethod _selectedPaymentMethod = PaymentMethod.cash;
  final PaymentType _selectedPaymentType = PaymentType.monthlyFee;

  @override
  void initState() {
    super.initState();
    _student = widget.student;
    _amountController.text = _student?.monthlyFee.toStringAsFixed(0) ?? '';
    _descriptionController.text = 'Monthly Fee';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_student == null) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Student) {
        _student = args;
        _amountController.text = _student!.monthlyFee.toStringAsFixed(0);
      }
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_student == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Record Payment')),
        body: const Center(child: Text('Student not found')),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStudentCard(),
                  const SizedBox(height: 24),
                  _buildPaymentForm(),
                ],
              ),
            ),
          ),
          _buildRecordPaymentButton(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        'Record Payment',
        style: TextStyle(color: AppTheme.textDark, fontWeight: FontWeight.w600),
      ),
      backgroundColor: Colors.white,
      elevation: 0,
      iconTheme: const IconThemeData(color: AppTheme.textDark),
      actions: [
        IconButton(
          onPressed: () {
            // TODO: Add help/info functionality
          },
          icon: const Icon(Icons.help_outline),
        ),
      ],
    );
  }

  Widget _buildStudentCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF6366F1), // Primary purple
            Color(0xFF8B5CF6), // Secondary purple
          ],
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildProfileAvatar(),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _student!.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_student!.grade.displayName} • Student ID: ${_student!.admissionNumber ?? 'N/A'}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Enrolled Subjects
          const Text(
            'Enrolled Subjects',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: _student!.subjects
                .map(
                  (subject) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      subject.name,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),

          const SizedBox(height: 16),

          // Monthly Fee Display
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Text(
                  'Monthly Fee',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    AppUtils.formatCurrency(_student!.monthlyFee),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryPurple,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileAvatar() {
    // Generate consistent color for avatar
    final colors = [
      Colors.white.withValues(alpha: 0.2),
      Colors.blue.withValues(alpha: 0.2),
      Colors.green.withValues(alpha: 0.2),
      Colors.orange.withValues(alpha: 0.2),
    ];
    final colorIndex = _student!.name.hashCode % colors.length;
    final avatarColor = colors[colorIndex.abs()];

    final initials = _student!.name
        .split(' ')
        .map((name) => name.isNotEmpty ? name[0] : '')
        .join('')
        .toUpperCase();

    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: avatarColor,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: _student!.profileImage != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(23),
              child: Image.network(
                _student!.profileImage!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Text(
                      initials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
            )
          : Center(
              child: Text(
                initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
    );
  }

  Widget _buildPaymentForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
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
                    Icons.payment,
                    color: AppTheme.primaryPurple,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Payment Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Payment Amount
            const Text(
              'Payment Amount',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                hintText: 'Enter amount',
                prefixText: AppConstants.currencySymbol,
                prefixStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textDark,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppTheme.primaryPurple,
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter payment amount';
                }
                final amount = double.tryParse(value);
                if (amount == null || amount <= 0) {
                  return 'Please enter a valid amount';
                }
                return null;
              },
            ),

            const SizedBox(height: 20),

            // Payment Date
            const Text(
              'Payment Date',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: _selectDate,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Text(
                      AppUtils.formatDate(_selectedDate),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.calendar_today,
                      color: AppTheme.primaryPurple,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Payment Mode
            const Text(
              'Payment Mode',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 12),
            _buildPaymentMethods(),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethods() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 2.5,
      children: [
        _buildPaymentMethodCard(
          PaymentMethod.cash,
          'Cash',
          Icons.money,
          const Color(0xFF10B981),
        ),
        _buildPaymentMethodCard(
          PaymentMethod.digitalWallet,
          'UPI',
          Icons.qr_code,
          const Color(0xFF3B82F6),
        ),
        _buildPaymentMethodCard(
          PaymentMethod.bankTransfer,
          'Bank',
          Icons.account_balance,
          const Color(0xFF8B5CF6),
        ),
        _buildPaymentMethodCard(
          PaymentMethod.card,
          'Debit Card',
          Icons.credit_card,
          const Color(0xFFE97B47),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodCard(
    PaymentMethod method,
    String label,
    IconData icon,
    Color color,
  ) {
    final isSelected = _selectedPaymentMethod == method;

    return InkWell(
      onTap: () => setState(() => _selectedPaymentMethod = method),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.1)
              : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? color : Colors.grey.shade600,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? color : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordPaymentButton() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _recordPayment,
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
              Icon(Icons.check_circle_outline, size: 20),
              SizedBox(width: 8),
              Text(
                'Record Payment',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryPurple,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppTheme.textDark,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _recordPayment() async {
    if (_formKey.currentState?.validate() ?? false) {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      try {
        final amount = double.parse(_amountController.text);
        final firebaseService = FirebaseService.instance;

        // Create payment document in Firestore
        final paymentData = {
          'studentId': _student!.id,
          'studentName': _student!.name,
          'amount': amount,
          'paymentDate': _selectedDate.toIso8601String(),
          'method': _selectedPaymentMethod.name,
          'description': _descriptionController.text.isNotEmpty
              ? _descriptionController.text
              : _selectedPaymentType.displayName,
          'type': _selectedPaymentType.name,
          'createdAt': DateTime.now().toIso8601String(),
          'status': 'completed',
        };

        // Save to Firestore
        final docRef = await firebaseService.firestore
            .collection('users')
            .doc(firebaseService.currentUserId)
            .collection('payments')
            .add(paymentData);

        // Create payment object for navigation
        final payment = Payment(
          id: docRef.id,
          studentId: _student!.id,
          amount: amount,
          paymentDate: _selectedDate,
          method: _selectedPaymentMethod,
          description: _descriptionController.text.isNotEmpty
              ? _descriptionController.text
              : _selectedPaymentType.displayName,
          type: _selectedPaymentType,
        );

        // Hide loading indicator
        if (mounted) Navigator.pop(context);

        // Navigate to payment confirmation page
        if (mounted) {
          Navigator.pushNamed(
            context,
            '/payment-confirmation',
            arguments: {'payment': payment, 'student': _student},
          );
        }
      } catch (e) {
        // Hide loading indicator
        if (mounted) Navigator.pop(context);

        // Show error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to save payment: $e'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }
}
