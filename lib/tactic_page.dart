import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';
import 'package:zporter_tactical_board/app/services/navigation_service.dart';
import 'package:zporter_tactical_board/presentation/admin/view/admin_screen.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/tacticboard_screen.dart';

import 'app/listener/connectivity_listener.dart';

class TacticApp extends StatelessWidget {
  const TacticApp({super.key});

  @override
  Widget build(BuildContext context) {
    final botToastBuilder = BotToastInit();
    return ScreenUtilInit(
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return MaterialApp(
          navigatorKey: NavigationService.navigatorKey,
          debugShowCheckedModeBanner: false,
          title: 'Zporter Board',
          builder: (context, child) {
            // Wrap the child from BotToast with our new ConnectivityListener
            child = ConnectivityListener(child: child!);
            // Then, call the original builder from BotToast
            return botToastBuilder(context, child);
          },
          localizationsDelegates: const [
            // GlobalMaterialLocalizations.delegate,
            // GlobalCupertinoLocalizations.delegate,
            // GlobalWidgetsLocalizations.delegate,
            FlutterQuillLocalizations.delegate,
          ],

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
