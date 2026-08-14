import 'package:equatable/equatable.dart';

/// Wallet balance snapshot. Amount is stored in kobo (integer minor units)
/// to match the Laravel ledger and avoid floating point drift — see
/// shared/extensions/currency_extensions.dart for kobo<->Naira display.
class WalletBalance extends Equatable {
  const WalletBalance({
    required this.balanceKobo,
    this.currency = 'NGN',
  });

  final int balanceKobo;
  final String currency;

  @override
  List<Object?> get props => [balanceKobo, currency];
}
