import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:zporter_tactical_board/app/helper/size_helper.dart';
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
    position = SizeHelper.getBoardActualVector(
      gameScreenSize: game.gameField.size,
      actualPosition: object.offset ?? Vector2(x, y),
    );
    angle = object.angle ?? 0;
    FormItemModel? formItemModel = object.formItemModel;
    if (formItemModel is FormTextModel) {
      plugin = FormTextPlugin();
      size = plugin!.calculateSize(object, scale);
    }
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    object.offset = SizeHelper.getBoardRelativeVector(
      gameScreenSize: game.gameField.size,
      actualPosition: position,
    );
  }

  @override
  void onScaleUpdate(DragUpdateEvent event) {
    super.onScaleUpdate(event);
    object.offset = SizeHelper.getBoardRelativeVector(
      gameScreenSize: game.gameField.size,
      actualPosition: position,
    );
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
