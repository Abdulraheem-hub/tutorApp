/// @context7:feature:dashboard
/// @context7:dependencies:flutter_bloc,equatable,dashboard_entities
/// @context7:pattern:bloc_state
/// 
/// Dashboard BLoC states
library;

import 'package:equatable/equatable.dart';
import '../../domain/entities/dashboard_entities.dart';

abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {
  const DashboardInitial();
}

class DashboardLoading extends DashboardState {
  const DashboardLoading();
}

class DashboardLoaded extends DashboardState {
  final DashboardData dashboardData;

  const DashboardLoaded({required this.dashboardData});

  @override
  List<Object?> get props => [dashboardData];
}

class DashboardError extends DashboardState {
  final String message;

  const DashboardError({required this.message});

  @override
  List<Object?> get props => [message];
}

class DashboardRefreshing extends DashboardState {
  final DashboardData currentData;

  const DashboardRefreshing({required this.currentData});

  @override
  List<Object?> get props => [currentData];
}
