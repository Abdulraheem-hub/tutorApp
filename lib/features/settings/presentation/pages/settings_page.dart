/**
 * @context7:feature:settings
 * @context7:pattern:page_widget
 * 
 * Settings page with user profile, account settings, support, and app info
 */

import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../widgets/settings_section.dart';
import '../widgets/settings_item.dart';
import '../widgets/user_profile_section.dart';
import 'payment_settings_page.dart';
import 'app_configuration_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

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
          'Settings',
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
            // User Profile Section
            const UserProfileSection(),

            const SizedBox(height: 24),

            // Account Settings Section
            SettingsSection(
              title: 'Account Settings',
              children: [
                SettingsItem(
                  icon: Icons.credit_card,
                  iconColor: AppTheme.successColor,
                  iconBackgroundColor: AppTheme.successColor.withOpacity(0.1),
                  title: 'Payment Methods',
                  subtitle: 'Manage payment method labels',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const PaymentSettingsPage(),
                    ),
                  ),
                ),
                SettingsItem(
                  icon: Icons.settings,
                  iconColor: AppTheme.primaryPurple,
                  iconBackgroundColor: AppTheme.primaryPurple.withOpacity(0.1),
                  title: 'App Configuration',
                  subtitle: 'Manage grades and subjects',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const AppConfigurationPage(),
                    ),
                  ),
                ),
                SettingsItem(
                  icon: Icons.receipt_long,
                  iconColor: const Color(0xFF8B5CF6),
                  iconBackgroundColor: const Color(0xFF8B5CF6).withOpacity(0.1),
                  title: 'Receipt Generation',
                  subtitle: 'Customize receipt templates',
                  onTap: () =>
                      _showComingSoonDialog(context, 'Receipt Generation'),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Support Section
            SettingsSection(
              title: 'Support',
              children: [
                SettingsItem(
                  icon: Icons.support_agent,
                  iconColor: AppTheme.warningColor,
                  iconBackgroundColor: AppTheme.warningColor.withOpacity(0.1),
                  title: 'Contact Support',
                  subtitle: 'Get help from our team',
                  onTap: () =>
                      _showComingSoonDialog(context, 'Contact Support'),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // About Section
            SettingsSection(
              title: '',
              children: [
                SettingsItem(
                  icon: Icons.info_outline,
                  iconColor: AppTheme.textDark,
                  iconBackgroundColor: AppTheme.textDark.withOpacity(0.1),
                  title: 'About ${AppConstants.appName}',
                  subtitle: 'Version ${AppConstants.appVersion}',
                  onTap: () => _showComingSoonDialog(
                    context,
                    'About ${AppConstants.appName}',
                  ),
                ),
                SettingsItem(
                  icon: Icons.logout,
                  iconColor: AppTheme.errorColor,
                  iconBackgroundColor: AppTheme.errorColor.withOpacity(0.1),
                  title: 'Sign Out',
                  subtitle: 'Sign out of your account',
                  onTap: () => _showSignOutDialog(context),
                  isDestructive: true,
                ),
              ],
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _showComingSoonDialog(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(feature),
        content: Text('$feature feature is coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text(
          'Are you sure you want to sign out of your account?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement sign out logic
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Sign out functionality coming soon!'),
                ),
              );
            },
            child: Text(
              'Sign Out',
              style: TextStyle(color: AppTheme.errorColor),
            ),
          ),
        ],
      ),
    );
  }
}
