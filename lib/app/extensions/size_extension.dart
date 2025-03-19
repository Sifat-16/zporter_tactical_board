import 'package:flutter/material.dart';

extension SizeExtension on BuildContext {
  Size get screenSize => MediaQuery.of(this).size;
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
  EdgeInsets get padding => MediaQuery.of(this).padding;

  double widthPercent(double percent) => screenWidth * percent / 100;
  double heightPercent(double percent) => screenHeight * percent / 100;
}
