import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class MedicationEntity extends Equatable {
  final String id;
  final String name;
  final String dosage;
  final String frequency;
  final String instructions;
  final TimeOfDay reminderTime;
  final bool enableReminders;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isTakenToday;

  const MedicationEntity({
    required this.id,
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.instructions,
    required this.reminderTime,
    required this.enableReminders,
    required this.createdAt,
    this.updatedAt,
    this.isTakenToday = false,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    dosage,
    frequency,
    instructions,
    reminderTime,
    enableReminders,
    createdAt,
    updatedAt,
    isTakenToday,
  ];

  MedicationEntity copyWith({
    String? id,
    String? name,
    String? dosage,
    String? frequency,
    String? instructions,
    TimeOfDay? reminderTime,
    bool? enableReminders,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isTakenToday,
  }) {
    return MedicationEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      frequency: frequency ?? this.frequency,
      instructions: instructions ?? this.instructions,
      reminderTime: reminderTime ?? this.reminderTime,
      enableReminders: enableReminders ?? this.enableReminders,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isTakenToday: isTakenToday ?? this.isTakenToday,
    );
  }
}