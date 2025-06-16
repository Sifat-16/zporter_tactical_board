// create_new_lineup_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For FilteringTextInputFormatter
import 'package:uuid/uuid.dart'; // For generating unique IDs - add dependency: flutter pub add uuid
import 'package:zporter_tactical_board/app/manager/color_manager.dart';
import 'package:zporter_tactical_board/data/admin/model/default_lineup_model.dart';
import 'package:zporter_tactical_board/data/animation/model/animation_item_model.dart';

class CreateNewLineupDialog extends StatefulWidget {
  final List<FormationCategory> existingCategories;
  final Function(FormationCategory category, FormationTemplate template)
  onLineupCreated;

  const CreateNewLineupDialog({
    super.key,
    required this.existingCategories,
    required this.onLineupCreated,
  });

  @override
  State<CreateNewLineupDialog> createState() => _CreateNewLineupDialogState();
}

class _CreateNewLineupDialogState extends State<CreateNewLineupDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _categoryDisplayNameController =
      TextEditingController();
  final TextEditingController _numberOfPlayersController =
      TextEditingController();
  final TextEditingController _templateNameController = TextEditingController();

  String? _selectedExistingCategoryId;
  bool _useExistingCategory = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingCategories.isNotEmpty) {
      _useExistingCategory = true; // Default to using existing if available
      _selectedExistingCategoryId = widget.existingCategories.first.categoryId;
      // Pre-fill number of players if an existing category is selected
      _updateFieldsFromSelectedCategory(widget.existingCategories.first);
    }
  }

  void _updateFieldsFromSelectedCategory(FormationCategory category) {
    _numberOfPlayersController.text = category.numberOfPlayers.toString();
    _categoryDisplayNameController.text = category.displayName;
  }

  @override
  void dispose() {
    _categoryDisplayNameController.dispose();
    _numberOfPlayersController.dispose();
    _templateNameController.dispose();
    super.dispose();
  }

  void _handleCreate() {
    if (_formKey.currentState!.validate()) {
      late FormationCategory categoryToUse;
      final String templateName = _templateNameController.text.trim();
      const uuid = Uuid();

      if (_useExistingCategory && _selectedExistingCategoryId != null) {
        categoryToUse = widget.existingCategories.firstWhere(
          (cat) => cat.categoryId == _selectedExistingCategoryId,
        );
      } else {
        // Create new category
        final int numberOfPlayers = int.parse(
          _numberOfPlayersController.text.trim(),
        );
        final String categoryDisplayName =
            _categoryDisplayNameController.text.trim();

        // Check if a category with the same number of players and display name already exists
        // This is a simple check; you might want more sophisticated logic for "uniqueness"
        var existingNewCategoryCheck =
            widget.existingCategories
                .where(
                  (cat) =>
                      cat.numberOfPlayers == numberOfPlayers &&
                      cat.displayName == categoryDisplayName,
                )
                .toList();

        if (existingNewCategoryCheck.isNotEmpty) {
          categoryToUse = existingNewCategoryCheck.first;
        } else {
          categoryToUse = FormationCategory(
            categoryId:
                '${numberOfPlayers}v${numberOfPlayers}_${uuid.v4().substring(0, 8)}', // More robust ID
            numberOfPlayers: numberOfPlayers,
            displayName: categoryDisplayName,
          );
        }
      }

      final newTemplate = FormationTemplate(
        templateId: uuid.v4(),
        categoryId: categoryToUse.categoryId,
        name: templateName,
        scene: AnimationItemModel.createEmptyAnimationItem(),
      );

      widget.onLineupCreated(categoryToUse, newTemplate);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: ColorManager.dark2,
      title: const Text(
        'Create New Lineup',
        style: TextStyle(color: ColorManager.white),
      ),
      scrollable: true, // Makes content scrollable if it overflows
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (widget.existingCategories.isNotEmpty) ...[
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Use Existing Category?',
                      style: TextStyle(color: ColorManager.white),
                    ),
                  ),
                  Switch(
                    value: _useExistingCategory,
                    onChanged: (value) {
                      setState(() {
                        _useExistingCategory = value;
                        if (value && widget.existingCategories.isNotEmpty) {
                          _selectedExistingCategoryId =
                              widget.existingCategories.first.categoryId;
                          _updateFieldsFromSelectedCategory(
                            widget.existingCategories.first,
                          );
                        } else {
                          _selectedExistingCategoryId = null;
                          _numberOfPlayersController.clear();
                          _categoryDisplayNameController.clear();
                        }
                      });
                    },
                    activeColor: ColorManager.green,
                  ),
                ],
              ),
              if (_useExistingCategory)
                DropdownButtonFormField<String>(
                  value: _selectedExistingCategoryId,
                  dropdownColor: ColorManager.dark1,
                  style: const TextStyle(color: ColorManager.white),
                  decoration: InputDecoration(
                    labelText: 'Select Category',
                    labelStyle: TextStyle(color: ColorManager.grey),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: ColorManager.grey),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: ColorManager.green),
                    ),
                  ),
                  items:
                      widget.existingCategories.map((
                        FormationCategory category,
                      ) {
                        return DropdownMenuItem<String>(
                          value: category.categoryId,
                          child: Text(
                            category.displayName,
                            style: TextStyle(color: ColorManager.white),
                          ),
                        );
                      }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedExistingCategoryId = newValue;
                      if (newValue != null) {
                        final selectedCat = widget.existingCategories
                            .firstWhere((cat) => cat.categoryId == newValue);
                        _updateFieldsFromSelectedCategory(selectedCat);
                      }
                    });
                  },
                  validator:
                      (value) =>
                          value == null ? 'Please select a category' : null,
                )
              else ...[
                _buildTextField(
                  controller: _categoryDisplayNameController,
                  labelText: 'Category Display Name (e.g., 11 vs 11 Pro)',
                  validatorText: 'Please enter a category display name',
                ),
                const SizedBox(height: 15),
                _buildTextField(
                  controller: _numberOfPlayersController,
                  labelText: 'Number of Players (e.g., 11)',
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validatorText: 'Please enter the number of players',
                  isNumber: true,
                ),
              ],
            ],
            if (widget.existingCategories.isEmpty) ...[
              // If no existing categories, force new category creation
              _buildTextField(
                controller: _categoryDisplayNameController,
                labelText: 'Category Display Name (e.g., 11 vs 11 Pro)',
                validatorText: 'Please enter a category display name',
              ),
              const SizedBox(height: 15),
              _buildTextField(
                controller: _numberOfPlayersController,
                labelText: 'Number of Players (e.g., 11)',
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validatorText: 'Please enter the number of players',
                isNumber: true,
              ),
            ],
            const SizedBox(height: 20),
            Text(
              'Lineup Template Details',
              style: TextStyle(
                color: ColorManager.yellow,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            _buildTextField(
              controller: _templateNameController,
              labelText: 'Template Name (e.g., My Custom 4-3-3)',
              validatorText: 'Please enter a template name',
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text(
            'Cancel',
            style: TextStyle(color: ColorManager.grey),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: ColorManager.green),
          onPressed: _handleCreate,
          child: const Text(
            'Create',
            style: TextStyle(color: ColorManager.white),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required String validatorText,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    bool isNumber = false,
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: ColorManager.white),
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(color: ColorManager.grey),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: ColorManager.green),
        ),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: ColorManager.grey),
        ),
        errorStyle: TextStyle(color: ColorManager.red.withOpacity(0.8)),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return validatorText;
        }
        if (isNumber) {
          if (int.tryParse(value.trim()) == null) {
            return 'Please enter a valid number';
          }
          if (int.parse(value.trim()) <= 0) {
            return 'Number of players must be positive';
          }
        }
        return null;
      },
    );
  }
}
