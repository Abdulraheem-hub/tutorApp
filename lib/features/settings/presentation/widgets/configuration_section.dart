/**
 * @context7:feature:app_configuration
 * @context7:pattern:widget_component
 * @context7:dependencies:flutter/material.dart
 * 
 * Reusable configuration section widget for displaying and managing
 * a list of configurable items (grades or subjects) with add, edit, delete actions
 */

import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class ConfigurationSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final List<dynamic> items;
  final VoidCallback onAddItem;
  final Function(dynamic) onEditItem;
  final Function(dynamic) onDeleteItem;
  final Function(dynamic, bool)? onToggleActive;
  final Widget Function(dynamic) itemBuilder;

  const ConfigurationSection({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.items,
    required this.onAddItem,
    required this.onEditItem,
    required this.onDeleteItem,
    this.onToggleActive,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 20, color: iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.textLight,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onAddItem,
              icon: const Icon(Icons.add, color: AppTheme.primaryPurple),
              style: IconButton.styleFrom(
                backgroundColor: AppTheme.primaryPurple.withOpacity(0.1),
                padding: const EdgeInsets.all(8),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Items list
        if (items.isEmpty) _buildEmptyState(context) else _buildItemsList(),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.textLight.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Icon(icon, size: 24, color: iconColor),
          ),
          const SizedBox(height: 12),
          Text(
            'No $title Added',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Add $title to customize available options',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppTheme.textLight,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildItemsList() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.textLight.withOpacity(0.2)),
      ),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return Container(
            decoration: BoxDecoration(
              border: index < items.length - 1
                  ? Border(
                      bottom: BorderSide(
                        color: AppTheme.textLight.withOpacity(0.1),
                      ),
                    )
                  : null,
            ),
            child: Dismissible(
              key: Key('${title}_${index}'),
              direction: DismissDirection.endToStart,
              confirmDismiss: (direction) async {
                return await _showDeleteConfirmation(context, item);
              },
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                decoration: BoxDecoration(
                  color: AppTheme.errorColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              child: InkWell(
                onTap: () => onEditItem(item),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: itemBuilder(item),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<bool> _showDeleteConfirmation(
    BuildContext context,
    dynamic item,
  ) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Delete ${title.substring(0, title.length - 1)}'),
            content: Text(
              'Are you sure you want to delete this ${title.toLowerCase().substring(0, title.length - 1)}?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                  onDeleteItem(item);
                },
                child: Text(
                  'Delete',
                  style: TextStyle(color: AppTheme.errorColor),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }
}
