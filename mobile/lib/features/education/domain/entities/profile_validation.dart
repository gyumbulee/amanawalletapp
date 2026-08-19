import 'package:equatable/equatable.dart';

/// Result of validating a JAMB profile ID before purchase — lets the user
/// confirm they're buying the PIN for the right candidate.
class ProfileValidation extends Equatable {
  const ProfileValidation({required this.candidateName});

  final String candidateName;

  @override
  List<Object?> get props => [candidateName];
}
