import 'package:equatable/equatable.dart';

/// Result of validating a meter number before purchase — lets the user
/// confirm they're paying for the right property before committing.
class MeterValidation extends Equatable {
  const MeterValidation({
    required this.customerName,
    this.customerAddress,
  });

  final String customerName;
  final String? customerAddress;

  @override
  List<Object?> get props => [customerName, customerAddress];
}
