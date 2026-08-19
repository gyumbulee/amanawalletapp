import 'package:equatable/equatable.dart';

/// Top-line referral stats: the user's own code plus how many people
/// they've referred and how much they've earned from it.
class ReferralSummary extends Equatable {
  const ReferralSummary({
    required this.referralCode,
    required this.referralCount,
    required this.totalEarningsKobo,
  });

  final String referralCode;
  final int referralCount;
  final int totalEarningsKobo;

  @override
  List<Object?> get props => [referralCode, referralCount, totalEarningsKobo];
}
