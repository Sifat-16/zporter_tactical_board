import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';

class ZLoader extends StatelessWidget {
  final double logoSize;
  final double indicatorSize;
  final double indicatorStrokeWidth;
  final Color indicatorColor;
  final String logoAssetPath; // Path to your logo asset

  const ZLoader({
    super.key,
    this.logoSize = 32.0, // More standard icon-like size
    this.indicatorSize =
        48.0, // Gives enough space for the logo and spinner visibility
    this.indicatorStrokeWidth = 3.0,
    this.indicatorColor = ColorManager.yellow,
    required this.logoAssetPath,
  }) : assert(indicatorSize > logoSize,
            "Indicator size must be greater than logo size");

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            // Your Logo
            Image.asset(
              logoAssetPath,
              width: logoSize,
              height: logoSize,
            ),
            // Circular Progress Indicator
            SizedBox(
              width: indicatorSize,
              height: indicatorSize,
              child: CircularProgressIndicator(
                strokeWidth: indicatorStrokeWidth,
                valueColor: AlwaysStoppedAnimation<Color>(indicatorColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void showZLoader() {
  BotToast.showCustomLoading(
    toastBuilder: (CancelFunc cancelFunc) {
      // Using the new default sizes:
      return const ZLoader(
        logoAssetPath: "assets/image/logo.png", // <<< REPLACE
      );
    },
    backgroundColor: Colors.black.withValues(alpha: 0.7),
    allowClick: false,
    clickClose: false,
    ignoreContentClick: true,
  );
}
