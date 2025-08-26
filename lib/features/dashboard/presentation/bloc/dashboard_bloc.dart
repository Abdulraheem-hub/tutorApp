/// @context7:feature:dashboard
/// @context7:dependencies:flutter_bloc,dashboard_models
/// @context7:pattern:bloc_cubit
/// 
/// Dashboard BLoC implementation
library;

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/dashboard_models.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  DashboardBloc() : super(const DashboardInitial()) {
    on<LoadDashboardData>(_onLoadDashboardData);
    on<RefreshDashboardData>(_onRefreshDashboardData);
    on<UpdateDashboardData>(_onUpdateDashboardData);
  }

  Future<void> _onLoadDashboardData(
    LoadDashboardData event,
    Emitter<DashboardState> emit,
  ) async {
    emit(const DashboardLoading());
    
    try {
      // Simulate API call delay
      await Future.delayed(const Duration(milliseconds: 1500));
      
      // Load dummy data (in real app, this would be from repository)
      final dashboardData = DashboardDataModel.fromDummyData();
      
      emit(DashboardLoaded(dashboardData: dashboardData));
    } catch (e) {
      emit(DashboardError(message: e.toString()));
    }
  }

  Future<void> _onRefreshDashboardData(
    RefreshDashboardData event,
    Emitter<DashboardState> emit,
  ) async {
    final currentState = state;
    
    if (currentState is DashboardLoaded) {
      emit(DashboardRefreshing(currentData: currentState.dashboardData));
      
      try {
        // Simulate API call delay
        await Future.delayed(const Duration(milliseconds: 800));
        
        // Load updated data
        final dashboardData = DashboardDataModel.fromDummyData();
        
        emit(DashboardLoaded(dashboardData: dashboardData));
      } catch (e) {
        emit(DashboardError(message: e.toString()));
      }
    } else {
      // If not loaded, just load normally
      add(const LoadDashboardData());
    }
  }

  Future<void> _onUpdateDashboardData(
    UpdateDashboardData event,
    Emitter<DashboardState> emit,
  ) async {
    final currentState = state;
    
    if (currentState is DashboardLoaded) {
      try {
        // Simulate real-time update
        final updatedData = DashboardDataModel.fromDummyData();
        emit(DashboardLoaded(dashboardData: updatedData));
      } catch (e) {
        emit(DashboardError(message: e.toString()));
      }
    }
  }
}
