import 'package:flutter/material.dart';
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
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((t) {
      setupEquipments();
    });
  }

  setupEquipments() {
    setState(() {
      equipments = EquipmentUtils.generateEquipments();
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return GridView.count(
      crossAxisCount: 3,
      children: List.generate(equipments.length, (index) {
        return EquipmentItem(equipmentModel: equipments[index]);
      }),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
