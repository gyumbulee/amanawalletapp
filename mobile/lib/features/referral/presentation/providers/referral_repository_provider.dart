import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../providers/global_providers.dart';
import '../../data/datasources/referral_api_service.dart';
import '../../data/repositories/referral_repository_impl.dart';
import '../../domain/repositories/referral_repository.dart';

final referralApiServiceProvider = Provider<ReferralApiService>((ref) {
  return ReferralApiService(ref.watch(dioProvider));
});

final referralRepositoryProvider = Provider<ReferralRepository>((ref) {
  return ReferralRepositoryImpl(ref.watch(referralApiServiceProvider));
});
