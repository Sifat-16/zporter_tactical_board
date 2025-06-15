import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

import 'dart:convert';

import 'package:zporter_tactical_board/app/manager/color_manager.dart';
import 'package:zporter_tactical_board/presentation/admin/view/animation/default_animation_screen.dart';
import 'package:zporter_tactical_board/presentation/admin/view/lineup/default_lineup_screen.dart';
import 'package:zporter_tactical_board/presentation/admin/view/tutorials/admin_tutorials_screen.dart';

class AdminScreenTablet extends StatefulWidget {
  const AdminScreenTablet({super.key});

  @override
  State<AdminScreenTablet> createState() => _AdminScreenTabletState();
}

class _AdminScreenTabletState extends State<AdminScreenTablet> {
  // Helper to create styled buttons, reducing code repetition
  Widget _buildAdminButton({
    required String text,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: ColorManager.dark1,
        foregroundColor: ColorManager.white,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
        textStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        shape: RoundedRectangleBorder(
          side: BorderSide(color: ColorManager.dark2, width: 1),
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 5,
      ),
      child: Text(text),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.black,
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Admin Panel',
          style: TextStyle(
            color: ColorManager.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: ColorManager.black,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _buildAdminButton(
              text: 'Default Lineup',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => DefaultLineupScreen()),
                );
              },
            ),
            const SizedBox(height: 25),
            _buildAdminButton(
              text: 'Default Animation',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => DefaultAnimationScreen()),
                );
              },
            ),
            const SizedBox(height: 25),
            // *** NEW: Tutorials Button ***
            _buildAdminButton(
              text: 'Manage Tutorials',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => AdminTutorialsScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
