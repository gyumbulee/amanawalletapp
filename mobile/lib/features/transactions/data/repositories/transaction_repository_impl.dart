import '../../../../core/network/error_mapper.dart';
import '../../../../core/network/paginated_result.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/entities/transaction_filter.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/transaction_api_service.dart';
import '../models/transaction_model.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  TransactionRepositoryImpl(this._api);
  final TransactionApiService _api;

  @override
  Future<PaginatedResult<Transaction>> getTransactions({
    int page = 1,
    TransactionFilter filter = const TransactionFilter(),
  }) async {
    try {
      final response = await _api.getTransactions(page: page, filterParams: filter.toQueryParams());
      final data = response.data as Map<String, dynamic>;
      final rawList = (data['data'] as List?) ?? const [];
      final items = rawList.map((e) => TransactionModel.fromJson(e as Map<String, dynamic>)).toList();

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

  @override
  Future<Transaction> getTransactionDetail(String reference) async {
    try {
      final response = await _api.getTransactionDetail(reference);
      final data = response.data as Map<String, dynamic>;
      final payload = data['data'] is Map ? data['data'] as Map<String, dynamic> : data;
      return TransactionModel.fromJson(payload);
    } catch (e) {
      throw ErrorMapper.map(e);
    }
  }
}
