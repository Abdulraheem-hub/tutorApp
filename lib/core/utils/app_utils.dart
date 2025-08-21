/**
 * @context7:feature:utilities
 * @context7:dependencies:intl
 * @context7:pattern:helper_functions
 * 
 * Utility functions for formatting and common operations
 */

import 'package:intl/intl.dart';
import '../constants/app_constants.dart';

class AppUtils {
  // Currency Formatting
  static String formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      symbol: AppConstants.currencySymbol,
      decimalDigits: amount % 1 == 0 ? 0 : 2,
    );
    return formatter.format(amount);
  }
  
  // Percentage Formatting
  static String formatPercentage(double percentage) {
    final formatter = NumberFormat.percentPattern();
    return formatter.format(percentage / 100);
  }
  
  // Date Formatting
  static String formatDate(DateTime date) {
    return DateFormat(AppConstants.dateFormat).format(date);
  }
  
  static String formatTime(DateTime time) {
    return DateFormat(AppConstants.timeFormat).format(time);
  }
  
  static String formatDateTime(DateTime dateTime) {
    return DateFormat(AppConstants.dateTimeFormat).format(dateTime);
  }
  
  // Time ago formatting
  static String timeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '${years}y ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '${months}mo ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
  
  // Number Formatting
  static String formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
  
  // Validation
  static bool isValidEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(email);
  }
  
  static bool isValidPhone(String phone) {
    return RegExp(r'^\+?[\d\s\-\(\)]{10,}$').hasMatch(phone);
  }
  
  // Color helpers for status
  static String getPaymentStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'paid':
        return 'success';
      case 'pending':
        return 'warning';
      case 'overdue':
      case 'failed':
        return 'error';
      default:
        return 'info';
    }
  }
  
  // Generate dummy data (for development)
  static List<Map<String, dynamic>> generateDummyStudents() {
    return [
      {
        'id': '1',
        'name': 'Sarah Johnson',
        'profileImage': null,
        'lastPayment': DateTime.now().subtract(const Duration(hours: 2)),
        'amount': 80.0,
        'status': 'paid',
      },
      {
        'id': '2',
        'name': 'Mike Chen',
        'profileImage': null,
        'lastPayment': DateTime.now().subtract(const Duration(hours: 16)),
        'amount': 0.0,
        'status': 'new',
      },
      {
        'id': '3',
        'name': 'Emma Davis',
        'profileImage': null,
        'lastPayment': DateTime.now().subtract(const Duration(days: 5)),
        'amount': 120.0,
        'status': 'overdue',
      },
    ];
  }
  
  static Map<String, dynamic> generateDummyDashboardData() {
    return {
      'totalEarnings': 2450.0,
      'earningsChange': 12.0, // percentage
      'activeStudents': 24,
      'studentsChange': 3,
      'pendingAmount': 320.0,
      'pendingCount': 5,
      'monthlyGoal': 890.0,
      'goalProgress': 0.75, // 75%
      'recentActivity': generateDummyStudents(),
    };
  }
}
