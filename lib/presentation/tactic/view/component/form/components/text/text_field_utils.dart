import 'package:flame/extensions.dart';
import 'package:flutter/material.dart';
import 'package:zporter_tactical_board/app/extensions/size_extension.dart';
import 'package:zporter_tactical_board/app/generator/random_generator.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';
import 'package:zporter_tactical_board/data/tactic/model/field_item_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/text_model.dart';

class TextFieldUtils {
  static final List<TextModel> _texts = [
    TextModel(
      id: RandomGenerator.generateId(),
      fieldItemType: FieldItemType.TEXT,
      color: ColorManager.white,
      name: "TEXT",
      imagePath: "text.png",
      text: '',
    ),
  ];
  static List<TextModel> generateTexts() {
    return _texts;
  }

  static Future<TextModel?> insertTextDialog(BuildContext context) async {
    final TextEditingController textController = TextEditingController();
    String? enteredText;

    return await showDialog<TextModel?>(
      context: context,
      barrierDismissible: false, // User must tap button!
      builder: (BuildContext dialogContext) {
        return Theme(
          data: ThemeData.dark().copyWith(
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.white, // Text color for TextButtons
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              hintStyle: TextStyle(color: Colors.grey[400]),
            ),
          ),
          child: AlertDialog(
            backgroundColor: ColorManager.black,
            title: const Text('Add Text to Field'),
            content: TextField(
              controller: textController,
              maxLines: null,
              keyboardType:
                  TextInputType.multiline, // Good for multi-line input
              autofocus: true,
              decoration: const InputDecoration(hintText: "Enter text here"),
              onChanged: (value) {
                enteredText = value;
              },
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.of(
                    dialogContext,
                  ).pop(null); // Return null on cancel
                },
              ),
              TextButton(
                child: const Text('Add'),
                onPressed: () {
                  var text = enteredText?.trim();
                  if (text != null && text.isNotEmpty) {
                    // text = formatTextToMaxLineLength(text);
                    Size size = calculateTextSize(
                        text: text,
                        style: TextStyle(fontSize: 32),
                        maxWidth: context.widthPercent(20));
                    final newTextModel = TextModel(
                      id: RandomGenerator.generateId(),
                      text: text,
                      size: size.toVector2(),
                      color: ColorManager.white,
                      name: "TEXT",
                      imagePath: "text.png",
                    );
                    Navigator.of(dialogContext).pop(newTextModel);
                  } else {
                    Navigator.of(dialogContext).pop(null);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  static String formatTextToMaxLineLength(String text, {int maxLength = 20}) {
    if (text.isEmpty || maxLength <= 0) {
      return text; // Return original text if it's empty or maxLength is invalid
    }
    StringBuffer result = StringBuffer();
    int currentLineCharCount = 0;

    for (int i = 0; i < text.length; i++) {
      final char = text[i];

      if (char == '\n') {
        result.write(char); // Append the existing newline
        currentLineCharCount = 0; // Reset counter for the new line
      } else {
        // Check if the current line char count has reached the maxLength
        if (currentLineCharCount == maxLength) {
          result.write('\n'); // Add a newline because maxLength is reached
          result.write(char); // Add the current character to the new line
          currentLineCharCount =
              1; // Reset counter, this char is the first on the new line
        } else {
          result.write(char); // Append the character
          currentLineCharCount++; // Increment counter
        }
      }
    }
    return result.toString();
  }

  static Size calculateTextSize({
    required String text,
    required TextStyle style,
    double minWidth = 0,
    double maxWidth = double.infinity,
    int? maxLines,
    TextDirection textDirection = TextDirection.ltr, // Default LTR
  }) {
    // Create a TextSpan with the text and style
    final TextSpan textSpan = TextSpan(text: text, style: style);

    // Create a TextPainter
    final TextPainter textPainter = TextPainter(
      text: textSpan,
      textDirection: textDirection,
      maxLines: maxLines,
    );

    // Layout the text with the given constraints
    textPainter.layout(
      minWidth: minWidth,
      maxWidth: maxWidth,
    );

    // Return the calculated size
    return textPainter.size;
  }
}
