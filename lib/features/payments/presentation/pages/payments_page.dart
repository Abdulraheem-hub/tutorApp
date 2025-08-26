/// @context7:feature:payments
/// @context7:dependencies:flutter,firebase_payment_repository,payment_cards
/// @context7:pattern:page_widget
///
/// Main payments page to view all payments with comprehensive payment information
library;

import "package:flutter/material.dart";
import "../../../students/presentation/pages/payments_list_page.dart";

/// Main payments page that delegates to the comprehensive payments list
class PaymentsPage extends StatelessWidget {
  const PaymentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Delegate to the comprehensive payments list page
    return const PaymentsListPage();
  }
}
