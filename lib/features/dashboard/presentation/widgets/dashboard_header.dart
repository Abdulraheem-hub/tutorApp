/// @context7:feature:dashboard
/// @context7:pattern:widget_component
/// 
/// Dashboard header with greeting and app branding
library;

import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../settings/presentation/pages/settings_page.dart';

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    
    // Determine greeting based on time
    String greeting;
    if (now.hour < 12) {
      greeting = 'Good morning';
    } else if (now.hour < 17) {
      greeting = 'Good afternoon';
    } else {
      greeting = 'Good evening';
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // App bar with logo and settings
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // App Logo and Name
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.school_outlined,
                      color: theme.colorScheme.onPrimary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    AppConstants.appName,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              
              // Settings button
              IconButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const SettingsPage(),
                    ),
                  );
                },
                icon: Icon(
                  Icons.settings_outlined,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                tooltip: 'Settings',
                style: IconButton.styleFrom(
                  backgroundColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Welcome back text
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome back!',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Here\'s your payment overview',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
