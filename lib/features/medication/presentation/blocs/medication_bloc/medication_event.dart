import 'package:equatable/equatable.dart';
import '../../../domain/entities/medication_entity.dart';

abstract class MedicationEvent extends Equatable {
  const MedicationEvent();

  @override
  List<Object> get props => [];
}

class GetMedicationsRequested extends MedicationEvent {}

class AddMedicationRequested extends MedicationEvent {
  final MedicationEntity medication;

  const AddMedicationRequested({required this.medication});

  @override
  List<Object> get props => [medication];
}

class UpdateMedicationRequested extends MedicationEvent {
  final MedicationEntity medication;

  const UpdateMedicationRequested({required this.medication});

  @override
  List<Object> get props => [medication];
}

class DeleteMedicationRequested extends MedicationEvent {
  final String medicationId;

  const DeleteMedicationRequested({required this.medicationId});

  @override
  List<Object> get props => [medicationId];
}