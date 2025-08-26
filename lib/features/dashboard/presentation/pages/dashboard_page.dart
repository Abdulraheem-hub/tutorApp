/// @context7:feature:dashboard
/// @context7:dependencies:flutter_bloc,dashboard_bloc
/// @context7:pattern:page_widget
///
/// Main dashboard page following the TutorPay design
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/dashboard_stats_cards.dart';
import '../widgets/dashboard_quick_actions.dart';
import '../widgets/dashboard_recent_activity.dart';
import '../../../../core/constants/app_constants.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    // Load dashboard data when page initializes
    context.read<DashboardBloc>().add(const LoadDashboardData());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.developerTools);
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.build, color: Colors.white),
      ),
      body: SafeArea(
        child: BlocBuilder<DashboardBloc, DashboardState>(
          builder: (context, state) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<DashboardBloc>().add(const RefreshDashboardData());
              },
              child: CustomScrollView(
                slivers: [
                  // Header with greeting and settings
                  const SliverToBoxAdapter(child: DashboardHeader()),

                  // Main content
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),

                          // Loading or Error States
                          if (state is DashboardLoading)
                            const _LoadingWidget()
                          else if (state is DashboardError)
                            _ErrorWidget(message: state.message)
                          else if (state is DashboardLoaded ||
                              state is DashboardRefreshing)
                            _DashboardContent(
                              state: state,
                              isRefreshing: state is DashboardRefreshing,
                            ),

                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  final DashboardState state;
  final bool isRefreshing;

  const _DashboardContent({required this.state, this.isRefreshing = false});

  @override
  Widget build(BuildContext context) {
    final dashboardData = state is DashboardLoaded
        ? (state as DashboardLoaded).dashboardData
        : (state as DashboardRefreshing).currentData;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Stats Cards
        DashboardStatsCards(
          dashboardData: dashboardData,
          isRefreshing: isRefreshing,
        ),

        const SizedBox(height: 24),

        // Quick Actions
        const DashboardQuickActions(),

        const SizedBox(height: 24),

        // Recent Activity
        DashboardRecentActivity(
          activities: dashboardData.recentActivity,
          isRefreshing: isRefreshing,
        ),
      ],
    );
  }
}

class _LoadingWidget extends StatelessWidget {
  const _LoadingWidget();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 100),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Loading your dashboard...',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 100),
      ],
    );
  }
}

class _ErrorWidget extends StatelessWidget {
  final String message;

  const _ErrorWidget({required this.message});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 100),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Oops! Something went wrong',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  context.read<DashboardBloc>().add(const LoadDashboardData());
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 100),
      ],
    );
  }
}
