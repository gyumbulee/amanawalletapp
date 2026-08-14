import '../../../../core/network/paginated_result.dart';
import '../entities/transaction.dart';
import '../entities/transaction_filter.dart';

abstract class TransactionRepository {
  Future<PaginatedResult<Transaction>> getTransactions({
    int page = 1,
    TransactionFilter filter = const TransactionFilter(),
  });

  Future<Transaction> getTransactionDetail(String reference);
}
