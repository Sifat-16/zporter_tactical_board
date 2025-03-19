import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/tacticboard_screen_v2.dart';

class TacticApp extends StatelessWidget {
  const TacticApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Zporter Board',
          themeMode: ThemeMode.system,
          home: Scaffold(
            backgroundColor: ColorManager.black,
            body: TacticboardScreenV2(),
          ),
        );
      },
    );
    // TacticboardScreenV2();
  }
}
