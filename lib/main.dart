// import 'package:device_preview/device_preview.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:zporter_tactical_board/app/services/injection_container.dart';
// import 'package:zporter_tactical_board/tactic_page.dart';
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await initializeTacticBoardDependencies();
//   runApp(
//     DevicePreview(
//       enabled: false,
//       builder: (context) {
//         return ProviderScope(child: const TacticApp());
//       },
//     ),
//   );
// }

// lib/main.dart

// This special import statement chooses the correct file at compile time.
// It imports 'main_web.dart' for web builds and 'main_mobile.dart' for others.
import 'main_web.dart' if (dart.library.io) 'main_mobile.dart' as entrypoint;

void main() {
  // This calls the main() function from the correctly imported file.
  entrypoint.main();
}
