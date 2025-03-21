import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:zporter_tactical_board/data/tactic/model/form_model.dart';

import 'form_component_plugin.dart';

class FormTextPlugin implements FormComponentPlugin {
  @override
  void render(Canvas canvas, FormModel model, Vector2 size, Vector2 scale) {
    final text = (model.formItemModel as FormTextModel).text;
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(color: Colors.black, fontSize: 16 * scale.x),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout(maxWidth: size.x);

    final textPosition =
        size.toOffset() / 2 -
        Offset(textPainter.width / 2, textPainter.height / 2);
    textPainter.paint(canvas, textPosition);
  }

  @override
  void onScaleUpdate(
    FormModel model,
    Vector2 scale,
    Function(Vector2) updateSize,
  ) {
    updateSize(calculateSize(model, scale));
  }

  @override
  void showTextInputDialog(
    FormModel model,
    BuildContext context,
    Function(String) onTextUpdated,
  ) {
    TextEditingController controller = TextEditingController(
      text: (model.formItemModel as FormTextModel).text,
    );
    showDialog(
      context: context,
      builder:
          (context) => Theme(
            data: ThemeData.dark(), // Set dark theme for the dialog
            child: AlertDialog(
              backgroundColor: Colors.black87, // Black background
              title: const Text(
                'Enter Text',
                style: TextStyle(color: Colors.white), // White title text
              ),
              content: TextField(
                controller: controller,
                maxLines: null,
                style: const TextStyle(color: Colors.white), // White input text
                decoration: const InputDecoration(
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
                onSubmitted: (value) {
                  onTextUpdated(value);
                  Navigator.of(context).pop();
                },
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    var inputText = controller.text.trim();
                    if (inputText.isEmpty) {
                      inputText = "T";
                    }
                    onTextUpdated(inputText);
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'OK',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  @override
  Vector2 calculateSize(FormModel model, Vector2 scale) {
    final text = (model.formItemModel as FormTextModel).text;
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(color: Colors.black, fontSize: 16 * scale.x),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout(
      maxWidth: 1000 * scale.x,
    ); // or game.size.x / 4 * scale.x

    return Vector2(
      textPainter.width + 20 * scale.x,
      textPainter.height + 10 * scale.x,
    );
  }
}
