import 'package:flutter/material.dart';

@immutable
class BreakpointsHelper {
  const BreakpointsHelper._();

  static const double maxWidth = 1400;

  static const double tablet = 600;
  static const double largeTablet = 900;
  static const double desktop = 1200;

  static DeviceType of(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    if (width >= desktop) {
      return DeviceType.desktop;
    }

    if (width >= largeTablet) {
      return DeviceType.largeTablet;
    }

    if (width >= tablet) {
      return DeviceType.tablet;
    }

    return DeviceType.mobile;
  }
}

enum DeviceType { mobile, tablet, largeTablet, desktop }
