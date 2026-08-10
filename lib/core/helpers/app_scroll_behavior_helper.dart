import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class AppScrollBehaviorHelper extends MaterialScrollBehavior {
  const AppScrollBehaviorHelper();

  // Enable scrolling with all major input devices (Web + Desktop + Mobile).
  @override
  Set<PointerDeviceKind> get dragDevices => const {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.stylus,
    PointerDeviceKind.trackpad,
  };

  // Unified physics builder.
  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    final platform = Theme.of(context).platform;

    final basePhysics = _getPlatformPhysics(platform);

    return const AlwaysScrollableScrollPhysics().applyTo(basePhysics);
  }

  // Platform specific physics.
  ScrollPhysics _getPlatformPhysics(TargetPlatform platform) {
    final isCupertino =
        platform == TargetPlatform.iOS || platform == TargetPlatform.macOS;

    if (isCupertino) {
      return const BouncingScrollPhysics();
    }

    return const ClampingScrollPhysics();
  }
}
