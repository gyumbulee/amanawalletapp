import '../../../../core/network/paginated_result.dart';
import '../entities/referral_entry.dart';
import '../entities/referral_summary.dart';

abstract class ReferralRepository {
  Future<ReferralSummary> getSummary();

  Future<PaginatedResult<ReferralEntry>> getHistory({int page = 1});
}
