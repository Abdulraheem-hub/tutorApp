/// @context7:feature:developer_tools
/// @context7:dependencies:flutter,database_seeder
/// @context7:pattern:page_widget
///
/// Developer tools page for testing and database management
library;

import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/firebase_service.dart';

class DeveloperToolsPage extends StatefulWidget {
  const DeveloperToolsPage({super.key});

  @override
  State<DeveloperToolsPage> createState() => _DeveloperToolsPageState();
}

class _DeveloperToolsPageState extends State<DeveloperToolsPage> {
  bool _isPopulating = false;
  bool _isClearing = false;
  String _statusMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Developer Tools',
          style: TextStyle(
            color: AppTheme.textDark,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.textDark),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(),
            const SizedBox(height: 24),
            _buildDataManagementSection(),
            const SizedBox(height: 24),
            _buildUITestingSection(),
            const SizedBox(height: 24),
            _buildTestScenariosSection(),
            if (_statusMessage.isNotEmpty) ...[
              const SizedBox(height: 24),
              _buildStatusSection(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.developer_mode,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  'Database Testing Tools',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Use these tools to populate your database with comprehensive sample data for testing all payment scenarios and features.',
            style: TextStyle(fontSize: 14, color: Colors.white70, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildDataManagementSection() {
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
                  Icons.storage,
                  color: AppTheme.primaryPurple,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Database Management',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildActionButton(
            title: 'Populate Sample Data',
            description:
                'Add comprehensive sample students, payments, and analytics data',
            icon: Icons.add_chart,
            color: Colors.green,
            isLoading: _isPopulating,
            onPressed: _isPopulating || _isClearing
                ? null
                : _populateSampleData,
          ),
          const SizedBox(height: 16),
          _buildActionButton(
            title: 'Clear All Data',
            description:
                'Remove all existing students, payments, and analytics data',
            icon: Icons.delete_forever,
            color: Colors.red,
            isLoading: _isClearing,
            onPressed: _isPopulating || _isClearing
                ? null
                : _showClearDataDialog,
          ),
        ],
      ),
    );
  }

  Widget _buildUITestingSection() {
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
                  Icons.design_services,
                  color: AppTheme.primaryPurple,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'UI Testing',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildActionButton(
            title: 'Payment Card Demo',
            description:
                'View all payment card designs with different payment scenarios',
            icon: Icons.credit_card,
            color: AppTheme.infoColor,
            isLoading: false,
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.paymentCardDemo);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTestScenariosSection() {
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
                  Icons.science,
                  color: AppTheme.primaryPurple,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Test Scenarios Included',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildScenarioList(),
        ],
      ),
    );
  }

  Widget _buildScenarioList() {
    final scenarios = [
      '✅ Current students (all payments up to date)',
      '🆕 New students (first month, no payments yet)',
      '⏳ Current month pending (only current month due)',
      '❌ Multiple months overdue (various outstanding amounts)',
      '⚠️ Partial payments (current month paid, previous dues)',
      '💎 High-value students (multiple subjects, high fees)',
      '👶 Elementary students (lower grades, basic subjects)',
      '📊 Irregular payment patterns (mixed payment history)',
      '💰 Various payment methods (cash, UPI, bank, card)',
      '🎯 Different payment types (monthly, registration, exam fees)',
    ];

    return Column(
      children: scenarios
          .map(
            (scenario) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    scenario.split(' ')[0],
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      scenario.substring(scenario.indexOf(' ') + 1),
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.textLight,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildActionButton({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required bool isLoading,
    required VoidCallback? onPressed,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: isLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(color),
                          ),
                        )
                      : Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: onPressed == null
                              ? AppTheme.textLight
                              : AppTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 13,
                          color: onPressed == null
                              ? AppTheme.textLight
                              : AppTheme.textLight,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isLoading && onPressed != null)
                  Icon(Icons.arrow_forward_ios, color: color, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryPurple.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryPurple.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline,
            color: AppTheme.primaryPurple,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _statusMessage,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textDark,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _populateSampleData() async {
    setState(() {
      _isPopulating = true;
      _statusMessage = 'Populating sample data... This may take a few moments.';
    });

    try {
      await FirebaseService.instance.populateSampleData();

      if (mounted) {
        setState(() {
          _statusMessage =
              '🎉 Sample data populated successfully! You can now test all payment scenarios.';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sample data populated successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _statusMessage = '❌ Error populating sample data: $e';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error populating data: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPopulating = false;
        });
      }
    }
  }

  Future<void> _clearAllData() async {
    setState(() {
      _isClearing = true;
      _statusMessage = 'Clearing all data... Please wait.';
    });

    try {
      final firestore = FirebaseService.instance.firestore;
      final userId = FirebaseService.instance.currentUserId;

      // Clear students
      final studentsSnapshot = await firestore
          .collection('users')
          .doc(userId)
          .collection('students')
          .get();

      final studentsBatch = firestore.batch();
      for (final doc in studentsSnapshot.docs) {
        studentsBatch.delete(doc.reference);
      }
      await studentsBatch.commit();

      // Clear payments
      final paymentsSnapshot = await firestore
          .collection('users')
          .doc(userId)
          .collection('payments')
          .get();

      final paymentsBatch = firestore.batch();
      for (final doc in paymentsSnapshot.docs) {
        paymentsBatch.delete(doc.reference);
      }
      await paymentsBatch.commit();

      if (mounted) {
        setState(() {
          _statusMessage =
              '🗑️ All data cleared successfully! Database is now empty.';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All data cleared successfully!'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _statusMessage = '❌ Error clearing data: $e';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error clearing data: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isClearing = false;
        });
      }
    }
  }

  void _showClearDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
          'This will permanently delete all students, payments, and analytics data. This action cannot be undone.\n\nAre you sure you want to continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _clearAllData();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear All Data'),
          ),
        ],
      ),
    );
  }
}
