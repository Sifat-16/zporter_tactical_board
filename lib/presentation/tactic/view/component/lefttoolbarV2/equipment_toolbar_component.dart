// import 'package:flutter/material.dart';
// import 'package:zporter_tactical_board/app/manager/color_manager.dart';
// import 'package:zporter_tactical_board/data/tactic/model/equipment_model.dart';
// import 'package:zporter_tactical_board/presentation/tactic/view/component/equipment/equipment_item.dart';
// import 'package:zporter_tactical_board/presentation/tactic/view/component/equipment/equipment_utils.dart';
//
// class EquipmentToolbarComponent extends StatefulWidget {
//   const EquipmentToolbarComponent({super.key});
//
//   @override
//   State<EquipmentToolbarComponent> createState() =>
//       _EquipmentToolbarComponentState();
// }
//
// class _EquipmentToolbarComponentState extends State<EquipmentToolbarComponent>
//     with AutomaticKeepAliveClientMixin {
//   List<EquipmentModel> equipments = [];
//
//   @override
//   void initState() {
//     super.initState();
//     setupEquipments();
//   }
//
//   void setupEquipments() {
//     equipments = EquipmentUtils.generateEquipments();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     super.build(context);
//
//     if (equipments.isEmpty) {
//       return const SizedBox.shrink();
//     }
//
//     const int itemsPerRow = 3;
//
//     return Container(
//       child: LayoutBuilder(
//         builder: (context, constraints) {
//           final double itemHeight = constraints.maxWidth / itemsPerRow;
//           final int rowCount = (equipments.length / itemsPerRow).ceil();
//
//           return ListView.builder(
//             itemCount: rowCount,
//             itemBuilder: (context, rowIndex) {
//               final int startIndex = rowIndex * itemsPerRow;
//               final int endIndex =
//                   (startIndex + itemsPerRow > equipments.length)
//                       ? equipments.length
//                       : startIndex + itemsPerRow;
//               final List<EquipmentModel> rowItems =
//                   equipments.sublist(startIndex, endIndex);
//
//               // *** THE CORRECTED LOGIC ***
//               // Check if this is the last row AND it contains only one item.
//               if (rowIndex == rowCount - 1 && rowItems.length == 1) {
//                 // Build a container that is full-width and has the same
//                 // height as the square items in the rows above.
//                 return SizedBox(
//                   height: itemHeight,
//                   width: double.infinity,
//                   // Pass `isExpanded: true` to the modified EquipmentItem,
//                   // telling it to adopt its flexible layout.
//                   child: EquipmentItem(
//                     equipmentModel: rowItems.first,
//                     isExpanded: true,
//                   ),
//                 );
//               } else {
//                 // Build a normal row of square items.
//                 return Row(
//                   children: List.generate(itemsPerRow, (itemIndex) {
//                     if (itemIndex < rowItems.length) {
//                       return Expanded(
//                         child: AspectRatio(
//                           aspectRatio: 1.0, // Ensures items are square
//                           child: EquipmentItem(
//                               equipmentModel: rowItems[itemIndex]),
//                         ),
//                       );
//                     } else {
//                       // Placeholder to maintain alignment
//                       return Expanded(child: Container());
//                     }
//                   }),
//                 );
//               }
//             },
//           );
//         },
//       ),
//     );
//   }
//
//   @override
//   bool get wantKeepAlive => true;
// }

import 'package:flutter/material.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';
import 'package:zporter_tactical_board/data/tactic/model/equipment_model.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/equipment/equipment_item.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/equipment/equipment_utils.dart';

class EquipmentToolbarComponent extends StatefulWidget {
  const EquipmentToolbarComponent({super.key});

  @override
  State<EquipmentToolbarComponent> createState() =>
      _EquipmentToolbarComponentState();
}

class _EquipmentToolbarComponentState extends State<EquipmentToolbarComponent>
    with AutomaticKeepAliveClientMixin {
  List<EquipmentModel> equipments = [];

  @override
  void initState() {
    super.initState();
    setupEquipments();
  }

  void setupEquipments() {
    equipments = EquipmentUtils.generateEquipments();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (equipments.isEmpty) {
      return const SizedBox.shrink();
    }

    const int itemsPerRow = 3;

    return Container(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double itemHeight = constraints.maxWidth / itemsPerRow;
          final int rowCount = (equipments.length / itemsPerRow).ceil();

          return ListView.builder(
            itemCount: rowCount,
            itemBuilder: (context, rowIndex) {
              final int startIndex = rowIndex * itemsPerRow;
              final int endIndex =
                  (startIndex + itemsPerRow > equipments.length)
                      ? equipments.length
                      : startIndex + itemsPerRow;
              final List<EquipmentModel> rowItems =
                  equipments.sublist(startIndex, endIndex);

              // Check if this is the last row.
              if (rowIndex == rowCount - 1) {
                // *** LOGIC FOR ONE ITEM IN LAST ROW ***
                if (rowItems.length == 1) {
                  return SizedBox(
                    height: itemHeight,
                    width: double.infinity,
                    child: EquipmentItem(
                      equipmentModel: rowItems.first,
                      isExpanded: true,
                    ),
                  );
                }
                // *** NEW LOGIC FOR TWO ITEMS IN LAST ROW ***
                else if (rowItems.length == 2) {
                  return SizedBox(
                    height: itemHeight,
                    child: Row(
                      children: [
                        Expanded(
                          child: EquipmentItem(
                            equipmentModel: rowItems[0],
                            isExpanded: true,
                          ),
                        ),
                        Expanded(
                          child: EquipmentItem(
                            equipmentModel: rowItems[1],
                            isExpanded: true,
                          ),
                        ),
                      ],
                    ),
                  );
                }
              }

              // This is the default logic for all full rows.
              return Row(
                children: List.generate(itemsPerRow, (itemIndex) {
                  if (itemIndex < rowItems.length) {
                    return Expanded(
                      child: AspectRatio(
                        aspectRatio: 1.0, // Ensures items are square
                        child:
                            EquipmentItem(equipmentModel: rowItems[itemIndex]),
                      ),
                    );
                  } else {
                    // Placeholder to maintain alignment
                    return Expanded(child: Container());
                  }
                }),
              );
            },
          );
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
