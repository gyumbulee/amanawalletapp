import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/referral_summary.dart';
import 'referral_repository_provider.dart';

/// Same AsyncNotifier-with-refresh pattern as walletBalanceProvider — lets
/// the screen pull-to-refresh explicitly.
class ReferralSummaryController extends AsyncNotifier<ReferralSummary> {
  @override
  Future<ReferralSummary> build() {
    return ref.read(referralRepositoryProvider).getSummary();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(referralRepositoryProvider).getSummary());
  }
}

final referralSummaryProvider =
    AsyncNotifierProvider<ReferralSummaryController, ReferralSummary>(ReferralSummaryController.new);
