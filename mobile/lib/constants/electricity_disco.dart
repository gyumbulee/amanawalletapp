/// Nigerian electricity distribution companies (discos). No list endpoint
/// exists for these per the API spec, so — same approach as
/// [NetworkProvider] for telecoms — this is a fixed client-side reference
/// list using VTpass-style service IDs.
enum ElectricityDisco {
  ikeja,
  eko,
  abuja,
  kano,
  portHarcourt,
  jos,
  ibadan,
  kaduna,
  enugu,
  benin,
  aba,
  yola;

  String get apiValue {
    switch (this) {
      case ElectricityDisco.ikeja:
        return 'ikeja-electric';
      case ElectricityDisco.eko:
        return 'eko-electric';
      case ElectricityDisco.abuja:
        return 'abuja-electric';
      case ElectricityDisco.kano:
        return 'kano-electric';
      case ElectricityDisco.portHarcourt:
        return 'portharcourt-electric';
      case ElectricityDisco.jos:
        return 'jos-electric';
      case ElectricityDisco.ibadan:
        return 'ibadan-electric';
      case ElectricityDisco.kaduna:
        return 'kaduna-electric';
      case ElectricityDisco.enugu:
        return 'enugu-electric';
      case ElectricityDisco.benin:
        return 'benin-electric';
      case ElectricityDisco.aba:
        return 'aba-electric';
      case ElectricityDisco.yola:
        return 'yola-electric';
    }
  }

  String get label {
    switch (this) {
      case ElectricityDisco.ikeja:
        return 'Ikeja Electric';
      case ElectricityDisco.eko:
        return 'Eko Electric';
      case ElectricityDisco.abuja:
        return 'Abuja Electric';
      case ElectricityDisco.kano:
        return 'Kano Electric';
      case ElectricityDisco.portHarcourt:
        return 'Port Harcourt Electric';
      case ElectricityDisco.jos:
        return 'Jos Electric';
      case ElectricityDisco.ibadan:
        return 'Ibadan Electric';
      case ElectricityDisco.kaduna:
        return 'Kaduna Electric';
      case ElectricityDisco.enugu:
        return 'Enugu Electric';
      case ElectricityDisco.benin:
        return 'Benin Electric';
      case ElectricityDisco.aba:
        return 'Aba Electric';
      case ElectricityDisco.yola:
        return 'Yola Electric';
    }
  }
}

enum MeterType {
  prepaid,
  postpaid;

  String get apiValue => name;

  String get label => this == MeterType.prepaid ? 'Prepaid' : 'Postpaid';
}
