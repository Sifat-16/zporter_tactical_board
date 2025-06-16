import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zporter_tactical_board/app/config/version/version_info.dart';
import 'package:zporter_tactical_board/app/manager/asset_manager.dart';
import 'package:zporter_tactical_board/app/manager/values_manager.dart';

class ZporterLogoLauncher extends StatelessWidget {
  const ZporterLogoLauncher({super.key});

  Future<void> _launchUrl(BuildContext context) async {
    String url = AppInfo.zporter_url;
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      try {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (e) {
        // It's good practice to show feedback to the user if launching fails.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not launch $url. Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not launch $url'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _launchUrl(context);
      },
      child: Image.asset(
        AssetsManager.logo,
        height: AppSize.s40,
        width: AppSize.s40,
      ),
    );
  }
}
