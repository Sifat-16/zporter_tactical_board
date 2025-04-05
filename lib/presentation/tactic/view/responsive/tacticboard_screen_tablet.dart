import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:multi_split_view/multi_split_view.dart';
import 'package:zporter_tactical_board/app/core/component/pagination_component.dart';
import 'package:zporter_tactical_board/app/extensions/size_extension.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';
import 'package:zporter_tactical_board/data/animation/model/animation_collection_model.dart';
import 'package:zporter_tactical_board/data/animation/model/animation_item_model.dart';
import 'package:zporter_tactical_board/data/animation/model/animation_model.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/animation/show_quick_save_component.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/field/field_tool_bar.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/lefttoolbarV2/lefttoolbar_component.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/r&d/game_screen.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/righttoolbar/animation_data_input_component.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/righttoolbar/righttoolbar_component.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/animation/animation_provider.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/board/board_provider.dart';

class TacticboardScreenTablet extends ConsumerStatefulWidget {
  const TacticboardScreenTablet({super.key});

  @override
  ConsumerState<TacticboardScreenTablet> createState() =>
      _TacticboardScreenTabletState();
}

class _TacticboardScreenTabletState
    extends ConsumerState<TacticboardScreenTablet> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((t) async {
      await ref.read(animationProvider.notifier).getAllCollections();
      await ref.read(animationProvider.notifier).configureDefaultAnimations();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bp = ref.watch(boardProvider);
    final ap = ref.watch(animationProvider);

    return ap.isLoadingAnimationCollections
        ? Center(child: CircularProgressIndicator())
        : MultiSplitView(
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
                final asp = ref.watch(animationProvider);
                AnimationCollectionModel? collectionModel =
                    asp.selectedAnimationCollectionModel;
                AnimationModel? animationModel = asp.selectedAnimationModel;
                AnimationItemModel? selectedScene = asp.selectedScene;

                return Padding(
                  padding: const EdgeInsets.only(top: 50.0),
                  child:
                      asp.showNewCollectionInput == true ||
                              asp.showNewAnimationInput == true
                          ? AnimationDataInputComponent()
                          : asp.showQuickSave
                          ? ShowQuickSaveComponent()
                          : SingleChildScrollView(
                            child: Column(
                              spacing: 10,
                              children: [
                                // Flexible(flex: 7, child: GameScreen(key: _gameScreenKey)),
                                SizedBox(
                                  height: context.heightPercent(80),
                                  child: GameScreen(scene: selectedScene),
                                ),

                                FieldToolBar(
                                  selectedCollection: collectionModel,
                                  selectedAnimation: animationModel,
                                  selectedScene: selectedScene,
                                ),

                                if (animationModel == null)
                                  Row(
                                    children: [
                                      if (asp.defaultAnimationItems.isNotEmpty)
                                        Expanded(
                                          child: PaginationComponent(
                                            totalPages:
                                                asp
                                                    .defaultAnimationItems
                                                    .length,
                                            initialPage:
                                                asp.defaultAnimationItemIndex,
                                            currentPage:
                                                asp.defaultAnimationItemIndex,
                                            onIndexChange: (index) {
                                              ref
                                                  .read(
                                                    animationProvider.notifier,
                                                  )
                                                  .changeDefaultAnimationIndex(
                                                    index,
                                                  );
                                            },
                                          ),
                                        ),
                                      IconButton(
                                        onPressed: () {
                                          ref
                                              .read(animationProvider.notifier)
                                              .createNewDefaultAnimationItem();
                                        },
                                        icon: Icon(
                                          Icons.add,
                                          color: ColorManager.white,
                                        ),
                                      ),

                                      IconButton(
                                        onPressed: () {
                                          ref
                                              .read(animationProvider.notifier)
                                              .deleteDefaultAnimation();
                                        },
                                        icon: Icon(
                                          Icons.delete,
                                          color: ColorManager.white,
                                        ),
                                      ),
                                    ],
                                  ),

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
  }
}
