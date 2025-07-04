import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart'; // For Color, TextStyle, EdgeInsets
import 'package:zporter_tactical_board/app/helper/logger.dart';
// Assuming your project structure, adjust these paths if necessary
import 'package:zporter_tactical_board/app/helper/size_helper.dart';
import 'package:zporter_tactical_board/app/services/navigation_service.dart';
import 'package:zporter_tactical_board/data/tactic/model/text_model.dart'; // Your TextModel
import 'package:zporter_tactical_board/presentation/tactic/view/component/field/field_component.dart'; // Your base FieldComponent
import 'package:zporter_tactical_board/presentation/tactic/view/component/form/components/text/text_field_utils.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/board/board_provider.dart'; // Your BoardProvider

class TextFieldComponent extends FieldComponent<TextModel>
    with DoubleTapCallbacks {
  TextBoxComponent? _textBox;
  final TextPainter _measuringPainter =
      TextPainter(textDirection: TextDirection.ltr);

  TextFieldComponent({required super.object}) {
    anchor = Anchor.center;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // Load the background sprite for TextFieldComponent
    sprite = await game.loadSprite("text.png", srcSize: Vector2.zero());

    size = object.size ?? Vector2(100, 30);
    position = SizeHelper.getBoardActualVector(
      gameScreenSize: game.gameField.size,
      actualPosition: object.offset ?? Vector2.zero(),
    );
    angle = object.angle ?? 0.0;

    _createOrUpdateTextBox();
  }

  // Helper to find the best fitting font size
  double _calculateFittingFontSize({
    required String text,
    required TextStyle baseStyle, // Does not include font size
    required double targetWidth, // Max width the text can occupy
    required double targetHeight, // Max height the text can occupy
    required double initialFontSize,
    required double minFontSize,
  }) {
    if (text.isEmpty || targetWidth <= 0 || targetHeight <= 0) {
      return minFontSize;
    }

    double currentFontSize = initialFontSize;

    while (currentFontSize >= minFontSize) {
      _measuringPainter.text = TextSpan(
          text: text, style: baseStyle.copyWith(fontSize: currentFontSize));
      _measuringPainter.layout(minWidth: 0, maxWidth: targetWidth);

      if (_measuringPainter.height <= targetHeight) {
        return currentFontSize; // This font size fits
      }

      if (currentFontSize == minFontSize) {
        break; // Already at min, will return minFontSize
      }

      currentFontSize -= 0.5; // Smaller step for finer adjustment
      if (currentFontSize < minFontSize) {
        currentFontSize = minFontSize;
      }
    }
    // If loop finishes, it means even minFontSize might be too large.
    // In this case, TextBoxComponent will still clip based on its size,
    // but we've provided the smallest requested font.
    return minFontSize;
  }

  @override
  void update(double dt) {
    // TODO: implement update
    super.update(dt);

    try {
      final textRenderer = _textBox!.textRenderer;
      if (textRenderer is TextPaint) {
        Color textColor = textRenderer.style.color!;
        Color objectColor = object.color!.withValues(alpha: object.opacity);
        if (textColor != objectColor) {
          zlog(data: "Color difference detected updating the componenbt");
          _createOrUpdateTextBox();
        }
      }
    } catch (e) {}
  }

  void _createOrUpdateTextBox() async {
    final componentSize = object.size ?? Vector2(100, 30);
    if (componentSize.x <= 0 || componentSize.y <= 0) return; // Avoid issues

    final String textToRender = object.text.isEmpty ? " " : object.text;

    final textColor = object.color ?? Colors.white;
    final textOpacity = (object.opacity ?? 1.0).clamp(0.0, 1.0);
    final effectiveTextColor = textColor.withValues(alpha: textOpacity);

    // --- Define overall padding INSIDE TextFieldComponent for the TextBoxComponent ---
    // The TextBoxComponent itself will be made smaller by this padding.
    // Or, alternatively, use TextBoxComponent's internal 'margins'.
    // Let's opt to make TextBoxComponent smaller by this external padding, for clarity in measurement.
    const EdgeInsets visualPadding =
        EdgeInsets.all(5.0); // e.g., 5px on all sides of the text content area

    final double actualTextAllowedWidth =
        componentSize.x - visualPadding.horizontal;
    final double actualTextAllowedHeight =
        componentSize.y - visualPadding.vertical;

    // Base text style for measurement and final rendering (font size determined next)
    final baseTextStyle = TextStyle(
      color: effectiveTextColor,
      // Add other non-size-dependent properties: fontFamily, fontWeight (if fixed)
    );

    // Calculate the fitting font size using our helper
    // Initial font size guess (e.g., trying to fit 2 lines of text)
    double initialFontSizeGuess = actualTextAllowedHeight / 2.5;
    const double minAllowedFontSize = 6.0;
    if (initialFontSizeGuess < minAllowedFontSize) {
      initialFontSizeGuess = minAllowedFontSize;
    }

    double fittingFontSize = _calculateFittingFontSize(
      text: textToRender,
      baseStyle: baseTextStyle,
      targetWidth: actualTextAllowedWidth,
      targetHeight: actualTextAllowedHeight,
      initialFontSize: initialFontSizeGuess,
      minFontSize: minAllowedFontSize,
    );

    const EdgeInsets textBoxInternalMargins =
        EdgeInsets.all(5.0); // Internal padding FOR the TextBox.
    final double widthForFontSizeCalc =
        componentSize.x - textBoxInternalMargins.horizontal;
    final double heightForFontSizeCalc =
        componentSize.y - textBoxInternalMargins.vertical;

    initialFontSizeGuess =
        heightForFontSizeCalc / 2.5; // Try to fit 2.5 lines within margins
    if (initialFontSizeGuess < minAllowedFontSize) {
      initialFontSizeGuess = minAllowedFontSize;
    }

    fittingFontSize = _calculateFittingFontSize(
      text: textToRender,
      baseStyle: baseTextStyle,
      targetWidth: widthForFontSizeCalc,
      targetHeight: heightForFontSizeCalc,
      initialFontSize: initialFontSizeGuess,
      minFontSize: minAllowedFontSize,
    );
    final finalTextStyleForTextBox = baseTextStyle.copyWith(
        fontSize: fittingFontSize,
        color: baseTextStyle.color,
        overflow: TextOverflow.ellipsis);
    final textPaintForTextBox = TextPaint(style: finalTextStyleForTextBox);

    final textBoxConfig = TextBoxConfig(
      margins:
          textBoxInternalMargins, // Use TextBoxComponent's own margins for padding
    );
    TextBoxComponent textBox = TextBoxComponent(
      text: textToRender,
      textRenderer: textPaintForTextBox,
      boxConfig: textBoxConfig,
      align: Anchor.center,
      size: componentSize
          .clone(), // TextBox is same size as parent, margins make text area smaller
      position: Vector2.zero(),
      anchor: Anchor.topLeft,
      // debugMode: true, // Turn this on to see TextBoxComponent's boundaries & margins
    );

    await add(textBox);
    _textBox?.removeFromParent(); // Remove old one if exists
    _textBox = textBox;
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    ref
        .read(boardProvider.notifier)
        .toggleSelectItemEvent(fieldItemModel: object);
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
  }

  @override
  void onRotationUpdate() {
    super.onRotationUpdate();
    object.angle = angle;
  }

  @override
  void onComponentScale(Vector2 newSize) {
    super.onComponentScale(newSize); // Updates TextFieldComponent's own size
    object.size = newSize.clone();

    // When TextFieldComponent (parent) scales, recreate the TextBox child
    // so its font size is recalculated based on the new parent size.
    _createOrUpdateTextBox();
  }

  // Call this if object.text, .color, or other relevant model properties change externally
  void refreshTextVisuals() {
    _createOrUpdateTextBox();
  }

  @override
  void render(Canvas canvas) {
    // super.render will draw the TextFieldComponent's own sprite ("text.png")
    // and apply its transforms (position, rotation, scale).
    // Since your TextFieldComponent has anchor = Anchor.center, after super.render(),
    // the canvas origin (0,0) is at the CENTER of the TextFieldComponent.
    // Flame will also automatically render children (like _textBox) based on their
    // own position and anchor relative to this parent.
    super.render(canvas);

    // --- START: Code for drawing the border around the TextBoxComponent's area ---
    if (_textBox != null && object.size != null) {
      // Ensure _textBox and its size exist
      // 1. Determine the border color (same as object's color with opacity)
      final Color baseBorderColor =
          object.color ?? Colors.white; // Default if object.color is null
      final double borderOpacity = (object.opacity ?? 1.0).clamp(0.0, 1.0);
      final Color effectiveBorderColor =
          baseBorderColor.withOpacity(borderOpacity);

      // 2. Create the Paint for the border
      final double borderStrokeWidth =
          1.5; // Or make this a configurable property
      final Paint borderPaint = Paint()
        ..color = effectiveBorderColor
        ..style = PaintingStyle.stroke // This makes it an outline
        ..strokeWidth = borderStrokeWidth;

      // 3. Define the Rectangle for the border
      // Your _textBox has:
      // - size: object.size (same as componentSize)
      // - position: Vector2.zero() (relative to parent's anchor point)
      // - anchor: Anchor.topLeft (child's own anchor)
      //
      // Since the parent (TextFieldComponent) has anchor = Anchor.center,
      // its local (0,0) after super.render() is its center.
      // The _textBox (child) is placed with its top-left at this (0,0) point.
      // So, the Rect for the border, in this local coordinate system, is:
      final Rect borderRect = Rect.fromLTWH(
          0, // Left (relative to parent's center)
          0, // Top (relative to parent's center)
          object.size!.x, // Width (which is _textBox.size.x)
          object.size!.y // Height (which is _textBox.size.y)
          );

      // 4. Draw the rectangle
      canvas.drawRect(borderRect, borderPaint);
    }
    // --- END: Code for drawing the border ---
  }

  void moveTo(Vector2 newPosition) {
    position.setFrom(newPosition);
    object.offset = SizeHelper.getBoardRelativeVector(
      gameScreenSize: game.gameField.size,
      actualPosition: position,
    );
  }

  @override
  void onDoubleTapDown(DoubleTapDownEvent event) async {
    super.onDoubleTapDown(event);
    try {
      TextModel? edittedText = await TextFieldUtils.editTextDialog(
        game.context,
        object,
      );
      if (edittedText != null && edittedText.text != object.text) {
        zlog(data: "needs to update the text in firebase");
        object = edittedText;
        ref
            .read(boardProvider.notifier)
            .editTextComponent(textModel: edittedText);
      }
    } catch (e) {}

    event.handled = true; // Prevents the event from propagating further
  }
}
