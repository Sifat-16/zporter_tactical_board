import 'package:flutter/material.dart';
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
                  final text = enteredText?.trim();
                  if (text != null && text.isNotEmpty) {
                    final newTextModel = TextModel(
                      id: RandomGenerator.generateId(),
                      text: text,
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
}
