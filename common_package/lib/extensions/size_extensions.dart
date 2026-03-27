import 'package:flutter/material.dart';

extension SizeExtensions on BuildContext {
  MediaQueryData get mediaQuery => MediaQuery.of(this);

  double get bodyHeight {
    Size size = mediaQuery.size;
    double statusBar = mediaQuery.viewPadding.top;
    // double kLeadingWidth = kToolbarHeight;
    double bottomBar = mediaQuery.viewInsets.bottom;
    double bottomPadding = mediaQuery.viewPadding.bottom;
    double bottomSafeArea = mediaQuery.padding.bottom;
    return size.height -
        statusBar /*- kLeadingWidth*/ -
        bottomBar -
        bottomPadding -
        bottomSafeArea;
  }

  Size size() => MediaQuery.of(this).size;

  /// return screen width
  double get width => MediaQuery.sizeOf(this).width;

  /// return screen height
  double get height => MediaQuery.sizeOf(this).height;

  /// return screen devicePixelRatio
  double get pixelRatio => MediaQuery.devicePixelRatioOf(this);

  /// returns brightness
  Brightness get platformBrightness => MediaQuery.platformBrightnessOf(this);

  /// Return the height of status bar
  double get statusBarHeight => MediaQuery.paddingOf(this).top;

  /// Return the height of navigation bar
  double get navigationBarHeight => MediaQuery.paddingOf(this).bottom;
}
