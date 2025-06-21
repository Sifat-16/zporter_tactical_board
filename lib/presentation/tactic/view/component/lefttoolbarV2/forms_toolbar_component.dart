// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:zporter_tactical_board/app/helper/logger.dart';
// import 'package:zporter_tactical_board/data/tactic/model/line_model.dart';
// import 'package:zporter_tactical_board/data/tactic/model/shape_model.dart';
// import 'package:zporter_tactical_board/data/tactic/model/text_model.dart';
// import 'package:zporter_tactical_board/presentation/tactic/view/component/board/tactic_board_game.dart';
// import 'package:zporter_tactical_board/presentation/tactic/view/component/form/components/line/form_line_item.dart';
// import 'package:zporter_tactical_board/presentation/tactic/view/component/form/components/shapes/form_shape_item.dart';
// import 'package:zporter_tactical_board/presentation/tactic/view/component/form/components/text/form_text_item.dart';
// import 'package:zporter_tactical_board/presentation/tactic/view/component/form/components/text/text_field_utils.dart';
// import 'package:zporter_tactical_board/presentation/tactic/view/component/form/line_utils.dart';
// import 'package:zporter_tactical_board/presentation/tactic/view/component/form/shape_utils.dart';
// import 'package:zporter_tactical_board/presentation/tactic/view_model/board/board_provider.dart';
// import 'package:zporter_tactical_board/presentation/tactic/view_model/form/line/line_provider.dart';
//
// class FormsToolbarComponent extends ConsumerStatefulWidget {
//   const FormsToolbarComponent({super.key});
//
//   @override
//   ConsumerState<FormsToolbarComponent> createState() =>
//       _FormsToolbarComponentState();
// }
//
// class _FormsToolbarComponentState extends ConsumerState<FormsToolbarComponent>
//     with AutomaticKeepAliveClientMixin {
//   List<LineModelV2> lines = [];
//   List<ShapeModel> shapes = [];
//   List<TextModel> texts = [];
//
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((t) {
//       setupForms();
//     });
//   }
//
//   void setupForms() {
//     setState(() {
//       lines = LineUtils.generateLines();
//       shapes = ShapeUtils.generateShapes();
//       texts = TextFieldUtils.generateTexts();
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     super.build(context);
//
//     final totalItems = lines.length + shapes.length + texts.length;
//     final lineNotifier = ref.read(lineProvider.notifier);
//
//     return GridView.builder(
//       itemCount: totalItems,
//       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 3,
//         crossAxisSpacing: 10.0,
//         mainAxisSpacing: 10.0,
//         childAspectRatio: 1.0,
//       ),
//       itemBuilder: (BuildContext gridContext, int index) {
//         if (index < texts.length) {
//           final textModel = texts[index];
//           return FormTextItem(
//             textModel: textModel,
//             onTap: () async {
//               TextModel? textModel = await TextFieldUtils.insertTextDialog(
//                 context,
//               );
//               if (textModel != null) {
//                 TacticBoardGame? tacticBoardGame =
//                     ref.read(boardProvider).tacticBoardGame;
//                 if (tacticBoardGame is TacticBoard) {
//                   tacticBoardGame.addNewTextOnTheField(object: textModel);
//                 }
//               }
//               zlog(data: "The text model generated ${textModel?.toJson()}");
//             },
//           );
//         } else if (index < (lines.length + texts.length)) {
//           final lineIndex = index - texts.length;
//           final lineModel = lines[lineIndex];
//           return FormLineItem(
//             lineModelV2: lineModel,
//             onTap: () {},
//           );
//         } else {
//           final shapeIndex = index - lines.length - texts.length;
//           if (shapeIndex < shapes.length) {
//             final shapeModel = shapes[shapeIndex];
//             return FormShapeItem(
//               shapeModel: shapeModel,
//               onTap: () {},
//             );
//           } else {
//             return Container(color: Colors.red); // Error indicator
//           }
//         }
//       },
//     );
//   }
//
//   @override
//   // TODO: implement wantKeepAlive
//   bool get wantKeepAlive => true;
// }

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zporter_tactical_board/app/helper/logger.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';
import 'package:zporter_tactical_board/data/tactic/model/line_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/shape_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/text_model.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/board/tactic_board_game.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/form/components/line/form_line_item.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/form/components/shapes/form_shape_item.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/form/components/text/form_text_item.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/form/components/text/text_field_utils.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/form/line_utils.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/form/shape_utils.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/board/board_provider.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/form/line/line_provider.dart';

class FormsToolbarComponent extends ConsumerStatefulWidget {
  const FormsToolbarComponent({super.key});

  @override
  ConsumerState<FormsToolbarComponent> createState() =>
      _FormsToolbarComponentState();
}

class _FormsToolbarComponentState extends ConsumerState<FormsToolbarComponent>
    with AutomaticKeepAliveClientMixin {
  List<LineModelV2> lines = [];
  List<ShapeModel> shapes = [];
  List<TextModel> texts = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((t) {
      setupForms();
    });
  }

  void setupForms() {
    setState(() {
      lines = LineUtils.generateLines()
          .where((line) =>
              line.name.contains(' ') ||
              ['Walk', 'Jog', 'Sprint', 'Jump', 'Pass', 'Dribble', 'Shoot']
                  .contains(line.name))
          .toList();
      shapes = ShapeUtils.generateShapes();
      texts = TextFieldUtils.generateTexts();
    });
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0, bottom: 8.0, left: 16.0),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.white.withOpacity(0.8),
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  // CORRECTED: This helper now always shows the label for every group.
  Widget _buildMovementGroup(String label, List<LineModelV2> models) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // The 'if' condition that caused the bug has been removed.
          // This Text widget will now always be built.
          Text(label,
              style: const TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 8),
          GridView.builder(
            itemCount: models.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 3.0,
            ),
            itemBuilder: (context, index) {
              final line = models[index];
              return FormLineItem(lineModelV2: line, onTap: () {});
            },
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final playerMovementGroups = {
      'Walk': lines.where((l) => l.name.contains('Walk')).toList(),
      'Jog': lines.where((l) => l.name.contains('Jog')).toList(),
      'Sprint': lines.where((l) => l.name.contains('Sprint')).toList(),
      'Jump': lines.where((l) => l.name == 'Jump').toList(),
    };
    final ballMovementGroups = {
      'Pass': lines.where((l) => l.name == 'Pass').toList(),
      'Pass high/cross':
          lines.where((l) => l.name == 'Pass high/cross').toList(),
      'Dribble': lines.where((l) => l.name == 'Dribble').toList(),
      'Shoot': lines.where((l) => l.name == 'Shoot').toList(),
    };

    final otherItems = <Widget>[
      ...shapes.map((shape) => FormShapeItem(shapeModel: shape, onTap: () {})),
      ...texts.map((text) {
        return FormTextItem(
          textModel: text,
          onTap: () async {
            TextModel? textModel =
                await TextFieldUtils.insertTextDialog(context);
            if (textModel != null) {
              final TacticBoardGame? tacticBoardGame =
                  ref.read(boardProvider).tacticBoardGame;
              if (tacticBoardGame is TacticBoard) {
                tacticBoardGame.addNewTextOnTheField(object: textModel);
              }
            }
          },
        );
      }),
    ];

    return Container(
      decoration:
          BoxDecoration(color: ColorManager.black.withValues(alpha: 0.7)),
      child: ListView(
        children: [
          _buildSectionHeader('Player movements'),
          ...playerMovementGroups.entries
              .where((entry) => entry.value.isNotEmpty)
              .map((entry) => _buildMovementGroup(entry.key, entry.value)),
          _buildSectionHeader('Ball movements'),
          ...ballMovementGroups.entries
              .where((entry) => entry.value.isNotEmpty)
              .map((entry) => _buildMovementGroup(entry.key, entry.value)),
          _buildSectionHeader('Other'),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: GridView.builder(
              itemCount: otherItems.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.2,
              ),
              itemBuilder: (context, index) {
                return otherItems[index];
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
