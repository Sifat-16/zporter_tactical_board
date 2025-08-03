import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zporter_tactical_board/app/services/injection_container.dart';
import 'package:zporter_tactical_board/tactic_page.dart';

// This is the main function for your Android & iOS app.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeTacticBoardDependencies();
  runApp(
    DevicePreview(
      enabled: false,
      builder: (context) {
        return const ProviderScope(child: TacticApp());
      },
    ),
  );
}
