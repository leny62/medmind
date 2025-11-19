import 'package:equatable/equatable.dart';

abstract class BarcodeEvent extends Equatable {
  const BarcodeEvent();

  @override
  List<Object> get props => [];
}

class StartBarcodeScan extends BarcodeEvent {}

class StopBarcodeScan extends BarcodeEvent {}

class BarcodeDetected extends BarcodeEvent {
  final String barcode;

  const BarcodeDetected({required this.barcode});

  @override
  List<Object> get props => [barcode];
}