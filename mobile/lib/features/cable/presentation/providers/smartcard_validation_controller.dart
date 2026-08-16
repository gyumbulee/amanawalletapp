import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../constants/cable_provider.dart';
import '../../domain/entities/smartcard_validation.dart';
import 'cable_repository_provider.dart';

class SmartcardValidationController extends AsyncNotifier<SmartcardValidation?> {
  @override
  SmartcardValidation? build() => null;

  Future<void> validate({required CableProvider provider, required String smartCardNumber}) async {
    state = const AsyncLoading();
    final repo = ref.read(cableRepositoryProvider);
    state = await AsyncValue.guard(
      () => repo.validateSmartcard(provider: provider, smartCardNumber: smartCardNumber),
    );
  }

  void reset() => state = const AsyncData(null);
}

final smartcardValidationControllerProvider =
    AsyncNotifierProvider<SmartcardValidationController, SmartcardValidation?>(
        SmartcardValidationController.new);
