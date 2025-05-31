import 'package:flutter/material.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';
import 'package:zporter_tactical_board/presentation/admin/view/animation/default_animation_screen.dart';
import 'package:zporter_tactical_board/presentation/admin/view/lineup/default_lineup_screen.dart'; // Assuming this is the correct path to your ColorManager

class AdminScreenTablet extends StatefulWidget {
  const AdminScreenTablet({super.key});

  @override
  State<AdminScreenTablet> createState() => _AdminScreenTabletState();
}

class _AdminScreenTabletState extends State<AdminScreenTablet> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.black, // Use black from ColorManager
      appBar: AppBar(
        centerTitle: true, // Center the AppBar title
        title: const Text(
          'Admin Panel',
          style: TextStyle(color: ColorManager.white), // Title text color
        ),
        backgroundColor: ColorManager.black, // AppBar background also black
        elevation: 0, // Optional: remove shadow for a flatter look
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => DefaultLineupScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    ColorManager.dark1, // Dark theme button background
                foregroundColor:
                    ColorManager.white, // Text color from ColorManager
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    color: ColorManager.dark2,
                    width: 1,
                  ), // Optional: subtle border
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Default Lineup'),
            ),
            const SizedBox(height: 25), // Spacing between buttons
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => DefaultAnimationScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    ColorManager.dark1, // Dark theme button background
                foregroundColor:
                    ColorManager.white, // Text color from ColorManager
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    color: ColorManager.dark2,
                    width: 1,
                  ), // Optional: subtle border
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Default Animation'),
            ),
          ],
        ),
      ),
    );
  }
}
