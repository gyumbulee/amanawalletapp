import '../../../../core/network/error_mapper.dart';
import '../../../../core/network/paginated_result.dart';
import '../../domain/entities/wallet_balance.dart';
import '../../domain/entities/wallet_ledger_entry.dart';
import '../../domain/repositories/wallet_repository.dart';
import '../datasources/wallet_api_service.dart';
import '../models/wallet_models.dart';

class WalletRepositoryImpl implements WalletRepository {
  WalletRepositoryImpl(this._api);
  final WalletApiService _api;

  @override
  Future<WalletBalance> getBalance() async {
    try {
      final response = await _api.getBalance();
      final data = response.data as Map<String, dynamic>;
      // Support both a flat response and one wrapped in "data".
      final payload = data['data'] is Map ? data['data'] as Map<String, dynamic> : data;
      return WalletBalanceModel.fromJson(payload);
    } catch (e) {
      throw ErrorMapper.map(e);
    }
  }

  @override
  Future<PaginatedResult<WalletLedgerEntry>> getLedger({int page = 1}) async {
    try {
      final response = await _api.getLedger(page: page);
      final data = response.data as Map<String, dynamic>;
      final rawList = (data['data'] as List?) ?? const [];
      final items = rawList
          .map((e) => WalletLedgerEntryModel.fromJson(e as Map<String, dynamic>))
          .toList();

      final meta = data['meta'] as Map<String, dynamic>?;
      return PaginatedResult(
        items: items,
        currentPage: meta?['current_page'] as int? ?? page,
        lastPage: meta?['last_page'] as int? ?? page,
      );
    } catch (e) {
      throw ErrorMapper.map(e);
    }
  }
}
