import 'package:flutter/material.dart';

/// Corner radii per branding guidelines.
class AppRadii {
  AppRadii._();

  static const double button = 12;
  static const double card = 16;
  static const double bottomSheet = 20;
  static const double input = 12;

  static BorderRadius get buttonRadius => BorderRadius.circular(button);
  static BorderRadius get cardRadius => BorderRadius.circular(card);
  static BorderRadius get inputRadius => BorderRadius.circular(input);
  static BorderRadius get bottomSheetRadius =>
      const BorderRadius.vertical(top: Radius.circular(bottomSheet));
}
