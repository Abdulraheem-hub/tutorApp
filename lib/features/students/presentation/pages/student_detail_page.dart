/// @context7:feature:students
/// @context7:dependencies:flutter,student_entities
/// @context7:pattern:page_widget
///
/// Student detail page with comprehensive student information
library;

import 'package:flutter/material.dart';
import '../../domain/entities/student_entities.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_utils.dart';
import '../../../../core/constants/app_constants.dart';

class StudentDetailPage extends StatefulWidget {
  final Student? student;

  const StudentDetailPage({super.key, this.student});

  @override
  State<StudentDetailPage> createState() => _StudentDetailPageState();
}

class _StudentDetailPageState extends State<StudentDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Student? _student;

  // Mock payments data
  final List<Payment> _mockPayments = [
    Payment(
      id: '1',
      studentId: '1',
      amount: 5000.0,
      paymentDate: DateTime(2024, 1, 15),
      method: PaymentMethod.cash,
      description: 'January Fee',
      type: PaymentType.monthlyFee,
    ),
    Payment(
      id: '2',
      studentId: '1',
      amount: 5000.0,
      paymentDate: DateTime(2023, 12, 15),
      method: PaymentMethod.bankTransfer,
      description: 'December Fee',
      type: PaymentType.monthlyFee,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _student = widget.student;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_student == null) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Student) {
        _student = args;
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_student == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Student Details')),
        body: const Center(child: Text('Student not found')),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildProfileSection(),
          _buildPaymentSummarySection(),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildBasicInfoTab(),
                _buildAcademicTab(),
                _buildContactsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        'Student Details',
        style: TextStyle(color: AppTheme.textDark, fontWeight: FontWeight.w600),
      ),
      backgroundColor: Colors.white,
      elevation: 0,
      iconTheme: IconThemeData(color: AppTheme.textDark),
      actions: [
        IconButton(
          onPressed: () {
            // TODO: Implement edit functionality
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Edit feature coming soon!')),
            );
          },
          icon: const Icon(Icons.edit_outlined),
        ),
      ],
    );
  }

  Widget _buildProfileSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Profile Picture
          _buildProfilePicture(),

          const SizedBox(height: 16),

          // Name
          Text(
            _student!.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),

          const SizedBox(height: 4),

          // Status Badge
          _buildStatusBadge(),

          const SizedBox(height: 8),

          // Admission Info
          Text(
            'Admission: ${_student!.admissionNumber ?? 'N/A'}',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textLight,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
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
    final colorIndex = _student!.name.hashCode % colors.length;
    final avatarColor = colors[colorIndex.abs()];

    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: avatarColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(40),
      ),
      child: _student!.profileImage != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(40),
              child: Image.network(
                _student!.profileImage!,
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
    final initials = _student!.name
        .split(' ')
        .map((name) => name.isNotEmpty ? name[0] : '')
        .join('')
        .toUpperCase();

    return Center(
      child: Text(
        initials,
        style: TextStyle(
          color: color,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color badgeColor;
    Color textColor;

    switch (_student!.paymentStatus) {
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _student!.paymentStatus.displayName,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        labelColor: AppTheme.primaryPurple,
        unselectedLabelColor: AppTheme.textLight,
        indicatorColor: AppTheme.primaryPurple,
        labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        tabs: const [
          Tab(text: 'Basic Info'),
          Tab(text: 'Academic'),
          Tab(text: 'Contacts'),
        ],
      ),
    );
  }

  Widget _buildBasicInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoSection(
            title: 'Basic Information',
            children: [
              _buildInfoRow('Name (English)', _student!.name),
              _buildInfoRow('Name (Urdu)', 'احمد حسن'), // Mock Urdu name
              _buildInfoRow(
                'Admission Number',
                _student!.admissionNumber ?? 'N/A',
              ),
              _buildInfoRow(
                'Admission Date',
                _student!.admissionDate != null
                    ? AppUtils.formatDate(_student!.admissionDate!)
                    : 'N/A',
              ),
              _buildInfoRow('Address', _student!.address ?? 'N/A'),
            ],
          ),

          const SizedBox(height: 24),

          _buildRecentPaymentsSection(),
        ],
      ),
    );
  }

  Widget _buildAcademicTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoSection(
            title: 'Academic Information',
            children: [
              _buildInfoRow('Grade', _student!.grade.displayName),
              _buildInfoRow('Subjects', _getSubjectsText()),
              _buildInfoRow(
                'Monthly Fee',
                AppUtils.formatCurrency(_student!.monthlyFee),
              ),
              _buildInfoRow(
                'Join Date',
                AppUtils.formatDate(_student!.joinDate),
              ),
              _buildInfoRow(
                'Status',
                _student!.isActive ? 'Active' : 'Inactive',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoSection(
            title: 'Contact Information',
            children: [
              _buildInfoRow('Phone Number', _student!.phoneNumber ?? 'N/A'),
              _buildInfoRow('Email', _student!.email ?? 'N/A'),
              _buildInfoRow('Address', _student!.address ?? 'N/A'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
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

  Widget _buildPaymentSummarySection() {
    final totalPaid = _mockPayments.fold<double>(
      0.0,
      (sum, payment) => sum + payment.amount,
    );
    final outstandingAmount = 5000.0; // Mock outstanding amount

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Payment Summary',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppUtils.formatCurrency(totalPaid),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.greenPositive,
                      ),
                    ),
                    const Text(
                      'Total Paid',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textLight,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppUtils.formatCurrency(outstandingAmount),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.errorColor,
                      ),
                    ),
                    const Text(
                      'Outstanding',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textLight,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.addPayment,
                      arguments: _student,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.greenPositive,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.add, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Add Payment',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/payments',
                      arguments:
                          _student!.id, // Pass student ID to filter payments
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.receipt_long, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'View Payments',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentPaymentsSection() {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Payments',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('View all payments coming soon!'),
                    ),
                  );
                },
                child: Text(
                  'View All',
                  style: TextStyle(
                    color: AppTheme.primaryPurple,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...(_mockPayments
              .take(2)
              .map((payment) => _buildPaymentItem(payment))),
        ],
      ),
    );
  }

  Widget _buildPaymentItem(Payment payment) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.greenPositive.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.check_circle,
              color: AppTheme.greenPositive,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  payment.description,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textDark,
                  ),
                ),
                Text(
                  AppUtils.formatDate(payment.paymentDate),
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textLight,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Text(
            AppUtils.formatCurrency(payment.amount),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppTheme.greenPositive,
            ),
          ),
        ],
      ),
    );
  }

  String _getSubjectsText() {
    if (_student!.subjects.isEmpty) return 'No subjects';
    return _student!.subjects.map((s) => s.name).join(', ');
  }
}
