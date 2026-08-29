/// Education PIN exam boards.
enum EducationExamType {
  waec,
  waecRegistration,
  neco,
  nabteb,
  jamb;

  String get apiValue {
    switch (this) {
      case EducationExamType.waec:
        return 'waec';

      case EducationExamType.waecRegistration:
        return 'waec-registration';

      case EducationExamType.neco:
        return 'neco';

      case EducationExamType.nabteb:
        return 'nabteb';

      case EducationExamType.jamb:
        return 'jamb';
    }
  }

  String get label {
    switch (this) {
      case EducationExamType.waec:
        return 'WAEC';

      case EducationExamType.waecRegistration:
        return 'WAEC Registration';

      case EducationExamType.neco:
        return 'NECO';

      case EducationExamType.nabteb:
        return 'NABTEB';

      case EducationExamType.jamb:
        return 'JAMB';
    }
  }

  /// Only JAMB requires validating a profile ID before purchase.
  bool get requiresProfileValidation => this == EducationExamType.jamb;
}
