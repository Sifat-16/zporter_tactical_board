// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:zporter_tactical_board/app/config/version/version_info.dart';
// import 'package:zporter_tactical_board/app/core/component/color_picker_slider.dart';
// import 'package:zporter_tactical_board/app/core/component/link_text.dart';
// import 'package:zporter_tactical_board/app/manager/color_manager.dart';
// import 'package:zporter_tactical_board/presentation/tactic/view_model/animation/animation_provider.dart';
// import 'package:zporter_tactical_board/presentation/tactic/view_model/board/board_provider.dart';
// import 'package:zporter_tactical_board/presentation/tactic/view_model/board/board_state.dart';
//
// class SettingsToolbarComponent extends ConsumerStatefulWidget {
//   const SettingsToolbarComponent({super.key});
//
//   @override
//   ConsumerState<SettingsToolbarComponent> createState() =>
//       _SettingsToolbarComponentState();
// }
//
// class _SettingsToolbarComponentState
//     extends ConsumerState<SettingsToolbarComponent> {
//   @override
//   Widget build(BuildContext context) {
//     final bp = ref.watch(boardProvider);
//     return Container(
//       padding: EdgeInsets.symmetric(vertical: 25, horizontal: 10),
//       child: ListView(
//         children: [
//           // DropdownSelector<String>(
//           //   label: "Home Club",
//           //   items: ["Club 1", "Club 2", "Club 3"],
//           //   initialValue: null,
//           //   onChanged: (s) {},
//           //   itemAsString: (String item) {
//           //     return item;
//           //   },
//           // ),
//           //
//           // DropdownSelector<String>(
//           //   label: "Home Team",
//           //   items: ["Team 1", "Team 2", "Team 3"],
//           //   initialValue: null,
//           //   onChanged: (s) {},
//           //   itemAsString: (String item) {
//           //     return item;
//           //   },
//           // ),
//           //
//           // DropdownSelector<String>(
//           //   label: "Away Club",
//           //   items: ["Club 1", "Club 2", "Club 3"],
//           //   initialValue: null,
//           //   onChanged: (s) {},
//           //   itemAsString: (String item) {
//           //     return item;
//           //   },
//           // ),
//           //
//           // DropdownSelector<String>(
//           //   label: "Away Team",
//           //   items: ["Team 1", "Team 2", "Team 3"],
//           //   initialValue: null,
//           //   onChanged: (s) {},
//           //   itemAsString: (String item) {
//           //     return item;
//           //   },
//           // ),
//           _buildFillColorWidget("Field Color", boardState: bp),
//
//           _buildAppInfo()
//
//           // ImagePicker(label: "Background Image",  onChanged: (s){})
//         ],
//       ),
//     );
//   }
//
//   Widget _buildFillColorWidget(String title, {required BoardState boardState}) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//       spacing: 10,
//       children: [
//         Text(
//           title,
//           style: Theme.of(
//             context,
//           ).textTheme.labelLarge!.copyWith(color: ColorManager.grey),
//         ),
//         ColorSlider(
//           initialColor: boardState.boardColor,
//           colors: [
//             ColorManager.grey,
//             Colors.red,
//             Colors.blue,
//             Colors.green,
//             Colors.yellow,
//             Colors.purple,
//           ],
//           onColorChanged: (c) {
//             ref.read(boardProvider.notifier).updateBoardColor(c);
//             ref.read(animationProvider.notifier).updateBoardColor(c);
//           },
//         ),
//       ],
//     );
//   }
//
//   Widget _buildAppInfo() {
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       spacing: 10,
//       children: [
//         LinkText(
//           text: AppInfo.supportLinkName,
//           url: AppInfo.supportLink,
//           style: Theme.of(context)
//               .textTheme
//               .labelMedium!
//               .copyWith(color: ColorManager.white),
//         ),
//         Column(
//           mainAxisSize: MainAxisSize.min,
//           spacing: 2,
//           children: [
//             Text(
//               "Version ${AppInfo.version}",
//               style: Theme.of(context)
//                   .textTheme
//                   .labelMedium!
//                   .copyWith(color: ColorManager.white),
//             ),
//             Text(
//               "Last updated ${AppInfo.lastUpdated}",
//               style: Theme.of(context)
//                   .textTheme
//                   .labelMedium!
//                   .copyWith(color: ColorManager.white),
//             ),
//           ],
//         )
//       ],
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:zporter_tactical_board/app/config/version/version_info.dart'; // Assuming this path is correct
import 'package:zporter_tactical_board/app/core/component/color_picker_slider.dart'; // Assuming this path is correct
import 'package:zporter_tactical_board/app/core/component/link_text.dart'; // Assuming this path is correct
import 'package:zporter_tactical_board/app/manager/color_manager.dart'; // Assuming this path is correct
import 'package:zporter_tactical_board/presentation/tactic/view_model/animation/animation_provider.dart'; // Assuming this path is correct
import 'package:zporter_tactical_board/presentation/tactic/view_model/board/board_provider.dart'; // Assuming this path is correct
import 'package:zporter_tactical_board/presentation/tactic/view_model/board/board_state.dart';

import 'components/field_preview_painter.dart'; // Assuming this path is correct

class SettingsToolbarComponent extends ConsumerStatefulWidget {
  const SettingsToolbarComponent({super.key});

  @override
  ConsumerState<SettingsToolbarComponent> createState() =>
      _SettingsToolbarComponentState();
}

class _SettingsToolbarComponentState
    extends ConsumerState<SettingsToolbarComponent> {
  @override
  Widget build(BuildContext context) {
    final bp = ref.watch(boardProvider);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 10),
      child: Column(
        // Changed from ListView to Column
        children: [
          Expanded(
            // Makes the ListView take available space, pushing _buildAppInfo down
            child: ListView(
              children: [
                // DropdownSelector<String>(
                //   label: "Home Club",
                //   items: ["Club 1", "Club 2", "Club 3"],
                //   initialValue: null,
                //   onChanged: (s) {},
                //   itemAsString: (String item) {
                //     return item;
                //   },
                // ),
                //
                // DropdownSelector<String>(
                //   label: "Home Team",
                //   items: ["Team 1", "Team 2", "Team 3"],
                //   initialValue: null,
                //   onChanged: (s) {},
                //   itemAsString: (String item) {
                //     return item;
                //   },
                // ),
                //
                // DropdownSelector<String>(
                //   label: "Away Club",
                //   items: ["Club 1", "Club 2", "Club 3"],
                //   initialValue: null,
                //   onChanged: (s) {},
                //   itemAsString: (String item) {
                //     return item;
                //   },
                // ),
                //
                // DropdownSelector<String>(
                //   label: "Away Team",
                //   items: ["Team 1", "Team 2", "Team 3"],
                //   initialValue: null,
                //   onChanged: (s) {},
                //   itemAsString: (String item) {
                //     return item;
                //   },
                // ),
                _buildFillColorWidget("Field Color", boardState: bp),

                // ImagePicker(label: "Background Image",  onChanged: (s){})
                // Note: _buildAppInfo() is moved out of this ListView

                const SizedBox(height: 20), // Add some spacing
                _buildBackgroundSelector(),
              ],
            ),
          ),
          _buildAppInfo(), // This widget will now be at the bottom
        ],
      ),
    );
  }

  Widget _buildFillColorWidget(String title, {required BoardState boardState}) {
    // Note: The 'spacing' property is not standard for Flutter's Column.
    // You might intend to use SizedBox widgets for spacing or have a custom Column widget.
    // If it's standard Flutter Column, you'd typically use:
    // children: [Widget1, SizedBox(height: 10), Widget2]
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      // spacing: 10, // This is not a standard Column property
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.labelLarge!.copyWith(color: ColorManager.grey),
        ),
        const SizedBox(height: 10), // Example of spacing
        ColorSlider(
          initialColor: boardState.boardColor,
          colors: [
            ColorManager.grey,
            Colors.red,
            Colors.blue,
            Colors.green,
            Colors.yellow,
            Colors.purple,
          ],
          onColorChanged: (c) {
            ref.read(boardProvider.notifier).updateBoardColor(c);
            ref.read(animationProvider.notifier).updateBoardColor(c);
          },
        ),
      ],
    );
  }

  Widget _buildAppInfo() {
    // Note: The 'spacing' property is not standard for Flutter's Column.
    return Padding(
      padding: const EdgeInsets.only(
          top: 10.0), // Add some padding if needed before app info
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 10, // This is not a standard Column property
        children: [
          Text(
            "Support",
            style: Theme.of(context)
                .textTheme
                .labelMedium!
                .copyWith(color: ColorManager.white.withValues(alpha: 0.5)),
          ),
          LinkText(
            text: AppInfo.supportLinkName,
            url: AppInfo.supportLink,
            style: Theme.of(context)
                .textTheme
                .labelMedium!
                .copyWith(color: ColorManager.white),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            // spacing: 2, // This is not a standard Column property
            children: [
              Text(
                "Version ${AppInfo.version}",
                style: Theme.of(context)
                    .textTheme
                    .labelMedium!
                    .copyWith(color: ColorManager.white),
              ),
              const SizedBox(height: 2), // Example of spacing
              Text(
                "Last updated ${AppInfo.lastUpdated}",
                style: Theme.of(context)
                    .textTheme
                    .labelMedium!
                    .copyWith(color: ColorManager.white),
              ),
            ],
          ),

          LayoutBuilder(builder: (context, constraints) {
            return QrImageView(
              data: AppInfo.zporter_url,
              size: constraints.maxWidth * .25,
              backgroundColor: ColorManager.white,
            );
          }),

          // Center(
          //   child: SvgPicture.asset(
          //     AssetsManager.splashLogo,
          //   ),
          // ),
        ],
      ),
    );
  }

  // Add this entire method inside the _SettingsToolbarComponentState class.

  // Replace the entire _buildBackgroundSelector method with this one
  // Replace the entire _buildBackgroundSelector method with this one
  Widget _buildBackgroundSelector() {
    final currentBackground =
        ref.watch(boardProvider.select((state) => state.boardBackground));

    // Create a list of all the background types to build the grid
    final backgroundOptions = BoardBackground.values;

    // Helper function to create each selectable option
    Widget buildOption(BoardBackground background) {
      final isSelected = currentBackground == background;

      return GestureDetector(
        onTap: () {
          // ref.read(boardProvider.notifier).updateBoardBackground(background);
          ref
              .read(animationProvider.notifier)
              .updateBoardBackground(background);
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: isSelected ? ColorManager.yellow : Colors.grey.shade700,
              width: isSelected ? 2.0 : 1.0,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Use the painter with a transparent background
                CustomPaint(
                  size: Size.infinite, // Painter will fill the available space
                  painter: FieldPreviewPainter(
                    backgroundType: background,
                    fieldColor: Colors.transparent, // As requested
                    lineColor: Colors.white, // As requested
                  ),
                ),
                // Show a checkmark if this item is selected
                if (isSelected)
                  Positioned(
                    top: 4,
                    left: 4,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Icon(Icons.check,
                          color: Colors.white, size: 16),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Field Options",
          style: Theme.of(context)
              .textTheme
              .labelLarge!
              .copyWith(color: ColorManager.grey),
        ),
        const SizedBox(height: 10),
        // Use GridView.builder to create the 2-column layout
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: backgroundOptions.length,
          // Inside the GridView.builder widget...
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            // Change this value to make items wider than they are tall
            childAspectRatio: 16 / 9, // e.g., an 80 width vs 60 height ratio
          ),
          itemBuilder: (context, index) {
            return buildOption(backgroundOptions[index]);
          },
        ),
      ],
    );
  }
}
