import 'package:flutter/material.dart';

import 'dimensions_helper.dart';

class MediaHelper {
  const MediaHelper._();

  // Internal MediaQuery access.
  static MediaQueryData _media(BuildContext context) {
    return MediaQuery.of(context);
  }

  // Returns full screen size (width + height).
  static Size size(BuildContext context) {
    return _media(context).size;
  }

  // Returns screen width in pixels.
  static double width(BuildContext context) {
    return size(context).width;
  }

  // Returns screen height in pixels.
  static double height(BuildContext context) {
    return size(context).height;
  }

  // Returns system safe area padding.
  static EdgeInsets viewPadding(BuildContext context) {
    return _media(context).viewPadding;
  }

  // Returns system UI insets.
  static EdgeInsets viewInsets(BuildContext context) {
    return _media(context).viewInsets;
  }

  // Returns Bottom system UI insets.
  static double bottomViewInsets(BuildContext context) =>
      _media(context).viewInsets.bottom;

  // Returns top safe area padding.
  static double topPadding(BuildContext context) {
    return viewPadding(context).top;
  }

  // Returns bottom safe area padding.
  static double bottomPadding(BuildContext context) {
    final bottom = viewPadding(context).bottom;

    return bottom < 16 ? 16.height : bottom;
  }

  // Returns left safe area padding
  static double leftPadding(BuildContext context) {
    return viewPadding(context).left;
  }

  // Returns right safe area padding
  static double rightPadding(BuildContext context) {
    return viewPadding(context).right;
  }

  // Returns default AppBar height.
  static double appBarHeight() {
    return kToolbarHeight;
  }

  // Returns true if device is in portrait mode.
  static bool isPortrait(BuildContext context) {
    return _media(context).orientation == Orientation.portrait;
  }

  // Returns true if device is in landscape mode.
  static bool isLandscape(BuildContext context) {
    return _media(context).orientation == Orientation.landscape;
  }

  // Returns true if keyboard is currently open.
  static bool isKeyboardOpen(BuildContext context) {
    return viewInsets(context).bottom > 0;
  }

  // Dismisses the keyboard if it is currently open.
  static void dismissKeyboard(BuildContext context) {
    FocusScope.of(context).unfocus();
  }
}
