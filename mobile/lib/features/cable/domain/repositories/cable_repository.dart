import '../../../../constants/cable_provider.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../entities/cable_package.dart';
import '../entities/smartcard_validation.dart';

abstract class CableRepository {
  Future<List<CablePackage>> getPackages({required CableProvider provider});

  Future<SmartcardValidation> validateSmartcard({
    required CableProvider provider,
    required String smartCardNumber,
  });

  Future<Transaction> purchase({
    required CableProvider provider,
    required String smartCardNumber,
    required String variationCode,
    required String phone,
    required String transactionPin,
  });
}
