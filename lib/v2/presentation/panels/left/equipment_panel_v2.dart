import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zporter_tactical_board/app/generator/random_generator.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/equipment/equipment_utils.dart';
import 'package:zporter_tactical_board/data/tactic/model/equipment_model.dart';
import 'package:zporter_tactical_board/v2/models/equipment_element.dart';
import 'package:zporter_tactical_board/v2/presentation/widgets/draggable_board_tile_v2.dart';

/// Equipment toolbar panel with a grid of draggable equipment items.
///
/// Uses [EquipmentUtils.generateEquipments()] to get V1 equipment models,
/// converts them to V2 [EquipmentElement] for drag-to-board.
class EquipmentPanelV2 extends ConsumerWidget {
  const EquipmentPanelV2({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final equipments = EquipmentUtils.generateEquipments();

    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemCount: equipments.length,
      itemBuilder: (context, index) {
        final equipment = equipments[index];
        final element = _toEquipmentElement(equipment);
        return DraggableBoardTileV2(
          element: element,
          child: _EquipmentTile(equipment: equipment),
        );
      },
    );
  }

  /// Convert V1 [EquipmentModel] → V2 [EquipmentElement] for drag data.
  EquipmentElement _toEquipmentElement(EquipmentModel equipment) {
    return EquipmentElement(
      id: RandomGenerator.generateId(),
      name: equipment.name,
      imagePath: equipment.imagePath,
      color: equipment.color,
      size: equipment.size != null
          ? Size(equipment.size!.x, equipment.size!.y)
          : const Size(32, 32),
    );
  }
}

/// Visual tile for equipment in the toolbar grid.
class _EquipmentTile extends StatelessWidget {
  final EquipmentModel equipment;

  const _EquipmentTile({required this.equipment});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 36,
          height: 36,
          child: Image.asset(
            'assets/images/${equipment.imagePath}',
            color: equipment.color,
            errorBuilder: (_, __, ___) => Icon(
              Icons.sports_soccer,
              color: equipment.color ?? Colors.white,
              size: 24,
            ),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          equipment.name,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 8,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
