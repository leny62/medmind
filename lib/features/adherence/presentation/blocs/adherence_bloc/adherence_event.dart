import 'package:equatable/equatable.dart';

abstract class AdherenceEvent extends Equatable {
  const AdherenceEvent();

  @override
  List<Object> get props => [];
}

class GetAdherenceLogsRequested extends AdherenceEvent {
  final DateTime startDate;
  final DateTime endDate;

  const GetAdherenceLogsRequested({
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object> get props => [startDate, endDate];
}

class GetAdherenceSummaryRequested extends AdherenceEvent {}

class LogMedicationTakenRequested extends AdherenceEvent {
  final String medicationId;
  final DateTime takenAt;
  final String? notes;

  const LogMedicationTakenRequested({
    required this.medicationId,
    required this.takenAt,
    this.notes,
  });

  @override
  List<Object> get props => [medicationId, takenAt, notes ?? ''];
}

class ExportAdherenceDataRequested extends AdherenceEvent {
  final String format; // 'pdf' or 'csv'

  const ExportAdherenceDataRequested({required this.format});

  @override
  List<Object> get props => [format];
}