import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zporter_tactical_board/data/tactic/model/line_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/shape_model.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/form/components/line/form_line_item.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/form/components/shapes/form_shape_item.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/form/line_utils.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/form/shape_utils.dart';
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
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final totalItems = lines.length + shapes.length;

    return GridView.builder(
      itemCount: totalItems,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 10.0,
        childAspectRatio: 1.0,
      ),
      itemBuilder: (BuildContext gridContext, int index) {
        if (index < lines.length) {
          final lineModel = lines[index];
          return FormLineItem(
            lineModelV2: lineModel,
            onTap: () {
              ref
                  .read(lineProvider.notifier)
                  .loadActiveLineModelToAddIntoGameFieldEvent(
                    lineModelV2: lineModel,
                  );
            },
          );
        } else {
          final shapeIndex = index - lines.length;
          if (shapeIndex < shapes.length) {
            final shapeModel = shapes[shapeIndex];
            return FormShapeItem(
              shapeModel: shapeModel,
              onTap: () {
                ref
                    .read(lineProvider.notifier)
                    .loadActiveShapeModelToAddIntoGameFieldEvent(
                      shapeModel: shapeModel,
                    );
              },
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
