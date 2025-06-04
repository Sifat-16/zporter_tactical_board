import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zporter_tactical_board/app/helper/logger.dart';
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
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((t) {
      setupForms();
    });
  }

  void setupForms() {
    setState(() {
      lines = LineUtils.generateLines();
      shapes = ShapeUtils.generateShapes();
      texts = TextFieldUtils.generateTexts();
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final totalItems = lines.length + shapes.length + texts.length;
    final lineNotifier = ref.read(lineProvider.notifier);

    return GridView.builder(
      itemCount: totalItems,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 10.0,
        childAspectRatio: 1.0,
      ),
      itemBuilder: (BuildContext gridContext, int index) {
        if (index < texts.length) {
          final textModel = texts[index];
          return FormTextItem(
            textModel: textModel,
            onTap: () async {
              TextModel? textModel = await TextFieldUtils.insertTextDialog(
                context,
              );
              if (textModel != null) {
                TacticBoardGame? tacticBoardGame =
                    ref.read(boardProvider).tacticBoardGame;
                if (tacticBoardGame is TacticBoard) {
                  tacticBoardGame.addNewTextOnTheField(object: textModel);
                }
              }
              zlog(data: "The text model generated ${textModel?.toJson()}");
            },
          );
        } else if (index < (lines.length + texts.length)) {
          final lineIndex = index - texts.length;
          final lineModel = lines[lineIndex];
          return FormLineItem(
            lineModelV2: lineModel,
            onTap: () {},
          );
        } else {
          final shapeIndex = index - lines.length - texts.length;
          if (shapeIndex < shapes.length) {
            final shapeModel = shapes[shapeIndex];
            return FormShapeItem(
              shapeModel: shapeModel,
              onTap: () {},
            );
          } else {
            return Container(color: Colors.red); // Error indicator
          }
        }
      },
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
