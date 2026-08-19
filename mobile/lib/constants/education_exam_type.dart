/// Education PIN exam boards — fixed client-side reference list, same
/// approach as NetworkProvider/ElectricityDisco/CableProvider.
enum EducationExamType {
  waec,
  neco,
  nabteb,
  jamb;

  String get apiValue => name;

  String get label {
    switch (this) {
      case EducationExamType.waec:
        return 'WAEC';
      case EducationExamType.neco:
        return 'NECO';
      case EducationExamType.nabteb:
        return 'NABTEB';
      case EducationExamType.jamb:
        return 'JAMB';
    }
  }

  /// Only JAMB requires validating a profile ID before purchase (like
  /// meter/smartcard validation elsewhere) — WAEC/NECO/NABTEB PINs are a
  /// straightforward package purchase, no upfront validation step.
  bool get requiresProfileValidation => this == EducationExamType.jamb;
}
