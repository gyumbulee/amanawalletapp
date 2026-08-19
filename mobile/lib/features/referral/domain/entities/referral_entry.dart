import 'package:equatable/equatable.dart';

enum ReferralStatus { pending, completed }

/// A single referred user and the bonus earned from them.
class ReferralEntry extends Equatable {
  const ReferralEntry({
    required this.id,
    required this.refereeName,
    required this.status,
    required this.bonusKobo,
    required this.joinedAt,
  });

  final String id;
  final String refereeName;
  final ReferralStatus status;
  final int bonusKobo;
  final DateTime joinedAt;

  @override
  List<Object?> get props => [id, refereeName, status, bonusKobo, joinedAt];
}
