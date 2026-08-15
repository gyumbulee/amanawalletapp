import 'package:flutter/material.dart';

/// Nigerian telecom networks — shared between the Airtime and Data (data
/// bundle) modules, since both route through the same VTpass/BigiSub
/// network selection. Lives in constants rather than a single feature's
/// domain folder to avoid a cross-feature import once Data is built.
enum NetworkProvider {
  mtn,
  glo,
  airtel,
  nineMobile;

  static NetworkProvider? fromApi(String? value) {
    switch (value) {
      case 'mtn':
        return NetworkProvider.mtn;
      case 'glo':
        return NetworkProvider.glo;
      case 'airtel':
        return NetworkProvider.airtel;
      case '9mobile':
        return NetworkProvider.nineMobile;
      default:
        return null;
    }
  }

  String get apiValue {
    switch (this) {
      case NetworkProvider.mtn:
        return 'mtn';
      case NetworkProvider.glo:
        return 'glo';
      case NetworkProvider.airtel:
        return 'airtel';
      case NetworkProvider.nineMobile:
        return '9mobile';
    }
  }

  String get label {
    switch (this) {
      case NetworkProvider.mtn:
        return 'MTN';
      case NetworkProvider.glo:
        return 'Glo';
      case NetworkProvider.airtel:
        return 'Airtel';
      case NetworkProvider.nineMobile:
        return '9mobile';
    }
  }

  /// Approximate brand color per network, used for the selector chips —
  /// not official brand assets, just enough for quick visual recognition.
  Color get brandColor {
    switch (this) {
      case NetworkProvider.mtn:
        return const Color(0xFFFFCC00);
      case NetworkProvider.glo:
        return const Color(0xFF3AB54A);
      case NetworkProvider.airtel:
        return const Color(0xFFED1C24);
      case NetworkProvider.nineMobile:
        return const Color(0xFF006E51);
    }
  }

  /// MTN's brand yellow needs dark text/icons to stay legible; all others
  /// read fine in white.
  Color get onBrandColor => this == NetworkProvider.mtn ? const Color(0xFF111827) : Colors.white;

  /// Best-effort network detection from a Nigerian phone number prefix —
  /// used to auto-select the network as the user types, which they can
  /// still override manually.
  static NetworkProvider? fromPhonePrefix(String phone) {
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    final normalized = digits.startsWith('234')
        ? '0${digits.substring(3)}'
        : digits;
    if (normalized.length < 4) return null;
    final prefix = normalized.substring(0, 4);

    const mtnPrefixes = ['0803', '0806', '0703', '0706', '0813', '0816', '0810', '0814', '0903', '0906', '0913', '0916'];
    const gloPrefixes = ['0805', '0807', '0705', '0815', '0811', '0905', '0915'];
    const airtelPrefixes = ['0802', '0808', '0708', '0812', '0701', '0902', '0901', '0904', '0907', '0912'];
    const nineMobilePrefixes = ['0809', '0817', '0818', '0908', '0909'];

    if (mtnPrefixes.contains(prefix)) return NetworkProvider.mtn;
    if (gloPrefixes.contains(prefix)) return NetworkProvider.glo;
    if (airtelPrefixes.contains(prefix)) return NetworkProvider.airtel;
    if (nineMobilePrefixes.contains(prefix)) return NetworkProvider.nineMobile;
    return null;
  }
}
