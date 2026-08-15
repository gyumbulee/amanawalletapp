import '../../../../constants/network_provider.dart';
import '../../../transactions/domain/entities/transaction.dart';

/// Purchase result reuses the [Transaction] entity from the transactions
/// feature — a bill payment purchase IS a transaction (per the project
/// spec: "every operation creates one transaction"), so this avoids
/// duplicating the same shape under a different name.
abstract class AirtimeRepository {
  Future<Transaction> purchase({
    required NetworkProvider network,
    required String phone,
    required int amountKobo,
    required String transactionPin,
  });
}
