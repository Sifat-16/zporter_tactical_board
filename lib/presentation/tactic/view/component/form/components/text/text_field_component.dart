import 'dart:async';

import 'package:flame/components.dart'; // Flame components
import 'package:flame/events.dart';
import 'package:flutter/material.dart'; // For TextStyle, Color, Canvas
// Assuming these are your project's helper/manager paths
import 'package:zporter_tactical_board/app/helper/size_helper.dart';
import 'package:zporter_tactical_board/app/manager/values_manager.dart'; // For AppSize defaults
// Import your simplified TextModel and the base FieldComponent
import 'package:zporter_tactical_board/data/tactic/model/text_model.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/field/field_component.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/board/board_provider.dart'; // If used for selection

class TextFieldComponent extends FieldComponent<TextModel> {
  late final TextComponent _flameTextComponent;
  TextStyle _currentTextStyle = const TextStyle();

  TextFieldComponent({required super.object}) {
    anchor = Anchor.center;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    sprite = await game.loadSprite("text.png", srcSize: Vector2.zero());

    size.setFrom(object.size ?? Vector2(AppSize.s128, AppSize.s32));

    position = SizeHelper.getBoardActualVector(
      gameScreenSize: game.gameField.size,
      actualPosition: object.offset ?? Vector2.zero(),
    );
    angle = object.angle ?? 0;

    _updateTextStyle();

    _flameTextComponent = TextComponent(
      text: object.text,
      textRenderer: TextPaint(style: _currentTextStyle),
      anchor: Anchor.center,
    );

    // ---- MODIFICATION FOR CENTERING ----
    // If TextFieldComponent.anchor = Anchor.center, its local (0,0) is its center.
    // If the background sprite ('text.png') is drawn by the superclass such that
    // its top-left corner is at this TextFieldComponent's center,
    // then the visual center of that sprite is at (size.x / 2, size.y / 2)
    // in TextFieldComponent's local coordinates.
    // We position the _flameTextComponent (which is also Anchor.center) there.
    _flameTextComponent.position = Vector2(size.x / 2, size.y / 2);
    // ---- END MODIFICATION ----

    add(_flameTextComponent);
  }

  void _updateTextStyle() {
    final baseColor = object.color ?? Colors.black;
    final effectiveOpacity = (object.opacity ?? 1.0).clamp(0.0, 1.0);
    final effectiveColor = baseColor.withOpacity(effectiveOpacity);

    final double derivedFontSize =
        (this.size.y > 0 ? this.size.y : AppSize.s32) * 0.7;

    _currentTextStyle = TextStyle(
      color: effectiveColor,
      fontSize: derivedFontSize,
      fontWeight: FontWeight.normal,
    );
  }

  void _refreshInternalTextVisuals() {
    _updateTextStyle();
    _flameTextComponent.text = object.text;
    _flameTextComponent.textRenderer = TextPaint(style: _currentTextStyle);
    // If size changed, the position might need re-adjustment if it depends on size
    _flameTextComponent.position = Vector2(size.x / 2, size.y / 2);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    // Debug drawing can be re-enabled here if needed
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    if (ref != null) {
      ref
          .read(boardProvider.notifier)
          .toggleSelectItemEvent(fieldItemModel: object);
    }
    event.handled = true;
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
  void onComponentScale(Vector2 newSize) {
    super.onComponentScale(newSize);
    object.size = newSize.clone();
    // Size has changed, so the position of _flameTextComponent needs to be updated
    // as it's relative to the new size. _refreshInternalTextVisuals will handle this.
    _refreshInternalTextVisuals();
  }

  @override
  void onRotationUpdate() {
    super.onRotationUpdate();
    object.angle = angle;
  }

  @override
  void update(double dt) {
    super.update(dt);

    bool needsVisualRefresh = false; // For text content or style
    bool positionOrSizeChanged = false; // For position of the child text

    final expectedPosition = SizeHelper.getBoardActualVector(
      gameScreenSize: game.gameField.size,
      actualPosition: object.offset ?? Vector2.zero(),
    );
    if (position != expectedPosition) {
      position.setFrom(expectedPosition);
    }

    if (object.size != null && size != object.size) {
      this.size.setFrom(object.size!);
      needsVisualRefresh = true;
      positionOrSizeChanged = true;
    }

    if (object.angle != null && angle != object.angle) {
      this.angle = object.angle!;
    }

    if (_flameTextComponent.text != object.text) {
      needsVisualRefresh = true;
    }
    final baseColor = object.color ?? Colors.black;
    final effectiveOpacity = (object.opacity ?? 1.0).clamp(0.0, 1.0);
    final effectiveColor = baseColor.withOpacity(effectiveOpacity);
    if (_currentTextStyle.color != effectiveColor) {
      needsVisualRefresh = true;
    }

    if (needsVisualRefresh) {
      _refreshInternalTextVisuals(); // This also updates position due to size change
    } else if (positionOrSizeChanged) {
      // If only size changed affecting position, but not text style/content
      _flameTextComponent.position = Vector2(size.x / 2, size.y / 2);
    }
  }
}
