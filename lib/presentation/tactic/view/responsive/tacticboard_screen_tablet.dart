import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:multi_split_view/multi_split_view.dart';
import 'package:zporter_tactical_board/app/core/component/custom_button.dart';
import 'package:zporter_tactical_board/app/extensions/size_extension.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';
import 'package:zporter_tactical_board/app/manager/values_manager.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/lefttoolbarV2/lefttoolbar_component.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/r&d/animation_screen.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/r&d/game_screen.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/righttoolbar/righttoolbar_component.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/board/board_bloc.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/board/board_event.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/board/board_state.dart';

class TacticboardScreenTablet extends StatefulWidget {
  const TacticboardScreenTablet({super.key});

  @override
  State<TacticboardScreenTablet> createState() =>
      _TacticboardScreenTabletState();
}

class _TacticboardScreenTabletState extends State<TacticboardScreenTablet>
    with AutomaticKeepAliveClientMixin {
  final GlobalKey _gameScreenKey = GlobalKey(); // Add a GlobalKey
  bool showAnimation = false;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocConsumer<BoardBloc, BoardState>(
      builder: (context, state) {
        return MultiSplitView(
          initialAreas: [
            Area(
              flex: 1,
              max: 1,
              builder: (context, area) {
                return LefttoolbarComponent();
              },
            ),
            Area(
              flex: 3,
              max: 3,
              builder: (context, area) {
                return Padding(
                  padding: const EdgeInsets.only(top: 50.0),
                  child: SingleChildScrollView(
                    child: Column(
                      spacing: 20,
                      children: [
                        // Flexible(flex: 7, child: GameScreen(key: _gameScreenKey)),
                        SizedBox(
                          height: context.heightPercent(80),
                          child:
                              showAnimation
                                  ? AnimationScreen()
                                  : GameScreen(key: _gameScreenKey),
                        ),

                        _buildFieldToolbar(),

                        // Flexible(flex: 1, child: Container(color: Colors.red)),
                      ],
                    ),
                  ),
                );
              },
            ),
            Area(
              flex: 1,
              max: 1,
              builder: (context, area) {
                return RighttoolbarComponent();
              },
            ),
          ],
        );
      },

      listener: (BuildContext context, BoardState state) {
        if (state.showAnimation != showAnimation) {
          setState(() {
            showAnimation = state.showAnimation;
          });
        }
      },
    );
  }

  Widget _buildFieldToolbar() {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Flexible(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Icons.fullscreen_rounded,
                    color: ColorManager.white,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    // setState(() {
                    //   if(rotationAngle==pi/2){
                    //     rotationAngle=0;
                    //   }else{
                    //     rotationAngle=pi/2;
                    //   }
                    // });
                  },
                  icon: Icon(Icons.rotate_left, color: ColorManager.white),
                ),
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.threed_rotation, color: ColorManager.white),
                ),
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.share, color: ColorManager.white),
                ),
              ],
            ),
          ),

          SizedBox(width: AppSize.s32),

          Flexible(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CustomButton(
                  borderColor: ColorManager.red,
                  fillColor: ColorManager.transparent,
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  borderRadius: 3,
                  child: Text(
                    "Delete",
                    style: Theme.of(context).textTheme.labelLarge!.copyWith(
                      color: ColorManager.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                CustomButton(
                  onTap: () {
                    context.read<BoardBloc>().add(SaveToAnimationEvent());
                    // AnimationDataModel animationDataModel = AnimationDataModel(id: ObjectId(), items: globalAnimations);
                    // context.read<AnimationBloc>().add(AnimationDatabaseSaveEvent(animationDataModel: animationDataModel));
                  },
                  fillColor: ColorManager.grey,
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  borderRadius: 3,
                  child: Text(
                    "Save to animation",
                    style: Theme.of(context).textTheme.labelLarge!.copyWith(
                      color: ColorManager.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                CustomButton(
                  fillColor: ColorManager.blue,

                  onTap: () {
                    // List<FieldDraggableItem> copiedItems = itemPosition.map(
                    //         (e){
                    //       if(e is ArrowHead){
                    //         return e.copyWith(parent: e.parent.copyWith());
                    //       }
                    //       return e.copyWith();
                    //     }
                    // ).toList();
                    // AnimationModel animationModel = AnimationModel(id: ObjectId(), items: copiedItems, index: -1);
                    // globalAnimations.add(animationModel);
                    // context.read<AnimationBloc>().add(AnimationSaveEvent(animationModel: animationModel));
                  },
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  borderRadius: 3,
                  child: Text(
                    "Save",
                    style: Theme.of(context).textTheme.labelLarge!.copyWith(
                      color: ColorManager.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                CustomButton(
                  onTap: () {
                    // context.read<AnimationBloc>().add(PlayAnimationEvent());
                    // context.read<BoardBloc>().add(ShowAnimationEvent());
                    setState(() {
                      showAnimation = !showAnimation;
                    });
                  },
                  fillColor: ColorManager.green,
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  borderRadius: 3,
                  child: Text(
                    "Play",
                    style: Theme.of(context).textTheme.labelLarge!.copyWith(
                      color: ColorManager.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
