import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/tacticboard_screen.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/board/board_bloc.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/form/line/line_bloc.dart';

class TacticApp extends StatelessWidget {
  const TacticApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<LineBloc>(create: (_) => LineBloc()),
        BlocProvider<BoardBloc>(create: (_) => BoardBloc()),
      ],
      child: ScreenUtilInit(
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
              body: TacticboardScreen(),
            ),
          );
        },
      ),
    );
    // TacticboardScreenV2();
  }
}
