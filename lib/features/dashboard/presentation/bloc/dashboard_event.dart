/**
 * @context7:feature:dashboard
 * @context7:dependencies:flutter_bloc,equatable
 * @context7:pattern:bloc_event
 * 
 * Dashboard BLoC events
 */

import 'package:equatable/equatable.dart';

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

class LoadDashboardData extends DashboardEvent {
  const LoadDashboardData();
}

class RefreshDashboardData extends DashboardEvent {
  const RefreshDashboardData();
}

class UpdateDashboardData extends DashboardEvent {
  const UpdateDashboardData();
}
