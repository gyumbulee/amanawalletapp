import '../../../../constants/electricity_disco.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../entities/meter_validation.dart';

abstract class ElectricityRepository {
  Future<MeterValidation> validateMeter({
    required ElectricityDisco disco,
    required MeterType meterType,
    required String meterNumber,
  });

  Future<Transaction> purchase({
    required ElectricityDisco disco,
    required MeterType meterType,
    required String meterNumber,
    required int amountKobo,
    required String phone,
    required String transactionPin,
  });
}
