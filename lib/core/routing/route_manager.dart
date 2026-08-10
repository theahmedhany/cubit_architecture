import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../helpers/app_logger.dart';

class RouteManager {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  // Safe Current Context.
  static BuildContext get currentContext {
    final context = navigatorKey.currentContext;

    assert(
      context != null,
      'RouteManager.currentContext is null.'
      'Make sure navigatorKey is attached to MaterialApp.',
    );

    return context!;
  }

  // Base Navigations.
  static Future<dynamic> navigateTo(
    Widget page, {
    RouteAnimation animation = RouteAnimation.none,
  }) {
    AppLogger.log(
      'Navigate To ➡️ ${page.runtimeType} 🔹 Animation: $animation',
      name: 'ROUTE_MANAGER',
    );

    return navigatorKey.currentState!.push(_buildPageRoute(page, animation));
  }

  static Future<dynamic> navigateAndReplaceCurrentScreen(
    Widget page, {
    RouteAnimation animation = RouteAnimation.none,
  }) {
    AppLogger.log(
      'Replace Current Screen ➡️ ${page.runtimeType} 🔹 Animation: $animation',
      name: 'ROUTE_MANAGER',
    );

    return navigatorKey.currentState!.pushReplacement(
      _buildPageRoute(page, animation),
    );
  }

  static Future<dynamic> navigateAndPopAll(
    Widget page, {
    RouteAnimation animation = RouteAnimation.none,
  }) {
    AppLogger.log(
      'Navigate And Pop All ➡️ ${page.runtimeType} 🔹 Animation: $animation',
      name: 'ROUTE_MANAGER',
    );

    return navigatorKey.currentState!.pushAndRemoveUntil(
      _buildPageRoute(page, animation),
      (_) => false,
    );
  }

  static Future<dynamic> navigateAndPopUntilFirstPage(
    Widget page, {
    RouteAnimation animation = RouteAnimation.none,
  }) {
    AppLogger.log(
      'Navigate And Pop Until First Page ➡️ ${page.runtimeType} 🔹 Animation: $animation',
      name: 'ROUTE_MANAGER',
    );

    return navigatorKey.currentState!.pushAndRemoveUntil(
      _buildPageRoute(page, animation),
      (route) => route.isFirst,
    );
  }

  // Pop Navigation if possible.
  static bool canPop() => navigatorKey.currentState!.canPop();

  static void pop<T extends Object?>([T? result]) {
    if (canPop()) {
      AppLogger.log('Pop Route 🔹 Result: $result', name: 'ROUTE_MANAGER');

      navigatorKey.currentState!.pop(result);
    }
  }

  // Route Builder.
  static Route<dynamic> _buildPageRoute(Widget page, RouteAnimation animation) {
    switch (animation) {
      case RouteAnimation.slideFromRight:
        return CupertinoPageRoute(builder: (_) => page);

      case RouteAnimation.fade:
        return PageRouteBuilder(
          pageBuilder: (_, a, _) => page,
          transitionsBuilder: (_, a, _, child) =>
              FadeTransition(opacity: a, child: child),
        );

      case RouteAnimation.slideFromBottom:
        return PageRouteBuilder(
          pageBuilder: (_, a, _) => page,
          transitionsBuilder: (_, a, _, child) => SlideTransition(
            position: Tween(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(a),
            child: child,
          ),
        );

      case RouteAnimation.scale:
        return PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 300),
          pageBuilder: (_, animation, _) => page,
          transitionsBuilder: (_, animation, _, child) {
            return ScaleTransition(
              scale: Tween<double>(begin: 0.9, end: 1).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              ),
              child: child,
            );
          },
        );

      case RouteAnimation.none:
        return MaterialPageRoute(builder: (_) => page);
    }
  }
}

// Enum for route animation types.
enum RouteAnimation { slideFromRight, fade, slideFromBottom, scale, none }
