import 'package:equatable/equatable.dart';
import '../../../domain/entities/medication_entity.dart';

abstract class MedicationState extends Equatable {
  const MedicationState();

  @override
  List<Object> get props => [];
}

class MedicationInitial extends MedicationState {}

class MedicationLoading extends MedicationState {}

class MedicationLoaded extends MedicationState {
  final List<MedicationEntity> medications;

  const MedicationLoaded({required this.medications});

  @override
  List<Object> get props => [medications];
}

class MedicationAdded extends MedicationState {
  final MedicationEntity medication;

  const MedicationAdded({required this.medication});

  @override
  List<Object> get props => [medication];
}

class MedicationUpdated extends MedicationState {
  final MedicationEntity medication;

  const MedicationUpdated({required this.medication});

  @override
  List<Object> get props => [medication];
}

class MedicationDeleted extends MedicationState {
  final String medicationId;

  const MedicationDeleted({required this.medicationId});

  @override
  List<Object> get props => [medicationId];
}

class MedicationError extends MedicationState {
  final String message;

  const MedicationError({required this.message});

  @override
  List<Object> get props => [message];
}