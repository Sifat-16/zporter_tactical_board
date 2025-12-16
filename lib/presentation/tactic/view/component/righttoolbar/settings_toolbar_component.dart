import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:zporter_tactical_board/app/config/version/version_info.dart';
import 'package:zporter_tactical_board/app/core/component/color_picker_slider.dart';
import 'package:zporter_tactical_board/app/core/component/link_text.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';
import 'package:zporter_tactical_board/presentation/admin/view/tutorials/tutorial_selection_dialogue.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/animation/animation_provider.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/board/board_provider.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/board/board_state.dart';

import 'components/field_preview_painter.dart';

class SettingsToolbarComponent extends ConsumerStatefulWidget {
  const SettingsToolbarComponent({super.key});

  @override
  ConsumerState<SettingsToolbarComponent> createState() =>
      _SettingsToolbarComponentState();
}

class _SettingsToolbarComponentState
    extends ConsumerState<SettingsToolbarComponent> {
  // Helper function to show the tutorial dialog
  void _showTutorialSelectionDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const TutorialSelectionDialog();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bp = ref.watch(boardProvider);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 10),
      child: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                _buildFillColorWidget("Field Color", boardState: bp),
                const SizedBox(height: 20),
                _buildTeamBorderColorSection(bp),
                const SizedBox(height: 20),
                _buildGridSliderWidget(),
                const SizedBox(height: 20),
                _buildBackgroundSelector(),
                const SizedBox(height: 20),
                // --- NEW SECTION ADDED HERE ---
                // This is the only addition. The rest of your code is untouched.
                _buildTutorialsSection(),
                // --- END OF NEW SECTION ---
              ],
            ),
          ),
          _buildAppInfo(), // This widget is unchanged
        ],
      ),
    );
  }

  // --- NEW WIDGET FOR THE TUTORIALS BUTTON ---
  Widget _buildTutorialsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Help",
          style: Theme.of(context)
              .textTheme
              .labelLarge!
              .copyWith(color: ColorManager.grey),
        ),
        const SizedBox(height: 10),
        Material(
          color: ColorManager.darkGrey.withOpacity(0.3),
          borderRadius: BorderRadius.circular(8),
          child: ListTile(
            leading:
                const Icon(Icons.school_outlined, color: ColorManager.grey),
            title: Text(
              'View Tutorials',
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge!
                  .copyWith(color: ColorManager.white),
            ),
            trailing: const Icon(Icons.chevron_right, color: ColorManager.grey),
            onTap: () => _showTutorialSelectionDialog(context),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            dense: true,
          ),
        ),
      ],
    );
  }

  // --- YOUR ORIGINAL CODE BELOW IS UNCHANGED ---

  Widget _buildTeamBorderColorSection(BoardState boardState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Team Border Colors",
          style: Theme.of(context)
              .textTheme
              .labelLarge!
              .copyWith(color: ColorManager.grey),
        ),
        const SizedBox(height: 10),
        // Home Team Color
        Column(
          children: [
            Text(
              "Home Team",
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium!
                  .copyWith(color: ColorManager.white),
            ),
            SizedBox(height: 10),
            ColorSlider(
              initialColor: boardState.homeTeamBorderColor,
              colors: const [
                Colors.blue,
                Colors.lightBlue,
                Colors.cyan,
                Colors.green,
                Colors.yellow,
                Colors.orange,
                Colors.purple,
                Colors.pink,
                Colors.white,
              ],
              onColorChanged: (c) {
                ref.read(boardProvider.notifier).updateHomeTeamBorderColor(c);
                ref
                    .read(animationProvider.notifier)
                    .updateHomeTeamBorderColor(c);
              },
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Away Team Color
        Column(
          children: [
            Text(
              "Away Team",
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium!
                  .copyWith(color: ColorManager.white),
            ),
            SizedBox(height: 10),
            ColorSlider(
              initialColor: boardState.awayTeamBorderColor,
              colors: const [
                Colors.red,
                Colors.deepOrange,
                Colors.orange,
                Colors.yellow,
                Colors.green,
                Colors.blue,
                Colors.purple,
                Colors.grey,
                Colors.white,
              ],
              onColorChanged: (c) {
                ref.read(boardProvider.notifier).updateAwayTeamBorderColor(c);
                ref
                    .read(animationProvider.notifier)
                    .updateAwayTeamBorderColor(c);
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          "Note: Individual player colors will override these defaults",
          style: Theme.of(context).textTheme.bodySmall!.copyWith(
                color: ColorManager.grey.withOpacity(0.7),
                fontStyle: FontStyle.italic,
              ),
        ),
      ],
    );
  }

  Widget _buildFillColorWidget(String title, {required BoardState boardState}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context)
              .textTheme
              .labelLarge!
              .copyWith(color: ColorManager.grey),
        ),
        const SizedBox(height: 10),
        ColorSlider(
          initialColor: boardState.boardColor,
          colors: const [
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
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Support",
            style: Theme.of(context)
                .textTheme
                .labelMedium!
                .copyWith(color: ColorManager.white.withOpacity(0.5)),
          ),
          LinkText(
            text: AppInfo.supportLinkName,
            url: AppInfo.supportLink,
            style: Theme.of(context)
                .textTheme
                .labelMedium!
                .copyWith(color: ColorManager.white),
          ),
          const SizedBox(height: 10),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Version ${AppInfo.version}",
                style: Theme.of(context)
                    .textTheme
                    .labelMedium!
                    .copyWith(color: ColorManager.white),
              ),
              const SizedBox(height: 2),
              Text(
                "Last updated ${AppInfo.lastUpdated}",
                style: Theme.of(context)
                    .textTheme
                    .labelMedium!
                    .copyWith(color: ColorManager.white),
              ),
            ],
          ),
          const SizedBox(height: 10),
          LayoutBuilder(builder: (context, constraints) {
            return QrImageView(
              data: AppInfo.zporter_url,
              size: constraints.maxWidth * .25,
              backgroundColor: ColorManager.white,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildBackgroundSelector() {
    final currentBackground =
        ref.watch(boardProvider.select((state) => state.boardBackground));
    final backgroundOptions = BoardBackground.values;

    Widget buildOption(BoardBackground background) {
      final isSelected = currentBackground == background;
      return GestureDetector(
        onTap: () {
          ref.read(boardProvider.notifier).updateBoardBackground(background);
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
                CustomPaint(
                  size: Size.infinite,
                  painter: FieldPreviewPainter(
                    backgroundType: background,
                    fieldColor: Colors.transparent,
                    lineColor: Colors.white,
                  ),
                ),
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
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: backgroundOptions.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 16 / 9,
          ),
          itemBuilder: (context, index) {
            return buildOption(backgroundOptions[index]);
          },
        ),
      ],
    );
  }

  // In class _SettingsToolbarComponentState

  Widget _buildGridSliderWidget() {
    // Watch the provider to get the current grid size
    final double currentGridSize =
        ref.watch(boardProvider.select((s) => s.gridSize));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Grid Size (${currentGridSize.toInt()})",
          style: Theme.of(context)
              .textTheme
              .labelLarge!
              .copyWith(color: ColorManager.grey),
        ),
        const SizedBox(height: 10),

        // --- UPDATED ---
        // We wrap the Slider in a SliderTheme, just like your ColorSlider,
        // to ensure it styles correctly and takes the full width.
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 4, // From ColorSlider
            thumbShape: const RoundSliderThumbShape(
                enabledThumbRadius: 10), // Comfortable thumb size
            overlayShape: const RoundSliderOverlayShape(
                overlayRadius: 24), // Larger touch area for better usability
            // We DON'T make the track transparent, so it's visible
          ),
          child: Slider(
            value: currentGridSize,
            min: 10.0,
            max: 100.0,
            divisions: 9,
            activeColor: ColorManager.yellow,
            inactiveColor: ColorManager.grey,
            thumbColor: ColorManager.yellow, // Match active color
            label: currentGridSize.toInt().toString(),
            onChanged: (double value) {
              ref.read(boardProvider.notifier).updateGridSize(value);
            },
          ),
        ),
        // --- END UPDATE ---
      ],
    );
  }

// ... (rest of your methods)
}
