import 'dart:math' as math;

import 'package:flutter/material.dart';

class AppDirectionalityWidget extends StatelessWidget {
  const AppDirectionalityWidget({
    super.key,
    required this.child,
    required this.direction,
    this.enabled = true,
  });

  final Widget child;
  final AppDirection direction;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    if (!enabled) {
      return child;
    }

    return Transform(
      alignment: Alignment.center,
      transform: direction.transform,
      child: child,
    );
  }
}

extension AppDirectionTransform on AppDirection {
  Matrix4 get transform {
    switch (this) {
      /// Horizontal
      case AppDirection.left:
        return Matrix4.diagonal3Values(-1.0, 1.0, 1.0);

      case AppDirection.right:
        return Matrix4.identity();

      case AppDirection.up:
        return Matrix4.rotationZ(-math.pi / 2);

      case AppDirection.upLeft:
        return Matrix4.rotationZ(-3 * math.pi / 4);

      case AppDirection.upRight:
        return Matrix4.rotationZ(-math.pi / 4);

      case AppDirection.down:
        return Matrix4.rotationZ(math.pi / 2);

      case AppDirection.downLeft:
        return Matrix4.rotationZ(3 * math.pi / 4);

      case AppDirection.downRight:
        return Matrix4.rotationZ(math.pi / 4);
    }
  }
}

enum AppDirection {
  left,
  right,
  up,
  upLeft,
  upRight,
  down,
  downLeft,
  downRight,
}
