import '../../../../core/network/paginated_result.dart';
import '../entities/wallet_balance.dart';
import '../entities/wallet_ledger_entry.dart';

abstract class WalletRepository {
  Future<WalletBalance> getBalance();

  Future<PaginatedResult<WalletLedgerEntry>> getLedger({int page = 1});
}
