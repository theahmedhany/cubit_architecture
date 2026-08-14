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

enum AppDirection {
  right(0),
  downRight(45),
  down(90),
  downLeft(135),
  left(180),
  upLeft(225),
  up(270),
  upRight(315);

  const AppDirection(this.degrees);

  final int degrees;

  Matrix4 get transform {
    if (this == left) {
      return Matrix4.diagonal3Values(-1.0, 1.0, 1.0);
    }

    return Matrix4.rotationZ(degrees * math.pi / 180);
  }
}
