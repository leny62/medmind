import 'package:equatable/equatable.dart';

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object> get props => [];
}

class LoadDashboardData extends DashboardEvent {}

class RefreshDashboardData extends DashboardEvent {}

class LogMedicationTaken extends DashboardEvent {
  final String medicationId;

  const LogMedicationTaken({required this.medicationId});

  @override
  List<Object> get props => [medicationId];
}