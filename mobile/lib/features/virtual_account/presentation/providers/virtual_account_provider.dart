import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../providers/global_providers.dart';
import '../../data/datasources/virtual_account_api_service.dart';
import '../../data/repositories/virtual_account_repository_impl.dart';
import '../../domain/entities/virtual_account.dart';
import '../../domain/repositories/virtual_account_repository.dart';

final virtualAccountApiServiceProvider = Provider<VirtualAccountApiService>((ref) {
  return VirtualAccountApiService(ref.watch(dioProvider));
});

final virtualAccountRepositoryProvider = Provider<VirtualAccountRepository>((ref) {
  return VirtualAccountRepositoryImpl(ref.watch(virtualAccountApiServiceProvider));
});

/// One virtual account per verified user — fetched once and cached; call
/// `ref.invalidate(virtualAccountProvider)` to force a re-fetch (e.g. after
/// BVN verification completes and the account becomes active).
final virtualAccountProvider = FutureProvider<VirtualAccount>((ref) {
  return ref.watch(virtualAccountRepositoryProvider).getVirtualAccount();
});
