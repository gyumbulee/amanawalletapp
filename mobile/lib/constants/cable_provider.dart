import 'package:flutter/material.dart';

/// Nigerian cable TV providers — fixed client-side reference list, same
/// approach as [NetworkProvider] and [ElectricityDisco]: no list endpoint
/// exists for these, and VTpass uses these as fixed service IDs.
enum CableProvider {
  dstv,
  gotv,
  startimes;

  String get apiValue {
    switch (this) {
      case CableProvider.dstv:
        return 'dstv';
      case CableProvider.gotv:
        return 'gotv';
      case CableProvider.startimes:
        return 'startimes';
    }
  }

  String get label {
    switch (this) {
      case CableProvider.dstv:
        return 'DStv';
      case CableProvider.gotv:
        return 'GOtv';
      case CableProvider.startimes:
        return 'StarTimes';
    }
  }

  /// Approximate brand color, same reasoning as NetworkProvider.brandColor
  /// — enough for quick visual recognition, not official brand assets.
  Color get brandColor {
    switch (this) {
      case CableProvider.dstv:
        return const Color(0xFF0F4C9C);
      case CableProvider.gotv:
        return const Color(0xFF00A650);
      case CableProvider.startimes:
        return const Color(0xFFE30613);
    }
  }

  Color get onBrandColor => Colors.white;
}
