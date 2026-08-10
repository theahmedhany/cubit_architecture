import 'package:flutter/material.dart';

import 'breakpoints_helper.dart';

class DesignSizeHelper {
  static Size getDesignSize(BuildContext context) {
    final deviceType = BreakpointsHelper.of(context);

    final size = MediaQuery.sizeOf(context);

    final isLandscape = size.width > size.height;

    switch (deviceType) {
      case DeviceType.desktop:
        return const Size(1440, 900);

      case DeviceType.largeTablet:
      case DeviceType.tablet:
        return isLandscape ? const Size(1024, 768) : const Size(768, 1024);

      case DeviceType.mobile:
        return isLandscape ? const Size(812, 375) : const Size(375, 812);
    }
  }
}
