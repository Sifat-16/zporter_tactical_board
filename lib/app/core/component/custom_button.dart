import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final VoidCallback? onTap;
  final Widget? child;
  final Color? fillColor;
  final Color? borderColor;
  final double? borderRadius;
  final EdgeInsets? padding;

  const CustomButton({
    super.key,
    this.onTap,
    this.child,
    this.fillColor = Colors.blue,
    this.borderColor,
    this.borderRadius = 8.0,
    this.padding = const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: fillColor,
          border: Border.all(color: borderColor ?? Colors.transparent),
          borderRadius: BorderRadius.circular(borderRadius ?? 0),
        ),
        child: Center(child: child),
      ),
    );
  }
}
