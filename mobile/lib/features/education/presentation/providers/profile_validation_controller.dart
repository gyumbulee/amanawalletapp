import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../constants/education_exam_type.dart';
import '../../domain/entities/profile_validation.dart';
import 'education_repository_provider.dart';

class ProfileValidationController extends AsyncNotifier<ProfileValidation?> {
  @override
  ProfileValidation? build() => null;

  Future<void> validate({
    required EducationExamType examType,
    required String variationCode,
    required String profileId,
  }) async {
    state = const AsyncLoading();
    final repo = ref.read(educationRepositoryProvider);
    state = await AsyncValue.guard(
      () => repo.validateProfile(examType: examType, variationCode: variationCode, profileId: profileId),
    );
  }

  void reset() => state = const AsyncData(null);
}

final profileValidationControllerProvider =
    AsyncNotifierProvider<ProfileValidationController, ProfileValidation?>(
        ProfileValidationController.new);
