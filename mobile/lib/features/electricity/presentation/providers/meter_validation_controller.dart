import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../constants/electricity_disco.dart';
import '../../domain/entities/meter_validation.dart';
import 'electricity_repository_provider.dart';

/// Manually triggered (not auto-run on every keystroke) since meter
/// validation hits VTpass/BigiSub upstream — the user taps "Validate
/// Meter" once they've filled in disco/type/number.
class MeterValidationController extends AsyncNotifier<MeterValidation?> {
  @override
  MeterValidation? build() => null;

  Future<void> validate({
    required ElectricityDisco disco,
    required MeterType meterType,
    required String meterNumber,
  }) async {
    state = const AsyncLoading();
    final repo = ref.read(electricityRepositoryProvider);
    state = await AsyncValue.guard(
      () => repo.validateMeter(disco: disco, meterType: meterType, meterNumber: meterNumber),
    );
  }

  void reset() => state = const AsyncData(null);
}

final meterValidationControllerProvider =
    AsyncNotifierProvider<MeterValidationController, MeterValidation?>(MeterValidationController.new);
