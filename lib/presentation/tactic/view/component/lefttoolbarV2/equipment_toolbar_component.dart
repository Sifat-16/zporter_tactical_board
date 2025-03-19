import 'package:flutter/material.dart';

class EquipmentToolbarComponent extends StatefulWidget {
  const EquipmentToolbarComponent({super.key});

  @override
  State<EquipmentToolbarComponent> createState() =>
      _EquipmentToolbarComponentState();
}

class _EquipmentToolbarComponentState extends State<EquipmentToolbarComponent>
    with AutomaticKeepAliveClientMixin {
  // List<EquipmentDataModel> equipments=[];

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   context.read<EquipmentBloc>().add(EquipmentLoadEvent(
  //     equipments: EquipmentUtils.generateEquipmentModelList(),
  //   ));
  // }

  // initiateEquipments(List<EquipmentDataModel> ep){
  //   setState(() {
  //     equipments = ep;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container();
    // return BlocListener<EquipmentBloc, EquipmentState>(
    //   listener: (context, state) {
    //     if (state is EquipmentLoadedState) {
    //       debug(data: "Equipment loaded");
    //       initiateEquipments(state.equipments);
    //     }
    //   },
    //   child: BlocBuilder<EquipmentBloc, EquipmentState>(
    //     buildWhen: (previous, current) => current is EquipmentLoadedState,
    //     builder: (context, state) {
    //       return GridView.count(
    //         crossAxisCount: 3,
    //         children: List.generate(equipments.length, (index) {
    //           return EquipmentComponent(equipmentDataModel: equipments[index]);
    //         }),
    //       );
    //     },
    //   ),
    // );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
