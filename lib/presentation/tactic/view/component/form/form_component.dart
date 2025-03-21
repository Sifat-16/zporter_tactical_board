import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:zporter_tactical_board/app/manager/values_manager.dart';
import 'package:zporter_tactical_board/data/tactic/model/form_model.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/field/field_component.dart';

import 'form_plugins/form_component_plugin.dart';
import 'form_plugins/form_text_plugin.dart';

class FormComponent extends FieldComponent<FormModel> {
  FormComponent({required super.object});

  FormComponentPlugin? plugin;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    sprite = await game.loadSprite("ball.png", srcSize: Vector2.zero());
    size = Vector2(AppSize.s32, AppSize.s32);
    position = object.offset ?? Vector2(x, y);
    angle = object.angle ?? 0;

    if (object.formItemModel is FormTextModel) {
      plugin = FormTextPlugin();
      size = plugin!.calculateSize(object, scale);
    }
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    object.offset = position;
  }

  @override
  void onScaleUpdate(DragUpdateEvent event) {
    super.onScaleUpdate(event);
    object.offset = position;
    plugin?.onScaleUpdate(object, scale, (newSize) {
      size = newSize;
    });
  }

  @override
  void onRotationUpdate() {
    super.onRotationUpdate();
    object.angle = angle;
  }

  @override
  void onLongTapDown(TapDownEvent event) {
    super.onLongTapDown(event);
    isSelected = false;
    if (object.formItemModel is FormTextModel) {
      plugin?.showTextInputDialog(object, game.buildContext!, _updateText);
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    plugin?.render(canvas, object, size, scale);
  }

  void _updateText(String text) {
    if (object.formItemModel is FormTextModel) {
      object.formItemModel = FormTextModel(text: text);
      size = plugin!.calculateSize(object, scale);
    }
  }
}

// class FormComponent extends FieldComponent<FormModel> {
//   FormComponent({required super.object});
//
//   @override
//   Future<void> onLoad() async {
//     await super.onLoad();
//     sprite = await game.loadSprite("ball.png", srcSize: Vector2.zero());
//     size = Vector2(AppSize.s32, AppSize.s32);
//     position = object.offset ?? Vector2(x, y);
//     angle = object.angle ?? 0;
//     _showTextInputDialog();
//   }
//
//   @override
//   void onDragUpdate(DragUpdateEvent event) {
//     super.onDragUpdate(event);
//     object.offset = position;
//   }
//
//   @override
//   void onScaleUpdate(DragUpdateEvent event) {
//     super.onScaleUpdate(event);
//     object.offset = position;
//   }
//
//   @override
//   void onRotationUpdate() {
//     super.onRotationUpdate();
//     object.angle = angle;
//   }
//
//   @override
//   void onLongTapDown(TapDownEvent event) {
//     // TODO: implement onLongTapDown
//     super.onLongTapDown(event);
//
//     if (object.formItemModel is FormTextModel) {
//       _showTextInputDialog();
//     }
//   }
//
//   @override
//   void render(Canvas canvas) {
//     super.render(canvas);
//     if (object.formItemModel is FormTextModel) {
//       final text = (object.formItemModel as FormTextModel).text;
//       final textPainter = TextPainter(
//         text: TextSpan(text: text, style: const TextStyle(color: Colors.black)),
//         textDirection: TextDirection.ltr,
//       );
//       // Get game field width or a container width
//       final maxWidth = game.size.x / 4; // Example: Subtract padding
//
//       textPainter.layout(maxWidth: maxWidth);
//
//       final textPosition =
//           size.toOffset() / 2 -
//           Offset(textPainter.width / 2, textPainter.height / 2);
//       textPainter.paint(canvas, textPosition);
//     }
//   }
//
//   void _showTextInputDialog() {
//     TextEditingController controller = TextEditingController(
//       text: (object.formItemModel as FormTextModel).text,
//     );
//     showDialog(
//       context: game.buildContext!,
//       builder:
//           (context) => AlertDialog(
//             title: const Text('Enter Text'),
//             content: TextField(
//               controller: controller,
//               maxLines: null,
//               onSubmitted: (value) {
//                 _updateText(value);
//                 Navigator.of(context).pop();
//               },
//             ),
//             actions: <Widget>[
//               TextButton(
//                 onPressed: () {
//                   Navigator.of(context).pop();
//                 },
//                 child: const Text('Cancel'),
//               ),
//               TextButton(
//                 onPressed: () {
//                   var inputText = controller.text.trim();
//                   if (inputText.isEmpty) {
//                     inputText = "T";
//                   }
//                   _updateText(inputText);
//                   Navigator.of(context).pop();
//                 },
//                 child: const Text('OK'),
//               ),
//             ],
//           ),
//     );
//   }
//
//   void _updateText(String text) {
//     if (object.formItemModel is FormTextModel) {
//       object.formItemModel = FormTextModel(text: text);
//       _calculateTextSize();
//     }
//   }
//
//   void _calculateTextSize() {
//     if (object.formItemModel is FormTextModel) {
//       final text = (object.formItemModel as FormTextModel).text;
//       final textPainter = TextPainter(
//         text: TextSpan(
//           text: text,
//           style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
//         ),
//         textDirection: TextDirection.ltr,
//       );
//
//       textPainter.layout(maxWidth: game.size.x / 4);
//
//       size = Vector2(textPainter.width + 20, textPainter.height + 10);
//     }
//   }
// }
