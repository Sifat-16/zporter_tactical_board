import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod
import 'package:zporter_tactical_board/app/manager/color_manager.dart'; // Adjust path as needed
import 'package:zporter_tactical_board/data/admin/model/default_lineup_model.dart'; // Adjust path as needed
import 'package:zporter_tactical_board/presentation/admin/view_model/lineup_view_model/lineup_controller.dart'; // Adjust path as needed
import 'package:zporter_tactical_board/presentation/admin/view_model/lineup_view_model/lineup_state.dart'; // Adjust path as needed

import 'create_lineup_dialog.dart';
import 'field/default_lineup_field_screen.dart'; // Adjust path as needed

// Helper classes for the unified list structure
abstract class ListItem {}

class CategoryHeaderItem implements ListItem {
  final String title;
  final String categoryId;
  final int numberOfPlayers;
  CategoryHeaderItem(this.title, this.categoryId, this.numberOfPlayers);
}

class LineupTemplateItem implements ListItem {
  final FormationTemplate template;
  LineupTemplateItem(this.template);
}

class NoLineupsItem implements ListItem {
  final String categoryId;
  NoLineupsItem(this.categoryId);
}

// Convert to ConsumerStatefulWidget
class DefaultLineupScreen extends ConsumerStatefulWidget {
  const DefaultLineupScreen({super.key});

  @override
  ConsumerState<DefaultLineupScreen> createState() =>
      _DefaultLineupScreenState();
}

class _DefaultLineupScreenState extends ConsumerState<DefaultLineupScreen> {
  List<ListItem> _unifiedListItems = [];

  @override
  void initState() {
    super.initState();
    // Initial data fetch is handled by the LineupController's constructor/init method.
  }

  // void _buildUnifiedList(
  //   List<FormationCategory> categories,
  //   List<FormationTemplate> templates,
  // ) {
  //   List<ListItem> items = [];
  //   if (!mounted) return;
  //
  //   if (categories.isEmpty && templates.isEmpty) {
  //     setState(() {
  //       _unifiedListItems = [];
  //     });
  //     return;
  //   }
  //
  //   for (var category in categories) {
  //     items.add(
  //       CategoryHeaderItem(
  //         category.displayName,
  //         category.categoryId,
  //         category.numberOfPlayers,
  //       ),
  //     );
  //     final templatesForCategory = templates
  //         .where((template) => template.categoryId == category.categoryId)
  //         .toList();
  //
  //     if (templatesForCategory.isEmpty) {
  //       items.add(NoLineupsItem(category.categoryId));
  //     } else {
  //       for (var template in templatesForCategory) {
  //         items.add(LineupTemplateItem(template));
  //       }
  //     }
  //   }
  //   setState(() {
  //     _unifiedListItems = items;
  //   });
  // }

  void _buildUnifiedList(
    List<FormationCategory> categories,
    List<FormationTemplate> templates,
  ) {
    List<ListItem> items = [];
    if (!mounted) return;

    if (categories.isEmpty && templates.isEmpty) {
      setState(() {
        _unifiedListItems = [];
      });
      return;
    }

    // MODIFIED: Sort categories by their orderIndex first
    List<FormationCategory> sortedCategories = List.from(categories)
      ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));

    for (var category in sortedCategories) {
      items.add(
        CategoryHeaderItem(
          category.displayName,
          category.categoryId,
          category.numberOfPlayers,
        ),
      );

      // MODIFIED: Sort templates within each category by their orderIndex
      final templatesForCategory = templates
          .where((template) => template.categoryId == category.categoryId)
          .toList()
        ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));

      if (templatesForCategory.isEmpty) {
        items.add(NoLineupsItem(category.categoryId));
      } else {
        for (var template in templatesForCategory) {
          items.add(LineupTemplateItem(template));
        }
      }
    }
    setState(() {
      _unifiedListItems = items;
    });
  }

  // --- NEW: Reorder Logic ---
  void _onReorder(int oldIndex, int newIndex) {
    // This adjustment is needed when moving an item downwards in the list.
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }

    final ListItem movedItem = _unifiedListItems[oldIndex];

    // --- Restriction Logic: Prevent moving templates between categories ---
    String getCategoryForIndex(int index) {
      for (int i = index; i >= 0; i--) {
        if (_unifiedListItems[i] is CategoryHeaderItem) {
          return (_unifiedListItems[i] as CategoryHeaderItem).categoryId;
        }
      }
      return '';
    }

    if (movedItem is LineupTemplateItem) {
      final oldCategory = getCategoryForIndex(oldIndex);
      final newCategory = getCategoryForIndex(newIndex);
      if (oldCategory != newCategory) {
        // Disallow the move by not updating the state

        return;
      }
    }
    // --- End Restriction Logic ---

    // Update the local list for immediate UI feedback
    setState(() {
      final item = _unifiedListItems.removeAt(oldIndex);
      _unifiedListItems.insert(newIndex, item);
    });

    // --- Persist the changes ---
    final lineupState = ref.read(lineupProvider);
    List<FormationCategory> updatedCategories = [];
    List<FormationTemplate> updatedTemplates = [];

    int categoryOrder = 0;
    Map<String, int> templateOrderMap = {};

    for (final item in _unifiedListItems) {
      if (item is CategoryHeaderItem) {
        final category = lineupState.categories
            .firstWhere((c) => c.categoryId == item.categoryId);
        updatedCategories.add(category.copyWith(orderIndex: categoryOrder++));
        templateOrderMap[item.categoryId] =
            0; // Reset template counter for this category
      } else if (item is LineupTemplateItem) {
        final template = lineupState.allTemplates
            .firstWhere((t) => t.templateId == item.template.templateId);
        final categoryId = template.categoryId;

        int currentOrder = templateOrderMap[categoryId] ?? 0;
        updatedTemplates.add(template.copyWith(orderIndex: currentOrder));
        templateOrderMap[categoryId] = currentOrder + 1;
      }
    }

    // Call the controller to save the new order
    ref.read(lineupProvider.notifier).updateLineupOrder(
          updatedCategories: updatedCategories,
          updatedTemplates: updatedTemplates,
        );
  }

  // --- Dialog Methods ---
  void _showCreateNewLineupDialog(List<FormationCategory> existingCategories) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return CreateNewLineupDialog(
          existingCategories: existingCategories,
          onLineupCreated: (
            FormationCategory category,
            FormationTemplate template,
          ) {
            ref.read(lineupProvider.notifier).createLineup(category, template);
          },
        );
      },
    );
  }

  void _editLineupTemplateDialog(FormationTemplate template) {
    TextEditingController controller = TextEditingController(
      text: template.name,
    );
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: ColorManager.dark2,
          title: const Text(
            'Edit Lineup Name',
            style: TextStyle(color: ColorManager.white),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            style: const TextStyle(color: ColorManager.white),
            decoration: const InputDecoration(
              hintText: 'Enter new name',
              hintStyle: TextStyle(color: ColorManager.grey),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: ColorManager.green),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: ColorManager.grey),
              ),
            ),
          ),
          actions: [
            TextButton(
              child: const Text(
                'Cancel',
                style: TextStyle(color: ColorManager.white),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text(
                'Save',
                style: TextStyle(color: ColorManager.green),
              ),
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  final updatedTemplate = FormationTemplate(
                    templateId: template.templateId,
                    categoryId: template.categoryId,
                    name: controller.text.trim(),
                    scene: template.scene,
                  );
                  ref
                      .read(lineupProvider.notifier)
                      .editLineupTemplate(updatedTemplate);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteLineupTemplateDialog(FormationTemplate template) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: ColorManager.dark2,
          title: const Text(
            'Confirm Delete Lineup',
            style: TextStyle(color: ColorManager.white),
          ),
          content: Text(
            'Are you sure you want to delete the lineup "${template.name}"?',
            style: const TextStyle(color: ColorManager.grey),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                "Cancel",
                style: TextStyle(color: ColorManager.white),
              ),
            ),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: ColorManager.red.withOpacity(0.8),
              ),
              child: const Text(
                'Delete',
                style: TextStyle(color: ColorManager.white),
              ),
              onPressed: () {
                ref
                    .read(lineupProvider.notifier)
                    .deleteLineupTemplate(template.templateId);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _editCategoryDialog(CategoryHeaderItem categoryItem) {
    final lineupState = ref.read(lineupProvider);
    final categoryToEdit = lineupState.categories.firstWhere(
      (cat) => cat.categoryId == categoryItem.categoryId,
      orElse: () => FormationCategory(
        categoryId: categoryItem.categoryId,
        displayName: categoryItem.title,
        numberOfPlayers: categoryItem.numberOfPlayers,
      ),
    );

    TextEditingController displayNameController = TextEditingController(
      text: categoryToEdit.displayName,
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: ColorManager.dark2,
          title: const Text(
            'Edit Category Name',
            style: TextStyle(color: ColorManager.white),
          ),
          content: TextField(
            controller: displayNameController,
            autofocus: true,
            style: const TextStyle(color: ColorManager.white),
            decoration: const InputDecoration(
              labelText: 'Category Display Name',
              labelStyle: TextStyle(color: ColorManager.grey),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: ColorManager.green),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: ColorManager.grey),
              ),
            ),
          ),
          actions: [
            TextButton(
              child: const Text(
                'Cancel',
                style: TextStyle(color: ColorManager.white),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text(
                'Save',
                style: TextStyle(color: ColorManager.green),
              ),
              onPressed: () {
                final updatedDisplayName = displayNameController.text.trim();
                if (updatedDisplayName.isNotEmpty) {
                  final updatedCategory = FormationCategory(
                    categoryId: categoryToEdit.categoryId,
                    displayName: updatedDisplayName,
                    numberOfPlayers: categoryToEdit.numberOfPlayers,
                  );
                  ref
                      .read(lineupProvider.notifier)
                      .editFormationCategory(updatedCategory);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteCategoryDialog(CategoryHeaderItem categoryItem) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: ColorManager.dark2,
          title: const Text(
            'Confirm Delete Category',
            style: TextStyle(color: ColorManager.white),
          ),
          content: Text(
            'Are you sure you want to delete the category "${categoryItem.title}"?\n\nALL LINEUPS under this category will also be DELETED permanently.',
            style: const TextStyle(color: ColorManager.grey),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                "Cancel",
                style: TextStyle(color: ColorManager.white),
              ),
            ),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: ColorManager.red.withOpacity(0.8),
              ),
              child: const Text(
                'Delete Category',
                style: TextStyle(color: ColorManager.white),
              ),
              onPressed: () {
                ref
                    .read(lineupProvider.notifier)
                    .deleteFormationCategory(categoryItem.categoryId);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // --- UI Building Helper Methods ---

  Widget _buildCreateLineupButton(List<FormationCategory> categories) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton.icon(
        icon: const Icon(Icons.add_circle_outline, color: ColorManager.white),
        label: const Text('Create New Lineup'),
        onPressed: () => _showCreateNewLineupDialog(categories),
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorManager.green,
          foregroundColor: ColorManager.white,
          minimumSize: const Size(double.infinity, 50),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Expanded(
      child: Center(
        child: CircularProgressIndicator(color: ColorManager.yellow),
      ),
    );
  }

  Widget _buildErrorDisplay(String? errorMessage) {
    return Expanded(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: ColorManager.red,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                'Error Loading Lineups',
                style: TextStyle(
                  color: ColorManager.red.withOpacity(0.9),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                errorMessage ?? 'An unknown error occurred.',
                style: TextStyle(
                  color: ColorManager.red.withOpacity(0.7),
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh, color: ColorManager.white),
                label: const Text(
                  "Retry",
                  style: TextStyle(color: ColorManager.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorManager.blueAccent.withOpacity(0.8),
                ),
                onPressed: () {
                  ref
                      .read(lineupProvider.notifier)
                      .fetchCategoriesAndTemplates();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.list_alt_rounded,
              color: ColorManager.grey,
              size: 60,
            ),
            const SizedBox(height: 16),
            Text(
              'No Lineups Found',
              style: TextStyle(
                color: ColorManager.grey,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap "Create New Lineup" to add your first one.',
              style: TextStyle(
                color: ColorManager.grey.withOpacity(0.8),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryHeaderWidget(CategoryHeaderItem item) {
    return Padding(
      key: ValueKey('cat_${item.categoryId}'), // KEY ADDED HERE
      padding:
          const EdgeInsets.only(left: 4.0, right: 8.0, top: 24.0, bottom: 10.0),
      child: Row(
        children: [
          ReorderableDragStartListener(
            index: _unifiedListItems.indexOf(item),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Icon(Icons.drag_handle, color: ColorManager.grey),
            ),
          ),
          Expanded(
            child: Text(
              item.title,
              style: TextStyle(
                color: ColorManager.yellow,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(
                  Icons.edit_note_outlined,
                  color: ColorManager.blueAccent.withOpacity(0.8),
                  size: 24,
                ),
                tooltip: 'Edit Category "${item.title}"',
                onPressed: () => _editCategoryDialog(item),
                padding: const EdgeInsets.all(8.0),
                constraints: const BoxConstraints(),
              ),
              IconButton(
                icon: Icon(
                  Icons.delete_sweep_outlined,
                  color: ColorManager.red.withOpacity(0.8),
                  size: 24,
                ),
                tooltip: 'Delete Category "${item.title}"',
                onPressed: () => _deleteCategoryDialog(item),
                padding: const EdgeInsets.all(8.0),
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLineupTemplateWidget(LineupTemplateItem item) {
    final template = item.template;
    return Card(
      key: ValueKey(
          template.templateId), // IMPORTANT: Add a unique key for reordering
      color: ColorManager.dark1,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 2,
      child: ListTile(
        contentPadding:
            const EdgeInsets.only(left: 4.0, right: 8.0, top: 4.0, bottom: 4.0),
        leading: ReorderableDragStartListener(
          index: _unifiedListItems.indexOf(item),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Icon(Icons.drag_handle, color: ColorManager.grey),
          ),
        ),
        title: Text(
          template.name,
          style: const TextStyle(
            color: ColorManager.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        DefaultLineupFieldScreen(template: template),
                  ),
                );
              },
              icon: ImageIcon(
                AssetImage("assets/image/soccer-field.png"),
                color: ColorManager.white,
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.edit_outlined,
                color: ColorManager.blueAccent,
              ),
              tooltip: 'Edit Lineup "${template.name}"',
              onPressed: () => _editLineupTemplateDialog(template),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: ColorManager.red),
              tooltip: 'Delete Lineup "${template.name}"',
              onPressed: () => _deleteLineupTemplateDialog(template),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoLineupsInCategoryWidget(NoLineupsItem item) {
    return Padding(
      key: ValueKey('no-lineup_${item.categoryId}'), // KEY ADDED HERE
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      child: Text(
        'No lineups in this category yet.',
        style: TextStyle(
          color: ColorManager.grey.withOpacity(0.7),
          fontStyle: FontStyle.italic,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildMainContentList() {
    return Expanded(
      child: ReorderableListView.builder(
        padding: const EdgeInsets.only(bottom: 16.0),
        itemCount: _unifiedListItems.length,
        onReorder: _onReorder,
        itemBuilder: (context, index) {
          final item = _unifiedListItems[index];

          // The key is now handled inside each respective build helper method.
          if (item is CategoryHeaderItem) {
            return _buildCategoryHeaderWidget(item);
          } else if (item is LineupTemplateItem) {
            return _buildLineupTemplateWidget(item);
          } else if (item is NoLineupsItem) {
            return _buildNoLineupsInCategoryWidget(item);
          }

          // Fallback, should not be reached with current logic
          return SizedBox(key: ValueKey('fallback_$index'));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lineupState = ref.watch(lineupProvider);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _buildUnifiedList(lineupState.categories, lineupState.allTemplates);
      }
    });

    return Scaffold(
      backgroundColor: ColorManager.black,
      appBar: AppBar(
        title: const Text(
          'Default Lineups',
          style: TextStyle(color: ColorManager.white),
        ),
        backgroundColor: ColorManager.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: ColorManager.white),
      ),
      body: Column(
        children: [
          _buildCreateLineupButton(lineupState.categories),
          if (lineupState.status == LineupStatus.loading &&
              _unifiedListItems.isEmpty)
            _buildLoadingIndicator()
          else if (lineupState.status == LineupStatus.error)
            _buildErrorDisplay(lineupState.errorMessage)
          else if (_unifiedListItems.isEmpty &&
              lineupState.status != LineupStatus.loading)
            Expanded(
              child: _buildEmptyState(),
            ) // Wrap in Expanded if it's the main content
          else
            _buildMainContentList(),
        ],
      ),
    );
  }
}
