import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:zporter_tactical_board/data/tactic/model/form_model.dart';

abstract class FormComponentPlugin {
  void render(Canvas canvas, FormModel model, Vector2 size, Vector2 scale);
  void onScaleUpdate(
    FormModel model,
    Vector2 scale,
    Function(Vector2) updateSize,
  );
  void showTextInputDialog(
    FormModel model,
    BuildContext context,
    Function(String) onTextUpdated,
  );
  Vector2 calculateSize(FormModel model, Vector2 scale);
}
