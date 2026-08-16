import 'package:equatable/equatable.dart';

/// Result of validating a smart card/IUC number before purchase — lets the
/// user confirm they're paying for the right decoder before committing.
class SmartcardValidation extends Equatable {
  const SmartcardValidation({required this.customerName});

  final String customerName;

  @override
  List<Object?> get props => [customerName];
}
