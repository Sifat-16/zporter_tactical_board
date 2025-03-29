import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:multi_split_view/multi_split_view.dart';
import 'package:zporter_tactical_board/app/core/component/custom_button.dart';
import 'package:zporter_tactical_board/app/core/component/custom_text_field.dart';
import 'package:zporter_tactical_board/app/extensions/size_extension.dart';
import 'package:zporter_tactical_board/app/helper/logger.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';
import 'package:zporter_tactical_board/app/manager/values_manager.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/lefttoolbarV2/lefttoolbar_component.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/r&d/animation_screen.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/r&d/game_screen.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/righttoolbar/righttoolbar_component.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/animation/animation_provider.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/animation/animation_state.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/board/board_provider.dart';

class TacticboardScreenTablet extends ConsumerStatefulWidget {
  const TacticboardScreenTablet({super.key});

  @override
  ConsumerState<TacticboardScreenTablet> createState() =>
      _TacticboardScreenTabletState();
}

class _TacticboardScreenTabletState
    extends ConsumerState<TacticboardScreenTablet>
    with AutomaticKeepAliveClientMixin {
  bool showAnimation = false;
  // Key for the "New Collection" form
  final _newCollectionFormKey = GlobalKey<FormState>();
  // Controller for the collection name input
  late TextEditingController _animationCollectionNameController;
  late TextEditingController _animationNameController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((t) {
      ref.read(animationProvider.notifier).getAllCollections();
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
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
                return Padding(
                  padding: const EdgeInsets.only(top: 50.0),
                  child:
                      asp.selectedAnimationCollectionModel == null
                          ? Center(child: _buildNewAnimationCollectionWidget())
                          : asp.selectedAnimationModel == null
                          ? Center(child: _buildNewAnimationWidget(ap: asp))
                          : SingleChildScrollView(
                            child: Column(
                              spacing: 20,
                              children: [
                                // Flexible(flex: 7, child: GameScreen(key: _gameScreenKey)),
                                SizedBox(
                                  height: context.heightPercent(80),
                                  child:
                                      showAnimation
                                          ? AnimationScreen()
                                          : GameScreen(),
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
  }

  Widget _buildFieldToolbar() {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Flexible(flex: 1, child: Container()),
          Flexible(
            flex: 2,
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
                // CustomButton(
                //   borderColor: ColorManager.red,
                //   fillColor: ColorManager.transparent,
                //   padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                //   borderRadius: 3,
                //   child: Text(
                //     "Delete",
                //     style: Theme.of(context).textTheme.labelLarge!.copyWith(
                //       color: ColorManager.white,
                //       fontWeight: FontWeight.bold,
                //     ),
                //   ),
                // ),
                CustomButton(
                  onTap: () {
                    ref.read(boardProvider.notifier).onAnimationSave();
                    // context.read<BoardBloc>().add(SaveToAnimationEvent());
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

                // CustomButton(
                //   fillColor: ColorManager.blue,
                //
                //   onTap: () {
                //     // List<FieldDraggableItem> copiedItems = itemPosition.map(
                //     //         (e){
                //     //       if(e is ArrowHead){
                //     //         return e.copyWith(parent: e.parent.copyWith());
                //     //       }
                //     //       return e.copyWith();
                //     //     }
                //     // ).toList();
                //     // AnimationModel animationModel = AnimationModel(id: ObjectId(), items: copiedItems, index: -1);
                //     // globalAnimations.add(animationModel);
                //     // context.read<AnimationBloc>().add(AnimationSaveEvent(animationModel: animationModel));
                //   },
                //   padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                //   borderRadius: 3,
                //   child: Text(
                //     "Save",
                //     style: Theme.of(context).textTheme.labelLarge!.copyWith(
                //       color: ColorManager.white,
                //       fontWeight: FontWeight.bold,
                //     ),
                //   ),
                // ),
                //
                // CustomButton(
                //   onTap: () {
                //     // context.read<AnimationBloc>().add(PlayAnimationEvent());
                //     // context.read<BoardBloc>().add(ShowAnimationEvent());
                //     setState(() {
                //       showAnimation = !showAnimation;
                //     });
                //   },
                //   fillColor: ColorManager.green,
                //   padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                //   borderRadius: 3,
                //   child: Text(
                //     "Play",
                //     style: Theme.of(context).textTheme.labelLarge!.copyWith(
                //       color: ColorManager.white,
                //       fontWeight: FontWeight.bold,
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- UPDATED Method to build the "Add New Collection" section ---
  Widget _buildNewAnimationCollectionWidget() {
    _animationCollectionNameController = TextEditingController();
    // Now uses the controller and key from the State class
    return Container(
      width: context.widthPercent(30),
      // Wrap content in a Form widget
      child: Form(
        key: _newCollectionFormKey, // Assign the key to the Form
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomTextFormField(
              // Use the controller from the State
              controller: _animationCollectionNameController,
              label: "Collection Name....",
              textInputAction: TextInputAction.done, // Set appropriate action
              // Add the validator
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a collection name.'; // Error message
                }
                return null; // Return null if valid
              },
              // Optional: Submit form when 'done' action is pressed on keyboard
              onFieldSubmitted: (_) {
                _submitNewCollection();
              },
            ),
            const SizedBox(height: 20), // Add spacing
            SizedBox(
              width: context.widthPercent(20),
              child: CustomButton(
                borderRadius: 2,
                onTap: _submitNewCollection, // Call separate submit method
                fillColor: ColorManager.blue,
                child: Text(
                  "Add new Collection",
                  style: Theme.of(context).textTheme.labelLarge!.copyWith(
                    color: ColorManager.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Helper method to handle form submission ---
  void _submitNewCollection() {
    // Validate the form using the GlobalKey
    if (_newCollectionFormKey.currentState?.validate() ?? false) {
      // If the form is valid:
      final newCollectionName = _animationCollectionNameController.text.trim();
      zlog(data: "Form is valid. Adding collection: $newCollectionName");

      // TODO: Call your Riverpod notifier method to actually create
      //       and select the new collection. Example:
      ref
          .read(animationProvider.notifier)
          .createNewCollection(newCollectionName);

      // Optionally clear the text field after submission
      // _animationCollectionNameController.clear();

      // Optional: Hide keyboard
      // FocusScope.of(context).unfocus();
    } else {
      // Form is invalid, validation errors will be displayed automatically
      zlog(data: "Form is invalid.");
    }
  }

  Widget _buildNewAnimationWidget({required AnimationState ap}) {
    _animationNameController = TextEditingController();
    // Now uses the controller and key from the State class
    return Container(
      width: context.widthPercent(30),
      // Wrap content in a Form widget
      child: Form(
        key: _newCollectionFormKey, // Assign the key to the Form
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Animation Collection : ${ap.selectedAnimationCollectionModel?.name ?? "Error"}",
              style: Theme.of(
                context,
              ).textTheme.labelLarge!.copyWith(color: ColorManager.white),
            ),
            CustomTextFormField(
              // Use the controller from the State
              controller: _animationNameController,
              label: "Animation Name....",
              textInputAction: TextInputAction.done, // Set appropriate action
              // Add the validator
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a Animation Name.'; // Error message
                }
                return null; // Return null if valid
              },
              // Optional: Submit form when 'done' action is pressed on keyboard
              onFieldSubmitted: (_) {
                _submitNewAnimation();
              },
            ),
            const SizedBox(height: 20), // Add spacing
            SizedBox(
              width: context.widthPercent(20),
              child: CustomButton(
                borderRadius: 2,
                onTap: _submitNewAnimation, // Call separate submit method
                fillColor: ColorManager.blue,
                child: Text(
                  "Add new Animation",
                  style: Theme.of(context).textTheme.labelLarge!.copyWith(
                    color: ColorManager.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Helper method to handle form submission ---
  void _submitNewAnimation() {
    // Validate the form using the GlobalKey
    if (_newCollectionFormKey.currentState?.validate() ?? false) {
      // If the form is valid:
      final newCollectionName = _animationNameController.text.trim();
      zlog(data: "Form is valid. Adding collection: $newCollectionName");

      // TODO: Call your Riverpod notifier method to actually create
      //       and select the new collection. Example:
      ref
          .read(animationProvider.notifier)
          .createNewAnimation(newCollectionName);
    } else {
      // Form is invalid, validation errors will be displayed automatically
      zlog(data: "Form is invalid.");
    }
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
