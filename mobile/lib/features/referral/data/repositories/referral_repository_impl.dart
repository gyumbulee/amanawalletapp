import '../../../../core/network/error_mapper.dart';
import '../../../../core/network/paginated_result.dart';
import '../../domain/entities/referral_entry.dart';
import '../../domain/entities/referral_summary.dart';
import '../../domain/repositories/referral_repository.dart';
import '../datasources/referral_api_service.dart';
import '../models/referral_models.dart';

class ReferralRepositoryImpl implements ReferralRepository {
  ReferralRepositoryImpl(this._api);
  final ReferralApiService _api;

  @override
  Future<ReferralSummary> getSummary() async {
    try {
      final response = await _api.getSummary();
      final data = response.data as Map<String, dynamic>;
      // Defensive unwrap, same pattern as wallet/virtual_account: backend
      // may nest under a named key, "data", or return flat.
      final payload = data['referral'] is Map
          ? data['referral'] as Map<String, dynamic>
          : (data['data'] is Map ? data['data'] as Map<String, dynamic> : data);
      return ReferralSummaryModel.fromJson(payload);
    } catch (e) {
      throw ErrorMapper.map(e);
    }
  }

  @override
  Future<PaginatedResult<ReferralEntry>> getHistory({int page = 1}) async {
    try {
      final response = await _api.getHistory(page: page);
      final data = response.data as Map<String, dynamic>;
      final rawList = (data['data'] as List?) ?? const [];
      final items = rawList.map((e) => ReferralEntryModel.fromJson(e as Map<String, dynamic>)).toList();

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
