import 'package:equatable/equatable.dart';

abstract class BarcodeState extends Equatable {
  const BarcodeState();

  @override
  List<Object> get props => [];
}

class BarcodeInitial extends BarcodeState {}

class BarcodeScanLoading extends BarcodeState {}

class BarcodeScanned extends BarcodeState {
  final String medicationName;
  final String barcode;

  const BarcodeScanned({
    required this.medicationName,
    required this.barcode,
  });

  @override
  List<Object> get props => [medicationName, barcode];
}

class BarcodeScanError extends BarcodeState {
  final String message;

  const BarcodeScanError({required this.message});

  @override
  List<Object> get props => [message];
}