import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';
import 'package:zporter_tactical_board/presentation/admin/view/admin_screen.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/tacticboard_screen.dart';

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
          builder: BotToastInit(),
          navigatorObservers: [BotToastNavigatorObserver()],
          themeMode: ThemeMode.system,
          home: Scaffold(
            backgroundColor: ColorManager.black,
            body: TacticPage(userId: "DUMMY_USER_ID"),
          ),
          // home: GameScreen(),
        );
      },
    );
  }
}

class TacticPage extends StatefulWidget {
  const TacticPage({super.key, required this.userId});

  final String userId;

  @override
  State<TacticPage> createState() => _TacticPageState();
}

class _TacticPageState extends State<TacticPage> {
  bool isAdmin = true;
  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: isAdmin ? AdminScreen() : TacticboardScreen(userId: widget.userId),
      // body: DrawingScreen(),
    );
  }
}
