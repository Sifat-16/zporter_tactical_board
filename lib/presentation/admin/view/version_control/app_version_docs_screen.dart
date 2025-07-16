import 'package:flutter/material.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';

class AppVersionDocsScreen extends StatelessWidget {
  const AppVersionDocsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.black,
      appBar: AppBar(
        title: const Text('System Documentation',
            style: TextStyle(color: ColorManager.white)),
        backgroundColor: ColorManager.black,
        iconTheme: const IconThemeData(color: ColorManager.white),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Text(
            'How Version Management Works',
            style: Theme.of(context)
                .textTheme
                .headlineSmall!
                .copyWith(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'This system gives you remote control over app updates. It works by checking a set of ordered rules from top to bottom. The first rule a user matches is applied. If no rules match, the "Default Settings" are used.',
            style:
                TextStyle(color: ColorManager.grey, height: 1.5, fontSize: 16),
          ),
          const Divider(height: 40, color: ColorManager.darkGrey),

          // --- Key Concepts Section ---
          Text("Key Concepts",
              style: Theme.of(context)
                  .textTheme
                  .titleLarge!
                  .copyWith(color: ColorManager.yellow)),
          const SizedBox(height: 12),
          _buildDocEntry(
            title: 'What is a "Hard" vs. "Soft" Update?',
            content:
                'A **Hard Update** shows a non-dismissible dialog that blocks the user from using the app until they update. Use this for critical security patches or essential features.\n\nA **Soft Update** shows a friendly, dismissible pop-up, suggesting an update that the user can ignore. Use this for minor features or UI improvements.',
            icon: Icons.compare_arrows_outlined,
          ),
          _buildDocEntry(
            title: 'How does Percentage Rollout work?',
            content:
                'This feature applies a rule to a random, consistent sample of your users. Each user\'s unique ID is converted into a number from 0-99. If that number is less than the percentage you set (e.g., 25), the rule applies to them. This is the best practice for safely testing new versions on a small group before releasing to everyone.',
            icon: Icons.pie_chart_outline,
          ),
          _buildDocEntry(
            title: 'How are Targeting Rules processed?',
            content:
                'Rules are checked in order from top to bottom. The **FIRST** rule that a user\'s device matches will be the one that is applied. Because of this, you should always place your most specific rules (like targeting a single user ID) at the top of the list, and more general rules (like a 100% rollout) at the bottom.',
            icon: Icons.filter_list_alt,
          ),

          const Divider(height: 40, color: ColorManager.darkGrey),

          // --- Rule Fields Section ---
          Text("Rule Field Explanations",
              style: Theme.of(context)
                  .textTheme
                  .titleLarge!
                  .copyWith(color: ColorManager.yellow)),
          const SizedBox(height: 12),
          _buildDocEntry(
            title: 'Target Platforms',
            content:
                'Limits a rule to only "android" or "ios". If you leave this blank, the rule will apply to both platforms.',
            icon: Icons.devices_other,
          ),
          _buildDocEntry(
            title: 'Target App Versions',
            content:
                'Targets users who are currently on specific, older versions of your app. This is useful for forcing users off a known buggy version. Enter versions separated by commas (e.g., "1.2.1, 1.2.2").',
            icon: Icons.new_releases_outlined,
          ),
          _buildDocEntry(
            title: 'Target Country Codes',
            content:
                'Limits a rule to users in specific countries. Use standard 2-letter ISO country codes, separated by commas (e.g., "US, DE, GB"). The app determines the user\'s country from their device settings.',
            icon: Icons.public,
          ),
          _buildDocEntry(
            title: 'Target User IDs',
            content:
                'This is the most precise targeting method. Apply a rule only to specific user IDs, separated by commas. This is ideal for internal testing with your team before a public rollout.',
            icon: Icons.person_pin,
          ),
        ],
      ),
    );
  }

  Widget _buildDocEntry(
      {required String title,
      required String content,
      required IconData icon}) {
    return Card(
      color: ColorManager.dark1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        leading: Icon(icon, color: ColorManager.yellow, size: 28),
        title: Text(title,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16)),
        childrenPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 20),
        expandedAlignment: Alignment.topLeft,
        iconColor: ColorManager.grey,
        collapsedIconColor: ColorManager.grey,
        children: [
          Text(content,
              style: const TextStyle(
                  color: ColorManager.grey, height: 1.6, fontSize: 14)),
        ],
      ),
    );
  }
}
